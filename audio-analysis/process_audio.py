import boto3
import json
import time
import requests

def analyze_piano_performance():
    # Initialize clients
    transcribe = boto3.client('transcribe', region_name='us-west-2')
    s3 = boto3.client('s3', region_name='us-west-2')
    bedrock = boto3.client('bedrock-runtime', region_name='us-west-2')
    
    bucket_name = 'piano-analysis-11c7d38e'  # Replace with your bucket
    job_name = f'piano-job-{int(time.time())}'
    
    # Upload to S3
    s3.upload_file('Piano-student-recording.mp3', bucket_name, 'piano.mp3')
    
    # Start transcription
    transcribe.start_transcription_job(
        TranscriptionJobName=job_name,
        Media={'MediaFileUri': f's3://{bucket_name}/piano.mp3'},
        MediaFormat='mp3',
        LanguageCode='en-US'
    )
    
    # Wait for completion
    while True:
        job = transcribe.get_transcription_job(TranscriptionJobName=job_name)
        status = job['TranscriptionJob']['TranscriptionJobStatus']
        if status == 'COMPLETED':
            transcript_url = job['TranscriptionJob']['Transcript']['TranscriptFileUri']
            transcript_data = requests.get(transcript_url).json()
            transcript_text = transcript_data['results']['transcripts'][0]['transcript']
            break
        elif status == 'FAILED':
            return "Transcription failed"
        time.sleep(10)
    
    # Analyze with Nova Pro
    prompt = f"""
Analyze this piano performance transcript for a music student across 4 quadrants:

Transcript: {transcript_text}

1. Technical Skills & Competence: Evaluate technique, timing, accuracy
2. Compositional & Musicianship Knowledge: Assess musical understanding, phrasing
3. Repertoire & Cultural Knowledge: Identify piece and stylistic appropriateness
4. Performing Artistry: Evaluate expression and artistic interpretation

Provide scores (1-10) and feedback for each quadrant.
"""
    
    response = bedrock.converse(
        modelId='us.amazon.nova-pro-v1:0',
        messages=[{'role': 'user', 'content': [{'text': prompt}]}],
        inferenceConfig={'maxTokens': 2000, 'temperature': 0.3}
    )
    
    return response['output']['message']['content'][0]['text']

if __name__ == "__main__":
    result = analyze_piano_performance()
    print(result)