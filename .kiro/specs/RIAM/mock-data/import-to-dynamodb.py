#!/usr/bin/env python3
"""
RIAM Accordo AI - Mock Data Import Script for DynamoDB
Imports student data from students-complete-data.json into DynamoDB tables
"""

import json
import boto3
from datetime import datetime
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

# Table references (update with actual table names after CDK deployment)
STUDENT_PROFILES_TABLE = 'AccordoAI-StudentProfiles'
PERFORMANCE_RECORDINGS_TABLE = 'AccordoAI-PerformanceRecordings'

def load_student_data():
    """Load student data from JSON file"""
    with open('students-complete-data.json', 'r') as f:
        data = json.load(f)
    return data['students']

def convert_floats_to_decimal(obj):
    """Convert float values to Decimal for DynamoDB compatibility"""
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_floats_to_decimal(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_floats_to_decimal(v) for v in obj]
    return obj

def import_student_profile(student, table):
    """Import a single student profile to DynamoDB"""
    
    profile = student['profile']
    
    # Construct DynamoDB item
    item = {
        'PK': f"STUDENT#{student['studentId']}",
        'SK': 'PROFILE',
        'studentId': student['studentId'],
        'email': profile['email'],
        'name': profile['name'],
        'age': profile['age'],
        'stage': profile['stage'],
        'programme': profile['programme'],
        'instrument': profile['instrument'],
        'faculty': profile.get('faculty', ''),
        'teacher': profile['teacher'],
        'enrollmentDate': profile['enrollmentDate'],
        'piecesInProgress': profile['piecesInProgress'],
        
        # Four Quadrant Scores
        'technicalSkillsCompetence': convert_floats_to_decimal(student['technicalSkillsCompetence']),
        'compositionalMusicianshipKnowledge': convert_floats_to_decimal(student['compositionalMusicianshipKnowledge']),
        'repertoireCulturalKnowledge': convert_floats_to_decimal(student['repertoireCulturalKnowledge']),
        'performingArtistry': convert_floats_to_decimal(student['performingArtistry']),
        
        # Metadata
        'lastAssessmentDate': datetime.now().isoformat(),
        'totalRecordings': 0,
        'totalFeedbackReceived': 0,
        'createdAt': datetime.now().isoformat(),
        'updatedAt': datetime.now().isoformat()
    }
    
    # Put item into DynamoDB
    table.put_item(Item=item)
    print(f"✓ Imported student profile: {profile['name']['first']} {profile['name']['last']} ({student['studentId']})")

def import_aural_recordings(student, table):
    """Import aural evidence recordings as performance recordings"""
    
    student_id = student['studentId']
    aural_recordings = student['compositionalMusicianshipKnowledge'].get('auralEvidenceRecordings', [])
    
    for idx, s3_url in enumerate(aural_recordings):
        recording_id = f"{student_id}-aural-{idx+1:03d}"
        timestamp = datetime.now().isoformat()
        
        # Extract filename from S3 URL
        filename = s3_url.split('/')[-1] if '/' in s3_url else f"aural-{idx+1}.mp3"
        
        item = {
            'PK': f"STUDENT#{student_id}",
            'SK': f"RECORDING#{timestamp}",
            'recordingId': recording_id,
            'studentId': student_id,
            
            # Recording Details
            's3Key': s3_url.replace('s3://accordo-recordings/', ''),
            's3Bucket': 'accordo-recordings',
            'fileName': filename,
            'fileSize': 512000,  # Mock size
            'duration': 30,  # Mock duration (30 seconds)
            'format': 'mp3',
            
            # Performance Context
            'piece': 'Aural Skills Exercise',
            'composer': 'N/A',
            'repertoireLevel': student['profile']['stage'],
            'performanceType': 'Aural Evidence',
            
            # Status
            'uploadedAt': timestamp,
            'status': 'completed'
        }
        
        table.put_item(Item=item)
    
    print(f"  ✓ Imported {len(aural_recordings)} aural recordings for {student_id}")

def main():
    """Main import function"""
    
    print("=" * 60)
    print("RIAM Accordo AI - Mock Data Import to DynamoDB")
    print("=" * 60)
    print()
    
    # Load student data
    students = load_student_data()
    print(f"Loaded {len(students)} student records from JSON")
    print()
    
    # Get DynamoDB tables
    profiles_table = dynamodb.Table(STUDENT_PROFILES_TABLE)
    recordings_table = dynamodb.Table(PERFORMANCE_RECORDINGS_TABLE)
    
    # Import student profiles
    print("Importing Student Profiles...")
    print("-" * 60)
    for student in students:
        import_student_profile(student, profiles_table)
    
    print()
    print("Importing Aural Evidence Recordings...")
    print("-" * 60)
    for student in students:
        import_aural_recordings(student, recordings_table)
    
    print()
    print("=" * 60)
    print("✓ Import Complete!")
    print("=" * 60)
    print()
    print("Summary:")
    print(f"  • Student Profiles: {len(students)}")
    total_recordings = sum(len(s['compositionalMusicianshipKnowledge'].get('auralEvidenceRecordings', [])) for s in students)
    print(f"  • Aural Recordings: {total_recordings}")
    print()
    print("Next Steps:")
    print("  1. Verify data in DynamoDB console")
    print("  2. Run import-to-rds.py for exam results and assessments")
    print("  3. Test API endpoints with imported data")
    print()

if __name__ == '__main__':
    main()
