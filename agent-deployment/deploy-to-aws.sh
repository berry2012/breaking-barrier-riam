#!/bin/bash

set -e

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="riam-accordo-demo-${ACCOUNT_ID}"
LAMBDA_NAME="riam-chat-handler"
API_NAME="riam-accordo-api"

echo "🚀 Deploying RIAM Accordo to AWS..."
echo ""

# Step 1: Create S3 bucket for website
echo "📦 Creating S3 bucket for website..."
aws s3 mb s3://${BUCKET_NAME} --region ${REGION} 2>/dev/null || echo "Bucket exists"

# Enable static website hosting
aws s3 website s3://${BUCKET_NAME} \
  --index-document landing-page.html \
  --error-document landing-page.html

echo "✅ S3 bucket created: ${BUCKET_NAME}"

# Step 2: Create Lambda execution role
echo "🔐 Creating Lambda execution role..."
cat > /tmp/lambda-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role \
  --role-name ${LAMBDA_NAME}-role \
  --assume-role-policy-document file:///tmp/lambda-trust-policy.json 2>/dev/null || echo "Role exists"

aws iam attach-role-policy \
  --role-name ${LAMBDA_NAME}-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
  --role-name ${LAMBDA_NAME}-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

echo "✅ Lambda role created"

# Wait for role to propagate
sleep 10

# Step 3: Package and deploy Lambda
echo "📦 Packaging Lambda function..."
cd lambda
npm install --production 2>/dev/null || npm install
zip -q -r function.zip . -x "*.git*"
cd ..

echo "🚀 Deploying Lambda function..."
aws lambda create-function \
  --function-name ${LAMBDA_NAME} \
  --runtime nodejs20.x \
  --role arn:aws:iam::${ACCOUNT_ID}:role/${LAMBDA_NAME}-role \
  --handler chat-handler.handler \
  --zip-file fileb://lambda/function.zip \
  --timeout 60 \
  --memory-size 512 \
  --region ${REGION} 2>/dev/null || \
aws lambda update-function-code \
  --function-name ${LAMBDA_NAME} \
  --zip-file fileb://lambda/function.zip \
  --region ${REGION}

echo "✅ Lambda function deployed"

# Step 4: Create API Gateway
echo "🌐 Creating API Gateway..."
API_ID=$(aws apigatewayv2 create-api \
  --name ${API_NAME} \
  --protocol-type HTTP \
  --cors-configuration AllowOrigins="*",AllowMethods="POST,OPTIONS",AllowHeaders="Content-Type" \
  --region ${REGION} \
  --query 'ApiId' \
  --output text 2>/dev/null || \
aws apigatewayv2 get-apis --region ${REGION} --query "Items[?Name=='${API_NAME}'].ApiId" --output text)

echo "API ID: ${API_ID}"

# Create integration
INTEGRATION_ID=$(aws apigatewayv2 create-integration \
  --api-id ${API_ID} \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${LAMBDA_NAME} \
  --payload-format-version 2.0 \
  --region ${REGION} \
  --query 'IntegrationId' \
  --output text 2>/dev/null || \
aws apigatewayv2 get-integrations --api-id ${API_ID} --region ${REGION} --query 'Items[0].IntegrationId' --output text)

# Create route
aws apigatewayv2 create-route \
  --api-id ${API_ID} \
  --route-key "POST /chat" \
  --target integrations/${INTEGRATION_ID} \
  --region ${REGION} 2>/dev/null || echo "Route exists"

# Create stage
aws apigatewayv2 create-stage \
  --api-id ${API_ID} \
  --stage-name prod \
  --auto-deploy \
  --region ${REGION} 2>/dev/null || echo "Stage exists"

# Add Lambda permission
aws lambda add-permission \
  --function-name ${LAMBDA_NAME} \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:${REGION}:${ACCOUNT_ID}:${API_ID}/*/*/chat" \
  --region ${REGION} 2>/dev/null || echo "Permission exists"

API_ENDPOINT="https://${API_ID}.execute-api.${REGION}.amazonaws.com/prod"
echo "✅ API Gateway created: ${API_ENDPOINT}"

# Step 5: Update landing page with API endpoint
echo "📝 Updating landing page with API endpoint..."
sed "s|http://localhost:3000|${API_ENDPOINT}|g" landing-page.html > landing-page-aws.html

# Step 6: Upload to S3
echo "📤 Uploading landing page to S3..."
aws s3 cp landing-page-aws.html s3://${BUCKET_NAME}/landing-page.html --content-type "text/html"

# Enable public access for website hosting
aws s3api put-public-access-block \
  --bucket ${BUCKET_NAME} \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

WEBSITE_URL="http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"

echo ""
echo "✨ Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Website URL: ${WEBSITE_URL}"
echo "🔗 API Endpoint: ${API_ENDPOINT}/chat"
echo "📦 S3 Bucket: ${BUCKET_NAME}"
echo "⚡ Lambda Function: ${LAMBDA_NAME}"
echo ""
echo "🎵 Open your browser to start chatting with the AI coach!"
echo ""

# Save deployment info
cat > aws-deployment-info.json <<EOF
{
  "websiteUrl": "${WEBSITE_URL}",
  "apiEndpoint": "${API_ENDPOINT}",
  "s3Bucket": "${BUCKET_NAME}",
  "lambdaFunction": "${LAMBDA_NAME}",
  "apiId": "${API_ID}",
  "region": "${REGION}",
  "deployedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "📝 Deployment info saved to: aws-deployment-info.json"
