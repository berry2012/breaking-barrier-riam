# RIAM Accordo AI - Technical Specification Document
## AWS Breaking Barriers Challenge 2026 - Hackathon MVP

**Document Version:** 1.0  
**Last Updated:** 2026-01-11  
**Project Timeline:** 3-Day Hackathon  
**Target Deployment:** AWS Cloud Infrastructure

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Project Scope](#project-scope)
3. [System Architecture](#system-architecture)
4. [Technical Requirements](#technical-requirements)
5. [Data Models](#data-models)
6. [API Specifications](#api-specifications)
7. [User Stories & Acceptance Criteria](#user-stories--acceptance-criteria)
8. [Frontend Specifications](#frontend-specifications)
9. [AI/ML Integration](#aiml-integration)
10. [Security & Authentication](#security--authentication)
11. [Implementation Plan](#implementation-plan)
12. [Testing Strategy](#testing-strategy)
13. [Deployment & DevOps](#deployment--devops)

---

## 1. Executive Summary

### 1.1 Project Overview
**Accordo AI** is an intelligent digital passport and coaching system for music education that unifies student progress tracking, provides AI-powered performance feedback, and enables conversational coaching at scale.

### 1.2 Problem Statement
RIAM faces fragmented learning across 35,000+ students with no unified framework connecting:
- Teacher assessments
- Exam performance data
- Student reflections
- Performance recordings
- Progress tracking

### 1.3 Solution
A three-pillar MVP demonstrating:
1. **Digital Passport**: Unified student development tracking
2. **AI Feedback Engine**: Automated performance analysis using Amazon Bedrock Nova
3. **Conversational AI Coach**: Personalized guidance via Bedrock AgentCore

### 1.4 Hackathon Constraints
- **Timeline**: 3 days
- **Team Size**: 8 members (2 AWS partners, 1-2 charity reps, 2 industry, 1 university, AWS support)
- **Scope**: Working MVP with mock data (5 sample students)
- **Target**: Demonstrate global applicability for music education sector

---

## 2. Project Scope

### 2.1 In-Scope Features

#### Core Features (Must Have)
- ✅ Digital Passport with 4 development dimensions (RIAM Quadrant Model)
- ✅ AI-powered performance feedback (5-10 sample recordings)
- ✅ **Video feedback capability** (multimodal audio + visual analysis)
- ✅ Conversational AI coaching agent (3 dialogue scenarios)
- ✅ Mock data integration pipeline
- ✅ Student, Teacher, Admin portals
- ✅ Authentication and role-based access

#### Supporting Features (Should Have)
- ✅ Progress visualization and timeline
- ✅ Audio AND video file upload and storage
- ✅ Basic analytics dashboard
- ✅ Feedback history tracking
- ✅ Video playback with timestamp markers
- ✅ Visual assessment (posture, body mechanics, stage presence)

### 2.2 Out-of-Scope (Post-Hackathon)
- ❌ Real RIAM system integration
- ❌ Webcam recording feature (browser-based video capture)
- ❌ Mobile applications
- ❌ Multi-language support
- ❌ Custom ML model training
- ❌ Live production deployment
- ❌ Payment/subscription systems
- ❌ Advanced scheduling features

### 2.3 Mock Data Package

**Source**: Real RIAM data structure from `RIAM Quadrant synthesised data.xlsx`

**Location**: `/mock-data/` directory

#### Files Provided:
1. **`students-profiles.csv`** (978 bytes)
   - 5 complete student profiles
   - Instruments: Violin, Flute, Piano, Trumpet, Voice
   - Age range: 10-17 years
   - Stages: Development, Intermediate, Advanced, Young Artist
   - All 4 quadrant scores included

2. **`students-complete-data.json`** (12.8KB)
   - Detailed quadrant measures for all 5 students
   - 13 aural evidence recordings (S3 URLs)
   - 5 listening logs with contextual notes
   - 5 performance reflections
   - Real teacher advice entries from RIAM

3. **`teacher-checklist-prompt-library.json`** (3.0KB)
   - 6 standard prompt areas for Technical Skills & Competence
   - Instrument-specific checklists (Violin, Flute, Piano, Trumpet, Voice)
   - Usage guidelines for teachers

4. **`import-to-dynamodb.py`** (5.7KB)
   - Python script to import student data to DynamoDB
   - Handles StudentProfiles and PerformanceRecordings tables
   - Automatic UUID and timestamp generation

5. **`import-to-rds.sql`** (14.1KB)
   - PostgreSQL script to import exam results, teacher assessments, practice logs
   - 5 teachers, 5 exam results, 5 assessments, 10 practice logs
   - Verification queries included

6. **`README.md`** (11.1KB)
   - Complete documentation for mock data usage
   - Import process guide
   - Demo flow recommendations
   - Troubleshooting tips

#### Student Profiles Summary:

| ID | Name | Age | Instrument | Stage | Tech | Music | Rep | Art |
|----|------|-----|------------|-------|------|-------|-----|-----|
| S01 | Aoife Byrne | 10 | Violin | Development | 58 | 55 | 60 | 62 |
| S02 | Conor Walsh | 12 | Flute | Intermediate | 70 | 72 | 74 | 68 |
| S03 | Ella Murphy | 14 | Piano | Advanced | 82 | 80 | 85 | 78 |
| S04 | Rory Fitzpatrick | 15 | Trumpet | Young Artist | 92 | 78 | 76 | 80 |
| S05 | Saoirse Nolan | 17 | Voice | Young Artist | 85 | 90 | 92 | 94 |

**Recommended Demo Student**: S03 (Ella Murphy) - Balanced scores, rich data, appropriate for feature demonstration

---

## 3. System Architecture

### 3.1 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        User Layer                            │
│  Student Portal  │  Teacher Portal  │  Admin Dashboard      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     Frontend Layer                           │
│         React/Next.js + CloudFront CDN + S3 Hosting         │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway Layer                         │
│        API Gateway + Amazon Cognito Authentication          │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                  Application Layer (Lambda)                  │
│  Passport API │ Feedback API │ Analytics API │ Integration  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                    AI/ML Services                            │
│  Bedrock Nova  │  AgentCore  │  SageMaker (Optional)        │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  DynamoDB  │  RDS PostgreSQL  │  S3 (Audio/Data Lake)      │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Technology Stack

#### Frontend
- **Framework**: React 18+ with Next.js 14
- **UI Library**: Tailwind CSS + Shadcn/ui components
- **State Management**: React Context API / Zustand
- **Charts**: Recharts / Chart.js
- **Audio Player**: Wavesurfer.js

#### Backend
- **Compute**: AWS Lambda (Node.js 20.x runtime)
- **API**: Amazon API Gateway (REST API)
- **Authentication**: Amazon Cognito User Pools
- **Storage**: 
  - DynamoDB (student profiles, progress logs)
  - RDS PostgreSQL (assessment data, exam results)
  - S3 (audio recordings, static assets)

#### AI/ML
- **Primary**: Amazon Bedrock with Nova Pro models
- **Agent**: Bedrock AgentCore for conversational AI
- **Optional**: Amazon SageMaker for custom models

#### Infrastructure
- **IaC**: AWS CDK (TypeScript)
- **CI/CD**: GitHub Actions
- **Monitoring**: CloudWatch Logs + X-Ray

---

## 4. Technical Requirements

### 4.1 Functional Requirements

#### FR-1: User Authentication
- **FR-1.1**: Users must authenticate via Amazon Cognito
- **FR-1.2**: Support three roles: Student, Teacher, Admin
- **FR-1.3**: Role-based access control (RBAC) for all endpoints
- **FR-1.4**: Session management with JWT tokens

#### FR-2: Digital Passport
- **FR-2.1**: Display student profile with three development dimensions
- **FR-2.2**: Calculate scores: Technical Mastery, Creative Expression, Reflective Practice
- **FR-2.3**: Show historical progress timeline
- **FR-2.4**: Support CRUD operations for student data

#### FR-3: AI Feedback Engine
- **FR-3.1**: Accept audio file uploads (MP3, WAV, M4A formats)
- **FR-3.2**: Process recordings with Amazon Bedrock Nova
- **FR-3.3**: Generate technical and expressive assessments
- **FR-3.4**: Store feedback history linked to student profile
- **FR-3.5**: Display actionable recommendations

#### FR-4: Conversational AI Coach
- **FR-4.1**: Implement chat interface for student-AI interaction
- **FR-4.2**: Support four dialogue types: goal-setting, reflection, progress, motivation
- **FR-4.3**: Maintain conversation context using Bedrock AgentCore
- **FR-4.4**: Store conversation history in DynamoDB

#### FR-5: Mock Data Integration
- **FR-5.1**: Ingest simulated RIAM Exams data
- **FR-5.2**: Ingest mock LMS engagement metrics
- **FR-5.3**: Ingest sample reflective journals
- **FR-5.4**: Transform and unify into standardized schema

#### FR-6: Analytics Dashboard
- **FR-6.1**: Aggregate student progress metrics
- **FR-6.2**: Display cohort-level insights (teacher/admin view)
- **FR-6.3**: Generate basic reports (PDF/CSV export)

### 4.2 Non-Functional Requirements

#### NFR-1: Performance
- **NFR-1.1**: API response time < 2 seconds (excluding AI processing)
- **NFR-1.2**: AI feedback generation < 30 seconds per recording
- **NFR-1.3**: Frontend initial load < 3 seconds

#### NFR-2: Scalability
- **NFR-2.1**: Support 5 concurrent users (hackathon demo)
- **NFR-2.2**: Architecture designed for 1000+ concurrent users (future)

#### NFR-3: Security
- **NFR-3.1**: All API endpoints require authentication
- **NFR-3.2**: Audio recordings encrypted at rest (S3 encryption)
- **NFR-3.3**: HTTPS/TLS for all communications
- **NFR-3.4**: Input validation on all user inputs

#### NFR-4: Reliability
- **NFR-4.1**: 99% uptime during hackathon demo period
- **NFR-4.2**: Graceful error handling with user-friendly messages
- **NFR-4.3**: Retry logic for AI service calls

#### NFR-5: Usability
- **NFR-5.1**: Mobile-responsive design
- **NFR-5.2**: Accessibility compliance (WCAG 2.1 Level AA)
- **NFR-5.3**: Intuitive navigation (max 3 clicks to any feature)

---

## 5. Data Models

### 5.1 DynamoDB Tables

#### Table: StudentProfiles
```typescript
interface StudentProfile {
  PK: string;                          // "STUDENT#<studentId>"
  SK: string;                          // "PROFILE"
  studentId: string;                   // UUID
  email: string;
  name: {
    first: string;
    last: string;
  };
  program: string;                     // "Tertiary" | "Junior" | "Exam Candidate"
  instrument: string;                  // "Piano" | "Violin" | "Vocals" etc.
  enrollmentDate: string;              // ISO 8601
  
  // Four Development Dimensions (RIAM Quadrant Model)
  technicalSkillsCompetence: {
    score: number;                     // 0-100 aggregate
    practicalTechniqueMark: number;    // /100, annual practical assessment (Examiner)
    teacherTechnicalAdvice: string[];  // Weekly/fortnightly bullets (Teacher)
    teacherChecklist: {                // Tick/partial tick each term (Teacher)
      achieved: string[];
      partial: string[];
    };
  };
  
  compositionalMusicianshipKnowledge: {
    score: number;                     // 0-100 aggregate
    musicianshipMark: number;          // /100, term or annual (Teacher)
    auralEvidenceRecordings: string[]; // Audio clips: sing back/clap back/play back (Student)
    creativeReflectiveNotes: string[]; // Short notes for AI coaching prompts (Student/Teacher)
  };
  
  repertoireCulturalKnowledge: {
    score: number;                     // 0-100 aggregate
    repertoireCulturalMark: number;    // /100, term or annual (Teacher)
    listeningLogs: Array<{             // 2-4 listens per term (Student)
      piece: string;
      composer: string;
      date: string;
      notes: string;
    }>;
    contextMeaningNotes: string[];     // 1-2 sentences linking listening to repertoire (Student)
  };
  
  performingArtistry: {
    score: number;                     // 0-100 aggregate
    practicalArtistryMark: number;     // /100, annual practical assessment (Examiner)
    studentPerformanceReflections: Array<{  // After performances/assessments (Student)
      date: string;
      performance: string;
      reflection: string;
    }>;
    teacherPerformancePrepNotes: string[];  // Before performances/mock runs (Teacher)
  };
  
  // Metadata
  lastAssessmentDate: string;
  totalRecordings: number;
  totalFeedbackReceived: number;
  
  createdAt: string;
  updatedAt: string;
}
```

#### Quadrant Measures Reference (RIAM Model)

The four development dimensions are measured through specific data points, each with designated owners and collection frequencies:

**1. Technical Skills & Competence**

| Measure | Owner | Scale/Frequency | Data Type |
|---------|-------|-----------------|-----------|
| Practical Technique Mark | Examiner (E) | /100, annual practical assessment | Numeric score |
| Teacher Technical Advice Entry | Teacher (T) | Weekly/fortnightly bullets | Text array |
| Teacher Checklist (skills achieved) | Teacher (T) | Tick/partial tick each term | Object {achieved[], partial[]} |

**2. Compositional & Musicianship Knowledge**

| Measure | Owner | Scale/Frequency | Data Type |
|---------|-------|-----------------|-----------|
| Musicianship Mark | Teacher (T) | /100, term or annual | Numeric score |
| Aural Evidence Recording | Student (S) | Audio clips (sing back/clap back/play back) | S3 file references |
| Creative/Reflective Note | Student/Teacher (S/T) | Short note for AI coaching prompts | Text array |

**3. Repertoire & Cultural Knowledge**

| Measure | Owner | Scale/Frequency | Data Type |
|---------|-------|-----------------|-----------|
| Repertoire & Cultural Mark | Teacher (T) | /100, term or annual | Numeric score |
| Listening Log | Student (S) | 2-4 listens per term (prompted) | Object array {piece, composer, date, notes} |
| Context/Meaning Note | Student (S) | 1-2 sentences linking listening to repertoire | Text array |

**4. Performing Artistry**

| Measure | Owner | Scale/Frequency | Data Type |
|---------|-------|-----------------|-----------|
| Practical Artistry Mark | Examiner (E) | /100, annual practical assessment | Numeric score |
| Student Performance Reflection | Student (S) | After performances/assessments | Object array {date, performance, reflection} |
| Teacher Performance Prep Notes | Teacher (T) | Before performances/mock runs | Text array |

**Score Aggregation Logic:**
Each quadrant score (0-100) is calculated as a weighted average of its constituent measures:
- Examiner marks (where present): 60% weight
- Teacher marks/assessments: 30% weight  
- Student contributions (logs, reflections, recordings): 10% weight

**Pie Chart Calculation:**
The pie chart displays the relative strength across all four quadrants:
```typescript
const total = technicalSkills + musicianship + repertoire + performingArtistry;
const pieChartData = {
  technicalSkillsCompetence: (technicalSkills / total) * 100,
  compositionalMusicianshipKnowledge: (musicianship / total) * 100,
  repertoireCulturalKnowledge: (repertoire / total) * 100,
  performingArtistry: (performingArtistry / total) * 100
};
```

#### Table: PerformanceRecordings
```typescript
interface PerformanceRecording {
  PK: string;                          // "STUDENT#<studentId>"
  SK: string;                          // "RECORDING#<timestamp>"
  recordingId: string;                 // UUID
  studentId: string;
  
  // Recording Details
  s3Key: string;                       // S3 object key
  s3Bucket: string;
  fileName: string;
  fileSize: number;                    // bytes
  duration: number;                    // seconds
  mediaType: "audio" | "video";        // Type of recording
  format: string;                      // Audio: "mp3" | "wav" | "m4a" | Video: "mp4" | "mov" | "webm"
  
  // Video-Specific Metadata (only for video recordings)
  videoMetadata?: {
    resolution: string;                // "1920x1080", "1280x720", etc.
    fps: number;                       // Frames per second
    codec: string;                     // "H.264", "H.265", etc.
    thumbnailS3Key?: string;           // S3 key for video thumbnail
  };
  
  // Performance Context
  piece: string;                       // "Beethoven Sonata No. 14"
  composer: string;
  repertoireLevel: string;             // "Grade 5" | "Advanced" etc.
  performanceType: string;             // "Practice" | "Exam" | "Recital"
  
  // AI Analysis Results
  aiFeedback?: {
    technicalAssessment: {
      accuracy: number;                // 0-100
      timing: number;
      technique: number;
      overallScore: number;
      issues: Array<{
        timestamp: number;             // seconds
        description: string;
        severity: "minor" | "moderate" | "major";
      }>;
    };
    expressiveAssessment: {
      musicality: number;              // 0-100
      interpretation: number;
      dynamics: number;
      phrasing: number;
      overallScore: number;
      strengths: Array<{
        timestamp: number;             // seconds
        description: string;
      }>;
    };
    
    // Video-Specific Analysis (only for video recordings)
    visualAssessment?: {
      posture: number;                 // 0-100
      bodyMechanics: number;           // 0-100 (bow arm, finger position, breath support visibility)
      stagePresence: number;           // 0-100 (confidence, engagement, presentation)
      instrumentHandling: number;      // 0-100 (proper hold, setup, positioning)
      overallScore: number;
      observations: Array<{
        timestamp: number;             // seconds
        category: "posture" | "mechanics" | "presence" | "handling";
        description: string;
        severity: "excellent" | "good" | "needs-attention";
      }>;
    };
    
    recommendations: string[];
    nextSteps: string[];
    generatedAt: string;
  };
  
  // Teacher Validation
  teacherReview?: {
    teacherId: string;
    validated: boolean;
    comments: string;
    reviewedAt: string;
  };
  
  uploadedAt: string;
  processedAt?: string;
  status: "uploaded" | "processing" | "completed" | "failed";
}
```

#### Table: ConversationHistory
```typescript
interface ConversationHistory {
  PK: string;                          // "STUDENT#<studentId>"
  SK: string;                          // "CONVERSATION#<sessionId>#<timestamp>"
  sessionId: string;                   // UUID
  studentId: string;
  
  messages: Array<{
    role: "user" | "assistant";
    content: string;
    timestamp: string;
  }>;
  
  conversationType: "goal-setting" | "reflection" | "progress" | "motivation";
  context: {
    recentRecordings?: string[];       // recordingIds
    currentGoals?: string[];
    practiceStreak?: number;
  };
  
  startedAt: string;
  lastMessageAt: string;
  status: "active" | "completed";
}
```

#### Table: ReflectiveJournals
```typescript
interface ReflectiveJournal {
  PK: string;                          // "STUDENT#<studentId>"
  SK: string;                          // "JOURNAL#<timestamp>"
  journalId: string;                   // UUID
  studentId: string;
  
  entry: string;                       // Student's reflection text
  mood: "frustrated" | "confident" | "curious" | "motivated" | "neutral";
  practiceContext: {
    duration: number;                  // minutes
    focusAreas: string[];
    challenges: string[];
  };
  
  // AI-Generated Insights
  aiInsights?: {
    sentiment: string;
    suggestedActions: string[];
    relatedGoals: string[];
  };
  
  createdAt: string;
}
```

### 5.2 RDS PostgreSQL Schema

#### Table: exam_results
```sql
CREATE TABLE exam_results (
  exam_result_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  exam_date DATE NOT NULL,
  exam_type VARCHAR(50) NOT NULL,              -- "RIAM Grade 5", "ABRSM Grade 8"
  instrument VARCHAR(50) NOT NULL,
  
  -- Scores
  technical_score INTEGER CHECK (technical_score >= 0 AND technical_score <= 100),
  musical_interpretation_score INTEGER CHECK (musical_interpretation_score >= 0 AND musical_interpretation_score <= 100),
  overall_grade VARCHAR(10),                    -- "Distinction", "Merit", "Pass"
  
  -- Details
  pieces_performed JSONB,                       -- Array of {title, composer, score}
  examiner_feedback TEXT,
  examiner_id VARCHAR(50),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_exam_results_student ON exam_results(student_id);
CREATE INDEX idx_exam_results_date ON exam_results(exam_date);
```

#### Table: teacher_assessments
```sql
CREATE TABLE teacher_assessments (
  assessment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  teacher_id UUID NOT NULL,
  assessment_date DATE NOT NULL,
  
  -- Assessment Categories
  technical_proficiency INTEGER CHECK (technical_proficiency >= 1 AND technical_proficiency <= 10),
  musical_expression INTEGER CHECK (musical_expression >= 1 AND musical_expression <= 10),
  practice_consistency INTEGER CHECK (practice_consistency >= 1 AND practice_consistency <= 10),
  growth_mindset INTEGER CHECK (growth_mindset >= 1 AND growth_mindset <= 10),
  
  -- Qualitative Feedback
  strengths TEXT,
  areas_for_improvement TEXT,
  recommended_repertoire TEXT,
  next_steps TEXT,
  
  lesson_context VARCHAR(100),                  -- "Regular Lesson", "Mock Exam", "Performance Review"
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_teacher_assessments_student ON teacher_assessments(student_id);
CREATE INDEX idx_teacher_assessments_teacher ON teacher_assessments(teacher_id);
```

#### Table: practice_logs
```sql
CREATE TABLE practice_logs (
  practice_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  practice_date DATE NOT NULL,
  
  duration_minutes INTEGER NOT NULL,
  focus_areas TEXT[],                           -- Array: ["scales", "arpeggios", "repertoire"]
  pieces_practiced JSONB,                       -- Array of {title, composer, timeSpent}
  
  self_rating INTEGER CHECK (self_rating >= 1 AND self_rating <= 5),
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_practice_logs_student ON practice_logs(student_id);
CREATE INDEX idx_practice_logs_date ON practice_logs(practice_date);
```

#### Table: teachers
```sql
CREATE TABLE teachers (
  teacher_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cognito_user_id VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  
  name_first VARCHAR(100) NOT NULL,
  name_last VARCHAR(100) NOT NULL,
  
  instruments TEXT[],                           -- Instruments they teach
  specializations TEXT[],                       -- "Classical", "Jazz", "Contemporary"
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.3 Teacher Checklist Prompt Library

The Teacher Checklist Prompt Library provides standardized assessment prompts for evaluating Technical Skills & Competence across all instruments and faculties.

#### Purpose
- Ensure consistent evaluation criteria across different teachers
- Provide clear, actionable checkpoints for skill development
- Feed data into quadrant score calculations
- Enable AI coaching to reference specific skill gaps

#### Standard Prompt Areas

**1. Posture & Set-up**
- **Prompt**: "Maintains balanced posture with relaxed shoulders"
- **Applies to**: All instruments and faculties
- **Assessment**: ✔ (achieved), ✖ (not yet), ⚪ (partial)

**2. Sound/Tone**
- **Prompt**: "Produces a consistent, centred tone at current level"
- **Notes**: Young students = short phrases; Advanced = sustained control
- **Applies to**: All wind, string, and vocal instruments

**3. Accuracy**
- **Prompt**: "Plays with reliable pitch/rhythm accuracy at current tempo"
- **Notes**: Use metronome targets appropriate for student level
- **Applies to**: All instruments

**4. Coordination**
- **Prompt**: "Hands/breath/bow coordination is efficient and relaxed"
- **Notes**: Watch for tension indicators
- **Applies to**: Piano, strings, wind instruments requiring coordination

**5. Rhythmic Security**
- **Prompt**: "Counts accurately through rests and changes"
- **Notes**: Include clapping/counting strategies
- **Applies to**: All instruments

**6. Technique Transfer**
- **Prompt**: "Applies technical focus successfully inside repertoire"
- **Notes**: Not only in isolated exercises
- **Applies to**: All instruments

#### Instrument-Specific Checklists

**Violin/Strings:**
- Posture ✔/✖
- Bow hold ✔/✖
- Intonation ✔/✖
- Rhythm ✔/✖
- Vibrato ✔/✖
- Shifting ✔/✖

**Flute/Woodwind:**
- Tone ✔/✖
- Breath ✔/✖
- Finger clarity ✔/✖
- Rhythm ✔/✖
- Articulation ✔/✖
- Dynamics ✔/✖

**Piano/Keyboard:**
- Posture ✔/✖
- Balance (LH/RH) ✔/✖
- Articulation ✔/✖
- Accuracy ✔/✖
- Pedaling ✔/✖
- Voicing ✔/✖

**Trumpet/Brass:**
- Breath ✔/✖
- Range ✔/✖
- Articulation ✔/✖
- Endurance ✔/✖
- Intonation ✔/✖
- Dynamics ✔/✖

**Voice/Vocal Studies:**
- Breath ✔/✖
- Tone ✔/✖
- Diction ✔/✖
- Projection ✔/✖
- Pitch accuracy ✔/✖
- Interpretation ✔/✖

#### Usage Guidelines

**Frequency**: Each term (3 times per academic year)

**Format**:
- ✔ = Skill achieved consistently
- ✖ = Skill not yet developed
- ⚪ = Partial achievement (in progress)

**Owner**: Teacher (T)

**Integration**:
- Results stored in `technicalSkillsCompetence.teacherChecklist`
- Contributes to Technical Skills & Competence quadrant score (30% weighting)
- AI coach references checklist to provide targeted recommendations

#### Implementation in UI

**Teacher Portal - Checklist Entry Form:**
```typescript
interface ChecklistEntryForm {
  studentId: string;
  term: "Term 1" | "Term 2" | "Term 3";
  academicYear: string;
  instrument: string;
  
  checklist: {
    [skillName: string]: "achieved" | "not-achieved" | "partial";
  };
  
  notes?: string;  // Optional additional comments
}
```

**Example API Payload:**
```json
{
  "studentId": "S01",
  "term": "Term 1",
  "academicYear": "2024-2025",
  "instrument": "Violin",
  "checklist": {
    "Posture": "achieved",
    "Bow hold": "not-achieved",
    "Intonation": "not-achieved",
    "Rhythm": "achieved",
    "Vibrato": "partial",
    "Shifting": "not-achieved"
  },
  "notes": "Strong rhythmic foundation. Focus on bow hold exercises daily."
}
```

#### Score Calculation Impact

The checklist contributes to the Technical Skills & Competence score:

```typescript
function calculateChecklistScore(checklist: TeacherChecklist): number {
  const achievedCount = checklist.achieved.length;
  const partialCount = checklist.partial.length;
  const totalSkills = achievedCount + partialCount + checklist.notAchieved.length;
  
  // Achieved = 1 point, Partial = 0.5 points, Not achieved = 0 points
  const score = (achievedCount + (partialCount * 0.5)) / totalSkills * 100;
  
  return Math.round(score);
}

// Example: S01 (Aoife) - Posture ✔, Rhythm ✔, Bow hold ✖, Intonation ✖
// Achieved: 2, Partial: 0, Total: 4
// Score = (2 + 0) / 4 * 100 = 50
```

#### AI Coaching Integration

The AI coach can reference checklist data to provide targeted advice:

**Example AI Prompt Context:**
```
Student: Aoife Byrne (S01), Violin, Age 10
Technical Skills & Competence: 58/100

Teacher Checklist (Term 1):
- Posture: ✔ Achieved
- Bow hold: ✖ Not achieved
- Intonation: ✖ Not achieved
- Rhythm: ✔ Achieved

AI Coach Prompt:
"I noticed your teacher marked posture and rhythm as strengths! Those are 
great foundations. Let's work on bow hold together. Can you describe how 
your thumb feels when you hold the bow? Is it tight or relaxed?"
```

#### Data File Reference

Complete prompt library available in:
- **File**: `/mock-data/teacher-checklist-prompt-library.json`
- **Format**: JSON with prompt areas, instrument-specific lists, usage guidelines
- **Size**: 3.0KB

---

## 6. API Specifications

### 6.1 Base Configuration

**Base URL**: `https://api.accordo-ai.hackathon.aws/v1`

**Authentication**: Bearer token (JWT from Cognito)
```
Authorization: Bearer <id_token>
```

**Standard Response Format**:
```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  metadata?: {
    timestamp: string;
    requestId: string;
  };
}
```

### 6.2 Authentication Endpoints

#### POST /auth/login
```typescript
Request:
{
  email: string;
  password: string;
}

Response:
{
  success: true,
  data: {
    idToken: string;
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
    user: {
      userId: string;
      email: string;
      role: "student" | "teacher" | "admin";
      profile: {
        name: string;
        studentId?: string;
        teacherId?: string;
      }
    }
  }
}
```

#### POST /auth/refresh
```typescript
Request:
{
  refreshToken: string;
}

Response:
{
  success: true,
  data: {
    idToken: string;
    accessToken: string;
    expiresIn: number;
  }
}
```

### 6.3 Digital Passport Endpoints

#### GET /students/{studentId}/passport
**Authorization**: Student (own), Teacher, Admin

```typescript
Response:
{
  success: true,
  data: {
    student: {
      studentId: string;
      name: string;
      email: string;
      instrument: string;
      program: string;
      enrollmentDate: string;
    },
    // Four Quadrant Development Scores (RIAM Model)
    developmentScores: {
      technicalSkillsCompetence: {
        current: number;                  // 0-100 aggregate score
        trend: "improving" | "stable" | "declining";
        history: Array<{ date: string; score: number }>;
        components: {
          practicalTechniqueMark: number; // /100
          teacherAdviceCount: number;     // Number of weekly advice entries
          checklistProgress: number;      // % of skills achieved
        };
      },
      compositionalMusicianshipKnowledge: {
        current: number;
        trend: "improving" | "stable" | "declining";
        history: Array<{ date: string; score: number }>;
        components: {
          musicianshipMark: number;       // /100
          auralRecordingsCount: number;
          reflectiveNotesCount: number;
        };
      },
      repertoireCulturalKnowledge: {
        current: number;
        trend: "improving" | "stable" | "declining";
        history: Array<{ date: string; score: number }>;
        components: {
          repertoireCulturalMark: number; // /100
          listeningLogsCount: number;
          contextNotesCount: number;
        };
      },
      performingArtistry: {
        current: number;
        trend: "improving" | "stable" | "declining";
        history: Array<{ date: string; score: number }>;
        components: {
          practicalArtistryMark: number;  // /100
          reflectionsCount: number;
          teacherPrepNotesCount: number;
        };
      }
    },
    // Pie Chart Data (for visualization)
    pieChartData: {
      technicalSkillsCompetence: number;      // Percentage of total
      compositionalMusicianshipKnowledge: number;
      repertoireCulturalKnowledge: number;
      performingArtistry: number;
    },
    recentActivity: {
      lastRecording: string;              // ISO date
      lastJournalEntry: string;
      lastAssessment: string;
      practiceStreak: number;             // days
    },
    milestones: Array<{
      title: string;
      description: string;
      achievedAt: string;
      category: "technical-skills" | "musicianship" | "repertoire-cultural" | "performing-artistry";
    }>
  }
}
```

#### GET /students/{studentId}/timeline
**Authorization**: Student (own), Teacher, Admin

```typescript
Query Parameters:
- startDate: string (ISO 8601)
- endDate: string (ISO 8601)
- category?: "recordings" | "assessments" | "journals" | "exams"

Response:
{
  success: true,
  data: {
    events: Array<{
      eventId: string;
      type: "recording" | "assessment" | "journal" | "exam" | "milestone";
      title: string;
      description: string;
      date: string;
      metadata: object;
    }>
  }
}
```

### 6.4 Performance Recording Endpoints

#### POST /recordings/upload
**Authorization**: Student, Teacher

```typescript
Request (multipart/form-data):
{
  file: File;                             // Audio or Video file
  mediaType: "audio" | "video";           // Type of recording
  studentId: string;
  piece: string;
  composer: string;
  repertoireLevel: string;
  performanceType: string;
  
  // Optional video metadata
  videoMetadata?: {
    resolution?: string;                  // Auto-detected if not provided
    fps?: number;
  };
}

Response:
{
  success: true,
  data: {
    recordingId: string;
    mediaType: "audio" | "video";
    uploadUrl: string;                    // Pre-signed S3 URL
    expiresIn: number;                    // seconds
    maxFileSize: number;                  // bytes (50MB for audio, 500MB for video)
  }
}

// Supported Formats:
// Audio: .mp3, .wav, .m4a, .aac, .flac (max 50MB)
// Video: .mp4, .mov, .webm, .avi (max 500MB)
```

#### POST /recordings/{recordingId}/analyze
**Authorization**: Student (own recording), Teacher, Admin

```typescript
Request:
{
  recordingId: string;
}

Response:
{
  success: true,
  data: {
    recordingId: string;
    status: "queued" | "processing" | "completed";
    estimatedTime: number;                // seconds
    analysisId: string;
  }
}
```

#### GET /recordings/{recordingId}/feedback
**Authorization**: Student (own), Teacher, Admin

```typescript
Response:
{
  success: true,
  data: {
    recordingId: string;
    recording: {
      piece: string;
      composer: string;
      duration: number;
      uploadedAt: string;
    },
    aiFeedback: {
      technical: {
        accuracy: number;
        timing: number;
        technique: number;
        overallScore: number;
        issues: Array<{
          timestamp: number;              // seconds
          description: string;
          severity: "minor" | "moderate" | "major";
        }>;
      },
      expressive: {
        musicality: number;
        interpretation: number;
        dynamics: number;
        phrasing: number;
        overallScore: number;
        strengths: Array<{
          timestamp: number;
          description: string;
        }>;
      },
      summary: string;
      recommendations: string[];
      nextSteps: string[];
      generatedAt: string;
    },
    teacherReview?: {
      validated: boolean;
      comments: string;
      reviewedAt: string;
      teacherName: string;
    }
  }
}
```

#### GET /students/{studentId}/recordings
**Authorization**: Student (own), Teacher, Admin

```typescript
Query Parameters:
- limit?: number (default: 20)
- offset?: number (default: 0)
- status?: "uploaded" | "processing" | "completed" | "failed"
- sortBy?: "uploadedAt" | "piece"
- sortOrder?: "asc" | "desc"

Response:
{
  success: true,
  data: {
    recordings: Array<{
      recordingId: string;
      piece: string;
      composer: string;
      uploadedAt: string;
      status: string;
      hasFeedback: boolean;
      overallScore?: number;
    }>,
    pagination: {
      total: number;
      limit: number;
      offset: number;
      hasMore: boolean;
    }
  }
}
```

### 6.5 AI Coach Endpoints

#### POST /coach/sessions
**Authorization**: Student

```typescript
Request:
{
  studentId: string;
  conversationType: "goal-setting" | "reflection" | "progress" | "motivation";
}

Response:
{
  success: true,
  data: {
    sessionId: string;
    conversationType: string;
    initialMessage: {
      role: "assistant";
      content: string;
      timestamp: string;
    }
  }
}
```

#### POST /coach/sessions/{sessionId}/messages
**Authorization**: Student (own session)

```typescript
Request:
{
  message: string;
}

Response:
{
  success: true,
  data: {
    sessionId: string;
    response: {
      role: "assistant";
      content: string;
      timestamp: string;
    },
    suggestedActions?: string[];
  }
}
```

#### GET /coach/sessions/{sessionId}
**Authorization**: Student (own session), Teacher, Admin

```typescript
Response:
{
  success: true,
  data: {
    sessionId: string;
    studentId: string;
    conversationType: string;
    messages: Array<{
      role: "user" | "assistant";
      content: string;
      timestamp: string;
    }>,
    startedAt: string;
    lastMessageAt: string;
    status: "active" | "completed";
  }
}
```

#### GET /students/{studentId}/coach/history
**Authorization**: Student (own), Teacher, Admin

```typescript
Query Parameters:
- limit?: number (default: 10)
- conversationType?: string

Response:
{
  success: true,
  data: {
    sessions: Array<{
      sessionId: string;
      conversationType: string;
      messageCount: number;
      startedAt: string;
      lastMessageAt: string;
      summary: string;
    }>
  }
}
```

### 6.6 Analytics Endpoints

#### GET /analytics/students/{studentId}/summary
**Authorization**: Student (own), Teacher, Admin

```typescript
Query Parameters:
- period: "week" | "month" | "quarter" | "year"

Response:
{
  success: true,
  data: {
    period: {
      start: string;
      end: string;
    },
    metrics: {
      recordingsSubmitted: number;
      averageTechnicalScore: number;
      averageExpressiveScore: number;
      practiceHours: number;
      journalEntries: number;
      coachingInteractions: number;
    },
    progressTrends: {
      technicalMastery: {
        change: number;                   // percentage
        direction: "up" | "down" | "stable";
      },
      creativeExpression: {
        change: number;
        direction: "up" | "down" | "stable";
      },
      reflectivePractice: {
        change: number;
        direction: "up" | "down" | "stable";
      }
    },
    insights: string[];
  }
}
```

#### GET /analytics/cohorts/overview
**Authorization**: Teacher, Admin

```typescript
Query Parameters:
- program?: string
- instrument?: string

Response:
{
  success: true,
  data: {
    totalStudents: number;
    activeStudents: number;               // Active in last 30 days
    metrics: {
      averageTechnicalScore: number;
      averageExpressiveScore: number;
      totalRecordings: number;
      totalPracticeHours: number;
    },
    distribution: {
      technicalMastery: {
        excellent: number;                // 90-100
        good: number;                     // 75-89
        developing: number;               // 60-74
        needs_attention: number;          // <60
      },
      creativeExpression: { /* same structure */ },
      reflectivePractice: { /* same structure */ }
    }
  }
}
```

### 6.7 Mock Data Integration Endpoints

#### POST /admin/mock-data/import
**Authorization**: Admin only

```typescript
Request:
{
  dataSource: "riam-exams" | "lms-system" | "reflective-journals";
  fileUrl: string;                        // S3 URL or data payload
  options: {
    overwrite: boolean;
    validateOnly: boolean;
  }
}

Response:
{
  success: true,
  data: {
    importId: string;
    recordsProcessed: number;
    recordsImported: number;
    errors: Array<{
      recordId: string;
      error: string;
    }>;
    summary: {
      studentsCreated: number;
      recordingsLinked: number;
      assessmentsImported: number;
    }
  }
}
```

---

## 7. User Stories & Acceptance Criteria

### 7.1 Student User Stories

#### US-1: View Digital Passport
**As a** student  
**I want to** view my complete digital passport  
**So that** I can track my artistic development across all dimensions

**Acceptance Criteria:**
- [ ] Student can log in with email/password
- [ ] Passport displays current scores for all four dimensions:
  - Technical Skills & Competence
  - Compositional & Musicianship Knowledge
  - Repertoire & Cultural Knowledge
  - Performing Artistry
- [ ] Pie chart visualizes the four quadrants with interactive segments
- [ ] Each dimension shows trend indicator (improving/stable/declining)
- [ ] Visual progress charts show trends over time
- [ ] Recent activity section shows last recording, journal entry, assessment
- [ ] Milestones are displayed with achievement dates
- [ ] Page loads within 3 seconds

#### US-2: Upload Performance Recording
**As a** student  
**I want to** upload my practice recordings  
**So that** I can receive AI-powered feedback on my performance

**Acceptance Criteria:**
- [ ] Student can upload MP3, WAV, or M4A files up to 50MB
- [ ] Upload form captures: piece name, composer, performance type
- [ ] Progress bar shows upload status
- [ ] Success confirmation displays with recording ID
- [ ] Recording appears in "My Recordings" list immediately
- [ ] Status shows as "Processing" until AI analysis completes

#### US-3: Receive AI Feedback
**As a** student  
**I want to** receive detailed feedback on my recordings  
**So that** I can understand my strengths and areas for improvement

**Acceptance Criteria:**
- [ ] Feedback generates within 30 seconds of analysis request
- [ ] Technical assessment shows: accuracy, timing, technique scores
- [ ] Expressive assessment shows: musicality, interpretation, dynamics scores
- [ ] Specific issues are highlighted with timestamps
- [ ] Actionable recommendations are provided (3-5 items)
- [ ] Feedback can be downloaded as PDF
- [ ] Feedback updates passport scores automatically

#### US-4: Chat with AI Coach
**As a** student  
**I want to** have conversations with an AI coaching assistant  
**So that** I can get personalized guidance and motivation

**Acceptance Criteria:**
- [ ] Student can start new coaching session from dashboard
- [ ] Four conversation types available: goal-setting, reflection, progress, motivation
- [ ] AI responds within 5 seconds per message
- [ ] Conversation references recent recordings and progress
- [ ] Chat history is saved and accessible later
- [ ] AI provides contextually relevant suggestions
- [ ] Student can rate conversation helpfulness

#### US-5: Maintain Reflective Journal
**As a** student  
**I want to** record my practice reflections  
**So that** I can develop metacognitive awareness of my learning

**Acceptance Criteria:**
- [ ] Student can create new journal entry from dashboard
- [ ] Form captures: reflection text, mood, practice duration, focus areas
- [ ] AI provides optional insights on journal entry
- [ ] Journal entries appear in passport timeline
- [ ] Past entries are searchable by date/keyword
- [ ] Entries contribute to Reflective Practice score

### 7.2 Teacher User Stories

#### US-6: View Student Progress Dashboard
**As a** teacher  
**I want to** view all my students' progress in one place  
**So that** I can identify who needs additional support

**Acceptance Criteria:**
- [ ] Dashboard shows list of all assigned students
- [ ] Each student card displays: name, instrument, current scores, last activity date
- [ ] Visual indicators (colors) show progress trends
- [ ] Students can be filtered by: instrument, score range, activity status
- [ ] Teacher can click student to view full passport
- [ ] "Needs Attention" section highlights struggling students

#### US-7: Validate AI Feedback
**As a** teacher  
**I want to** review and validate AI-generated feedback  
**So that** I can ensure accuracy and add human context

**Acceptance Criteria:**
- [ ] Teacher receives notification when student submits recording
- [ ] Teacher can view recording + AI feedback side-by-side
- [ ] Teacher can mark feedback as "Validated" or "Needs Revision"
- [ ] Teacher can add supplementary comments
- [ ] Validated feedback shows badge to student
- [ ] Teacher comments append to AI feedback in student view

#### US-8: Generate Class Reports
**As a** teacher  
**I want to** generate analytics reports for my students  
**So that** I can assess cohort progress and plan curriculum

**Acceptance Criteria:**
- [ ] Teacher can select report type: individual, cohort, comparative
- [ ] Date range selector (last week, month, quarter, custom)
- [ ] Report shows: average scores, progress trends, engagement metrics
- [ ] Visual charts included (bar, line, distribution)
- [ ] Report exports to PDF or CSV
- [ ] Report generation completes within 10 seconds

### 7.3 Admin User Stories

#### US-9: Import Mock Data
**As an** admin  
**I want to** import mock data from legacy systems  
**So that** I can demonstrate system integration capabilities

**Acceptance Criteria:**
- [ ] Admin can upload CSV/JSON files for three data sources
- [ ] Data validation occurs before import
- [ ] Import summary shows: records processed, errors, warnings
- [ ] Failed records are logged with error details
- [ ] Successful import updates all relevant tables/collections
- [ ] Import process can be rolled back if critical errors occur

#### US-10: Monitor System Health
**As an** admin  
**I want to** view system health metrics  
**So that** I can ensure reliable operation during demo

**Acceptance Criteria:**
- [ ] Dashboard shows: API response times, error rates, active users
- [ ] AI service status indicators (Bedrock, AgentCore)
- [ ] Storage metrics (S3 usage, DynamoDB capacity)
- [ ] Recent error logs with filters
- [ ] Ability to manually trigger cache clear or service restart
- [ ] Refresh every 30 seconds

---

## 8. Frontend Specifications

### 8.1 Design System

#### Color Palette
```css
/* Primary Colors */
--primary-blue: #0066CC;
--primary-blue-dark: #004C99;
--primary-blue-light: #3399FF;

/* Secondary Colors */
--accent-purple: #6B46C1;
--accent-gold: #F59E0B;
--accent-green: #10B981;

/* Neutral Colors */
--gray-50: #F9FAFB;
--gray-100: #F3F4F6;
--gray-200: #E5E7EB;
--gray-700: #374151;
--gray-900: #111827;

/* Semantic Colors */
--success: #10B981;
--warning: #F59E0B;
--error: #EF4444;
--info: #3B82F6;
```

#### Typography
```css
/* Headings */
--font-heading: 'Inter', sans-serif;
--h1-size: 2.5rem;    /* 40px */
--h2-size: 2rem;      /* 32px */
--h3-size: 1.5rem;    /* 24px */
--h4-size: 1.25rem;   /* 20px */

/* Body */
--font-body: 'Inter', sans-serif;
--body-size: 1rem;    /* 16px */
--body-small: 0.875rem; /* 14px */

/* Code/Monospace */
--font-mono: 'Fira Code', monospace;
```

### 8.2 Page Components

#### Student Dashboard (`/dashboard`)
```typescript
interface StudentDashboardProps {
  student: StudentProfile;
  recentActivity: Activity[];
  upcomingGoals: Goal[];
}

Components:
- WelcomeHeader (personalized greeting)
- QuadrantPieChart (4 quadrant scores visualized as pie chart with legends)
- DevelopmentScoreCards (4 dimension cards with trend indicators)
- RecentActivityFeed (timeline of last 10 activities)
- QuickActions (upload recording, start coaching, add journal)
- UpcomingGoals (progress bars for current goals)
- PracticeStreakBadge (gamification element)
```

#### Digital Passport Page (`/passport`)
```typescript
interface PassportPageProps {
  student: StudentProfile;
  timeline: TimelineEvent[];
  milestones: Milestone[];
}

Components:
- PassportHeader (student info, profile picture, key stats)
- QuadrantPieChart (interactive pie chart showing 4 dimensions with drill-down)
- DimensionDetailCards (expandable cards for each of 4 dimensions):
  * Technical Skills & Competence
  * Compositional & Musicianship Knowledge
  * Repertoire & Cultural Knowledge
  * Performing Artistry
- ProgressTimeline (interactive timeline with filters)
- MilestoneGallery (achievements showcase)
- ExportButton (download passport as PDF)
```

#### Recording Upload Page (`/recordings/upload`)
```typescript
interface UploadPageProps {
  onUploadComplete: (recording: Recording) => void;
}

Components:
- MediaTypeSelector (toggle between Audio/Video upload)
- FileDropzone (drag-drop audio OR video file upload)
  * Audio: Accepts .mp3, .wav, .m4a, .aac, .flac (max 50MB)
  * Video: Accepts .mp4, .mov, .webm, .avi (max 500MB)
- MetadataForm (piece, composer, level, type)
- UploadProgressBar (with file size and estimated time)
- PreviewPlayer (audio waveform OR video player before upload)
- FileSizeIndicator (warns if file exceeds limits)
- SubmitButton (with loading state and progress percentage)
```

**Video Upload Additional Features:**
- Automatic video compression option (reduce file size while maintaining quality)
- Camera/webcam recording option (record directly in browser)
- Thumbnail preview generation
- Resolution display (720p, 1080p, etc.)
- Duration display with warning if >5 minutes

#### Feedback View Page (`/recordings/{id}/feedback`)
```typescript
interface FeedbackPageProps {
  recording: Recording;
  feedback: AIFeedback;
  teacherReview?: TeacherReview;
}

Components:
- MediaPlayer (adaptive based on recording type):
  * Audio: Waveform visualization with Wavesurfer.js
  * Video: HTML5 video player with timestamp markers
- ScoreOverview (summary scores mapped to 4 quadrants with progress bars)
- QuadrantImpactIndicator (shows which quadrants this feedback affects)
- TechnicalAnalysis (expandable section with issue markers - contributes to Technical Skills & Competence)
- ExpressiveAnalysis (expandable section with strength markers - contributes to Performing Artistry)
- VisualAnalysis (VIDEO ONLY - expandable section):
  * PostureScore (0-100 with timeline graph)
  * BodyMechanicsScore (0-100 with specific observations)
  * StagePresenceScore (0-100 with highlights)
  * InstrumentHandlingScore (0-100 with technique notes)
  * TimestampedObservations (clickable timestamps jump to video position)
  * Side-by-side comparison view (video + annotations)
- RecommendationsList (actionable next steps mapped to relevant quadrants)
- TeacherComments (if validated)
- ShareButton (share feedback via link)
```

**Video-Specific Features:**
- Click timestamp annotations to jump to specific moments in video
- Slow-motion playback for technique review (0.5x, 0.75x speed)
- Frame-by-frame scrubbing for detailed posture analysis
- Picture-in-picture mode for comparing sections
- Screenshot capture of key technique moments

#### AI Coach Chat Page (`/coach`)
```typescript
interface CoachPageProps {
  sessionId?: string;
  conversationType?: ConversationType;
}

Components:
- ConversationTypeSelector (4 buttons for dialogue types)
- ChatMessageList (scrollable message history)
- MessageInput (text input with send button)
- TypingIndicator (animated dots when AI is responding)
- SuggestedPrompts (clickable quick actions)
- SessionHistory (sidebar with past conversations)
```

#### Teacher Dashboard (`/teacher/dashboard`)
```typescript
interface TeacherDashboardProps {
  students: StudentSummary[];
  cohortMetrics: CohortMetrics;
}

Components:
- CohortOverviewCards (total students, average scores, engagement)
- StudentGrid (filterable/sortable student cards)
- AlertsFeed (students needing attention)
- RecentSubmissions (recordings awaiting validation)
- AnalyticsCharts (cohort progress trends)
```

### 8.3 Responsive Breakpoints
```css
/* Mobile First */
--mobile: 0px;
--tablet: 768px;
--desktop: 1024px;
--wide: 1440px;
```

### 8.4 Component Library
**Recommended**: Shadcn/ui + Tailwind CSS

**Core Components:**
- Button (primary, secondary, ghost variants)
- Card (with header, content, footer)
- Input (text, email, password)
- Select (dropdown)
- Table (sortable, filterable)
- Modal (dialog overlay)
- Toast (notification system)
- Badge (status indicators)
- Progress Bar
- Tabs
- Accordion
- Chart (Recharts integration):
  - **PieChart**: Primary visualization for 4-quadrant development scores
  - LineChart: Progress trends over time
  - BarChart: Comparative analytics
  - ProgressBar: Individual metric tracking

### 8.5 Quadrant Pie Chart Implementation

**Component Specification:**
```typescript
interface QuadrantPieChartProps {
  data: {
    technicalSkillsCompetence: number;
    compositionalMusicianshipKnowledge: number;
    repertoireCulturalKnowledge: number;
    performingArtistry: number;
  };
  interactive?: boolean;      // Enable click to drill down
  showLegend?: boolean;        // Display legend with labels
  size?: 'small' | 'medium' | 'large';
}
```

**Recharts Implementation:**
```tsx
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

const COLORS = {
  technicalSkillsCompetence: '#0066CC',        // Blue
  compositionalMusicianshipKnowledge: '#6B46C1', // Purple
  repertoireCulturalKnowledge: '#F59E0B',      // Gold
  performingArtistry: '#10B981'                 // Green
};

const QuadrantPieChart = ({ data, interactive = true, showLegend = true, size = 'medium' }) => {
  const chartData = [
    { name: 'Technical Skills & Competence', value: data.technicalSkillsCompetence, key: 'technical' },
    { name: 'Compositional & Musicianship', value: data.compositionalMusicianshipKnowledge, key: 'musicianship' },
    { name: 'Repertoire & Cultural Knowledge', value: data.repertoireCulturalKnowledge, key: 'repertoire' },
    { name: 'Performing Artistry', value: data.performingArtistry, key: 'artistry' }
  ];
  
  const sizes = { small: 200, medium: 300, large: 400 };
  
  return (
    <ResponsiveContainer width="100%" height={sizes[size]}>
      <PieChart>
        <Pie
          data={chartData}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {chartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={Object.values(COLORS)[index]} />
          ))}
        </Pie>
        {showLegend && <Legend />}
        <Tooltip formatter={(value) => `${value}/100`} />
      </PieChart>
    </ResponsiveContainer>
  );
};
```

**Visual Design Guidelines:**
- Each quadrant segment should be clearly distinct with contrasting colors
- Interactive segments highlight on hover
- Click on segment navigates to detailed dimension view
- Display percentage AND absolute score (e.g., "Technical Skills: 85/100 (28%)")
- Show total aggregate score in center of pie chart
- Minimum segment size threshold to ensure visibility (at least 5%)

---

## 9. AI/ML Integration

### 9.1 Amazon Bedrock Configuration

#### Nova Model Selection
```typescript
const BEDROCK_CONFIG = {
  region: 'us-east-1',
  models: {
    audioAnalysis: 'amazon.nova-pro-v1:0',
    videoAnalysis: 'amazon.nova-pro-v1:0',    // Multimodal model with video support
    conversational: 'amazon.nova-lite-v1:0'
  },
  inference: {
    maxTokens: 2048,
    temperature: 0.7,
    topP: 0.9
  },
  video: {
    maxDuration: 300,                          // seconds (5 minutes)
    frameExtractionRate: 1,                    // Extract 1 frame per second
    thumbnailTimestamp: 30                     // Generate thumbnail at 30 seconds
  }
};
```

#### Audio Analysis Prompt Template
```typescript
const AUDIO_ANALYSIS_PROMPT = `
You are an expert music educator analyzing a performance recording.

Context:
- Student: {{studentName}}
- Instrument: {{instrument}}
- Piece: {{piece}} by {{composer}}
- Level: {{repertoireLevel}}

Task: Analyze this performance recording and provide:

1. TECHNICAL ASSESSMENT (0-100 scale):
   - Accuracy: Pitch and note correctness
   - Timing: Rhythm precision and tempo stability
   - Technique: Instrumental technique quality
   - Overall Technical Score

2. EXPRESSIVE ASSESSMENT (0-100 scale):
   - Musicality: Musical interpretation and phrasing
   - Interpretation: Understanding of style and composer intent
   - Dynamics: Range and control of volume
   - Phrasing: Breath/bow management and musical shape
   - Overall Expressive Score

3. SPECIFIC ISSUES (with timestamps):
   List 3-5 technical issues with exact timing

4. STRENGTHS (with timestamps):
   List 3-5 expressive strengths with exact timing

5. RECOMMENDATIONS:
   Provide 3-5 actionable practice suggestions

6. NEXT STEPS:
   Suggest immediate focus areas for improvement

Format your response as JSON matching this schema:
{{jsonSchema}}
`;
```

#### Response Schema
```typescript
interface BedrockAnalysisResponse {
  technical: {
    accuracy: number;
    timing: number;
    technique: number;
    overallScore: number;
    issues: Array<{
      timestamp: number;
      description: string;
      severity: 'minor' | 'moderate' | 'major';
    }>;
  };
  expressive: {
    musicality: number;
    interpretation: number;
    dynamics: number;
    phrasing: number;
    overallScore: number;
    strengths: Array<{
      timestamp: number;
      description: string;
    }>;
  };
  recommendations: string[];
  nextSteps: string[];
}
```

#### Video Analysis Prompt Template
```typescript
const VIDEO_ANALYSIS_PROMPT = `
You are an expert music educator analyzing a video performance recording.

Context:
- Student: {{studentName}}
- Age: {{age}}
- Instrument: {{instrument}}
- Piece: {{piece}} by {{composer}}
- Level: {{repertoireLevel}}

Task: Analyze this video performance and provide:

1. AUDIO TECHNICAL ASSESSMENT (0-100 scale):
   - Accuracy: Pitch and note correctness
   - Timing: Rhythm precision and tempo stability
   - Technique: Instrumental technique quality (as heard)
   - Overall Audio Technical Score

2. AUDIO EXPRESSIVE ASSESSMENT (0-100 scale):
   - Musicality: Musical interpretation and phrasing
   - Interpretation: Understanding of style and composer intent
   - Dynamics: Range and control of volume
   - Phrasing: Musical shape and breath/bow management
   - Overall Audio Expressive Score

3. VISUAL ASSESSMENT (0-100 scale):
   - Posture: Body alignment, relaxed shoulders, balanced setup
   - Body Mechanics: Instrument-specific technique visibility
     * Strings: Bow arm movement, left hand position, vibrato execution
     * Woodwind/Brass: Embouchure, breath support, finger technique
     * Piano: Hand position, wrist alignment, pedaling technique
     * Voice: Breath support visibility, jaw relaxation, body engagement
   - Stage Presence: Confidence, engagement, professional presentation
   - Instrument Handling: Proper hold, setup, positioning
   - Overall Visual Score

4. VISUAL OBSERVATIONS (with timestamps):
   Identify 3-5 specific visual observations:
   - Excellent posture moments
   - Technique that needs attention (e.g., tense shoulders, awkward finger position)
   - Stage presence highlights or areas to develop

5. INTEGRATED RECOMMENDATIONS:
   Provide 3-5 actionable recommendations combining audio and visual insights

6. NEXT STEPS:
   Prioritized focus areas based on both audio and visual analysis

Format your response as JSON matching this schema:
{{jsonSchema}}
`;
```

#### Video Analysis Response Schema
```typescript
interface BedrockVideoAnalysisResponse {
  // Audio analysis (same as audio-only)
  technical: {
    accuracy: number;
    timing: number;
    technique: number;
    overallScore: number;
    issues: Array<{
      timestamp: number;
      description: string;
      severity: 'minor' | 'moderate' | 'major';
    }>;
  };
  expressive: {
    musicality: number;
    interpretation: number;
    dynamics: number;
    phrasing: number;
    overallScore: number;
    strengths: Array<{
      timestamp: number;
      description: string;
    }>;
  };
  
  // Video-specific analysis
  visual: {
    posture: number;                     // 0-100
    bodyMechanics: number;               // 0-100
    stagePresence: number;               // 0-100
    instrumentHandling: number;          // 0-100
    overallScore: number;                // 0-100
    observations: Array<{
      timestamp: number;                 // seconds
      category: 'posture' | 'mechanics' | 'presence' | 'handling';
      description: string;
      severity: 'excellent' | 'good' | 'needs-attention';
    }>;
  };
  
  recommendations: string[];
  nextSteps: string[];
}
```

#### Video Processing Workflow

```typescript
// Lambda function for video analysis
async function analyzeVideoRecording(recordingId: string, s3Key: string): Promise<VideoAnalysis> {
  // 1. Extract frames from video (1 fps for 5-minute max video)
  const frames = await extractVideoFrames(s3Key, {
    rate: 1,  // 1 frame per second
    maxFrames: 300  // Max 5 minutes
  });
  
  // 2. Extract audio track
  const audioTrack = await extractAudioFromVideo(s3Key);
  
  // 3. Generate thumbnail (at 30 seconds or middle of video)
  const thumbnail = await generateThumbnail(s3Key, { timestamp: 30 });
  await uploadToS3(thumbnail, `${recordingId}-thumbnail.jpg`);
  
  // 4. Call Bedrock Nova with multimodal input
  const analysis = await bedrock.invokeModel({
    modelId: 'amazon.nova-pro-v1:0',
    contentType: 'application/json',
    body: JSON.stringify({
      inputVideo: frames,                // Array of base64-encoded frames
      inputAudio: audioTrack,            // Audio stream
      prompt: VIDEO_ANALYSIS_PROMPT,
      inferenceConfig: {
        maxTokens: 3072,                 // More tokens for video analysis
        temperature: 0.7,
        topP: 0.9
      }
    })
  });
  
  // 5. Parse and return results
  return parseVideoAnalysisResponse(analysis);
}
```

#### Quadrant Mapping for Video Feedback

Video analysis contributes to multiple quadrants:

| Video Analysis Component | Updates Quadrant |
|--------------------------|------------------|
| Audio Technical Assessment | **Technical Skills & Competence** (60% weight) |
| Audio Expressive Assessment | **Performing Artistry** (60% weight) |
| Visual: Posture + Body Mechanics | **Technical Skills & Competence** (20% weight) |
| Visual: Stage Presence | **Performing Artistry** (30% weight) |
| Visual: Instrument Handling | **Technical Skills & Competence** (20% weight) |

**Score Aggregation Example:**
```typescript
// Technical Skills & Competence Score
const technicalScore = 
  (audioTechnical * 0.6) +              // 60% from audio technical
  (visual.posture * 0.1) +              // 10% from posture
  (visual.bodyMechanics * 0.2) +        // 20% from body mechanics
  (visual.instrumentHandling * 0.1);    // 10% from instrument handling

// Performing Artistry Score
const artistryScore = 
  (audioExpressive * 0.6) +             // 60% from audio expressive
  (visual.stagePresence * 0.4);         // 40% from stage presence
```

### 9.2 Bedrock AgentCore Configuration

#### Agent Definition
```typescript
const COACH_AGENT_CONFIG = {
  agentName: 'accordo-ai-coach',
  description: 'Personalized music education coaching assistant',
  instruction: `
    You are a supportive music education coach helping students achieve their artistic goals.
    
    Your capabilities:
    1. Goal Setting: Help students define SMART goals for their musical development
    2. Reflection: Guide students through reflective practice about their learning
    3. Progress Insights: Analyze and communicate progress trends
    4. Motivation: Provide encouragement tailored to student's journey
    
    Guidelines:
    - Be warm, encouraging, and conversational
    - Reference specific student data (recent recordings, scores, practice patterns)
    - Ask open-ended questions to deepen reflection
    - Celebrate small wins and progress
    - Provide concrete, actionable advice
    - Acknowledge challenges with empathy
    - Use music terminology appropriately for student level
    
    Context: You have access to student profile, recording history, and practice data.
  `,
  
  actionGroups: [
    {
      actionGroupName: 'student-data-lookup',
      description: 'Retrieve student profile and progress data',
      functions: [
        {
          name: 'getStudentProfile',
          description: 'Get student basic info and current scores'
        },
        {
          name: 'getRecentRecordings',
          description: 'Get last 5 recordings with feedback'
        },
        {
          name: 'getPracticeStats',
          description: 'Get practice hours and consistency metrics'
        }
      ]
    },
    {
      actionGroupName: 'goal-management',
      description: 'Help students set and track goals',
      functions: [
        {
          name: 'createGoal',
          description: 'Create new student goal'
        },
        {
          name: 'getActiveGoals',
          description: 'Get current active goals'
        },
        {
          name: 'updateGoalProgress',
          description: 'Update progress on existing goal'
        }
      ]
    }
  ],
  
  guardrails: {
    contentFiltering: {
      hate: 'HIGH',
      insults: 'HIGH',
      sexual: 'HIGH',
      violence: 'HIGH'
    },
    contextualGrounding: {
      threshold: 0.8,
      requireCitations: true
    }
  }
};
```

#### Conversation Flow Examples

**Goal-Setting Dialogue:**
```
Agent: "Hi [Student]! I'm excited to help you set some musical goals. 
Looking at your recent progress, I can see you've been working on [Piece]. 
What aspect of your playing would you most like to improve over the next month?"

Student: "I want to get better at my scales"

Agent: "Great choice! Scales are fundamental. Let's make this specific. 
I see you're currently scoring 72/100 on technical mastery. 
How about we aim for: 'Practice scales in all major keys at 80 BPM with 90% accuracy by February 10th'? 
Does that feel achievable?"

Student: "Yes, that works"

Agent: "Perfect! I've saved this goal to your passport. I'll check in with you 
weekly to see how you're progressing. Would you like some practice tips to get started?"
```

**Reflective Prompts:**
```
Agent: "I noticed you uploaded a recording of [Piece] today. 
How did you feel about that performance?"

Student: "I messed up the middle section"

Agent: "It's great that you're being self-aware. The AI analysis shows 
you actually nailed the tempo and dynamics there. What specifically felt off to you?"

Student: "I think my left hand was too loud"

Agent: "That's a keen observation about balance. Have you tried recording 
just the left hand part separately to isolate it? That can help you hear exactly 
what's happening. Want to try that for your next practice session?"
```

### 9.3 Lambda Integration Code

#### Bedrock Audio Analysis Lambda
```typescript
// lambda/analyze-recording/index.ts

import { BedrockRuntimeClient, InvokeModelCommand } from '@aws-sdk/client-bedrock-runtime';
import { S3Client, GetObjectCommand } from '@aws-sdk/client-s3';
import { DynamoDBClient, UpdateItemCommand } from '@aws-sdk/client-dynamodb';

const bedrock = new BedrockRuntimeClient({ region: 'us-east-1' });
const s3 = new S3Client({ region: 'us-east-1' });
const dynamodb = new DynamoDBClient({ region: 'us-east-1' });

export const handler = async (event: any) => {
  const { recordingId, studentId, s3Key } = JSON.parse(event.body);
  
  try {
    // 1. Get audio file from S3
    const audioData = await s3.send(new GetObjectCommand({
      Bucket: process.env.RECORDINGS_BUCKET!,
      Key: s3Key
    }));
    
    // 2. Prepare Bedrock request
    const prompt = buildAnalysisPrompt(event);
    
    const response = await bedrock.send(new InvokeModelCommand({
      modelId: 'amazon.nova-pro-v1:0',
      contentType: 'application/json',
      accept: 'application/json',
      body: JSON.stringify({
        inputAudio: await streamToBase64(audioData.Body),
        prompt: prompt,
        inferenceConfig: {
          maxTokens: 2048,
          temperature: 0.7,
          topP: 0.9
        }
      })
    }));
    
    // 3. Parse response
    const result = JSON.parse(new TextDecoder().decode(response.body));
    const feedback = parseBedrockResponse(result);
    
    // 4. Update DynamoDB
    await dynamodb.send(new UpdateItemCommand({
      TableName: process.env.RECORDINGS_TABLE!,
      Key: {
        PK: { S: `STUDENT#${studentId}` },
        SK: { S: `RECORDING#${recordingId}` }
      },
      UpdateExpression: 'SET aiFeedback = :feedback, #status = :status, processedAt = :timestamp',
      ExpressionAttributeNames: {
        '#status': 'status'
      },
      ExpressionAttributeValues: {
        ':feedback': { M: dynamoDBMarshall(feedback) },
        ':status': { S: 'completed' },
        ':timestamp': { S: new Date().toISOString() }
      }
    }));
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        data: {
          recordingId,
          feedback,
          processedAt: new Date().toISOString()
        }
      })
    };
    
  } catch (error) {
    console.error('Bedrock analysis failed:', error);
    
    // Update status to failed
    await dynamodb.send(new UpdateItemCommand({
      TableName: process.env.RECORDINGS_TABLE!,
      Key: {
        PK: { S: `STUDENT#${studentId}` },
        SK: { S: `RECORDING#${recordingId}` }
      },
      UpdateExpression: 'SET #status = :status',
      ExpressionAttributeNames: { '#status': 'status' },
      ExpressionAttributeValues: { ':status': { S: 'failed' } }
    }));
    
    return {
      statusCode: 500,
      body: JSON.stringify({
        success: false,
        error: {
          code: 'ANALYSIS_FAILED',
          message: 'Failed to analyze recording'
        }
      })
    };
  }
};
```

#### AgentCore Chat Lambda
```typescript
// lambda/coach-chat/index.ts

import { BedrockAgentRuntimeClient, InvokeAgentCommand } from '@aws-sdk/client-bedrock-agent-runtime';

const agentClient = new BedrockAgentRuntimeClient({ region: 'us-east-1' });

export const handler = async (event: any) => {
  const { sessionId, studentId, message } = JSON.parse(event.body);
  
  try {
    const response = await agentClient.send(new InvokeAgentCommand({
      agentId: process.env.AGENT_ID!,
      agentAliasId: process.env.AGENT_ALIAS_ID!,
      sessionId: sessionId,
      inputText: message,
      sessionState: {
        sessionAttributes: {
          studentId: studentId
        }
      }
    }));
    
    // Stream response chunks
    let fullResponse = '';
    for await (const chunk of response.completion!) {
      if (chunk.chunk?.bytes) {
        fullResponse += new TextDecoder().decode(chunk.chunk.bytes);
      }
    }
    
    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        data: {
          response: {
            role: 'assistant',
            content: fullResponse,
            timestamp: new Date().toISOString()
          }
        }
      })
    };
    
  } catch (error) {
    console.error('Agent invocation failed:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        success: false,
        error: {
          code: 'AGENT_FAILED',
          message: 'Coach is temporarily unavailable'
        }
      })
    };
  }
};
```

---

## 10. Security & Authentication

### 10.1 Amazon Cognito Configuration

#### User Pool Settings
```typescript
const USER_POOL_CONFIG = {
  poolName: 'accordo-ai-users',
  
  signInAliases: {
    email: true,
    username: false
  },
  
  autoVerifiedAttributes: ['email'],
  
  passwordPolicy: {
    minimumLength: 8,
    requireLowercase: true,
    requireUppercase: true,
    requireNumbers: true,
    requireSymbols: false
  },
  
  mfa: 'OPTIONAL',
  
  accountRecovery: {
    email: true
  },
  
  customAttributes: [
    { name: 'role', type: 'String' },          // student | teacher | admin
    { name: 'studentId', type: 'String' },
    { name: 'teacherId', type: 'String' }
  ]
};
```

#### User Groups
```typescript
const COGNITO_GROUPS = [
  {
    groupName: 'Students',
    description: 'Student users with access to own data',
    precedence: 3
  },
  {
    groupName: 'Teachers',
    description: 'Teacher users with access to assigned students',
    precedence: 2
  },
  {
    groupName: 'Admins',
    description: 'System administrators with full access',
    precedence: 1
  }
];
```

### 10.2 API Gateway Authorization

#### Lambda Authorizer
```typescript
// lambda/api-authorizer/index.ts

import { CognitoJwtVerifier } from 'aws-jwt-verify';

const verifier = CognitoJwtVerifier.create({
  userPoolId: process.env.USER_POOL_ID!,
  tokenUse: 'id',
  clientId: process.env.USER_POOL_CLIENT_ID!
});

export const handler = async (event: any) => {
  const token = event.authorizationToken?.replace('Bearer ', '');
  
  if (!token) {
    throw new Error('Unauthorized');
  }
  
  try {
    const payload = await verifier.verify(token);
    
    const policy = {
      principalId: payload.sub,
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'execute-api:Invoke',
            Effect: 'Allow',
            Resource: event.methodArn
          }
        ]
      },
      context: {
        userId: payload.sub,
        email: payload.email,
        role: payload['custom:role'],
        studentId: payload['custom:studentId'],
        teacherId: payload['custom:teacherId']
      }
    };
    
    return policy;
    
  } catch (error) {
    console.error('Token verification failed:', error);
    throw new Error('Unauthorized');
  }
};
```

### 10.3 Resource-Level Authorization

#### Authorization Helper
```typescript
// utils/authorization.ts

export const canAccessStudentData = (
  requestingUser: User,
  targetStudentId: string
): boolean => {
  // Admin can access all
  if (requestingUser.role === 'admin') {
    return true;
  }
  
  // Student can access own data
  if (requestingUser.role === 'student' && requestingUser.studentId === targetStudentId) {
    return true;
  }
  
  // Teacher can access assigned students
  if (requestingUser.role === 'teacher') {
    return isStudentAssignedToTeacher(requestingUser.teacherId, targetStudentId);
  }
  
  return false;
};

export const canModifyRecording = (
  requestingUser: User,
  recording: Recording
): boolean => {
  if (requestingUser.role === 'admin') {
    return true;
  }
  
  if (requestingUser.role === 'student') {
    return recording.studentId === requestingUser.studentId;
  }
  
  return false;
};
```

### 10.4 Data Encryption

#### S3 Encryption
```typescript
const S3_BUCKET_CONFIG = {
  encryption: {
    serverSideEncryption: 'AES256'
  },
  publicAccessBlock: {
    blockPublicAcls: true,
    blockPublicPolicy: true,
    ignorePublicAcls: true,
    restrictPublicBuckets: true
  }
};
```

#### DynamoDB Encryption
```typescript
const DYNAMODB_TABLE_CONFIG = {
  encryption: {
    encryptionType: 'AWS_MANAGED'
  }
};
```

### 10.5 API Rate Limiting

#### API Gateway Throttling
```typescript
const API_THROTTLE_CONFIG = {
  defaultRateLimit: 1000,              // requests per second
  defaultBurstLimit: 2000,
  
  methodThrottling: {
    'POST /recordings/upload': {
      rateLimit: 10,
      burstLimit: 20
    },
    'POST /recordings/*/analyze': {
      rateLimit: 5,
      burstLimit: 10
    },
    'POST /coach/sessions/*/messages': {
      rateLimit: 20,
      burstLimit: 40
    }
  }
};
```

---

## 11. Implementation Plan

### 11.1 Day 1: Foundation (8 hours)

#### Morning Session (4 hours)
**Team Split:**
- **Backend Team (3 people)**: Infrastructure setup
- **Frontend Team (3 people)**: Project scaffolding
- **Data Team (2 people)**: Mock data creation

**Backend Tasks:**
```
□ Set up AWS account and configure Bedrock access
□ Create CDK project structure
□ Deploy DynamoDB tables (StudentProfiles, PerformanceRecordings, ConversationHistory)
□ Deploy RDS PostgreSQL database with schema
□ Create S3 buckets (recordings, data-lake, frontend-hosting)
□ Set up Cognito User Pool with 3 groups
□ Create 5 test users (2 students, 2 teachers, 1 admin)
□ Deploy API Gateway with basic structure
```

**Frontend Tasks:**
```
□ Initialize Next.js 14 project with TypeScript
□ Set up Tailwind CSS + Shadcn/ui
□ Configure authentication flow with Cognito
□ Create basic routing structure (/dashboard, /passport, /recordings, /coach, /teacher)
□ Build reusable layout components (Header, Sidebar, Footer)
□ Implement authentication guard HOC
```

**Data Tasks:**
```
□ Create 5 detailed student profiles (CSV format)
□ Generate 10-15 mock audio files (royalty-free classical music samples)
□ Create 30 mock exam results (PostgreSQL inserts)
□ Write 20+ reflective journal entries
□ Create 50 teacher assessment records
□ Package into importable format
```

#### Afternoon Session (4 hours)
**Deliverable Goal:** Working authentication + basic data flow

**Integrated Tasks:**
```
□ Deploy Passport API Lambda (GET /students/{id}/passport)
□ Deploy Integration API Lambda (POST /admin/mock-data/import)
□ Import all mock data into DynamoDB + RDS
□ Build student login page with Cognito integration
□ Build basic dashboard showing student profile
□ Test end-to-end: Login → View Dashboard → See Profile
□ Deploy frontend to S3 + CloudFront
```

**End of Day 1 Demo:**
- Student can log in
- Dashboard displays student name, instrument, enrollment info
- Placeholder scores visible (not yet calculated)

### 11.2 Day 2: AI Integration (8 hours)

#### Morning Session (4 hours)
**Focus:** Bedrock Nova audio analysis

**Backend Tasks:**
```
□ Create Bedrock client configuration
□ Write audio analysis prompt template
□ Deploy Analyze Recording Lambda with Bedrock integration
□ Deploy Feedback API Lambda (GET /recordings/{id}/feedback)
□ Implement score calculation logic
□ Connect feedback to passport score updates
□ Create S3 pre-signed URL generator for uploads
```

**Frontend Tasks:**
```
□ Build recording upload page with drag-drop
□ Implement audio file preview player
□ Create feedback display component with waveform
□ Build score visualization (radial charts for technical/expressive)
□ Create recommendations list component
□ Implement recording list page with filters
```

**Testing:**
```
□ Upload 5 sample recordings
□ Trigger AI analysis for each
□ Verify feedback generation (< 30 seconds)
□ Confirm passport scores update automatically
□ Test teacher validation workflow
```

#### Afternoon Session (4 hours)
**Focus:** Bedrock AgentCore conversational AI

**Backend Tasks:**
```
□ Create AgentCore agent definition
□ Configure action groups (student-data-lookup, goal-management)
□ Deploy Lambda functions for action group APIs
□ Deploy Coach Chat Lambda (POST /coach/sessions, POST /coach/sessions/{id}/messages)
□ Implement conversation history storage
□ Test agent with sample dialogues
```

**Frontend Tasks:**
```
□ Build AI Coach chat interface
□ Implement conversation type selector
□ Create message bubble components
□ Add typing indicator animation
□ Build session history sidebar
□ Implement suggested prompts
```

**Testing:**
```
□ Test all 4 conversation types (goal-setting, reflection, progress, motivation)
□ Verify agent references student data correctly
□ Confirm conversation context maintained across messages
□ Test multi-turn dialogues (5+ messages)
```

**End of Day 2 Demo:**
- Student uploads recording → Receives AI feedback within 30 seconds
- Student starts coaching chat → AI responds contextually
- Digital passport shows updated scores from AI analysis

### 11.3 Day 3: Polish & Demo Prep (8 hours)

#### Morning Session (4 hours)
**Focus:** Analytics, teacher portal, final features

**Backend Tasks:**
```
□ Deploy Analytics API Lambda (GET /analytics/students/{id}/summary)
□ Deploy Cohort Analytics Lambda (GET /analytics/cohorts/overview)
□ Implement teacher assignment logic
□ Create validation endpoints for teacher feedback
□ Build export functionality (PDF/CSV)
```

**Frontend Tasks:**
```
□ Build teacher dashboard with student grid
□ Create cohort analytics page with charts
□ Implement admin dashboard with system metrics
□ Build digital passport PDF export
□ Add progress timeline component
□ Polish UI/UX (loading states, error messages, animations)
```

**Testing:**
```
□ Teacher logs in → Views all assigned students
□ Teacher validates AI feedback
□ Admin imports mock data successfully
□ All 5 sample students have complete data
□ Export features work correctly
```

#### Afternoon Session (4 hours)
**Focus:** Demo preparation and presentation

**Tasks:**
```
□ End-to-end testing with all user roles
□ Performance optimization (lazy loading, caching)
□ Mobile responsiveness verification
□ Accessibility audit (keyboard navigation, screen readers)
□ Bug fixes and edge case handling
□ Write demo script with timing
□ Prepare presentation slides
□ Create demo video backup (in case of live demo issues)
□ Final deployment to production environment
```

**Demo Script Outline (10 minutes):**
```
1. Introduction (1 min): Problem statement, solution overview
2. Student Journey (4 min):
   - Login as student
   - View digital passport (3 dimensions)
   - Upload performance recording
   - Receive AI feedback
   - Chat with AI coach
3. Teacher Portal (2 min):
   - View student dashboard
   - Validate AI feedback
   - See cohort analytics
4. Technical Architecture (2 min):
   - High-level diagram walkthrough
   - AWS services used
   - Mock data integration
5. Global Applicability (1 min):
   - How this scales to other institutions
   - Post-hackathon roadmap
```

**End of Day 3 Deliverables:**
- Fully functional MVP
- 5 complete student profiles with data
- 10+ analyzed recordings
- Working AI coaching across 4 scenarios
- Teacher and admin portals functional
- Polished presentation
- Demo video recorded

---

## 12. Testing Strategy

### 12.1 Unit Testing

#### Backend (Jest + AWS SDK Mocks)
```typescript
// Example: Analyze Recording Lambda test
describe('analyzeRecording', () => {
  it('should successfully analyze audio and return feedback', async () => {
    const mockEvent = {
      body: JSON.stringify({
        recordingId: 'rec-123',
        studentId: 'stu-456',
        s3Key: 'recordings/stu-456/performance-001.mp3'
      })
    };
    
    const result = await handler(mockEvent);
    
    expect(result.statusCode).toBe(200);
    const body = JSON.parse(result.body);
    expect(body.success).toBe(true);
    expect(body.data.feedback.technical.overallScore).toBeGreaterThanOrEqual(0);
    expect(body.data.feedback.technical.overallScore).toBeLessThanOrEqual(100);
  });
  
  it('should handle Bedrock API failures gracefully', async () => {
    // Mock Bedrock to throw error
    bedrockMock.onInvokeModel().rejects(new Error('Service unavailable'));
    
    const result = await handler(mockEvent);
    
    expect(result.statusCode).toBe(500);
    const body = JSON.parse(result.body);
    expect(body.success).toBe(false);
    expect(body.error.code).toBe('ANALYSIS_FAILED');
  });
});
```

#### Frontend (Jest + React Testing Library)
```typescript
// Example: Digital Passport component test
describe('DigitalPassport', () => {
  it('should render all three development dimensions', () => {
    const mockStudent = {
      studentId: 'stu-123',
      name: 'Alice Johnson',
      technicalMasteryScore: 85,
      creativeExpressionScore: 78,
      reflectivePracticeScore: 92
    };
    
    render(<DigitalPassport student={mockStudent} />);
    
    expect(screen.getByText('Technical Mastery')).toBeInTheDocument();
    expect(screen.getByText('85')).toBeInTheDocument();
    expect(screen.getByText('Creative Expression')).toBeInTheDocument();
    expect(screen.getByText('78')).toBeInTheDocument();
  });
});
```

### 12.2 Integration Testing

#### API Integration Tests
```typescript
describe('Recording Upload Flow', () => {
  it('should complete end-to-end upload and analysis', async () => {
    // 1. Upload recording
    const uploadResponse = await fetch('/recordings/upload', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${studentToken}` },
      body: formData
    });
    const { recordingId } = await uploadResponse.json();
    
    // 2. Trigger analysis
    const analyzeResponse = await fetch(`/recordings/${recordingId}/analyze`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${studentToken}` }
    });
    expect(analyzeResponse.status).toBe(200);
    
    // 3. Poll for feedback (max 30 seconds)
    let feedback;
    for (let i = 0; i < 30; i++) {
      const feedbackResponse = await fetch(`/recordings/${recordingId}/feedback`, {
        headers: { 'Authorization': `Bearer ${studentToken}` }
      });
      const data = await feedbackResponse.json();
      if (data.data.aiFeedback) {
        feedback = data.data.aiFeedback;
        break;
      }
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    // 4. Verify feedback structure
    expect(feedback).toBeDefined();
    expect(feedback.technical.overallScore).toBeGreaterThanOrEqual(0);
    expect(feedback.recommendations).toHaveLength(greaterThanOrEqual(3));
  });
});
```

### 12.3 User Acceptance Testing

#### Test Scenarios

**Scenario 1: New Student Onboarding**
```
Given: A new student has just enrolled
When: They log in for the first time
Then: 
  - Dashboard displays welcome message
  - Digital passport shows initial scores (0 or baseline)
  - Quick start guide is visible
  - Upload recording button is prominent
```

**Scenario 2: Recording Submission and Feedback**
```
Given: Student is logged in on dashboard
When: They upload a performance recording
Then:
  - File uploads successfully with progress indicator
  - Recording appears in "My Recordings" list with "Processing" status
  - Within 30 seconds, status changes to "Completed"
  - Feedback is accessible with technical and expressive scores
  - Recommendations are actionable and specific
  - Passport scores update automatically
```

**Scenario 3: AI Coaching Interaction**
```
Given: Student wants motivation after difficult practice session
When: They start a "Motivation" conversation with AI coach
Then:
  - AI greets them by name
  - AI references recent activities (e.g., "I saw you uploaded Beethoven Sonata")
  - AI asks empathetic questions about their feelings
  - AI provides specific encouragement based on progress data
  - Conversation feels natural and contextually relevant
```

**Scenario 4: Teacher Reviewing Student Progress**
```
Given: Teacher has 10 students assigned
When: They view the teacher dashboard
Then:
  - All 10 students are displayed with key metrics
  - Students needing attention are highlighted
  - Teacher can filter by instrument or score range
  - Clicking a student shows their full digital passport
  - Teacher can validate AI feedback with one click
```

### 12.4 Performance Testing

#### Load Testing Targets
```yaml
Endpoints to Test:
  - GET /students/{id}/passport: 100 req/sec (p99 < 1s)
  - POST /recordings/upload: 10 concurrent uploads
  - POST /recordings/{id}/analyze: 5 concurrent analyses
  - POST /coach/sessions/{id}/messages: 50 req/sec (p99 < 3s)

Tools:
  - Artillery.io for HTTP load testing
  - AWS CloudWatch for monitoring

Sample Artillery Config:
config:
  target: 'https://api.accordo-ai.hackathon.aws'
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Sustained load"
```

---

## 13. Deployment & DevOps

### 13.1 Infrastructure as Code (AWS CDK)

#### Project Structure
```
cdk/
├── bin/
│   └── accordo-ai.ts                  # CDK app entry point
├── lib/
│   ├── stacks/
│   │   ├── auth-stack.ts              # Cognito resources
│   │   ├── api-stack.ts               # API Gateway + Lambdas
│   │   ├── data-stack.ts              # DynamoDB + RDS
│   │   ├── storage-stack.ts           # S3 buckets
│   │   ├── ai-stack.ts                # Bedrock configuration
│   │   └── frontend-stack.ts          # CloudFront + S3 hosting
│   └── constructs/
│       ├── lambda-function.ts         # Reusable Lambda construct
│       └── api-endpoint.ts            # Reusable API endpoint construct
├── cdk.json
└── package.json
```

#### Example Stack: API Stack
```typescript
// lib/stacks/api-stack.ts

import * as cdk from 'aws-cdk-lib';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';

export class ApiStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    
    // Create API Gateway
    const api = new apigateway.RestApi(this, 'AccordoAPI', {
      restApiName: 'Accordo AI API',
      description: 'API for Accordo AI music education platform',
      deployOptions: {
        stageName: 'v1',
        throttlingRateLimit: 1000,
        throttlingBurstLimit: 2000,
        loggingLevel: apigateway.MethodLoggingLevel.INFO
      },
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS
      }
    });
    
    // Create Lambda functions
    const passportFunction = new lambda.Function(this, 'PassportFunction', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('lambda/passport-api'),
      environment: {
        STUDENT_PROFILES_TABLE: props.studentProfilesTable.tableName,
        RECORDINGS_TABLE: props.recordingsTable.tableName
      },
      timeout: cdk.Duration.seconds(10)
    });
    
    // Grant DynamoDB permissions
    props.studentProfilesTable.grantReadWriteData(passportFunction);
    props.recordingsTable.grantReadData(passportFunction);
    
    // Create API endpoints
    const students = api.root.addResource('students');
    const student = students.addResource('{studentId}');
    const passport = student.addResource('passport');
    
    passport.addMethod('GET', new apigateway.LambdaIntegration(passportFunction), {
      authorizer: props.authorizer,
      authorizationType: apigateway.AuthorizationType.CUSTOM
    });
    
    // Output API URL
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
      description: 'API Gateway URL'
    });
  }
}
```

### 13.2 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml

name: Deploy Accordo AI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          
      - name: Install dependencies
        run: |
          cd frontend && npm ci
          cd ../lambda && npm ci
          cd ../cdk && npm ci
          
      - name: Run frontend tests
        run: cd frontend && npm test
        
      - name: Run lambda tests
        run: cd lambda && npm test
        
      - name: Lint
        run: |
          cd frontend && npm run lint
          cd ../lambda && npm run lint

  deploy-backend:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE }}
          aws-region: ${{ env.AWS_REGION }}
          
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          
      - name: Install CDK dependencies
        run: cd cdk && npm ci
        
      - name: CDK Deploy
        run: cd cdk && npx cdk deploy --all --require-approval never

  deploy-frontend:
    needs: [test, deploy-backend]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          
      - name: Install dependencies
        run: cd frontend && npm ci
        
      - name: Build frontend
        run: cd frontend && npm run build
        env:
          NEXT_PUBLIC_API_URL: ${{ secrets.API_URL }}
          NEXT_PUBLIC_USER_POOL_ID: ${{ secrets.USER_POOL_ID }}
          NEXT_PUBLIC_USER_POOL_CLIENT_ID: ${{ secrets.USER_POOL_CLIENT_ID }}
          
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_DEPLOY_ROLE }}
          aws-region: ${{ env.AWS_REGION }}
          
      - name: Deploy to S3
        run: |
          aws s3 sync frontend/out s3://${{ secrets.FRONTEND_BUCKET }} --delete
          
      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

### 13.3 Environment Configuration

```typescript
// config/environments.ts

export const environments = {
  development: {
    apiUrl: 'http://localhost:3000',
    region: 'us-east-1',
    userPoolId: 'us-east-1_DevPoolId',
    userPoolClientId: 'dev-client-id',
    recordingsBucket: 'accordo-dev-recordings',
    bedrockModel: 'amazon.nova-lite-v1:0'  // Cheaper for dev
  },
  
  hackathon: {
    apiUrl: 'https://api.accordo-ai.hackathon.aws',
    region: 'us-east-1',
    userPoolId: 'us-east-1_HackPoolId',
    userPoolClientId: 'hack-client-id',
    recordingsBucket: 'accordo-hack-recordings',
    bedrockModel: 'amazon.nova-pro-v1:0'
  },
  
  production: {
    apiUrl: 'https://api.accordo-ai.com',
    region: 'us-east-1',
    userPoolId: 'us-east-1_ProdPoolId',
    userPoolClientId: 'prod-client-id',
    recordingsBucket: 'accordo-prod-recordings',
    bedrockModel: 'amazon.nova-pro-v1:0'
  }
};
```

### 13.4 Monitoring & Logging

#### CloudWatch Dashboards
```typescript
const dashboard = new cloudwatch.Dashboard(this, 'AccordoDashboard', {
  dashboardName: 'Accordo-AI-Metrics',
  widgets: [
    [
      new cloudwatch.GraphWidget({
        title: 'API Gateway Requests',
        left: [
          api.metricCount(),
          api.metric4XXError(),
          api.metric5XXError()
        ]
      })
    ],
    [
      new cloudwatch.GraphWidget({
        title: 'Lambda Invocations',
        left: [
          analyzeFunction.metricInvocations(),
          analyzeFunction.metricErrors(),
          analyzeFunction.metricThrottles()
        ]
      })
    ],
    [
      new cloudwatch.GraphWidget({
        title: 'Lambda Duration',
        left: [
          analyzeFunction.metricDuration(),
          coachFunction.metricDuration()
        ]
      })
    ]
  ]
});
```

#### CloudWatch Alarms
```typescript
// High error rate alarm
new cloudwatch.Alarm(this, 'HighErrorRate', {
  metric: api.metric5XXError(),
  threshold: 10,
  evaluationPeriods: 2,
  alarmDescription: 'Alert when 5XX errors exceed 10 in 2 minutes',
  actionsEnabled: true
});

// Long Lambda duration alarm
new cloudwatch.Alarm(this, 'LongAnalysisDuration', {
  metric: analyzeFunction.metricDuration(),
  threshold: 30000,  // 30 seconds
  evaluationPeriods: 3,
  alarmDescription: 'Alert when analysis takes longer than 30 seconds'
});
```

---

## 14. Appendices

### A. Glossary

- **Digital Passport**: Unified student profile tracking development across four dimensions using RIAM's quadrant model
- **RIAM Quadrant Model**: Four-dimensional assessment framework for music education development
- **Technical Skills & Competence**: Quadrant measuring practical technique marks, teacher technical advice, and skills checklists
- **Compositional & Musicianship Knowledge**: Quadrant measuring musicianship marks, aural evidence recordings, and creative/reflective notes
- **Repertoire & Cultural Knowledge**: Quadrant measuring repertoire marks, listening logs, and context/meaning notes
- **Performing Artistry**: Quadrant measuring practical artistry marks, student performance reflections, and teacher prep notes
- **Quadrant Owner**: Designated stakeholder responsible for data entry (E=Examiner, T=Teacher, S=Student)
- **Pie Chart Visualization**: Primary UI component displaying the four development quadrants as proportional segments
- **AI Feedback Engine**: Bedrock Nova-powered system for automated performance analysis
- **Conversational AI Coach**: Bedrock AgentCore-powered chatbot for student guidance
- **Mock Data**: Simulated student/assessment data for hackathon demonstration

### B. AWS Service Summary

| Service | Purpose | Configuration |
|---------|---------|---------------|
| Amazon Bedrock | AI-powered audio analysis and conversational agent | Nova Pro for analysis, Nova Lite for chat |
| Amazon Cognito | User authentication and authorization | User Pool with 3 groups (students/teachers/admins) |
| AWS Lambda | Serverless compute for API logic | Node.js 20.x, 512MB-1GB memory |
| API Gateway | REST API management | REST API with Lambda authorizer |
| DynamoDB | NoSQL database for profiles, recordings, conversations | On-demand capacity, 3 tables |
| RDS PostgreSQL | Relational database for assessments and exams | db.t3.micro, 20GB storage |
| Amazon S3 | Object storage for audio files and static hosting | 3 buckets with encryption |
| CloudFront | CDN for frontend delivery | HTTPS only, caching enabled |
| CloudWatch | Logging and monitoring | Custom dashboard + alarms |
| AWS CDK | Infrastructure as code | TypeScript, modular stacks |

### C. Mock Data Schema

#### CSV Format: Student Profiles
```csv
studentId,email,firstName,lastName,instrument,program,enrollmentDate,technicalSkillsScore,musicianshipScore,repertoireScore,performingArtistryScore
stu-001,alice.johnson@example.com,Alice,Johnson,Piano,Tertiary,2024-09-01,85,78,82,90
stu-002,bob.smith@example.com,Bob,Smith,Violin,Junior,2025-01-15,72,81,68,75
stu-003,carol.davis@example.com,Carol,Davis,Vocals,Tertiary,2024-09-01,88,92,85,94
stu-004,david.lee@example.com,David,Lee,Cello,Junior,2025-01-15,79,74,80,77
stu-005,emma.wilson@example.com,Emma,Wilson,Flute,Exam Candidate,2024-06-01,91,87,89,93
```

**Column Definitions:**
- `technicalSkillsScore`: Technical Skills & Competence (0-100)
- `musicianshipScore`: Compositional & Musicianship Knowledge (0-100)
- `repertoireScore`: Repertoire & Cultural Knowledge (0-100)
- `performingArtistryScore`: Performing Artistry (0-100)

#### JSON Format: Exam Results
```json
{
  "examResults": [
    {
      "examResultId": "exam-001",
      "studentId": "stu-001",
      "examDate": "2025-06-15",
      "examType": "RIAM Grade 7",
      "instrument": "Piano",
      "technicalScore": 88,
      "musicalInterpretationScore": 82,
      "overallGrade": "Distinction",
      "piecesPerformed": [
        {
          "title": "Prelude in C Major",
          "composer": "J.S. Bach",
          "score": 90
        }
      ],
      "examinerFeedback": "Excellent technical control. Work on dynamic contrasts."
    }
  ]
}
```

### D. API Postman Collection

Available at: `/docs/accordo-ai-postman-collection.json`

Includes:
- All API endpoints with sample requests
- Environment variables for dev/hackathon/prod
- Pre-request scripts for authentication
- Test assertions for validation

### E. Demo Video Script

**Duration: 10 minutes**

```
[0:00-1:00] Introduction
- Problem: Fragmented music education data
- Solution: Accordo AI unified platform
- Architecture overview

[1:00-2:00] Student Login & Dashboard
- Show authentication flow
- Navigate to dashboard
- Highlight three development scores

[2:00-4:00] Upload & AI Feedback
- Upload performance recording
- Show processing status
- Display AI feedback with technical/expressive scores
- Highlight actionable recommendations

[4:00-6:00] Digital Passport
- Navigate to passport view
- Explore progress timeline
- Show milestone achievements
- Demonstrate PDF export

[6:00-7:30] AI Coach Interaction
- Start goal-setting conversation
- Show contextual responses
- Demonstrate reflection dialogue
- Highlight conversation history

[7:30-8:30] Teacher Portal
- Switch to teacher account
- View student dashboard
- Validate AI feedback
- Show cohort analytics

[8:30-9:30] Technical Deep Dive
- AWS architecture diagram
- Bedrock integration highlights
- Mock data pipeline demonstration
- Security & scalability considerations

[9:30-10:00] Global Impact & Next Steps
- Applicability to other institutions
- Post-hackathon roadmap
- Call to action
```

---

## Document Control

**Approval:**
- [ ] Technical Lead: _______________  Date: _______
- [ ] Product Owner: _______________  Date: _______
- [ ] AWS Technical Mentor: _________ Date: _______

**Revision History:**
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-11 | Team Accordo AI | Initial specification |

---

**END OF SPECIFICATION DOCUMENT**

For questions or clarifications, contact: hackathon-team@accordo-ai.dev
