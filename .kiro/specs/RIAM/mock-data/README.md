# RIAM Accordo AI - Mock Data Package

## Overview
This directory contains production-ready mock data for the RIAM Accordo AI hackathon MVP, extracted from real RIAM data structures and adapted for demonstration purposes.

## Data Files

### 1. Student Data

#### `students-profiles.csv` (978 bytes)
Simple CSV format with basic student information and aggregate quadrant scores.

**Columns:**
- `studentId`: Unique identifier (S01-S05)
- `studentName`: Full name
- `age`: Current age (10-17)
- `stage`: Development stage (Development, Intermediate, Advanced)
- `programme`: RIAM programme enrolled in
- `instrumentFaculty`: Instrument and faculty
- `teacher`: Assigned teacher name
- `piecesInProgress`: Current repertoire (semicolon-separated)
- `technicalScore`: Technical Skills & Competence score (/100)
- `musicianshipScore`: Compositional & Musicianship Knowledge score (/100)
- `repertoireScore`: Repertoire & Cultural Knowledge score (/100)
- `performingArtistryScore`: Performing Artistry score (/100)

**Students:**
1. **S01 - Aoife Byrne** (10, Violin, Development): Scores 58/55/60/62
2. **S02 - Conor Walsh** (12, Flute, Intermediate): Scores 70/72/74/68
3. **S03 - Ella Murphy** (14, Piano, Advanced): Scores 82/80/85/78
4. **S04 - Rory Fitzpatrick** (15, Trumpet, Young Artist): Scores 92/78/76/80
5. **S05 - Saoirse Nolan** (17, Voice, Young Artist): Scores 85/90/92/94

#### `students-complete-data.json` (12.8KB)
Complete student profiles with all quadrant measures, following the exact RIAM data structure.

**Structure:**
```json
{
  "students": [
    {
      "studentId": "S01",
      "profile": {...},
      "technicalSkillsCompetence": {
        "score": 58,
        "practicalTechniqueMark": 58,
        "teacherTechnicalAdvice": [...],
        "teacherChecklist": {...}
      },
      "compositionalMusicianshipKnowledge": {
        "score": 55,
        "musicianshipMark": 55,
        "auralEvidenceRecordings": [...],
        "creativeReflectiveNotes": [...]
      },
      "repertoireCulturalKnowledge": {
        "score": 60,
        "repertoireCulturalMark": 60,
        "listeningLogs": [...],
        "contextMeaningNotes": [...]
      },
      "performingArtistry": {
        "score": 62,
        "practicalArtistryMark": 62,
        "studentPerformanceReflections": [...],
        "teacherPerformancePrepNotes": [...]
      }
    }
  ]
}
```

**Key Features:**
- ✅ All 4 quadrants with detailed measures
- ✅ Real teacher advice entries from RIAM data
- ✅ Authentic student reflections
- ✅ S3 URLs for aural evidence recordings
- ✅ Listening logs with contextual notes
- ✅ Teacher checklist with ✔/✖ marks

### 2. Reference Data

#### `teacher-checklist-prompt-library.json` (3.0KB)
Standard teacher checklist prompts for Technical Skills & Competence quadrant.

**Content:**
- **6 Prompt Areas**: Posture & Set-up, Sound/Tone, Accuracy, Coordination, Rhythmic Security, Technique Transfer
- **Instrument-Specific Checklists**: Violin, Flute, Piano, Trumpet, Voice
- **Usage Guidelines**: Frequency (each term), format (✔/✖/partial), owner (Teacher)

**Example:**
```json
{
  "area": "Posture & Set-up",
  "prompt": "Maintains balanced posture with relaxed shoulders",
  "notes": "Applies across all faculties"
}
```

### 3. Import Scripts

#### `import-to-dynamodb.py` (5.7KB)
Python script to import student data into DynamoDB tables.

**Features:**
- ✅ Loads from `students-complete-data.json`
- ✅ Converts to DynamoDB format (Decimal for numbers)
- ✅ Imports to `StudentProfiles` table
- ✅ Imports aural recordings to `PerformanceRecordings` table
- ✅ Generates UUIDs and timestamps
- ✅ Comprehensive error handling

**Usage:**
```bash
# Install dependencies
pip install boto3

# Configure AWS credentials
aws configure

# Update table names in script
# Then run:
python import-to-dynamodb.py
```

**Requirements:**
- Python 3.8+
- boto3 (AWS SDK for Python)
- AWS credentials with DynamoDB write permissions

#### `import-to-rds.sql` (14.1KB)
PostgreSQL SQL script to import data into RDS tables.

**Content:**
- 5 Teacher records (with instruments and specializations)
- 5 Exam results (annual practical assessments with examiner feedback)
- 5 Teacher assessments (term-based evaluations)
- 10 Practice logs (student self-reported practice sessions)
- Verification queries

**Usage:**
```bash
# Connect to RDS PostgreSQL instance
psql -h your-rds-endpoint.amazonaws.com -U postgres -d accordo_ai

# Run the import script
\i import-to-rds.sql

# Verify data
SELECT 'Teachers' as table_name, COUNT(*) FROM teachers
UNION ALL
SELECT 'Exam Results', COUNT(*) FROM exam_results;
```

**Tables Populated:**
- `teachers` (5 records)
- `exam_results` (5 records)
- `teacher_assessments` (5 records)
- `practice_logs` (10 records)

---

## Data Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                   Student Profile (DynamoDB)                │
│  • S01: Aoife Byrne (Violin, Development)                  │
│  • 4 Quadrant Scores + Detailed Measures                   │
└─────────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ▼               ▼               ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Exam Results │  │   Teacher    │  │ Practice Logs│
│    (RDS)     │  │ Assessments  │  │    (RDS)     │
│              │  │    (RDS)     │  │              │
│ • 58/100     │  │ • Term eval  │  │ • 25 min     │
│ • Examiner   │  │ • Strengths  │  │ • Self-rated │
│   feedback   │  │ • Next steps │  │ • Notes      │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## Import Process (Hackathon Day 1)

### Step 1: Prepare Infrastructure (Morning)
```bash
# Deploy CDK stacks
cd cdk
npm install
cdk deploy --all

# Note the output:
# - DynamoDB table names
# - RDS endpoint
# - S3 bucket names
```

### Step 2: Upload Mock Audio Files (Morning)
```bash
# Create mock aural evidence recordings (or use provided samples)
cd mock-data

# Upload to S3 (example)
aws s3 cp aural-samples/ s3://accordo-recordings/aural/ --recursive
```

### Step 3: Import to DynamoDB (Afternoon)
```bash
# Update table names in import-to-dynamodb.py
# Line 12-13: Update table names to match CDK output

# Run import
python import-to-dynamodb.py

# Expected output:
# ✓ Imported student profile: Aoife Byrne (S01)
# ✓ Imported student profile: Conor Walsh (S02)
# ...
# ✓ Imported 13 aural recordings
```

### Step 4: Import to RDS (Afternoon)
```bash
# Get RDS connection details from CDK output
# Update connection in psql command

# Run SQL import
psql -h accordo-rds.xxxxxx.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d accordo_ai \
     -f import-to-rds.sql

# Verify:
# Teachers: 5
# Exam Results: 5
# Teacher Assessments: 5
# Practice Logs: 10
```

### Step 5: Verify Data (Afternoon)
```bash
# Test API endpoints
curl https://api.accordo-ai.hackathon.aws/v1/students/S01/passport \
  -H "Authorization: Bearer $TOKEN"

# Expected: Full passport with 4 quadrants
```

---

## Data Quality Notes

### ✅ Authentic Elements
- **Teacher advice entries**: Real feedback patterns from RIAM teachers
- **Student reflections**: Age-appropriate and instrument-specific
- **Exam feedback**: Follows RIAM examiner conventions
- **Listening logs**: Appropriate repertoire for each level
- **Practice logs**: Realistic time allocations and self-ratings

### ⚠️ Simplified Elements
- **Email addresses**: Mock `.ie` domains (not real RIAM emails)
- **S3 URLs**: Placeholder paths (actual files need to be uploaded)
- **Dates**: Recent dates for demo consistency
- **File sizes/durations**: Mock values for recordings

### 🎯 Coverage
- **Age range**: 10-17 years (representing RIAM student demographics)
- **Instruments**: Strings, Woodwind, Keyboard, Brass, Voice (5 faculties)
- **Stages**: Development, Intermediate, Advanced, Young Artist (4 levels)
- **Programmes**: Junior RIAM (Years 1-6), Young Artist Programme
- **Score distribution**: 55-94 (realistic spread across quadrants)

---

## Using This Data for Demo

### Recommended Demo Flow (10 minutes)

**1. Login as S03 (Ella Murphy) [2 min]**
- 14 years old, Piano, Advanced stage
- Balanced scores: 82/80/85/78
- Good for showing complete features

**2. View Digital Passport [2 min]**
- Pie chart: 4 quadrants displayed
- Technical Skills: 82 (Posture ✔, Balance ✔, Articulation ✔, Accuracy ✔)
- Musicianship: 80 ("I like spotting how harmony supports the melody")
- Repertoire: 85 (Listening to Beethoven and Romantic pieces)
- Artistry: 78 ("I want more expression in slower sections")

**3. Upload Recording + AI Feedback [3 min]**
- Upload sample "Beethoven Sonatina" recording
- Show AI analysis (technical + expressive)
- Display feedback mapping to quadrants

**4. AI Coach Interaction [2 min]**
- Start "Motivation" conversation
- AI references: "I see you've been working on Beethoven Sonatina..."
- Show contextual coaching based on scores

**5. Teacher View (Switch to Teacher Portal) [1 min]**
- View all 5 students
- Highlight S01 (Aoife, Development) vs S05 (Saoirse, Young Artist)
- Show cohort analytics

---


---

## Video Recordings Feature

### New File: `sample-video-recordings.json` (14.1KB)

Contains 3 complete video performance recordings with multimodal AI feedback (audio + visual analysis).

**Students with Video Recordings:**

| ID | Student | Instrument | Piece | Duration | File Size | Scores (Tech/Art/Visual) |
|----|---------|------------|-------|----------|-----------|-------------------------|
| S02 | Conor Walsh | Flute | Bach Minuet in G Major | 3:00 | 119MB | 74/70/76 |
| S03 | Ella Murphy | Piano | Beethoven Sonatina Op.49 | 4:00 | 244MB | 85/79/85 |
| S05 | Saoirse Nolan | Voice | Caro mio ben | 3:15 | 180MB | 88/93/93 |

### Video Analysis Components

Each video recording includes:

#### Audio Analysis (Same as Audio-Only)
- Technical Assessment: Accuracy, Timing, Technique
- Expressive Assessment: Musicality, Interpretation, Dynamics, Phrasing
- Timestamped issues and strengths

#### Visual Assessment (Video-Specific)
- **Posture** (0-100): Body alignment, relaxed shoulders, balanced setup
- **Body Mechanics** (0-100): Instrument-specific technique visibility
  - Flute: Embouchure, breath support, finger technique
  - Piano: Hand position, wrist alignment, pedaling
  - Voice: Breath support visibility, jaw relaxation
- **Stage Presence** (0-100): Confidence, eye contact, facial expression
- **Instrument Handling** (0-100): Proper hold, setup, positioning

#### Timestamped Observations
Each video has 5-8 observations with:
- Timestamp (clickable to jump to video position)
- Category (posture, mechanics, presence, handling)
- Description (specific feedback)
- Severity (excellent, good, needs-attention)

**Example Observation:**
```json
{
  "timestamp": 48,
  "category": "mechanics",
  "description": "Right hand fingers slightly tense during fast passage",
  "severity": "needs-attention"
}
```

### Video Feedback Integration

#### Quadrant Score Updates
Video analysis contributes to multiple quadrants:

| Analysis Component | Quadrant | Weight |
|-------------------|----------|--------|
| Audio Technical | Technical Skills & Competence | 60% |
| Visual: Posture + Body Mechanics | Technical Skills & Competence | 30% |
| Visual: Instrument Handling | Technical Skills & Competence | 10% |
| Audio Expressive | Performing Artistry | 60% |
| Visual: Stage Presence | Performing Artistry | 40% |

**Score Calculation Example (S02 - Conor Walsh):**
```
Technical Skills & Competence:
= (Audio Technical: 72 × 0.6) + (Posture: 82 × 0.1) + (Body Mechanics: 75 × 0.2) + (Handling: 80 × 0.1)
= 43.2 + 8.2 + 15 + 8
= 74.4 → 74

Performing Artistry:
= (Audio Expressive: 71 × 0.6) + (Stage Presence: 68 × 0.4)
= 42.6 + 27.2
= 69.8 → 70
```

### Video Upload & Processing Specs

**Supported Formats:**
- ✅ MP4 (recommended)
- ✅ MOV (Apple/iOS)
- ✅ WEBM (web-optimized)
- ✅ AVI (legacy)

**Technical Limits:**
- Maximum file size: 500MB
- Maximum duration: 5 minutes (300 seconds)
- Recommended resolution: 1080p (1920x1080)
- Minimum resolution: 720p
- Frame rate: 24-60 fps (30 fps recommended)
- Codec: H.264 or H.265

**Processing Workflow:**
1. Student uploads video → S3
2. Lambda extracts frames (1 fps) and audio track
3. Generate thumbnail at 30 seconds
4. Amazon Bedrock Nova analyzes multimodal input
5. Analysis time: ~4-6 minutes for 3-minute video
6. Store feedback in DynamoDB
7. Update quadrant scores
8. Notify student + teacher

### Demo Video Recommendations

**Best for Demo: S03 (Ella Murphy - Piano)**
- Clear visual technique (hand position, wrist alignment)
- Balanced scores across audio and visual
- Rich timestamped observations (6 observations)
- Demonstrates full feature set

**Highlights to Show:**
1. **Video upload**: File size warning, resolution display, thumbnail generation
2. **Processing notification**: "AI analyzing your performance..."
3. **Feedback display**: 
   - Video player with timestamp markers
   - Audio scores (Technical 85, Expressive 79)
   - Visual scores (Posture 88, Mechanics 85, Presence 75, Handling 90)
4. **Timestamped observations**: Click timestamp → video jumps to that moment
5. **Quadrant impact**: Show how video feedback updates both Technical Skills and Performing Artistry
6. **Teacher validation**: Teacher adds comment on specific timestamp

### File Locations (Mock S3 Structure)

```
s3://accordo-recordings/
├── S02/
│   ├── audio/
│   │   └── bach-minuet-audio.mp3
│   └── video/
│       ├── bach-minuet-performance.mp4
│       └── bach-minuet-performance-thumb.jpg
├── S03/
│   ├── audio/
│   │   └── beethoven-sonatina-audio.mp3
│   └── video/
│       ├── beethoven-sonatina-op49.mp4
│       └── beethoven-sonatina-op49-thumb.jpg
└── S05/
    ├── audio/
    │   └── caro-mio-ben-audio.mp3
    └── video/
        ├── caro-mio-ben-performance.mp4
        └── caro-mio-ben-performance-thumb.jpg
```

**Note:** For hackathon demo, actual video files can be placeholder URLs. The JSON structure demonstrates the complete data model and AI feedback format.

---

## Additional Documentation

For complete video feedback specification, see:
- **`/RIAM-Video-Feedback-Feature.md`** (21KB) - Comprehensive video feature documentation including:
  - Technical specifications
  - Processing workflow
  - Frontend components
  - API endpoints
  - Cost analysis
  - User stories
  - Troubleshooting guide

---

**Last Updated**: 2026-01-11  
**Video Feature Version**: 1.0
