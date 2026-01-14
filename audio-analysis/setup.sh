#!/bin/bash

# Create virtual environment and install requirements
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Check/create S3 bucket and upload audio
python3 -c "
import boto3
import uuid
import os

s3 = boto3.client('s3', region_name='us-west-2')
bucket_name = f'piano-analysis-{str(uuid.uuid4())[:8]}'

try:
    s3.head_bucket(Bucket=bucket_name)
    print(f'Bucket {bucket_name} exists')
except:
    s3.create_bucket(
        Bucket=bucket_name,
        CreateBucketConfiguration={'LocationConstraint': 'us-west-2'}
    )
    print(f'Created bucket: {bucket_name}')

# Check if audio exists in bucket, upload if not
try:
    s3.head_object(Bucket=bucket_name, Key='piano.mp3')
    print('Audio file already exists in bucket')
except:
    if os.path.exists('Piano-student-recording.mp3'):
        s3.upload_file('Piano-student-recording.mp3', bucket_name, 'piano.mp3')
        print('Uploaded audio file to bucket')
    else:
        print('Audio file not found locally')

# Update bucket name in script
with open('process_audio.py', 'r') as f:
    content = f.read()

content = content.replace('piano-analysis-bucket', bucket_name)

with open('process_audio.py', 'w') as f:
    f.write(content)

print(f'Updated script with bucket: {bucket_name}')
"

echo "Setup complete. Run 'source venv/bin/activate' then 'python process_audio.py'"