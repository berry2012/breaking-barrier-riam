# RIAM Accordo AI - Video Feedback Feature Specification

## Overview
The video feedback feature extends the RIAM Accordo AI platform to support **multimodal performance analysis** using Amazon Bedrock Nova's video analysis capabilities. Students can upload video recordings of their performances to receive comprehensive feedback on both **audio** (sound quality, technique, musicality) and **visual** (posture, body mechanics, stage presence) aspects of their performance.

---

## Why Video Analysis?

### Educational Benefits
✅ **Holistic Assessment**: Captures what audio alone cannot - posture, technique visibility, stage presence  
✅ **Self-Awareness**: Students see themselves perform, developing metacognitive skills  
✅ **Technique Correction**: Visual identification of issues (tense shoulders, incorrect finger position, poor bow hold)  
✅ **Performance Skills**: Develops stage presence, audience connection, professional presentation  
✅ **Remote Learning**: Teachers can provide detailed feedback on technique without in-person observation  

### Quadrant Mapping
Video analysis contributes to **2 primary quadrants**:

| Visual Assessment | Quadrant | Weight |
|-------------------|----------|--------|
| Posture + Body Mechanics | **Technical Skills & Competence** | 30% |
| Instrument Handling | **Technical Skills & Competence** | 10% |
| Stage Presence | **Performing Artistry** | 40% |
| Audio Technical | **Technical Skills & Competence** | 60% |
| Audio Expressive | **Performing Artistry** | 60% |

---

## Technical Specifications

### 1. Supported Video Formats

#### File Formats
- ✅ MP4 (Recommended - best compatibility)
- ✅ MOV (Apple/iOS devices)
- ✅ WEBM (Web-optimized)
- ✅ AVI (Legacy support)

#### Technical Limits
- **Maximum file size**: 500MB
- **Maximum duration**: 5 minutes (300 seconds)
- **Recommended resolution**: 1080p (1920x1080)
- **Minimum resolution**: 720p (1280x720)
- **Frame rate**: 24-60 fps (30 fps recommended)
- **Codec**: H.264 or H.265

#### Quality Guidelines
**Good Quality Recording:**
- Student fully visible (head to waist minimum, full body preferred)
- Instrument clearly visible
- Good lighting (no harsh shadows)
- Stable camera (tripod or stable surface)
- Clear audio (built-in microphone acceptable)
- No distracting background

**Avoid:**
- Blurry or shaky footage
- Student partially out of frame
- Dark or poorly lit recordings
- Extreme close-ups that hide body posture
- Loud background noise

---

### 2. Video Processing Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Upload                                              │
│ • Student selects video file (drag-drop or file picker)    │
│ • File validation (format, size, duration)                 │
│ • Metadata entry (piece, composer, performance type)       │
│ • Pre-signed S3 URL generated                              │
│ • Upload with progress tracking                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Pre-processing (Lambda)                            │
│ • Extract video frames (1 frame per second)                │
│ • Extract audio track separately                           │
│ • Generate thumbnail at 30 seconds                         │
│ • Detect resolution, fps, codec                            │
│ • Validate video quality (lighting, framing)               │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: AI Analysis (Amazon Bedrock Nova)                  │
│ • Multimodal input: frames + audio stream + prompt         │
│ • Nova Pro model processes video (max 300 frames)          │
│ • Analysis time: ~4-6 minutes for 3-minute video           │
│ • Generates comprehensive feedback (audio + visual)        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: Storage & Notification                             │
│ • Store feedback in DynamoDB (PerformanceRecordings table) │
│ • Update student quadrant scores                           │
│ • Send notification to student (email + in-app)            │
│ • Notify teacher for validation                            │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: Student Views Feedback                             │
│ • Video player with timestamp markers                      │
│ • Audio scores (technical + expressive)                    │
│ • Visual scores (posture + mechanics + presence)           │
│ • Timestamped observations (clickable)                     │
│ • Recommendations + next steps                             │
└─────────────────────────────────────────────────────────────┘
```

---

### 3. AI Analysis Components

#### A. Audio Analysis (Same as Audio-Only Recordings)

**Technical Assessment (0-100)**:
- Accuracy: Pitch and note correctness
- Timing: Rhythm precision and tempo stability
- Technique: Instrumental technique quality (as heard)

**Expressive Assessment (0-100)**:
- Musicality: Musical interpretation and phrasing
- Interpretation: Understanding of style and composer intent
- Dynamics: Range and control of volume
- Phrasing: Musical shape and breath/bow management

#### B. Visual Assessment (Video-Specific)

**Posture (0-100)**:
- Body alignment and balance
- Relaxed shoulders
- Head and neck position
- Standing/sitting stability
- Energy and alertness

**Body Mechanics (0-100)** - Instrument-Specific:

| Instrument | Body Mechanics Evaluated |
|------------|-------------------------|
| **Violin/Strings** | Bow arm movement, left hand position, finger placement, vibrato execution, shifting technique |
| **Flute/Woodwind** | Embouchure formation, breath support visibility, finger technique, hand position |
| **Piano** | Hand position, wrist alignment, finger curvature, pedaling technique, arm weight usage |
| **Trumpet/Brass** | Embouchure, breath support visibility, valve technique, posture for air support |
| **Voice** | Breath support visibility (diaphragm), jaw relaxation, throat openness, body engagement |

**Stage Presence (0-100)**:
- Confidence and composure
- Eye contact with audience
- Facial expression (connection to music)
- Body language (open vs. closed)
- Professional presentation
- Entry and exit demeanor

**Instrument Handling (0-100)**:
- Proper instrument hold/positioning
- Setup and preparation
- Transitions between sections
- Technical adjustments during performance
- Care and respect for instrument

#### C. Timestamped Observations

AI generates 5-8 specific observations with timestamps:

**Example Observation Object**:
```json
{
  "timestamp": 48,
  "category": "mechanics",
  "description": "Right hand fingers slightly tense during fast passage - more relaxation needed",
  "severity": "needs-attention"
}
```

**Categories**:
- `posture`: Body alignment, balance, relaxation
- `mechanics`: Instrument-specific technique visibility
- `presence`: Stage presence, audience connection, confidence
- `handling`: Instrument setup, positioning, care

**Severity Levels**:
- `excellent`: Highlight strengths to continue
- `good`: Solid performance, minor refinement possible
- `needs-attention`: Area requiring focused improvement

---

### 4. Frontend Components

#### Video Upload Page (`/recordings/upload`)

**Media Type Selector**:
```tsx
<ToggleGroup type="single" value={mediaType} onValueChange={setMediaType}>
  <ToggleGroupItem value="audio">
    <MicIcon /> Audio Only
  </ToggleGroupItem>
  <ToggleGroupItem value="video">
    <VideoIcon /> Video Performance
  </ToggleGroupItem>
</ToggleGroup>
```

**Video-Specific Features**:
- 📹 **Camera recording option**: Record directly from webcam (browser MediaRecorder API)
- 🗜️ **Compression option**: Reduce file size while maintaining quality (FFmpeg.js)
- 🖼️ **Thumbnail preview**: Auto-generated from video at 30 seconds
- ⏱️ **Duration warning**: Alert if video exceeds 5 minutes
- 📊 **Resolution display**: Show video resolution (720p, 1080p, 4K)
- 📏 **File size indicator**: Real-time upload progress with estimated time

**Upload Progress**:
```tsx
<Progress value={uploadProgress} />
<p>{uploadProgress}% • {formatFileSize(uploadedBytes)} / {formatFileSize(totalBytes)}</p>
<p>Estimated time remaining: {formatTime(estimatedTime)}</p>
```

#### Video Feedback Page (`/recordings/{id}/feedback`)

**Layout**:
```
┌─────────────────────────────────────────────────────────────┐
│ Header: Student Name | Piece | Date | Teacher Validation   │
├──────────────────────────────┬──────────────────────────────┤
│                              │                              │
│  VIDEO PLAYER                │  SCORE OVERVIEW              │
│  (Main viewing area)         │  • Quadrant Pie Chart        │
│  • Timestamp markers         │  • Audio Scores              │
│  • Playback controls         │  • Visual Scores             │
│  • Speed controls (0.5x-2x)  │  • Overall Rating            │
│                              │                              │
├──────────────────────────────┴──────────────────────────────┤
│ TIMESTAMPED OBSERVATIONS (Timeline View)                    │
│ ━━━━━━●━━━━━●━━━●━━━━━━━●━━━━●━━━━━━━                     │
│ Click markers to jump to specific feedback moments           │
├─────────────────────────────────────────────────────────────┤
│ TABS:                                                        │
│ [Technical] [Expressive] [Visual] [Recommendations] [Notes] │
│                                                              │
│ Content area with expandable sections                       │
└─────────────────────────────────────────────────────────────┘
```

**Video Player Features**:
```tsx
<VideoPlayer
  src={videoUrl}
  timestamps={observations.map(o => o.timestamp)}
  onTimestampClick={(time) => jumpTo(time)}
  features={{
    playbackSpeed: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
    frameByFrame: true,
    screenshot: true,
    pictureInPicture: true,
    loop: {
      enabled: true,
      start: loopStart,
      end: loopEnd
    }
  }}
/>
```

**Visual Assessment Display**:
```tsx
<Card>
  <CardHeader>
    <CardTitle>Visual Assessment</CardTitle>
  </CardHeader>
  <CardContent>
    <div className="grid grid-cols-2 gap-4">
      <ScoreCard 
        title="Posture" 
        score={visualAssessment.posture} 
        icon={<UserIcon />}
      />
      <ScoreCard 
        title="Body Mechanics" 
        score={visualAssessment.bodyMechanics} 
        icon={<ActivityIcon />}
      />
      <ScoreCard 
        title="Stage Presence" 
        score={visualAssessment.stagePresence} 
        icon={<SparklesIcon />}
      />
      <ScoreCard 
        title="Instrument Handling" 
        score={visualAssessment.instrumentHandling} 
        icon={<ToolIcon />}
      />
    </div>
    
    <Separator className="my-4" />
    
    <h4>Timestamped Observations</h4>
    <ObservationTimeline observations={visualAssessment.observations} />
  </CardContent>
</Card>
```

---

### 5. API Endpoints

#### POST /recordings/upload
```typescript
Request:
{
  file: File,                      // Video file
  mediaType: "video",
  studentId: "S02",
  piece: "Bach Minuet in G Major",
  composer: "J.S. Bach",
  repertoireLevel: "Grade 3",
  performanceType: "Recital"
}

Response:
{
  success: true,
  data: {
    recordingId: "S02-video-001",
    mediaType: "video",
    uploadUrl: "https://accordo-recordings.s3.amazonaws.com/...",
    expiresIn: 3600,
    maxFileSize: 524288000  // 500MB
  }
}
```

#### GET /recordings/{id}/feedback
```typescript
Response (for video):
{
  success: true,
  data: {
    recordingId: "S02-video-001",
    mediaType: "video",
    recording: {
      s3Url: "https://...",
      thumbnailUrl: "https://...",
      duration: 180,
      resolution: "1920x1080"
    },
    aiFeedback: {
      technicalAssessment: { ... },
      expressiveAssessment: { ... },
      visualAssessment: {              // VIDEO ONLY
        posture: 82,
        bodyMechanics: 75,
        stagePresence: 68,
        instrumentHandling: 80,
        overallScore: 76,
        observations: [
          {
            timestamp: 15,
            category: "posture",
            description: "Excellent standing posture - balanced, shoulders relaxed",
            severity: "excellent"
          },
          ...
        ]
      },
      recommendations: [...],
      nextSteps: [...]
    }
  }
}
```

---

### 6. Database Schema Updates

#### DynamoDB: PerformanceRecordings Table
```typescript
{
  PK: "STUDENT#S02",
  SK: "RECORDING#2025-01-10T14:30:00Z",
  recordingId: "S02-video-001",
  studentId: "S02",
  
  mediaType: "video",              // NEW FIELD
  format: "mp4",
  
  videoMetadata: {                 // NEW OBJECT (video only)
    resolution: "1920x1080",
    fps: 30,
    codec: "H.264",
    thumbnailS3Key: "recordings/S02/video/bach-minuet-thumb.jpg"
  },
  
  aiFeedback: {
    technicalAssessment: { ... },
    expressiveAssessment: { ... },
    visualAssessment: {            // NEW OBJECT (video only)
      posture: 82,
      bodyMechanics: 75,
      stagePresence: 68,
      instrumentHandling: 80,
      overallScore: 76,
      observations: [...]
    }
  }
}
```

---

### 7. Score Calculation Updates

#### Technical Skills & Competence (with video)
```typescript
const technicalScore = 
  (audioTechnical * 0.60) +              // 60% from audio technical
  (visual.posture * 0.10) +              // 10% from posture
  (visual.bodyMechanics * 0.20) +        // 20% from body mechanics
  (visual.instrumentHandling * 0.10);    // 10% from instrument handling

// Example: S02 (Conor Walsh - Flute)
// Audio Technical: 72
// Visual Posture: 82
// Visual Body Mechanics: 75
// Visual Instrument Handling: 80
// Score = (72*0.6) + (82*0.1) + (75*0.2) + (80*0.1)
//       = 43.2 + 8.2 + 15 + 8
//       = 74.4 → 74
```

#### Performing Artistry (with video)
```typescript
const artistryScore = 
  (audioExpressive * 0.60) +             // 60% from audio expressive
  (visual.stagePresence * 0.40);         // 40% from stage presence

// Example: S02 (Conor Walsh - Flute)
// Audio Expressive: 71
// Visual Stage Presence: 68
// Score = (71*0.6) + (68*0.4)
//       = 42.6 + 27.2
//       = 69.8 → 70
```

---

### 8. Mock Data

#### Sample Video Recordings
**Location**: `/mock-data/sample-video-recordings.json`

**Included Students**:
1. **S02 - Conor Walsh** (Flute, Intermediate)
   - Piece: Bach Minuet in G Major
   - Duration: 3:00
   - Scores: Technical 74, Artistry 70, Visual 76

2. **S03 - Ella Murphy** (Piano, Advanced)
   - Piece: Beethoven Sonatina Op. 49 No. 1
   - Duration: 4:00
   - Scores: Technical 85, Artistry 79, Visual 85

3. **S05 - Saoirse Nolan** (Voice, Young Artist)
   - Piece: Caro mio ben by Giordani
   - Duration: 3:15
   - Scores: Technical 88, Artistry 93, Visual 93

---

### 9. Implementation Roadmap

#### Hackathon (Day 1-3)
- ✅ **Day 1 Afternoon**: Update data models and API specs
- ✅ **Day 2 Morning**: Implement video upload endpoint with S3
- ✅ **Day 2 Afternoon**: Integrate Bedrock Nova for video analysis
- ✅ **Day 3 Morning**: Build video feedback UI component
- ✅ **Day 3 Afternoon**: Test with sample video, polish demo

#### Post-Hackathon Enhancements
- 📹 **Month 1-2**: Add webcam recording feature (browser-based)
- 🎬 **Month 2-3**: Implement video editing tools (trim, rotate)
- 📊 **Month 3-4**: Side-by-side video comparison (before/after progress)
- 🤖 **Month 4-6**: Advanced AI features (pose estimation, technique scoring)
- 📱 **Month 6-9**: Mobile app with video recording
- 🌍 **Month 9-12**: Multi-angle video support (2+ camera angles)

---

### 10. Cost Considerations

#### Storage Costs
- **Video storage**: $0.023 per GB/month (S3 Standard)
- **Average video**: 190MB → $0.0044/month per video
- **1000 videos**: ~190GB → $4.37/month

#### Processing Costs
- **Bedrock Nova Pro**: $0.30 per 1000 input tokens (video frames)
- **300 frames** (5-min video @ 1fps): ~$0.15 per analysis
- **1000 video analyses/month**: ~$150/month

#### Bandwidth Costs
- **Video download**: $0.09 per GB (S3 data transfer)
- **Average viewing**: 2x full video playback per student
- **1000 videos** (380MB total bandwidth): ~$0.034

**Total Estimated Cost (1000 videos/month)**:
- Storage: $4.37
- Processing: $150
- Bandwidth: $0.34
- **Total: ~$155/month** or **$0.15 per video**

---

### 11. Privacy & Security

#### Video Storage
- ✅ Encrypted at rest (S3 AES-256)
- ✅ Encrypted in transit (TLS/HTTPS)
- ✅ Pre-signed URLs with expiration (1 hour)
- ✅ Access logs enabled for auditing

#### Access Control
- ✅ Students can only view own videos
- ✅ Teachers can view assigned student videos
- ✅ Admins have full access
- ✅ Videos not publicly accessible

#### Data Retention
- ✅ Videos retained for 2 years
- ✅ Automatic archival to S3 Glacier after 6 months (cost savings)
- ✅ Student can request video deletion (GDPR compliance)
- ✅ AI feedback retained indefinitely (separated from video file)

---

### 12. User Stories

#### US-10: Upload Video Performance
**As a** student  
**I want to** upload a video of my performance  
**So that** I can receive feedback on both my sound and technique

**Acceptance Criteria**:
- [ ] Student can select video file from device
- [ ] System validates video format and size (max 500MB)
- [ ] System warns if video exceeds 5 minutes
- [ ] Upload progress bar shows percentage and estimated time
- [ ] Thumbnail is generated and displayed
- [ ] Video appears in "My Recordings" with "Processing" status
- [ ] Student receives notification when AI analysis completes (within 5-7 minutes)

#### US-11: View Video Feedback
**As a** student  
**I want to** watch my video with AI feedback annotations  
**So that** I can see specific moments where I need to improve

**Acceptance Criteria**:
- [ ] Video player displays with full controls (play/pause, seek, speed)
- [ ] Timestamp markers appear on timeline for observations
- [ ] Clicking timestamp marker jumps to that moment in video
- [ ] Visual assessment scores displayed (posture, body mechanics, presence, handling)
- [ ] Observations categorized by severity (excellent/good/needs-attention)
- [ ] Audio scores displayed alongside visual scores
- [ ] Recommendations integrate both audio and visual insights
- [ ] Video can be downloaded or shared via link

#### US-12: Teacher Validates Video Feedback
**As a** teacher  
**I want to** review AI video feedback and add my observations  
**So that** students receive comprehensive guidance

**Acceptance Criteria**:
- [ ] Teacher can view student video with AI analysis
- [ ] Teacher can mark AI feedback as "Validated" or "Needs Revision"
- [ ] Teacher can add timestamped comments on video
- [ ] Teacher can override specific AI scores if needed
- [ ] Teacher comments are visible to student
- [ ] Teacher can compare video to previous performances


## Conclusion

The video feedback feature represents a **major enhancement** to RIAM Accordo AI, providing students with comprehensive multimodal performance analysis that was previously only available through in-person lessons. By leveraging Amazon Bedrock Nova's video analysis capabilities, the platform delivers:

✅ **Holistic feedback** combining audio and visual assessment  
✅ **Timestamped observations** for precise technique improvement  
✅ **Scalable coaching** reaching 35,000+ students with personalized feedback  
✅ **Quadrant integration** updating Technical Skills & Performing Artistry scores  
✅ **Cost-effective** at $0.15 per video analysis  

This feature positions RIAM as a leader in AI-powered music education innovation with global applicability.
