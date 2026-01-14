#!/bin/bash

# RIAM Accordo AI Agent Deployment Script
# This script deploys the AI coaching agent to AWS Bedrock AgentCore

set -e

REGION="us-east-1"
AGENT_NAME="riam-accordo-coach"
KNOWLEDGE_BASE_NAME="riam-student-data"

echo "🚀 Deploying RIAM Accordo AI Coach to AgentCore..."

# Step 1: Create Knowledge Base for student data
echo "📚 Creating Knowledge Base..."

KB_ID=$(aws bedrock-agent create-knowledge-base \
  --region $REGION \
  --name $KNOWLEDGE_BASE_NAME \
  --description "Student profiles and development data for RIAM Accordo AI" \
  --role-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/BedrockKnowledgeBaseRole" \
  --knowledge-base-configuration '{
    "type": "VECTOR",
    "vectorKnowledgeBaseConfiguration": {
      "embeddingModelArn": "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
    }
  }' \
  --storage-configuration '{
    "type": "OPENSEARCH_SERVERLESS",
    "opensearchServerlessConfiguration": {
      "collectionArn": "arn:aws:aoss:us-east-1:$(aws sts get-caller-identity --query Account --output text):collection/riam-kb",
      "vectorIndexName": "riam-student-index",
      "fieldMapping": {
        "vectorField": "embedding",
        "textField": "text",
        "metadataField": "metadata"
      }
    }
  }' \
  --query 'knowledgeBase.knowledgeBaseId' \
  --output text 2>/dev/null || echo "kb-existing")

echo "✅ Knowledge Base ID: $KB_ID"

# Step 2: Create Data Source and ingest student data
echo "📥 Ingesting student data..."

# Upload student data to S3
aws s3 cp ../.kiro/specs/RIAM/mock-data/students-complete-data.json s3://riam-accordo-kb-data/students-complete-data.json --region $REGION

# Create data source
DS_ID=$(aws bedrock-agent create-data-source \
  --region $REGION \
  --knowledge-base-id $KB_ID \
  --name "student-profiles" \
  --data-source-configuration '{
    "type": "S3",
    "s3Configuration": {
      "bucketArn": "arn:aws:s3:::riam-accordo-kb-data"
    }
  }' \
  --query 'dataSource.dataSourceId' \
  --output text 2>/dev/null || echo "ds-existing")

echo "✅ Data Source ID: $DS_ID"

# Start ingestion job
aws bedrock-agent start-ingestion-job \
  --region $REGION \
  --knowledge-base-id $KB_ID \
  --data-source-id $DS_ID

echo "⏳ Waiting for ingestion to complete..."
sleep 30

# Step 3: Create Bedrock Agent
echo "🤖 Creating Bedrock Agent..."

AGENT_ID=$(aws bedrock-agent create-agent \
  --region $REGION \
  --agent-name $AGENT_NAME \
  --description "AI coaching assistant for RIAM music education" \
  --foundation-model "anthropic.claude-3-5-sonnet-20241022-v2:0" \
  --instruction "$(cat agent-config.json | jq -r '.instructions')" \
  --idle-session-ttl-in-seconds 600 \
  --query 'agent.agentId' \
  --output text)

echo "✅ Agent ID: $AGENT_ID"

# Step 4: Associate Knowledge Base with Agent
echo "🔗 Associating Knowledge Base with Agent..."

aws bedrock-agent associate-agent-knowledge-base \
  --region $REGION \
  --agent-id $AGENT_ID \
  --agent-version "DRAFT" \
  --knowledge-base-id $KB_ID \
  --description "Student development data" \
  --knowledge-base-state "ENABLED"

# Step 5: Prepare Agent
echo "⚙️  Preparing Agent..."

aws bedrock-agent prepare-agent \
  --region $REGION \
  --agent-id $AGENT_ID

echo "⏳ Waiting for agent preparation..."
sleep 20

# Step 6: Create Agent Alias
echo "🏷️  Creating Agent Alias..."

ALIAS_ID=$(aws bedrock-agent create-agent-alias \
  --region $REGION \
  --agent-id $AGENT_ID \
  --agent-alias-name "production" \
  --description "Production alias for RIAM Accordo Coach" \
  --query 'agentAlias.agentAliasId' \
  --output text)

echo "✅ Agent Alias ID: $ALIAS_ID"

# Save deployment info
cat > deployment-info.json <<EOF
{
  "agentId": "$AGENT_ID",
  "agentAliasId": "$ALIAS_ID",
  "knowledgeBaseId": "$KB_ID",
  "region": "$REGION",
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo ""
echo "✨ Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Agent ID: $AGENT_ID"
echo "Alias ID: $ALIAS_ID"
echo "Knowledge Base ID: $KB_ID"
echo "Region: $REGION"
echo ""
echo "📝 Deployment info saved to: deployment-info.json"
echo ""
echo "🧪 Test your agent:"
echo "aws bedrock-agent-runtime invoke-agent \\"
echo "  --region $REGION \\"
echo "  --agent-id $AGENT_ID \\"
echo "  --agent-alias-id $ALIAS_ID \\"
echo "  --session-id test-session-1 \\"
echo "  --input-text 'Tell me about student Aoife Byrne' \\"
echo "  response.txt"
