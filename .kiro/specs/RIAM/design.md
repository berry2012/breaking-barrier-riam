# RIAM Accordo AI - System Design Document

## 1. Overview

### 1.1 System Purpose
RIAM Accordo AI is a comprehensive digital passport system for music education that tracks student development across four key dimensions using AI-powered feedback and coaching. The system integrates with existing RIAM infrastructure to provide personalized learning experiences for students, actionable insights for teachers, and comprehensive analytics for administrators.

### 1.2 Key Design Principles
- **Student-Centric**: All features prioritize student learning outcomes and engagement
- **AI-Enhanced, Human-Validated**: AI provides immediate feedback while teachers maintain oversight
- **Data-Driven Insights**: Every interaction generates actionable data for continuous improvement
- **Scalable Architecture**: Cloud-native design supports growth from pilot to full deployment
- **Privacy-First**: Student data protection and GDPR compliance built into every component

### 1.3 Success Metrics
- Student engagement: 80% weekly active usage
- AI feedback accuracy: 85% teacher validation rate
- System performance: <3s page load times, 99.9% uptime
- Educational impact: Measurable improvement in student development scores

## 2. Architecture

### 2.1 High-Level Architecture

The system follows a serverless, event-driven architecture on AWS:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Student UI    │    │   Teacher UI    │    │    Admin UI     │
│   (React SPA)   │    │   (React SPA)   │    │   (React SPA)   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │     CloudFront CDN       │
                    │   (Content Delivery)     │
                    └─────────────┬─────────────┘
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
│ - Student Data │    │ - Audio/Video     │    │ - Nova Pro (AI)   │
│ - Recordings   │    │ - Feedback PDFs   │    │ - AgentCore       │
│ - Conversations│    │ - Static Assets   │    │   (Coaching)      │
│ - Checklists   │    │                   │    │                   │
└────────────────┘    └───────────────────┘    └───────────────────┘
        │
┌───────▼────────┐
│   RDS PostgreSQL  │
│ - Exam Results     │
│ - Teacher Data     │
│ - Practice Logs    │
│ - Assessments      │
└────────────────────┘
```

### 2.2 Technology Stack

**Frontend:**
- React 18 with TypeScript
- Tailwind CSS + Shadcn/ui components
- Recharts for data visualization
- Wavesurfer.js for audio waveform display
- React Query for state management and caching

**Backend:**
- AWS Lambda (Node.js 20.x runtime)
- API Gateway for REST endpoints
- DynamoDB for real-time data (student profiles, recordings, conversations, checklists)
- RDS PostgreSQL for structured data (exam results, teacher assessments, practice logs)
- S3 for file storage (audio/video recordings, feedback PDFs)
- CloudFront for content delivery

**AI/ML Services:**
- Amazon Bedrock Nova Pro for audio analysis
- Amazon Bedrock AgentCore Nova Lite for conversational AI
- Custom prompt engineering for music education context

**Infrastructure:**
- CloudFormation for Infrastructure as Code
- CloudWatch for monitoring and logging
- AWS X-Ray for distributed tracing
- AWS Cognito for authentication (future enhancement)

### 2.2.1 Database Architecture Rationale

**Hybrid Database Strategy:**
The system employs a hybrid database approach optimized for different data access patterns:

**DynamoDB (NoSQL) for:**
- **Student profiles and real-time data**: Fast reads/writes for dashboard updates
- **Recording metadata and AI feedback**: Flexible schema for evolving AI analysis results
- **Conversation history**: Document-based storage for chat sessions
- **Teacher checklists**: Term-based assessments with flexible skill structures

**RDS PostgreSQL (Relational) for:**
- **Exam results and assessments**: Structured data requiring complex queries and reporting
- **Teacher data and assignments**: Relational data with foreign key constraints
- **Practice logs**: Time-series data requiring aggregation and analytics
- **Historical reporting**: Complex joins and analytical queries

**Design Decision Rationale:**
- **Performance**: DynamoDB provides single-digit millisecond latency for user-facing features
- **Scalability**: NoSQL handles variable load patterns and rapid scaling requirements
- **Analytics**: PostgreSQL enables complex reporting and data analysis for teachers/admins
- **Data Integrity**: Relational constraints ensure consistency for critical educational data
- **Cost Optimization**: Right-sized storage for different data types and access patterns

### 2.3 Data Flow Architecture

**Recording Analysis Flow:**
1. Student uploads audio/video → S3 bucket
2. S3 event triggers Lambda function
3. Lambda determines media type and invokes appropriate Bedrock Nova Pro analysis
4. For video: Multimodal analysis combines audio + visual assessment
5. Results stored in DynamoDB with media-specific feedback
6. Student notified via real-time updates
7. Teacher receives validation request

**Video Analysis Enhancement:**
- **Audio Track Extraction**: Video files processed for audio analysis using existing pipeline
- **Visual Analysis**: Frame sampling for posture, technique, and stage presence assessment
- **Multimodal Integration**: Combined audio-visual feedback with timestamp correlation
- **Progressive Enhancement**: Video analysis as optional enhancement to core audio functionality

**AI Coaching Flow:**
1. Student initiates chat session
2. API Gateway routes to coaching Lambda
3. Lambda retrieves student context from DynamoDB
4. Bedrock AgentCore generates contextual response
5. Conversation history persisted
6. Feedback ratings collected for model improvement

## 3. Components and Interfaces

### 3.1 Frontend Components

#### 3.1.1 Student Portal Components

**DashboardPage**
- Purpose: Primary landing page showing overview of student progress
- Key Features: Welcome header, score cards, activity feed, quick actions
- Data Dependencies: StudentProfile, RecentActivity, UpcomingGoals
- Performance: <2s initial load, cached data for subsequent visits

**DigitalPassportPage**
- Purpose: Comprehensive view of student's four-dimensional development
- Key Features: Interactive pie chart, timeline, milestones, export functionality
- Data Dependencies: StudentProfile, TimelineEvents, Milestones
- Design Decision: Pie chart as primary visualization to emphasize balanced development

**RecordingUploadPage**
- Purpose: Streamlined interface for submitting performance recordings
- Key Features: Drag-drop upload, metadata form, progress tracking, file type detection
- File Support: 
  - Audio (MP3, WAV, M4A ≤50MB) - Primary focus for MVP
  - Video (MP4, MOV ≤500MB) - Enhanced capability for multimodal analysis
- Upload Flow: File type auto-detection → appropriate metadata form → progress tracking
- Design Decision: Single-page flow to minimize friction, with conditional UI based on file type

**FeedbackViewPage**
- Purpose: Display AI-generated feedback with teacher validation
- Key Features: Audio player with waveform, score breakdown, recommendations
- Integration: Wavesurfer.js for precise timestamp-based feedback
- Design Decision: Side-by-side layout for audio and feedback to enable correlation

**AICoachChatPage**
- Purpose: Conversational interface for personalized coaching
- Key Features: Message history, typing indicators, feedback collection, quality monitoring
- Conversation Types: Goal-setting, reflection, progress review, motivation
- Feedback System: Thumbs up/down rating with optional text feedback for AI improvement
- Quality Metrics: Response ratings tracked for AI model optimization
- Design Decision: Separate conversation types to optimize AI prompt context

#### 3.1.2 Teacher Portal Components

**TeacherDashboardPage**
- Purpose: Overview of all assigned students with actionable insights
- Key Features: Student grid, cohort metrics, alerts, recent submissions
- Filtering: By instrument, score range, activity status, attention needed
- Design Decision: Card-based layout for quick visual scanning

**FeedbackValidationPage**
- Purpose: Review and validate AI-generated student feedback
- Key Features: Side-by-side audio/feedback view, validation controls, comments
- Workflow: Notification → Review → Validate/Revise → Student notification
- Design Decision: Streamlined validation to encourage teacher participation

**TeacherChecklistPage**
- Purpose: Standardized skill assessment using RIAM checklist system
- Key Features: Instrument-specific skill checklists, term-based tracking, progress indicators
- Assessment Types: Achieved (✔), Not Achieved (✖), Partial (⚪)
- Integration: Results feed into Technical Skills & Competence quadrant scoring
- Design Decision: Simplified checkbox interface with contextual prompts for consistency

### 3.2 Backend API Interfaces

#### 3.2.1 Student Management API

```typescript
// GET /api/students/{studentId}/profile
interface StudentProfileResponse {
  studentId: string;
  personalInfo: {
    firstName: string;
    lastName: string;
    email: string;
    instrument: string;
    program: "Junior" | "Tertiary" | "Exam Candidate";
    enrollmentDate: string;
  };
  developmentScores: {
    technicalSkillsCompetence: number;
    compositionalMusicianshipKnowledge: number;
    repertoireCulturalKnowledge: number;
    performingArtistry: number;
    lastUpdated: string;
  };
  recentActivity: Activity[];
  milestones: Milestone[];
}

// POST /api/students/{studentId}/recordings
interface RecordingUploadRequest {
  fileName: string;
  fileSize: number;
  contentType: string;
  metadata: {
    pieceTitle: string;
    composer: string;
    performanceType: "practice" | "performance" | "exam";
    notes?: string;
  };
}

interface RecordingUploadResponse {
  recordingId: string;
  uploadUrl: string;  // Pre-signed S3 URL
  expiresIn: number;
}
```

#### 3.2.2 AI Services API

```typescript
// POST /api/ai/analyze-recording
interface AnalysisRequest {
  recordingId: string;
  studentContext: {
    instrument: string;
    level: string;
    recentProgress: DevelopmentScores;
  };
}

interface AnalysisResponse {
  analysisId: string;
  status: "processing" | "completed" | "failed";
  mediaType: "audio" | "video";  // Indicates analysis type performed
  feedback?: {
    technicalAssessment: {
      score: number;
      strengths: string[];
      improvements: string[];
      specificIssues: Array<{
        timestamp: number;
        description: string;
        severity: "minor" | "moderate" | "major";
      }>;
    };
    expressiveAssessment: {
      score: number;
      musicality: number;
      interpretation: number;
      dynamics: number;
      recommendations: string[];
    };
    // Video-specific analysis (when mediaType = "video")
    visualAssessment?: {
      posture: number;
      technique: number;
      stagePresence: number;
      bodyMechanics: string[];
      visualCues: Array<{
        timestamp: number;
        observation: string;
        category: "posture" | "technique" | "expression" | "stage_presence";
      }>;
    };
    quadrantImpact: {
      technicalSkillsCompetence: number;
      compositionalMusicianshipKnowledge: number;
      repertoireCulturalKnowledge: number;
      performingArtistry: number;
    };
  };
}

// POST /api/ai/coach/chat
interface CoachChatRequest {
  sessionId?: string;
  conversationType: "goal-setting" | "reflection" | "progress" | "motivation";
  message: string;
  studentContext: {
    studentId: string;
    recentProgress: DevelopmentScores;
    recentActivity: Activity[];
    currentGoals: Goal[];
  };
}

interface CoachChatResponse {
  sessionId: string;
  response: string;
  suggestedFollowUps: string[];
  conversationContext: {
    messageCount: number;
    sessionDuration: number;
  };
}

// POST /api/ai/coach/feedback
interface CoachFeedbackRequest {
  sessionId: string;
  messageId: string;
  rating: "positive" | "negative";
  feedbackText?: string;
  category?: "unhelpful" | "repetitive" | "off-topic" | "inappropriate" | "other";
}

interface CoachFeedbackResponse {
  success: boolean;
  message: string;
  feedbackId: string;
}
```

#### 3.2.3 Teacher Validation API

```typescript
// GET /api/teacher/pending-validations
interface PendingValidationsResponse {
  validations: Array<{
    recordingId: string;
    studentName: string;
    instrument: string;
    pieceTitle: string;
    submittedAt: string;
    aiFeedback: AnalysisResponse["feedback"];
    priority: "high" | "medium" | "low";
  }>;
  totalCount: number;
}

// POST /api/teacher/validate-feedback
interface FeedbackValidationRequest {
  recordingId: string;
  status: "validated" | "needs_revision";
  teacherComments?: string;
  scoreAdjustments?: {
    technicalScore?: number;
    expressiveScore?: number;
  };
}
```

#### 3.2.4 Teacher Checklist API

```typescript
// GET /api/teacher/checklist-prompts/{instrument}
interface ChecklistPromptsResponse {
  instrument: string;
  standardPrompts: Array<{
    area: string;
    prompt: string;
    appliesTo: string[];
    notes?: string;
  }>;
  instrumentSpecific: Array<{
    skill: string;
    description: string;
  }>;
}

// POST /api/teacher/checklist-assessment
interface ChecklistAssessmentRequest {
  studentId: string;
  term: "Term 1" | "Term 2" | "Term 3";
  academicYear: string;
  instrument: string;
  checklist: {
    [skillName: string]: "achieved" | "not-achieved" | "partial";
  };
  notes?: string;
}

// GET /api/teacher/checklist-history/{studentId}
interface ChecklistHistoryResponse {
  studentId: string;
  assessments: Array<{
    term: string;
    academicYear: string;
    checklist: Record<string, string>;
    notes?: string;
    submittedAt: string;
  }>;
}
```

### 3.3 Data Storage Interfaces

#### 3.3.1 DynamoDB Table Design

**Students Table (PK: studentId)**
```typescript
interface StudentRecord {
  studentId: string;  // Partition Key
  personalInfo: PersonalInfo;
  developmentScores: DevelopmentScores;
  preferences: UserPreferences;
  createdAt: string;
  updatedAt: string;
  
  // GSI-1: email-index for login
  email: string;  // GSI-1 PK
}
```

**Recordings Table (PK: recordingId)**
```typescript
interface RecordingRecord {
  recordingId: string;  // Partition Key
  studentId: string;    // GSI-1 PK for student queries
  s3Key: string;
  metadata: RecordingMetadata;
  analysisStatus: "pending" | "processing" | "completed" | "failed";
  feedback?: AIFeedback;
  teacherValidation?: TeacherValidation;
  createdAt: string;    // GSI-1 SK for chronological sorting
  updatedAt: string;
}
```

**Conversations Table (PK: sessionId)**
```typescript
interface ConversationRecord {
  sessionId: string;     // Partition Key
  studentId: string;     // GSI-1 PK
  conversationType: ConversationType;
  messages: Array<{
    timestamp: string;
    sender: "student" | "ai";
    content: string;
    feedback?: "positive" | "negative";
    feedbackText?: string;
  }>;
  createdAt: string;     // GSI-1 SK
  lastMessageAt: string;
}
```

**TeacherChecklists Table (PK: studentId, SK: term)**
```typescript
interface TeacherChecklistRecord {
  studentId: string;     // Partition Key
  term: string;          // Sort Key: "2024-Term1", "2024-Term2", etc.
  teacherId: string;     // GSI-1 PK for teacher queries
  instrument: string;
  academicYear: string;
  
  checklist: {
    [skillName: string]: "achieved" | "not-achieved" | "partial";
  };
  
  // Calculated score contribution
  checklistScore: number;  // 0-100 based on achieved/partial/not-achieved
  
  notes?: string;
  submittedAt: string;    // GSI-1 SK for chronological sorting
  updatedAt: string;
}
```

#### 3.3.2 S3 Bucket Structure

```
riam-accordo-recordings/
├── audio/
│   ├── {studentId}/
│   │   ├── {recordingId}.mp3
│   │   ├── {recordingId}.wav
│   │   └── {recordingId}.m4a
├── video/
│   ├── {studentId}/
│   │   ├── {recordingId}.mp4
│   │   └── {recordingId}.mov
└── processed/
    ├── waveforms/
    │   └── {recordingId}.json
    └── thumbnails/
        └── {recordingId}.jpg
```

**S3 Lifecycle Policies:**
- Raw recordings: Transition to IA after 90 days, Glacier after 1 year
- Processed files: Retain in Standard for 30 days, then IA
- Temporary upload URLs: 1-hour expiration

## 4. Data Models

### 4.1 Core Domain Models

#### 4.1.1 Student Profile Model

```typescript
interface StudentProfile {
  studentId: string;
  personalInfo: {
    firstName: string;
    lastName: string;
    email: string;
    dateOfBirth?: string;
    instrument: string;
    program: "Junior" | "Tertiary" | "Exam Candidate";
    enrollmentDate: string;
    teacherId?: string;
  };
  
  developmentScores: {
    technicalSkillsCompetence: number;      // 0-100
    compositionalMusicianshipKnowledge: number; // 0-100
    repertoireCulturalKnowledge: number;    // 0-100
    performingArtistry: number;             // 0-100
    lastUpdated: string;
    history: Array<{
      date: string;
      scores: DevelopmentScores;
      source: "recording" | "exam" | "teacher_assessment";
    }>;
  };
  
  preferences: {
    notifications: boolean;
    publicProfile: boolean;
    dataSharing: boolean;
  };
  
  metadata: {
    createdAt: string;
    updatedAt: string;
    lastLoginAt?: string;
    totalRecordings: number;
    totalCoachingSessions: number;
  };
}
```

#### 4.1.2 Recording and Feedback Model

```typescript
interface Recording {
  recordingId: string;
  studentId: string;
  
  fileInfo: {
    fileName: string;
    fileSize: number;
    contentType: string;
    s3Key: string;
    duration?: number;  // seconds
  };
  
  metadata: {
    pieceTitle: string;
    composer: string;
    performanceType: "practice" | "performance" | "exam";
    notes?: string;
    recordedAt?: string;
  };
  
  analysisStatus: "pending" | "processing" | "completed" | "failed";
  
  feedback?: {
    analysisId: string;
    
    technicalAssessment: {
      overallScore: number;  // 0-100
      components: {
        accuracy: number;    // Pitch, rhythm accuracy
        technique: number;   // Instrument-specific technique
        timing: number;      // Tempo consistency
      };
      strengths: string[];
      improvements: string[];
      specificIssues: Array<{
        timestamp: number;   // seconds into recording
        description: string;
        severity: "minor" | "moderate" | "major";
        category: "pitch" | "rhythm" | "technique" | "dynamics";
      }>;
    };
    
    expressiveAssessment: {
      overallScore: number;  // 0-100
      components: {
        musicality: number;      // Musical understanding
        interpretation: number;  // Personal expression
        dynamics: number;        // Volume and articulation control
        phrasing: number;        // Musical sentence structure
      };
      recommendations: string[];
      highlights: Array<{
        timestamp: number;
        description: string;
        category: "interpretation" | "dynamics" | "phrasing" | "style";
      }>;
    };
    
    quadrantImpact: {
      technicalSkillsCompetence: number;           // -10 to +10
      compositionalMusicianshipKnowledge: number;  // -10 to +10
      repertoireCulturalKnowledge: number;         // -10 to +10
      performingArtistry: number;                  // -10 to +10
    };
    
    generatedAt: string;
    processingTimeMs: number;
  };
  
  teacherValidation?: {
    teacherId: string;
    status: "validated" | "needs_revision";
    comments?: string;
    scoreAdjustments?: {
      technicalScore?: number;
      expressiveScore?: number;
    };
    validatedAt: string;
  };
  
  createdAt: string;
  updatedAt: string;
}
```

#### 4.1.3 AI Coaching Session Model

```typescript
interface CoachingSession {
  sessionId: string;
  studentId: string;
  conversationType: "goal-setting" | "reflection" | "progress" | "motivation";
  
  messages: Array<{
    messageId: string;
    timestamp: string;
    sender: "student" | "ai";
    content: string;
    
    // For AI messages only
    confidence?: number;     // 0-1, AI confidence in response
    processingTimeMs?: number;
    
    // For student feedback on AI messages
    feedback?: {
      rating: "positive" | "negative";
      feedbackText?: string;
      submittedAt: string;
    };
  }>;
  
  context: {
    studentSnapshot: {
      currentScores: DevelopmentScores;
      recentActivity: Activity[];
      activeGoals: Goal[];
      strugglingAreas: string[];
    };
    conversationGoals: string[];  // What the session aims to achieve
    keyTopics: string[];          // Main topics discussed
  };
  
  outcomes?: {
    goalsSet: Goal[];
    insightsGenerated: string[];
    recommendedActions: string[];
    followUpScheduled?: string;
  };
  
  metadata: {
    createdAt: string;
    lastMessageAt: string;
    messageCount: number;
    sessionDurationMs: number;
    studentSatisfaction?: number;  // 1-5 rating
  };
}
```

### 4.2 Supporting Models

#### 4.2.1 Activity and Timeline Models

```typescript
interface Activity {
  activityId: string;
  studentId: string;
  type: "recording_uploaded" | "feedback_received" | "goal_set" | "milestone_achieved" | "coaching_session";
  
  title: string;
  description: string;
  
  relatedEntities: {
    recordingId?: string;
    sessionId?: string;
    goalId?: string;
    milestoneId?: string;
  };
  
  impact?: {
    quadrantChanges: Partial<DevelopmentScores>;
    significance: "minor" | "moderate" | "major";
  };
  
  timestamp: string;
}

interface Milestone {
  milestoneId: string;
  studentId: string;
  
  title: string;
  description: string;
  category: "technical" | "musical" | "repertoire" | "performance";
  
  criteria: {
    requiredScore?: number;
    requiredActivities?: string[];
    timeframe?: string;
  };
  
  status: "not_started" | "in_progress" | "achieved";
  achievedAt?: string;
  
  reward?: {
    badgeIcon: string;
    badgeColor: string;
    points: number;
  };
}
```

#### 4.2.2 Mock Data Integration Models

```typescript
interface MockDataImport {
  importId: string;
  source: "student_profiles" | "exam_results" | "teacher_assessments";
  
  fileInfo: {
    fileName: string;
    fileSize: number;
    format: "csv" | "json";
    s3Key: string;
  };
  
  processing: {
    status: "pending" | "processing" | "completed" | "failed";
    startedAt?: string;
    completedAt?: string;
    
    summary?: {
      totalRecords: number;
      successfulRecords: number;
      failedRecords: number;
      warnings: string[];
    };
    
    errors?: Array<{
      rowNumber?: number;
      field?: string;
      message: string;
      severity: "error" | "warning";
    }>;
  };
  
  mapping: {
    [csvColumn: string]: string;  // Maps CSV columns to data model fields
  };
  
  createdAt: string;
  updatedAt: string;
}
```

### 4.3 Data Relationships and Constraints

#### 4.3.1 Referential Integrity
- **Student → Recordings**: One-to-many, cascade delete recordings when student deleted
- **Recording → Feedback**: One-to-one, feedback deleted with recording
- **Student → CoachingSessions**: One-to-many, sessions retained for analytics even if student deleted
- **Teacher → Students**: Many-to-many through assignment table

#### 4.3.2 Data Validation Rules
- **Development Scores**: Must be 0-100, sum should be meaningful for pie chart display
- **Recording Files**: Size limits enforced at API Gateway (50MB audio, 500MB video)
- **Email Addresses**: Must be unique across all students and teachers
- **Timestamps**: All dates in ISO 8601 format with UTC timezone
- **Student IDs**: Format "stu-{6-digit-number}" for consistency with mock data

#### 4.3.3 Data Retention Policies
- **Student Data**: Retained indefinitely unless deletion requested
- **Recording Files**: Raw files archived after 1 year, metadata retained
- **Coaching Sessions**: Full history retained for AI model improvement
- **Feedback Data**: Retained for longitudinal analysis and model training
- **Audit Logs**: 7-year retention for compliance

## 5. Correctness Properties

### 5.1 Functional Correctness Properties

#### 5.1.1 Authentication and Authorization
**Property**: Role-based access control must be enforced across all system components
- Students can only access their own digital passport data
- Teachers can only view progress for assigned students
- Admin users have system-wide access with audit logging

**Verification Methods**:
- JWT token validation on every API request with role claims
- Database queries include user-specific filtering
- API Gateway authorizer functions validate permissions

**Test Strategy**:
- Automated tests for token validation and unauthorized access attempts
- Cross-user data access prevention testing
- Role escalation attack simulation

#### 5.1.2 Digital Passport Data Integrity
**Property**: Student development scores must remain consistent across all system views
- All four dimensions (Technical Skills, Musicianship, Repertoire, Performing Artistry) display current scores
- Pie chart percentages accurately reflect score proportions
- Trend indicators correctly show improving/stable/declining status
- Score updates from AI feedback are atomic and consistent

**Verification Methods**:
- Database constraints ensuring scores remain within 0-100 range
- Application-level validation for score calculations
- Cross-component data consistency checks

**Test Strategy**:
- Integration tests for score calculation and updates
- Concurrent update testing to prevent race conditions
- Data consistency validation across UI components

#### 5.1.3 Recording Upload and Processing Workflow
**Property**: File upload and AI analysis pipeline must handle all supported formats correctly
- Support MP3, WAV, M4A files up to 50MB
- Support MP4, MOV files up to 500MB
- Upload metadata (piece name, composer, performance type) must be captured
- Recordings appear in "My Recordings" list immediately
- Processing status updates in real-time until completion

**Verification Methods**:
- File type and size validation at API Gateway level
- S3 event triggers for processing pipeline
- DynamoDB status tracking with timestamps

**Test Strategy**:
- Boundary testing with maximum file sizes
- Invalid file format rejection testing
- Processing pipeline failure recovery testing

#### 5.1.4 AI Feedback Generation Accuracy
**Property**: AI-generated feedback must meet quality and completeness standards
- Technical assessment includes accuracy, timing, technique scores
- Expressive assessment includes musicality, interpretation, dynamics scores
- Specific issues highlighted with precise timestamps
- 3-5 actionable recommendations provided per recording
- Feedback achieves 85% teacher validation rate

**Verification Methods**:
- Teacher validation tracking in database
- Feedback completeness validation (all required fields present)
- Quality metrics aggregation and reporting

**Test Strategy**:
- A/B testing with different AI models and prompts
- Baseline accuracy testing with validated recordings
- Teacher feedback correlation analysis

#### 5.1.5 Conversational AI Coaching Quality
**Property**: AI coaching conversations must provide contextually relevant and helpful responses
- Four conversation types available: goal-setting, reflection, progress, motivation
- Responses reference recent recordings and progress data
- Contextually relevant suggestions based on student profile
- Chat history preserved and accessible
- Feedback rating system captures user satisfaction

**Verification Methods**:
- Response relevance scoring based on student context
- Conversation continuity validation
- User satisfaction metrics tracking

**Test Strategy**:
- Dialogue quality testing with predefined scenarios
- Context awareness validation across conversation turns
- User feedback analysis and model improvement

### 5.2 Performance Properties

#### 5.2.1 Response Time Requirements
**Property**: System must meet strict performance benchmarks for user experience
- Page loads complete within 3 seconds (US-1)
- AI feedback generation completes within 30 seconds (US-3)
- AI coach responses complete within 5 seconds per message (US-4)
- Report generation completes within 10 seconds (US-8)
- Dashboard refresh occurs every 30 seconds (US-10)

**Verification Methods**:
- CloudWatch metrics for API response times
- Real User Monitoring (RUM) for frontend performance
- Lambda function duration tracking
- Custom performance metrics for AI services

**Test Strategy**:
- Load testing under various user scenarios
- Performance regression testing in CI/CD pipeline
- Real-world network condition simulation

#### 5.2.2 Concurrent User Support
**Property**: System must handle concurrent users without performance degradation
- Support 10 concurrent users for hackathon demo
- Architecture designed for 1000+ concurrent users (future scaling)
- No performance degradation under expected load

**Verification Methods**:
- Load testing with realistic user behavior patterns
- Database connection pooling and throttling monitoring
- API Gateway throttling and caching effectiveness

**Test Strategy**:
- Gradual load increase testing with monitoring
- Stress testing to identify breaking points
- Concurrent file upload and processing testing

#### 5.2.3 File Processing Performance
**Property**: File upload and processing must provide responsive user experience
- Upload progress feedback every 100ms
- Processing status updates in real-time
- Large file handling without timeout errors

**Verification Methods**:
- S3 multipart upload progress tracking
- WebSocket connections for real-time updates
- Processing queue depth monitoring

**Test Strategy**:
- Large file upload testing (up to size limits)
- Network interruption recovery testing
- Processing queue backlog handling

### 5.3 Data Consistency and Integrity Properties

#### 5.3.1 Score Calculation Accuracy
**Property**: All score calculations must be mathematically correct and consistent
- Development scores calculated using defined weighting algorithms
- Historical progress trends accurately computed
- Pie chart segments reflect actual score proportions
- Score updates maintain referential integrity

**Verification Methods**:
- Mathematical validation of scoring algorithms
- Database transaction integrity for score updates
- Cross-reference calculations between components

**Test Strategy**:
- Unit tests for all scoring algorithms
- Integration tests for score update workflows
- Data consistency validation across time periods

#### 5.3.2 Data Validation and Constraints
**Property**: All data inputs must meet defined validation rules
- Scores within 0-100 range enforced
- File size limits strictly enforced (50MB audio, 500MB video)
- Required metadata fields validated before submission
- Email addresses unique across system

**Verification Methods**:
- Database constraints and triggers
- API Gateway request validation
- Application-level validation with error reporting

**Test Strategy**:
- Boundary value testing for all numeric inputs
- Invalid data injection testing
- Duplicate data prevention testing

### 5.4 Security and Privacy Properties

#### 5.4.1 Data Protection
**Property**: All sensitive data must be protected according to privacy regulations
- Student data encrypted at rest and in transit
- File uploads validated for type and content security
- User input sanitized to prevent XSS attacks
- JWT tokens validated and expired appropriately

**Verification Methods**:
- AWS service encryption configurations (DynamoDB, S3)
- HTTPS enforcement across all endpoints
- Input sanitization validation
- Token expiration and refresh testing

**Test Strategy**:
- Security scanning and penetration testing
- Data encryption verification
- Authentication bypass attempt testing

#### 5.4.2 Access Control Enforcement
**Property**: User access must be strictly controlled based on roles and assignments
- Students cannot access other students' data
- Teachers limited to assigned students only
- Admin functions require appropriate permissions
- Session management handles token expiration correctly

**Verification Methods**:
- Database row-level security policies
- API endpoint authorization testing
- Session timeout and cleanup validation

**Test Strategy**:
- Cross-user data access prevention testing
- Privilege escalation attack simulation
- Session hijacking prevention testing

### 5.5 Availability and Reliability Properties

#### 5.5.1 System Uptime and Resilience
**Property**: System must maintain high availability with graceful error handling
- 99% uptime during hackathon demo period
- Graceful degradation when AI services unavailable
- Retry logic for transient failures
- Circuit breaker pattern for external service protection

**Verification Methods**:
- CloudWatch uptime monitoring and alerting
- Health check endpoints for all services
- Error rate tracking and alerting

**Test Strategy**:
- Chaos engineering and failover testing
- Service dependency failure simulation
- Recovery time measurement

#### 5.5.2 Data Persistence and Recovery
**Property**: All critical data must be persistently stored and recoverable
- Recordings and feedback stored with redundancy
- Chat history preserved across sessions
- Import/export maintains data integrity
- Backup and recovery procedures validated

**Verification Methods**:
- Multi-AZ database replication
- S3 cross-region replication for recordings
- Automated backup verification

**Test Strategy**:
- Disaster recovery drills
- Data corruption recovery testing
- Backup restoration validation

### 5.6 AI Quality and Monitoring Properties

#### 5.6.1 AI Feedback Quality Assurance
**Property**: AI-generated content must meet educational quality standards
- Feedback accuracy validated by music education experts
- Inappropriate content filtered out
- Response confidence scoring tracked
- Continuous improvement through teacher validation

**Verification Methods**:
- Teacher validation rate tracking (target: 85%)
- Content filtering and safety checks
- Quality metrics dashboard and reporting

**Test Strategy**:
- Expert validation of AI feedback samples
- Content safety testing with edge cases
- Model performance regression testing

#### 5.6.2 Conversation Quality Monitoring
**Property**: AI coaching conversations must maintain educational value and safety
- Responses relevant to student musical context
- Conversation context maintained throughout sessions
- User satisfaction metrics tracked
- Feedback incorporation for model improvement

**Verification Methods**:
- Conversation quality scoring algorithms
- User feedback aggregation and analysis
- Context continuity validation

**Test Strategy**:
- Dialogue quality assessment with education experts
- Long conversation context preservation testing
- User satisfaction correlation analysis

### 5.7 Integration and Interoperability Properties

#### 5.7.1 Mock Data Integration Accuracy
**Property**: Legacy system data integration must preserve data integrity
- CSV/JSON imports validated before processing
- Import summaries accurate (records processed, errors, warnings)
- Failed records logged with detailed error information
- Rollback capability for critical import errors

**Verification Methods**:
- Data validation rules applied during import
- Import audit logging and error tracking
- Data consistency checks post-import

**Test Strategy**:
- Large dataset import testing
- Malformed data handling testing
- Import rollback and recovery testing

#### 5.7.2 Export and Reporting Accuracy
**Property**: Generated reports and exports must accurately reflect system data
- Report data matches source database records
- Visual charts render correctly with accurate data
- Export formats (PDF, CSV) preserve data integrity
- Date range filtering works correctly

**Verification Methods**:
- Data consistency validation between reports and source
- Export format validation and parsing tests
- Chart rendering accuracy verification

**Test Strategy**:
- Report accuracy validation against known datasets
- Export/import round-trip testing
- Visual regression testing for charts and reports

## 6. Error Handling

### 6.1 Error Classification

#### 6.1.1 User Errors (4xx)
**File Upload Errors:**
- **400 Bad Request**: Invalid file format or metadata
- **413 Payload Too Large**: File exceeds size limits (50MB audio, 500MB video)
- **415 Unsupported Media Type**: File type not in allowed list

**Authentication Errors:**
- **401 Unauthorized**: Invalid or expired JWT token
- **403 Forbidden**: User lacks permission for requested resource

**Validation Errors:**
- **422 Unprocessable Entity**: Valid format but invalid data (e.g., scores >100)

#### 6.1.2 System Errors (5xx)
**AI Service Errors:**
- **502 Bad Gateway**: Bedrock service unavailable
- **504 Gateway Timeout**: AI analysis taking longer than 60 seconds

**Database Errors:**
- **500 Internal Server Error**: DynamoDB connection failures
- **503 Service Unavailable**: Database capacity exceeded

### 6.2 Error Response Format

```typescript
interface ErrorResponse {
  error: {
    code: string;           // Machine-readable error code
    message: string;        // Human-readable error message
    details?: any;          // Additional context for debugging
    timestamp: string;      // ISO 8601 timestamp
    requestId: string;      // Unique identifier for tracking
  };
  
  // For validation errors
  validationErrors?: Array<{
    field: string;
    message: string;
    rejectedValue?: any;
  }>;
}
```

**Example Error Responses:**

```json
// File upload error
{
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "Audio file size exceeds 50MB limit",
    "details": {
      "fileSize": 52428800,
      "maxSize": 52428800,
      "fileType": "audio/mp3"
    },
    "timestamp": "2025-01-12T10:30:00Z",
    "requestId": "req-abc123"
  }
}

// AI service error
{
  "error": {
    "code": "AI_ANALYSIS_TIMEOUT",
    "message": "Audio analysis is taking longer than expected. Please try again.",
    "details": {
      "recordingId": "rec-xyz789",
      "processingTimeMs": 65000
    },
    "timestamp": "2025-01-12T10:30:00Z",
    "requestId": "req-def456"
  }
}
```

### 6.3 Error Recovery Strategies

#### 6.3.1 Retry Logic
**Exponential Backoff for AI Services:**
```typescript
const retryConfig = {
  maxRetries: 3,
  baseDelay: 1000,      // 1 second
  maxDelay: 10000,      // 10 seconds
  backoffMultiplier: 2
};

async function analyzeRecordingWithRetry(recordingId: string) {
  for (let attempt = 1; attempt <= retryConfig.maxRetries; attempt++) {
    try {
      return await bedrockAnalysis(recordingId);
    } catch (error) {
      if (attempt === retryConfig.maxRetries) throw error;
      
      const delay = Math.min(
        retryConfig.baseDelay * Math.pow(retryConfig.backoffMultiplier, attempt - 1),
        retryConfig.maxDelay
      );
      
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

#### 6.3.2 Circuit Breaker Pattern
**AI Service Circuit Breaker:**
```typescript
class AIServiceCircuitBreaker {
  private failureCount = 0;
  private lastFailureTime = 0;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  
  private readonly failureThreshold = 5;
  private readonly recoveryTimeout = 60000; // 1 minute
  
  async execute<T>(operation: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() - this.lastFailureTime > this.recoveryTimeout) {
        this.state = 'HALF_OPEN';
      } else {
        throw new Error('AI service temporarily unavailable');
      }
    }
    
    try {
      const result = await operation();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onSuccess() {
    this.failureCount = 0;
    this.state = 'CLOSED';
  }
  
  private onFailure() {
    this.failureCount++;
    this.lastFailureTime = Date.now();
    
    if (this.failureCount >= this.failureThreshold) {
      this.state = 'OPEN';
    }
  }
}
```

### 6.4 User Experience Error Handling

#### 6.4.1 Progressive Error Disclosure
**Upload Error Flow:**
1. **Immediate Validation**: File type/size checked before upload starts
2. **Progress Feedback**: Upload progress bar with cancel option
3. **Graceful Degradation**: If upload fails, offer retry or alternative format suggestion
4. **Contextual Help**: Link to supported formats and troubleshooting guide

#### 6.4.2 Error Recovery Actions
**AI Analysis Failure:**
- **Automatic Retry**: System attempts 3 retries with exponential backoff
- **User Notification**: "Analysis in progress, this may take a few moments..."
- **Fallback Option**: "Analysis taking longer than expected. We'll notify you when complete."
- **Manual Retry**: "Try Again" button after final failure

#### 6.4.3 Error Monitoring and Alerting
**CloudWatch Alarms:**
- **High Error Rate**: >5% of API requests returning 5xx errors
- **AI Service Failures**: >10% of Bedrock requests failing
- **Upload Failures**: >15% of file uploads failing
- **Database Errors**: Any DynamoDB throttling or capacity errors

**Alert Escalation:**
1. **Immediate**: Slack notification to development team
2. **5 minutes**: Email to technical lead
3. **15 minutes**: SMS to on-call engineer
4. **30 minutes**: Escalation to product manager

### 6.5 Data Integrity Error Handling

#### 6.5.1 Database Transaction Failures
**Score Update Consistency:**
```typescript
async function updateStudentScores(studentId: string, newScores: DevelopmentScores) {
  const transactionItems = [
    {
      Update: {
        TableName: 'Students',
        Key: { studentId },
        UpdateExpression: 'SET developmentScores = :scores, updatedAt = :timestamp',
        ExpressionAttributeValues: {
          ':scores': newScores,
          ':timestamp': new Date().toISOString()
        }
      }
    },
    {
      Put: {
        TableName: 'ScoreHistory',
        Item: {
          studentId,
          timestamp: new Date().toISOString(),
          scores: newScores,
          source: 'ai_feedback'
        }
      }
    }
  ];
  
  try {
    await dynamodb.transactWrite({ TransactItems: transactionItems }).promise();
  } catch (error) {
    if (error.code === 'TransactionCanceledException') {
      // Handle conditional check failures or conflicts
      throw new Error('Score update conflict - please refresh and try again');
    }
    throw error;
  }
}
```

#### 6.5.2 File Corruption Detection
**Recording Integrity Validation:**
```typescript
async function validateRecordingIntegrity(s3Key: string): Promise<boolean> {
  try {
    const headObject = await s3.headObject({
      Bucket: 'riam-accordo-recordings',
      Key: s3Key
    }).promise();
    
    // Check if file exists and has expected metadata
    if (!headObject.ContentLength || headObject.ContentLength === 0) {
      throw new Error('Recording file is empty or corrupted');
    }
    
    // For audio files, attempt to read metadata
    if (s3Key.includes('/audio/')) {
      const audioMetadata = await extractAudioMetadata(s3Key);
      if (!audioMetadata.duration || audioMetadata.duration < 1) {
        throw new Error('Recording appears to be corrupted - no audio detected');
      }
    }
    
    return true;
  } catch (error) {
    console.error('Recording validation failed:', error);
    return false;
  }
}
```

## 7. Testing Strategy

### 7.1 Testing Pyramid

#### 7.1.1 Unit Tests (70% of test coverage)
**Frontend Component Tests:**
- React component rendering and interaction
- State management and prop handling
- User input validation and form submission
- Chart rendering and data visualization

**Backend Function Tests:**
- Lambda function logic and error handling
- Data transformation and validation
- Business rule implementation
- Mock external service dependencies

**Test Framework:** Jest + React Testing Library for frontend, Jest + AWS SDK mocks for backend

#### 7.1.2 Integration Tests (20% of test coverage)
**API Integration Tests:**
- End-to-end API workflows (upload → analysis → feedback)
- Database operations and data consistency
- S3 file operations and lifecycle management
- AI service integration with mocked responses

**Cross-Service Integration:**
- DynamoDB + Lambda integration
- S3 event triggers and processing
- API Gateway + Lambda routing

**Test Framework:** Jest with AWS SDK integration, LocalStack for local AWS services

#### 7.1.3 End-to-End Tests (10% of test coverage)
**Critical User Journeys:**
- Student registration and profile setup
- Recording upload and feedback receipt
- AI coaching conversation flow
- Teacher validation workflow

**Test Framework:** Playwright for browser automation, Cypress as alternative

### 7.2 AI/ML Testing Strategy

#### 7.2.1 AI Feedback Quality Testing
**Baseline Accuracy Testing:**
```typescript
interface AITestCase {
  recordingId: string;
  expectedFeedback: {
    technicalScore: number;
    expressiveScore: number;
    keyIssues: string[];
    strengths: string[];
  };
  teacherValidation: {
    validated: boolean;
    comments: string;
  };
}

// Test suite with 100+ validated recordings
const aiAccuracyTests: AITestCase[] = [
  {
    recordingId: "test-violin-001",
    expectedFeedback: {
      technicalScore: 75,
      expressiveScore: 82,
      keyIssues: ["intonation", "bow_pressure"],
      strengths: ["rhythm", "dynamics"]
    },
    teacherValidation: {
      validated: true,
      comments: "Accurate assessment of technical issues"
    }
  }
  // ... more test cases
];
```

**A/B Testing Framework:**
- **Model Comparison**: Test different Bedrock models (Nova Pro vs alternatives)
- **Prompt Engineering**: Compare different prompt strategies
- **Confidence Scoring**: Track AI confidence vs teacher validation correlation

#### 7.2.2 Conversational AI Testing
**Dialogue Quality Metrics:**
- **Relevance**: AI responses address student questions appropriately
- **Consistency**: AI maintains context throughout conversation
- **Helpfulness**: Responses provide actionable guidance
- **Safety**: No inappropriate or harmful content generated

**Test Scenarios:**
```typescript
const coachingTestScenarios = [
  {
    conversationType: "goal-setting",
    studentContext: {
      instrument: "piano",
      currentScores: { technical: 65, expressive: 78 },
      strugglingAreas: ["scales", "sight-reading"]
    },
    expectedOutcomes: [
      "specific_goal_suggested",
      "timeline_provided",
      "practice_strategy_recommended"
    ]
  }
  // ... more scenarios
];
```

### 7.3 Performance Testing

#### 7.3.1 Load Testing Scenarios
**Concurrent User Testing:**
- **Baseline**: 10 concurrent users performing typical actions
- **Peak Load**: 100 concurrent users during high-usage periods
- **Stress Test**: 200+ users to identify breaking points

**Recording Upload Load Testing:**
- **File Size Variation**: Test with 1MB, 10MB, 50MB files
- **Concurrent Uploads**: Multiple students uploading simultaneously
- **AI Processing Queue**: Ensure analysis queue handles backlog gracefully

#### 7.3.2 Performance Benchmarks
**Response Time Targets:**
- **Page Load**: <3 seconds for initial dashboard load
- **API Responses**: <1 second for data retrieval
- **File Upload**: Progress feedback every 100ms
- **AI Analysis**: <60 seconds for audio processing

**Monitoring Implementation:**
```typescript
// CloudWatch custom metrics
const performanceMetrics = {
  apiResponseTime: new CloudWatchMetric('API/ResponseTime'),
  aiProcessingTime: new CloudWatchMetric('AI/ProcessingTime'),
  uploadSuccessRate: new CloudWatchMetric('Upload/SuccessRate'),
  userEngagement: new CloudWatchMetric('User/SessionDuration')
};

// Performance tracking middleware
const trackPerformance = (metricName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const startTime = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - startTime;
      performanceMetrics[metricName].putMetric(duration);
    });
    
    next();
  };
};
```

### 7.4 Security Testing

#### 7.4.1 Authentication and Authorization Testing
**JWT Token Security:**
- **Token Expiration**: Verify tokens expire after configured time
- **Token Tampering**: Ensure modified tokens are rejected
- **Role-Based Access**: Students cannot access other students' data
- **Teacher Permissions**: Teachers only see assigned students

#### 7.4.2 Data Protection Testing
**Input Validation:**
- **SQL Injection**: Test with malicious input patterns (though using DynamoDB)
- **XSS Prevention**: Ensure user input is properly sanitized
- **File Upload Security**: Validate file types and scan for malware
- **Data Encryption**: Verify encryption at rest and in transit

#### 7.4.3 Privacy Compliance Testing
**GDPR Compliance:**
- **Data Deletion**: Verify complete data removal on request
- **Data Export**: Ensure all user data can be exported
- **Consent Management**: Track and respect user consent preferences
- **Data Minimization**: Only collect necessary data

### 7.5 Accessibility Testing

#### 7.5.1 WCAG 2.1 AA Compliance
**Automated Testing:**
- **axe-core**: Integrated into component tests
- **Lighthouse**: Accessibility scoring in CI/CD pipeline
- **Color Contrast**: Verify 4.5:1 ratio for normal text

**Manual Testing:**
- **Screen Reader**: Test with NVDA/JAWS/VoiceOver
- **Keyboard Navigation**: All functionality accessible via keyboard
- **Focus Management**: Logical tab order and visible focus indicators

#### 7.5.2 Inclusive Design Testing
**Audio Content Accessibility:**
- **Transcription**: Provide text alternatives for audio feedback
- **Visual Indicators**: Waveform visualization for hearing-impaired users
- **Captions**: Video recordings include caption support

### 7.6 Test Data Management

#### 7.6.1 Mock Data Strategy
**Realistic Test Data:**
- **Student Profiles**: Diverse instruments, skill levels, demographics
- **Recording Samples**: Various quality levels and common issues
- **Teacher Feedback**: Range of validation scenarios

**Data Privacy:**
- **Synthetic Data**: Generated data that mimics real patterns
- **Anonymization**: Remove PII from production data used in testing
- **Data Masking**: Obscure sensitive information in test environments

#### 7.6.2 Test Environment Management
**Environment Isolation:**
- **Development**: Local testing with LocalStack
- **Staging**: Full AWS environment with test data
- **Production**: Live environment with monitoring

**Data Refresh Strategy:**
- **Daily**: Refresh staging with anonymized production data
- **On-Demand**: Reset test data for specific test scenarios
- **Cleanup**: Automated removal of test data after test completion

This comprehensive testing strategy ensures the RIAM Accordo AI system meets quality, performance, and security requirements while providing an excellent user experience for students, teachers, and administrators.