# RIAM Accordo AI - Deployed Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           USER'S BROWSER                                │
│                                                                         │
│  http://riam-accordo-demo-871442305974.s3-website-us-east-1.amazonaws.com │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             │ HTTP Request
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        AMAZON S3 (Static Website)                       │
│                                                                         │
│  • Bucket: riam-accordo-demo-871442305974                              │
│  • File: landing-page.html (React SPA)                                 │
│  • Public Read Access Enabled                                          │
│  • Website Hosting Enabled                                             │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             │ HTTPS POST /chat
                             │ (Student data + message)
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    API GATEWAY (HTTP API)                               │
│                                                                         │
│  • API ID: 4lk3cpbeh0                                                  │
│  • Endpoint: https://4lk3cpbeh0.execute-api.us-east-1.amazonaws.com    │
│  • Route: POST /prod/chat                                              │
│  • CORS: Enabled (Allow all origins)                                   │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             │ Lambda Proxy Integration
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      AWS LAMBDA FUNCTION                                │
│                                                                         │
│  • Function: riam-chat-handler                                         │
│  • Runtime: Node.js 20.x                                               │
│  • Memory: 512 MB                                                      │
│  • Timeout: 60 seconds                                                 │
│  • Handler: chat-handler.handler                                       │
│                                                                         │
│  Logic:                                                                │
│  1. Parse request (studentId, message, conversationType, sessionId)    │
│  2. Lookup student data (scores, instrument, context)                  │
│  3. Build context message with student info                            │
│  4. Call Bedrock Agent Runtime API                                     │
│  5. Stream response chunks                                             │
│  6. Return formatted JSON response                                     │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             │ AWS SDK
                             │ BedrockAgentRuntimeClient
                             │ InvokeAgentCommand
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    AMAZON BEDROCK AGENT                                 │
│                                                                         │
│  • Agent ID: 4EU9JDZKML                                                │
│  • Alias: TSTALIASID (Test/Draft)                                      │
│  • Model: us.anthropic.claude-3-5-sonnet-20241022-v2:0                 │
│  • Instructions: Music education coaching prompts                       │
│                                                                         │
│  Capabilities:                                                         │
│  • Goal-Setting conversations                                          │
│  • Reflection on practice                                              │
│  • Progress review                                                     │
│  • Motivation and encouragement                                        │
└────────────────────────────┬────────────────────────────────────────────┘
                             │
                             │ Foundation Model API
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    ANTHROPIC CLAUDE 3.5 SONNET                          │
│                                                                         │
│  • Inference Profile: us.anthropic.claude-3-5-sonnet-20241022-v2:0     │
│  • Context: Student profile + conversation history                     │
│  • Response: Personalized coaching advice                              │
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. User Interaction Flow
```
User selects student → Chooses conversation type → Types message
                                    ↓
              Browser sends POST to API Gateway
                                    ↓
                    {
                      "studentId": "S03",
                      "conversationType": "goal-setting",
                      "message": "Help me improve my pedaling",
                      "sessionId": "session-123"
                    }
```

### 2. Lambda Processing Flow
```
Lambda receives event → Parses request body → Looks up student data
                                    ↓
              Builds context message:
              "Student: Ella Murphy, Piano, Age 14
               Technical: 82/100, Musicianship: 80/100
               Repertoire: 85/100, Artistry: 78/100
               Context: Advanced stage, preparing Chopin Nocturne
               
               Help me improve my pedaling"
                                    ↓
              Calls Bedrock Agent Runtime API
```

### 3. Bedrock Agent Flow
```
Agent receives input → Applies coaching instructions → Calls Claude 3.5
                                    ↓
              Claude generates response based on:
              • Student's instrument (Piano)
              • Current skill level (Advanced)
              • Specific scores (Technical: 82/100)
              • Context (Working on Chopin Nocturne)
              • Conversation type (Goal-Setting)
                                    ↓
              Returns personalized coaching advice
```

### 4. Response Flow
```
Claude response → Streamed to Lambda → Formatted as JSON
                                    ↓
              {
                "response": "Hi Ella! Looking at your progress...",
                "messageId": "msg-1768389427918",
                "sessionId": "session-123"
              }
                                    ↓
              Returned to API Gateway → Sent to browser
                                    ↓
              Displayed in chat interface
```

## AWS Resources Created

### Frontend Layer
| Resource | ID/Name | Purpose |
|----------|---------|---------|
| S3 Bucket | `riam-accordo-demo-871442305974` | Static website hosting |
| S3 Object | `landing-page.html` | React SPA with chat interface |
| Bucket Policy | Public read access | Allow public website access |

### API Layer
| Resource | ID/Name | Purpose |
|----------|---------|---------|
| API Gateway | `4lk3cpbeh0` | HTTP API endpoint |
| API Route | `POST /prod/chat` | Chat message endpoint |
| Integration | Lambda proxy | Connect API to Lambda |
| CORS Config | Allow all origins | Enable browser requests |

### Compute Layer
| Resource | ID/Name | Purpose |
|----------|---------|---------|
| Lambda Function | `riam-chat-handler` | Process chat requests |
| IAM Role | `riam-chat-handler-role` | Lambda execution permissions |
| IAM Policy | AmazonBedrockFullAccess | Access Bedrock services |
| Lambda Permission | API Gateway invoke | Allow API to call Lambda |

### AI Layer
| Resource | ID/Name | Purpose |
|----------|---------|---------|
| Bedrock Agent | `4EU9JDZKML` | AI coaching orchestration |
| Agent Alias | `TSTALIASID` | Points to DRAFT version |
| Foundation Model | Claude 3.5 Sonnet v2 | LLM for responses |
| IAM Role | `RIAMBedrockAgentRole` | Agent permissions |

### Data Layer (Mock Data)
| Resource | ID/Name | Purpose |
|----------|---------|---------|
| S3 Bucket | `riam-accordo-kb-data-871442305974` | Student data storage |
| S3 Object | `students-complete-data.json` | 5 student profiles |

## Security Architecture

### Authentication & Authorization
```
┌─────────────────────────────────────────────────────────────┐
│ PUBLIC ACCESS (No Auth Required)                            │
│                                                             │
│ • S3 Website: Public read via bucket policy                │
│ • API Gateway: Open endpoint (CORS enabled)                │
│                                                             │
│ Note: Demo/hackathon setup - production would use Cognito  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ IAM ROLES & PERMISSIONS                                     │
│                                                             │
│ Lambda Execution Role:                                      │
│ • CloudWatch Logs (write logs)                             │
│ • Bedrock Agent Runtime (invoke agent)                     │
│                                                             │
│ Bedrock Agent Role:                                         │
│ • Bedrock Runtime (invoke foundation model)                │
│ • CloudWatch Logs (agent traces)                           │
└─────────────────────────────────────────────────────────────┘
```

### Network Flow
```
Internet → S3 (HTTPS) → Browser
Browser → API Gateway (HTTPS) → Lambda (Private VPC)
Lambda → Bedrock Agent (AWS PrivateLink) → Claude 3.5
```

## Performance Characteristics

### Latency Breakdown
```
User sends message
    ↓ ~50ms (Network)
API Gateway receives
    ↓ ~10ms (Routing)
Lambda cold start (first request only)
    ↓ ~300ms (Initialization)
Lambda execution
    ↓ ~100ms (Processing)
Bedrock Agent invocation
    ↓ ~2-5 seconds (AI generation)
Response streaming
    ↓ ~50ms (Network)
User sees response

Total: ~2.5-5.5 seconds (typical)
```

### Scalability
- **API Gateway**: 10,000 requests/second (default)
- **Lambda**: 1,000 concurrent executions (default)
- **Bedrock**: Rate limits vary by model (Claude 3.5: ~100 req/min)
- **S3**: Unlimited requests

### Cost Estimate (Demo Usage)
```
S3 Storage: $0.023/GB/month × 0.016 GB = $0.0004/month
S3 Requests: $0.0004/1000 × 100 = $0.00004
API Gateway: $1.00/million × 0.001 = $0.001
Lambda: $0.20/million × 0.001 = $0.0002
Bedrock Agent: $0.002/request × 100 = $0.20
Claude 3.5 Sonnet: ~$0.003/request × 100 = $0.30

Total Demo Cost: ~$0.50/month (100 requests)
```

## Monitoring & Debugging

### CloudWatch Logs
```
/aws/lambda/riam-chat-handler
  • Lambda execution logs
  • Error traces
  • Request/response data

/aws/bedrock/agent/4EU9JDZKML
  • Agent invocation traces
  • Model responses
  • Performance metrics
```

### Key Metrics
- Lambda Duration
- Lambda Errors
- API Gateway 4xx/5xx errors
- Bedrock throttling
- Response latency

## Deployment URLs

**Live Demo:**
- Website: http://riam-accordo-demo-871442305974.s3-website-us-east-1.amazonaws.com
- API: https://4lk3cpbeh0.execute-api.us-east-1.amazonaws.com/prod/chat

**AWS Console Links:**
- Lambda: https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/riam-chat-handler
- API Gateway: https://console.aws.amazon.com/apigateway/main/apis/4lk3cpbeh0
- Bedrock Agent: https://console.aws.amazon.com/bedrock/home?region=us-east-1#/agents/4EU9JDZKML
- S3 Bucket: https://s3.console.aws.amazon.com/s3/buckets/riam-accordo-demo-871442305974

## Student Data Structure

### Mock Students (Embedded in Lambda)
```javascript
{
  "S01": {
    name: "Aoife Byrne",
    instrument: "Violin",
    age: 10,
    scores: { tech: 58, music: 55, rep: 60, art: 62 },
    context: "Development stage, Twinkle variations"
  },
  "S02": {
    name: "Conor Walsh",
    instrument: "Flute",
    age: 12,
    scores: { tech: 70, music: 72, rep: 74, art: 68 },
    context: "Intermediate stage, Bach Minuet"
  },
  "S03": {
    name: "Ella Murphy",
    instrument: "Piano",
    age: 14,
    scores: { tech: 82, music: 80, rep: 85, art: 78 },
    context: "Advanced stage, Chopin Nocturne"
  },
  "S04": {
    name: "Rory Fitzpatrick",
    instrument: "Trumpet",
    age: 15,
    scores: { tech: 92, music: 78, rep: 76, art: 80 },
    context: "Young Artist, strong technical skills"
  },
  "S05": {
    name: "Saoirse Nolan",
    instrument: "Voice",
    age: 17,
    scores: { tech: 85, music: 90, rep: 92, art: 94 },
    context: "Young Artist, conservatory prep"
  }
}
```

## Future Enhancements

### Production Readiness
1. **Authentication**: Add AWS Cognito for user login
2. **Database**: Move student data to DynamoDB
3. **CDN**: Add CloudFront for global distribution
4. **Monitoring**: Set up CloudWatch alarms
5. **Rate Limiting**: Add API Gateway throttling
6. **Caching**: Cache student data in Lambda
7. **Error Handling**: Implement retry logic and circuit breakers

### Feature Additions
1. **Knowledge Base**: Add student data to Bedrock Knowledge Base
2. **Action Groups**: Enable agent to update student scores
3. **Feedback Loop**: Store user ratings in DynamoDB
4. **Analytics**: Track conversation quality metrics
5. **Multi-modal**: Add video analysis capability
