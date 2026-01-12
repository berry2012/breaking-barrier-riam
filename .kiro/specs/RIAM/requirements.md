# RIAM Accordo AI - Technical Specification Document
## AWS Breaking Barriers Challenge 2026 - Hackathon MVP


### 1.1 Project Overview
**Accordo AI** is an intelligent digital passport and coaching system for music education that unifies student progress tracking, provides AI-powered performance feedback, and enables conversational coaching at scale.

### Glossary

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

### 1.2 Problem Statement
RIAM faces fragmented learning across 35,000+ students with no unified framework connecting:
- Teacher assessments
- Exam performance data
- Student reflections
- Performance recordings (video/audio)
- Progress tracking

### 1.3 Solution
A three-pillar MVP demonstrating:
1. **Digital Passport**: Unified student development tracking
2. **AI Feedback Engine**: Automated performance analysis using Amazon Bedrock Nova
3. **Conversational AI Coach**: Personalized guidance via Bedrock AgentCore

### 1.4 Hackathon Constraints
- **Scope**: Working MVP with mock data (5 sample students)
- **Target**: Demonstrate global applicability for music education sector

---

## 2. Project Scope

### 2.1 In-Scope Features

#### MVP Phase 1 - Core Features (Must Have)
- ✅ Digital Passport with 4 development dimensions (RIAM Quadrant Model)
- ✅ AI-powered audio performance feedback (5-10 sample recordings)
- ✅ Conversational AI coaching agent (3 dialogue scenarios)
- ✅ Mock data integration pipeline
- ✅ Student, Teacher, Admin portals
- ✅ Authentication and role-based access
- ✅ Basic progress visualization (pie chart + timeline)
- ✅ Audio file upload and storage (MP3, WAV, M4A)

#### MVP Phase 2 - Enhanced Features (Should Have)
- ✅ Advanced analytics dashboard
- ✅ Feedback history tracking and search
- ✅ Teacher validation workflow
- ✅ PDF export functionality
- ✅ Practice streak gamification

#### Post-MVP - Advanced Features (Nice to Have)
- 🔄 **Video feedback capability** (multimodal audio + visual analysis)
- 🔄 Video file upload and storage (MP4, MOV)
- 🔄 Video playback with timestamp markers
- 🔄 Visual assessment (posture, body mechanics, stage presence)
- 🔄 Complex weighted scoring algorithms
- 🔄 Advanced progress analytics

### 2.2 Out-of-Scope (Post-Hackathon)
- ❌ Real RIAM system integration
- ❌ Mobile applications
- ❌ Multi-language support
- ❌ Custom ML model training
- ❌ Live production deployment
- ❌ Payment/subscription systems
- ❌ Advanced scheduling features
- ❌ Real-time collaborative features
- ❌ Advanced security features (2FA, SSO)

---

## 3. System Architecture

### 3.1 High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Student UI    │    │   Teacher UI    │    │    Admin UI     │
│   (React SPA)   │    │   (React SPA)   │    │   (React SPA)   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │     API Gateway          │
                    │   (Authentication +      │
                    │    Route Management)     │
                    └─────────────┬─────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │    Lambda Functions      │
                    │  - Student Management    │
                    │  - Recording Processing  │
                    │  - AI Feedback           │
                    │  - Analytics             │
                    └─────────────┬─────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                       │                        │
┌───────▼────────┐    ┌─────────▼─────────┐    ┌─────────▼─────────┐
│   DynamoDB     │    │    Amazon S3      │    │  Amazon Bedrock   │
│ - Student Data │    │ - Audio Files     │    │ - Nova Pro (AI)   │
│ - Recordings   │    │ - Feedback PDFs   │    │ - AgentCore       │
│ - Conversations│    │ - Static Assets   │    │   (Coaching)      │
└────────────────┘    └───────────────────┘    └───────────────────┘
        │
┌───────▼────────┐
│   RDS (PostgreSQL) │
│ - Exam Results     │
│ - Teacher Data     │
│ - Practice Logs    │
└────────────────────┘
```

### 3.2 Data Flow

1. **Authentication**: Cognito handles user auth, returns JWT tokens
2. **File Upload**: Student uploads audio → S3 → triggers Lambda
3. **AI Processing**: Lambda calls Bedrock Nova → stores feedback in DynamoDB
4. **Score Calculation**: Simple averaging algorithm updates quadrant scores
5. **Coaching**: AgentCore maintains conversation context in DynamoDB

### 3.3 Simplified Scoring Algorithm (MVP)

```typescript
// Simplified scoring for hackathon demo
function calculateQuadrantScore(measures: QuadrantMeasures): number {
  const weights = {
    examinerMark: 0.6,    // 60% - if available
    teacherMark: 0.3,     // 30% - if available  
    studentInput: 0.1     // 10% - reflections, logs, etc.
  };
  
  let totalScore = 0;
  let totalWeight = 0;
  
  if (measures.examinerMark) {
    totalScore += measures.examinerMark * weights.examinerMark;
    totalWeight += weights.examinerMark;
  }
  
  if (measures.teacherMark) {
    totalScore += measures.teacherMark * weights.teacherMark;
    totalWeight += weights.teacherMark;
  }
  
  if (measures.studentInputScore) {
    totalScore += measures.studentInputScore * weights.studentInput;
    totalWeight += weights.studentInput;
  }
  
  return totalWeight > 0 ? Math.round(totalScore / totalWeight) : 0;
}
```

---

## 5. API Specifications

### 5.1 Core API Endpoints

#### Authentication
```typescript
POST /auth/login
Body: { email: string, password: string }
Response: { token: string, user: UserProfile, expiresIn: number }

POST /auth/refresh
Headers: { Authorization: "Bearer <token>" }
Response: { token: string, expiresIn: number }
```

#### Student Management
```typescript
GET /api/students/{studentId}/profile
Headers: { Authorization: "Bearer <token>" }
Response: StudentProfile

PUT /api/students/{studentId}/profile
Body: Partial<StudentProfile>
Response: { success: boolean, updatedProfile: StudentProfile }
```

#### Recording Management
```typescript
POST /api/recordings/upload
Headers: { Authorization: "Bearer <token>" }
Body: FormData { file: File, metadata: RecordingMetadata }
Response: { recordingId: string, uploadUrl: string, status: "uploaded" }

GET /api/recordings/{recordingId}/feedback
Response: { feedback: AIFeedback, status: "completed" | "processing" | "failed" }
```

#### AI Coaching
```typescript
POST /api/coach/sessions
Body: { conversationType: string, initialMessage?: string }
Response: { sessionId: string, response: string, messageId: string }

POST /api/coach/sessions/{sessionId}/messages
Body: { message: string }
Response: { response: string, messageId: string, context: ConversationContext }

POST /api/coach/messages/{messageId}/feedback
Body: { rating: "positive" | "negative", comment?: string }
Response: { success: boolean, message: "Feedback recorded" }
```

### 5.2 Error Handling Strategy

#### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid/expired token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `429` - Rate Limited
- `500` - Internal Server Error
- `503` - Service Unavailable (AI services down)

#### Error Response Format
```typescript
interface ErrorResponse {
  error: {
    code: string;           // "VALIDATION_ERROR", "AI_SERVICE_UNAVAILABLE"
    message: string;        // Human-readable message
    details?: any;          // Additional context
    retryAfter?: number;    // Seconds to wait before retry
  };
  requestId: string;        // For debugging
}
```

#### Fallback Strategies
```typescript
// AI Service Fallback
if (bedrockUnavailable) {
  return {
    feedback: "AI analysis temporarily unavailable. Your recording has been saved and will be processed when service resumes.",
    status: "queued",
    estimatedProcessingTime: "15-30 minutes"
  };
}

// Graceful Degradation
if (coachingServiceDown) {
  return {
    response: "I'm having trouble connecting right now. Try asking: 'What should I practice today?' or 'How can I improve my technique?'",
    suggestedActions: ["Upload a recording", "View your progress", "Set a practice goal"]
  };
}
```

---

## 6. Mock Data Package

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


## 7. Technical Requirements

### 7.1 Functional Requirements

#### FR-1: User Authentication
- **FR-1.1**: Users must authenticate via Amazon Cognito
- **FR-1.2**: Support three roles: Student, Teacher, Admin
- **FR-1.3**: Role-based access control (RBAC) for all endpoints
- **FR-1.4**: Session management 

#### FR-2: Digital Passport
- **FR-2.1**: Display student profile with four development dimensions
- **FR-2.2**: Calculate scores: Technical Skills & Competence, Compositional & Musicianship Knowledge, Repertoire & Cultural Knowledge, Performing Artistry
- **FR-2.3**: Show historical progress timeline
- **FR-2.4**: Support CRUD operations for student data

#### FR-3: AI Feedback Engine
- **FR-3.1**: Accept audio file uploads (MP3, WAV, M4A formats)
- **FR-3.2**: Process recordings (Audio or Video) with Amazon Bedrock Nova
- **FR-3.3**: Generate technical and expressive assessments
- **FR-3.4**: Store feedback history linked to student profile
- **FR-3.5**: Display actionable recommendations
- **FR-3.6**: Accept video file uploads (MP4, MOV formats)

#### FR-4: Conversational AI Coach
- **FR-4.1**: Implement chat interface for student-AI interaction
- **FR-4.2**: Support four dialogue types: goal-setting, reflection, progress, motivation
- **FR-4.3**: Maintain conversation context using Bedrock AgentCore
- **FR-4.4**: Store conversation history in DynamoDB
- **FR-4.5**: Provide thumbs up/down feedback mechanism for AI responses
- **FR-4.6**: Store user feedback for AI response quality improvement

#### FR-5: Mock Data Integration
- **FR-5.1**: Ingest simulated RIAM Exams data
- **FR-5.2**: Ingest mock LMS engagement metrics
- **FR-5.3**: Ingest sample reflective journals
- **FR-5.4**: Transform and unify into standardized schema

#### FR-6: Analytics Dashboard
- **FR-6.1**: Aggregate student progress metrics
- **FR-6.2**: Display cohort-level insights (teacher/admin view)
- **FR-6.3**: Generate basic reports (PDF/CSV export)

### 7.2 Non-Functional Requirements

#### NFR-1: Performance
- **NFR-1.1**: API response time < 2 seconds (excluding AI processing)
- **NFR-1.2**: AI feedback generation < 30 seconds per recording
- **NFR-1.3**: Frontend initial load < 3 seconds

#### NFR-2: Scalability
- **NFR-2.1**: Support 10 concurrent users (hackathon demo)
- **NFR-2.2**: Architecture designed for 1000+ concurrent users (future)

#### NFR-3: Security
- **NFR-3.1**: All API endpoints require authentication
- **NFR-3.2**: Audio/video recordings encrypted at rest (S3 encryption)
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

## 8. Data Models

### 8.1 DynamoDB Tables

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
  format: string;                      // "mp3" | "wav" | "m4a"
  
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
    messageId: string;                 // UUID for individual message tracking
    userFeedback?: {                   // Thumbs up/down feedback
      rating: "positive" | "negative";
      timestamp: string;
      comment?: string;                // Optional text feedback
    };
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

#### Table: AIFeedbackAnalytics
```typescript
interface AIFeedbackAnalytics {
  PK: string;                          // "ANALYTICS#FEEDBACK"
  SK: string;                          // "DATE#<YYYY-MM-DD>"
  date: string;                        // YYYY-MM-DD
  
  // Daily aggregated metrics
  totalResponses: number;
  positiveRatings: number;
  negativeRatings: number;
  responseRate: number;                // % of messages that received feedback
  
  // Breakdown by conversation type
  byConversationType: {
    [key: string]: {                   // "goal-setting", "reflection", etc.
      total: number;
      positive: number;
      negative: number;
      avgRating: number;
    };
  };
  
  // Common feedback themes (from negative comments)
  commonIssues: Array<{
    theme: string;                     // "unhelpful", "repetitive", "off-topic"
    count: number;
    examples: string[];                // Sample user comments
  }>;
  
  createdAt: string;
  updatedAt: string;
}
```

### 8.2 RDS PostgreSQL Schema

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

### 8.3 Teacher Checklist Prompt Library

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

---

## 9. User Stories & Acceptance Criteria

### 9.1 Student User Stories

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
**I want to** upload my practice recordings  (video or audio)
**So that** I can receive AI-powered feedback on my performance

**Acceptance Criteria:**
- [ ] Student can upload MP3, WAV, or M4A files up to 50MB
- [ ] Student can upload MP4, or MOV files up to 500MB
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
- [ ] Student can rate AI responses with thumbs up/down
- [ ] Student can optionally add text feedback explaining their rating
- [ ] Feedback is stored and contributes to AI improvement metrics

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

### 9.2 Teacher User Stories

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

### 9.3 Admin User Stories

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

#### US-11: Monitor AI Feedback Quality
**As an** admin  
**I want to** view AI coaching feedback metrics  
**So that** I can monitor and improve AI response quality

**Acceptance Criteria:**
- [ ] Dashboard shows thumbs up/down ratios for AI responses
- [ ] Breakdown by conversation type (goal-setting, reflection, etc.)
- [ ] Recent negative feedback with user comments
- [ ] Trending topics in user feedback
- [ ] Export feedback data for AI model improvement
- [ ] Filter by date range and student demographics

---

## 10. Frontend Specifications

### 10.1 Design System

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

### 10.2 Page Components

#### Student Dashboard (`/dashboard`)
```typescript
interface StudentDashboardProps {
  student: StudentProfile;
  recentActivity: Activity[];
  upcomingGoals: Goal[];
}

Components:
- WelcomeHeader (personalized greeting)
- DevelopmentScoreCards (3 dimension scores with sparklines)
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
- DimensionDetailCards (expandable cards for each dimension)
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
- FileDropzone (drag-drop audio file upload)
- MetadataForm (piece, composer, level, type)
- UploadProgressBar
- PreviewPlayer (playback before upload)
- SubmitButton (with loading state)
```

#### Feedback View Page (`/recordings/{id}/feedback`)
```typescript
interface FeedbackPageProps {
  recording: Recording;
  feedback: AIFeedback;
  teacherReview?: TeacherReview;
}

Components:
- AudioPlayer (waveform visualization with Wavesurfer.js)
- ScoreOverview (summary scores with progress bars)
- QuadrantImpactIndicator (shows which quadrants this feedback affects)
- TechnicalAnalysis (expandable section with issue markers)
- ExpressiveAnalysis (expandable section with strength markers)
- RecommendationsList (actionable next steps mapped to relevant quadrants)
- TeacherComments (if validated)
- ShareButton (share feedback via link)
```

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
- MessageFeedback (thumbs up/down buttons for each AI response)
- FeedbackModal (optional text feedback when thumbs down is clicked)
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

### 10.3 Responsive Breakpoints
```css
/* Mobile First */
--mobile: 0px;
--tablet: 768px;
--desktop: 1024px;
--wide: 1440px;
```

### 10.4 Component Library
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

### 10.5 Quadrant Pie Chart Implementation

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

## 11. AI/ML Integration

### 11.1 Amazon Bedrock Configuration
- **Model Selection**:
  - **Audio Analysis**: Bedrock Nova Pro for detailed performance feedback
  - **Conversational AI**: Bedrock AgentCore Nova Lite for coaching interactions

### 11.2 Audio Analysis Workflow

```typescript
// Simplified audio analysis for MVP
interface AudioAnalysisRequest {
  s3Key: string;
  studentContext: {
    instrument: string;
    level: string;
    piece: string;
    composer: string;
  };
}

interface AudioAnalysisResponse {
  technicalScore: number;      // 0-100
  expressiveScore: number;     // 0-100
  recommendations: string[];
  issues: Array<{
    timestamp: number;
    description: string;
    severity: "minor" | "moderate" | "major";
  }>;
}
```

### 11.3 Conversation Flow Examples

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
```

**Reflective Prompts:**
```
Agent: "I noticed you uploaded a recording of [Piece] today. 
How did you feel about that performance?"

Student: "I messed up the middle section"

Agent: "It's great that you're being self-aware. The AI analysis shows 
you actually nailed the tempo and dynamics there. What specifically felt off to you?"
```



## 12. Deployment Strategy

### 12.1 Infrastructure as Code
- **CloudFormation templates** for AWS resource provisioning
- **Separate stacks** for different environments (dev, staging, demo)
- **Parameter-driven** configuration for easy environment switching

### 12.2 CI/CD Pipeline
```yaml
# Simplified deployment pipeline
stages:
  - build:
      - Frontend: React build → S3 static hosting
      - Backend: Lambda function packaging
  - test:
      - Unit tests for Lambda functions
      - Integration tests for API endpoints
  - deploy:
      - CloudFormation stack update
      - Database migrations (if needed)
      - Smoke tests
```

### 12.3 Monitoring & Observability
- **CloudWatch Logs** for Lambda function logging
- **CloudWatch Metrics** for API Gateway and DynamoDB
- **X-Ray tracing** for request flow visualization
- **Custom dashboards** for key business metrics

---

## 13. Appendices

### A. Mock Data Schema

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