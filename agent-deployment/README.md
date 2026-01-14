# RIAM Accordo AI Agent Deployment Guide

## Overview
This guide walks you through deploying the RIAM Accordo AI Coach to AWS Bedrock AgentCore and interacting with it via the landing page.

## Prerequisites

1. **AWS Account** with appropriate permissions:
   - Bedrock Agent access
   - S3 bucket creation
   - IAM role creation
   - OpenSearch Serverless

2. **AWS CLI** configured:
   ```bash
   aws configure
   ```

3. **Required IAM Role**: Create a role for Bedrock Knowledge Base:
   ```bash
   aws iam create-role \
     --role-name BedrockKnowledgeBaseRole \
     --assume-role-policy-document '{
       "Version": "2012-10-17",
       "Statement": [{
         "Effect": "Allow",
         "Principal": {"Service": "bedrock.amazonaws.com"},
         "Action": "sts:AssumeRole"
       }]
     }'
   ```

## Deployment Steps

### Step 1: Prepare Infrastructure

Create S3 bucket for knowledge base data:
```bash
aws s3 mb s3://riam-accordo-kb-data --region us-east-1
```

Create OpenSearch Serverless collection:
```bash
aws opensearchserverless create-collection \
  --name riam-kb \
  --type VECTORSEARCH \
  --region us-east-1
```

### Step 2: Deploy the Agent

Run the deployment script:
```bash
cd agent-deployment
chmod +x deploy-agent.sh
./deploy-agent.sh
```

This script will:
1. ✅ Create a Knowledge Base for student data
2. ✅ Upload and ingest student profiles from mock data
3. ✅ Create the Bedrock Agent with coaching instructions
4. ✅ Associate the Knowledge Base with the Agent
5. ✅ Create a production alias for the Agent

**Expected Output:**
```
✨ Deployment Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Agent ID: XXXXXXXXXX
Alias ID: YYYYYYYYYY
Knowledge Base ID: ZZZZZZZZZZ
Region: us-east-1
```

### Step 3: Test the Agent via CLI

Test the deployed agent:
```bash
aws bedrock-agent-runtime invoke-agent \
  --region us-east-1 \
  --agent-id <AGENT_ID> \
  --agent-alias-id <ALIAS_ID> \
  --session-id test-session-1 \
  --input-text "Tell me about student Aoife Byrne and suggest a practice goal" \
  response.txt

cat response.txt
```

### Step 4: Launch the Landing Page

#### Option A: Local Testing
```bash
# Open the HTML file directly in your browser
open landing-page.html
# or
python3 -m http.server 8000
# Then visit: http://localhost:8000/landing-page.html
```

#### Option B: Deploy to S3 Static Website
```bash
# Create S3 bucket for website
aws s3 mb s3://riam-accordo-demo --region us-east-1

# Enable static website hosting
aws s3 website s3://riam-accordo-demo \
  --index-document landing-page.html

# Upload landing page
aws s3 cp landing-page.html s3://riam-accordo-demo/ --acl public-read

# Access at: http://riam-accordo-demo.s3-website-us-east-1.amazonaws.com
```

## Using the Landing Page

### 1. Select a Student
Choose from 5 mock students:
- **Aoife Byrne** (Violin, Age 10) - Development stage
- **Conor Walsh** (Flute, Age 12) - Intermediate stage
- **Ella Murphy** (Piano, Age 14) - Advanced stage
- **Rory Fitzpatrick** (Trumpet, Age 15) - Young Artist
- **Saoirse Nolan** (Voice, Age 17) - Young Artist

### 2. Choose Conversation Type
- **🎯 Goal Setting** - Define SMART musical goals
- **💭 Reflection** - Process practice experiences
- **📈 Progress** - Review development trends
- **⭐ Motivation** - Get encouragement

### 3. Chat with the AI Coach
- Type your message in the input field
- Press Enter or click Send
- AI responds with personalized guidance based on student data

### 4. Provide Feedback
- After each AI response, rate it with 👍 or 👎
- Feedback is tracked for AI improvement

## Integrating Real Bedrock API

To connect the landing page to your deployed agent, update the `sendMessage()` function:

```javascript
async function sendMessage() {
    const input = document.getElementById('messageInput');
    const message = input.value.trim();
    if (!message) return;
    
    addMessage('user', message);
    input.value = '';
    
    // Show typing indicator
    const typingDiv = document.createElement('div');
    typingDiv.id = 'typing';
    typingDiv.className = 'flex justify-start';
    typingDiv.innerHTML = '<div class="bg-gray-200 rounded-lg px-4 py-3"><span class="animate-pulse">AI is thinking...</span></div>';
    document.getElementById('chatMessages').appendChild(typingDiv);
    
    try {
        // Call your backend API that invokes Bedrock Agent
        const response = await fetch('/api/coach/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                studentId: currentStudent,
                conversationType: conversationType,
                message: message,
                sessionId: sessionId
            })
        });
        
        const data = await response.json();
        document.getElementById('typing')?.remove();
        addMessage('assistant', data.response);
        lastMessageId = data.messageId;
        
    } catch (error) {
        document.getElementById('typing')?.remove();
        addMessage('assistant', 'Sorry, I encountered an error. Please try again.');
        console.error('Error:', error);
    }
}
```

## Backend API Integration

Create a Lambda function to handle chat requests:

```javascript
// lambda/chat-handler.js
const { BedrockAgentRuntimeClient, InvokeAgentCommand } = require('@aws-sdk/client-bedrock-agent-runtime');

const client = new BedrockAgentRuntimeClient({ region: 'us-east-1' });

exports.handler = async (event) => {
    const { studentId, conversationType, message, sessionId } = JSON.parse(event.body);
    
    // Build context from student data
    const studentContext = await getStudentContext(studentId);
    
    const command = new InvokeAgentCommand({
        agentId: process.env.AGENT_ID,
        agentAliasId: process.env.AGENT_ALIAS_ID,
        sessionId: sessionId,
        inputText: `[Conversation Type: ${conversationType}]\n[Student Context: ${JSON.stringify(studentContext)}]\n\nStudent: ${message}`
    });
    
    const response = await client.send(command);
    
    // Parse streaming response
    let aiResponse = '';
    for await (const chunk of response.completion) {
        if (chunk.chunk?.bytes) {
            aiResponse += new TextDecoder().decode(chunk.chunk.bytes);
        }
    }
    
    return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            response: aiResponse,
            messageId: `msg-${Date.now()}`,
            sessionId: sessionId
        })
    };
};
```

## Monitoring & Debugging

### View Agent Logs
```bash
aws logs tail /aws/bedrock/agent/<AGENT_ID> --follow
```

### Check Knowledge Base Ingestion Status
```bash
aws bedrock-agent list-ingestion-jobs \
  --knowledge-base-id <KB_ID> \
  --data-source-id <DS_ID>
```

### Test Agent Directly
```bash
aws bedrock-agent-runtime invoke-agent \
  --agent-id <AGENT_ID> \
  --agent-alias-id <ALIAS_ID> \
  --session-id debug-session \
  --input-text "What are Ella Murphy's current scores?" \
  debug-response.txt
```

## Troubleshooting

### Issue: Agent not responding
- Check agent status: `aws bedrock-agent get-agent --agent-id <AGENT_ID>`
- Verify alias is active: `aws bedrock-agent get-agent-alias --agent-id <AGENT_ID> --agent-alias-id <ALIAS_ID>`

### Issue: Knowledge Base not returning data
- Check ingestion job status
- Verify S3 bucket permissions
- Ensure OpenSearch collection is active

### Issue: Landing page not loading
- Check browser console for errors
- Verify CORS settings if using API
- Test with mock data first

## Next Steps

1. **Enhance Agent Instructions**: Refine the coaching prompts based on user feedback
2. **Add Action Groups**: Enable the agent to perform actions (update scores, schedule practice)
3. **Implement Feedback Loop**: Store user ratings in DynamoDB for analysis
4. **Add Authentication**: Integrate AWS Cognito for student login
5. **Deploy Production**: Use CloudFront + S3 for scalable hosting

## Cost Considerations

- **Bedrock Agent**: ~$0.002 per request
- **Knowledge Base**: ~$0.10 per GB stored + query costs
- **OpenSearch Serverless**: ~$0.24 per OCU-hour
- **S3 Storage**: ~$0.023 per GB

**Estimated Demo Cost**: $5-10 for hackathon period

## Support

For issues or questions:
- AWS Bedrock Documentation: https://docs.aws.amazon.com/bedrock/
- Agent Runtime API: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent-runtime_InvokeAgent.html
