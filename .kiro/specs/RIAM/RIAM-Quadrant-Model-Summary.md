# RIAM Accordo AI - Four Quadrant Model Summary

## Overview
The RIAM digital passport uses a **four-dimensional quadrant model** to assess student development holistically across music education competencies.

---

## The Four Quadrants

### 1️⃣ Technical Skills & Competence
**Purpose**: Measure practical instrumental/vocal technique and skill development

**Measures**:
| Data Point | Owner | Frequency | Format |
|------------|-------|-----------|--------|
| Practical Technique Mark | Examiner (E) | Annual assessment | /100 score |
| Teacher Technical Advice Entry | Teacher (T) | Weekly/fortnightly | Text bullets |
| Teacher Checklist (skills achieved) | Teacher (T) | Each term | Tick/partial tick list |

**Example Data**:
```typescript
technicalSkillsCompetence: {
  score: 85,
  practicalTechniqueMark: 88,
  teacherTechnicalAdvice: [
    "Work on bow control in detaché strokes",
    "Improve left-hand position shifts",
    "Practice scales with metronome at 80 BPM"
  ],
  teacherChecklist: {
    achieved: ["Major scales", "Arpeggios", "Vibrato"],
    partial: ["Double stops", "Harmonics"]
  }
}
```

---

### 2️⃣ Compositional & Musicianship Knowledge
**Purpose**: Assess theoretical understanding, aural skills, and creative musicianship

**Measures**:
| Data Point | Owner | Frequency | Format |
|------------|-------|-----------|--------|
| Musicianship Mark | Teacher (T) | Term or annual | /100 score |
| Aural Evidence Recording | Student (S) | Multiple per term | Audio clips (sing back/clap back/play back) |
| Creative/Reflective Note | Student/Teacher (S/T) | As needed | Short text for AI prompts |

**Example Data**:
```typescript
compositionalMusicianshipKnowledge: {
  score: 78,
  musicianshipMark: 82,
  auralEvidenceRecordings: [
    "s3://accordo/stu-001/aural/sing-back-001.mp3",
    "s3://accordo/stu-001/aural/clap-back-002.mp3"
  ],
  creativeReflectiveNotes: [
    "Student demonstrates strong melodic recall",
    "Working on harmonic interval recognition"
  ]
}
```

---

### 3️⃣ Repertoire & Cultural Knowledge
**Purpose**: Track exposure to diverse musical styles, historical context, and cultural awareness

**Measures**:
| Data Point | Owner | Frequency | Format |
|------------|-------|-----------|--------|
| Repertoire & Cultural Mark | Teacher (T) | Term or annual | /100 score |
| Listening Log | Student (S) | 2-4 per term | Structured log entries |
| Context/Meaning Note | Student (S) | 1-2 sentences each | Text linking listening to repertoire |

**Example Data**:
```typescript
repertoireCulturalKnowledge: {
  score: 82,
  repertoireCulturalMark: 85,
  listeningLogs: [
    {
      piece: "Brandenburg Concerto No. 3",
      composer: "J.S. Bach",
      date: "2025-01-05",
      notes: "Noticed the interweaving violin lines similar to my Vivaldi piece"
    },
    {
      piece: "The Rite of Spring",
      composer: "Igor Stravinsky",
      date: "2025-01-12",
      notes: "Completely different from Baroque - rhythmic complexity is intense"
    }
  ],
  contextMeaningNotes: [
    "Understanding Baroque counterpoint helps with my Bach Sonata interpretation",
    "20th century music shows how rhythm can be expressive beyond melody"
  ]
}
```

---

### 4️⃣ Performing Artistry
**Purpose**: Evaluate artistic expression, stage presence, and performance quality beyond technique

**Measures**:
| Data Point | Owner | Frequency | Format |
|------------|-------|-----------|--------|
| Practical Artistry Mark | Examiner (E) | Annual assessment | /100 score |
| Student Performance Reflection | Student (S) | After each performance | Structured reflection |
| Teacher Performance Prep Notes | Teacher (T) | Before performances/mock runs | Preparation guidance |

**Example Data**:
```typescript
performingArtistry: {
  score: 90,
  practicalArtistryMark: 93,
  studentPerformanceReflections: [
    {
      date: "2024-12-10",
      performance: "Winter Recital - Beethoven Sonata",
      reflection: "I felt nervous in the opening but found my flow in the second movement. I need to work on stage presence and connecting with the audience."
    }
  ],
  teacherPerformancePrepNotes: [
    "Focus on expressive dynamics in slow movement",
    "Practice mental preparation for performance nerves",
    "Remember to breathe between phrases"
  ]
}
```

---

## Score Aggregation Formula

Each quadrant aggregates its measures using weighted averages:

```typescript
function calculateQuadrantScore(quadrantData: QuadrantData): number {
  const weights = {
    examinerMarks: 0.60,    // 60% - External assessment
    teacherMarks: 0.30,     // 30% - Regular teacher evaluation
    studentContributions: 0.10  // 10% - Self-directed learning
  };
  
  let totalScore = 0;
  let totalWeight = 0;
  
  // Add examiner marks if present
  if (quadrantData.examinerMark !== null) {
    totalScore += quadrantData.examinerMark * weights.examinerMarks;
    totalWeight += weights.examinerMarks;
  }
  
  // Add teacher marks
  if (quadrantData.teacherMark !== null) {
    totalScore += quadrantData.teacherMark * weights.teacherMarks;
    totalWeight += weights.teacherMarks;
  }
  
  // Add student contributions (normalized to 0-100)
  const studentScore = normalizeStudentContributions(quadrantData);
  totalScore += studentScore * weights.studentContributions;
  totalWeight += weights.studentContributions;
  
  // Return weighted average
  return Math.round(totalScore / totalWeight);
}
```

---

## Pie Chart Calculation

The pie chart displays **relative strength** across all four quadrants:

```typescript
interface PieChartData {
  technicalSkillsCompetence: number;        // Percentage
  compositionalMusicianshipKnowledge: number;
  repertoireCulturalKnowledge: number;
  performingArtistry: number;
}

function calculatePieChartData(studentProfile: StudentProfile): PieChartData {
  const scores = {
    technical: studentProfile.technicalSkillsCompetence.score,
    musicianship: studentProfile.compositionalMusicianshipKnowledge.score,
    repertoire: studentProfile.repertoireCulturalKnowledge.score,
    artistry: studentProfile.performingArtistry.score
  };
  
  const total = scores.technical + scores.musicianship + scores.repertoire + scores.artistry;
  
  return {
    technicalSkillsCompetence: (scores.technical / total) * 100,
    compositionalMusicianshipKnowledge: (scores.musicianship / total) * 100,
    repertoireCulturalKnowledge: (scores.repertoire / total) * 100,
    performingArtistry: (scores.artistry / total) * 100
  };
}
```

**Example Output**:
```typescript
// Student with scores: Technical=85, Musicianship=78, Repertoire=82, Artistry=90
// Total = 335

pieChartData = {
  technicalSkillsCompetence: 25.4%,      // 85/335
  compositionalMusicianshipKnowledge: 23.3%,  // 78/335
  repertoireCulturalKnowledge: 24.5%,    // 82/335
  performingArtistry: 26.9%              // 90/335
}
```

---

## Visual Representation

```
                    RIAM Four Quadrant Model
                    
        ┌─────────────────────────────────────────┐
        │                                         │
        │     Technical Skills & Competence       │
        │     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━       │
        │     • Practical Technique Mark (E)      │
        │     • Teacher Technical Advice (T)      │
        │     • Skills Checklist (T)              │
        │                                         │
        ├─────────────────────────────────────────┤
        │                                         │
        │  Compositional & Musicianship Knowledge │
        │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
        │     • Musicianship Mark (T)             │
        │     • Aural Evidence Recordings (S)     │
        │     • Creative/Reflective Notes (S/T)   │
        │                                         │
        ├─────────────────────────────────────────┤
        │                                         │
        │   Repertoire & Cultural Knowledge       │
        │   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │
        │     • Repertoire & Cultural Mark (T)    │
        │     • Listening Logs (S)                │
        │     • Context/Meaning Notes (S)         │
        │                                         │
        ├─────────────────────────────────────────┤
        │                                         │
        │        Performing Artistry              │
        │        ━━━━━━━━━━━━━━━━━━              │
        │     • Practical Artistry Mark (E)       │
        │     • Student Performance Reflections(S)│
        │     • Teacher Performance Prep Notes(T) │
        │                                         │
        └─────────────────────────────────────────┘
        
        Legend:
        E = Examiner (External assessment)
        T = Teacher (Regular evaluation)
        S = Student (Self-directed learning)
```

---

## Integration with AI Feedback Engine

AI-generated feedback from Bedrock Nova automatically updates relevant quadrants:

| AI Analysis Component | Updates Quadrant |
|-----------------------|------------------|
| Technical Assessment (accuracy, timing, technique) | Technical Skills & Competence |
| Expressive Assessment (musicality, interpretation) | Performing Artistry |
| Repertoire Recognition | Repertoire & Cultural Knowledge |
| Creative Suggestions | Compositional & Musicianship Knowledge |

**Example Flow**:
1. Student uploads performance recording
2. Bedrock Nova analyzes: Technical Score = 88, Expressive Score = 92
3. System updates:
   - `technicalSkillsCompetence.practicalTechniqueMark` weighted with AI score
   - `performingArtistry.practicalArtistryMark` weighted with AI score
4. Aggregate quadrant scores recalculated
5. Pie chart updates automatically in passport UI

---

## Mock Data Structure for Hackathon

**Sample Student Profile** (Alice Johnson - Piano, Tertiary):

```json
{
  "studentId": "stu-001",
  "name": { "first": "Alice", "last": "Johnson" },
  "instrument": "Piano",
  "program": "Tertiary",
  
  "technicalSkillsCompetence": {
    "score": 85,
    "practicalTechniqueMark": 88,
    "teacherTechnicalAdvice": [
      "Excellent finger independence in scales",
      "Work on wrist relaxation in arpeggios",
      "Practice Hanon exercises daily"
    ],
    "teacherChecklist": {
      "achieved": ["All major scales", "Chromatic scales", "Contrary motion"],
      "partial": ["Thirds scales", "Double thirds"]
    }
  },
  
  "compositionalMusicianshipKnowledge": {
    "score": 78,
    "musicianshipMark": 82,
    "auralEvidenceRecordings": [
      "s3://accordo/stu-001/aural/interval-recognition.mp3",
      "s3://accordo/stu-001/aural/chord-playback.mp3"
    ],
    "creativeReflectiveNotes": [
      "Strong melodic memory, working on harmonic analysis",
      "Improvisation skills developing well"
    ]
  },
  
  "repertoireCulturalKnowledge": {
    "score": 82,
    "repertoireCulturalMark": 85,
    "listeningLogs": [
      {
        "piece": "Goldberg Variations",
        "composer": "J.S. Bach",
        "date": "2025-01-03",
        "notes": "Understanding of Baroque ornamentation and counterpoint"
      },
      {
        "piece": "Piano Sonata No. 14 'Moonlight'",
        "composer": "Beethoven",
        "date": "2025-01-10",
        "notes": "Romantic expressiveness vs Classical structure"
      }
    ],
    "contextMeaningNotes": [
      "Bach's counterpoint influences my interpretation of fugues",
      "Beethoven's emotional depth helps me connect with audiences"
    ]
  },
  
  "performingArtistry": {
    "score": 90,
    "practicalArtistryMark": 93,
    "studentPerformanceReflections": [
      {
        "date": "2024-12-15",
        "performance": "Christmas Concert - Chopin Nocturne",
        "reflection": "Felt confident with rubato, audience engagement was strong"
      }
    ],
    "teacherPerformancePrepNotes": [
      "Work on stage presence and bowing",
      "Practice mental imagery for performance confidence"
    ]
  }
}
```

---

## UI Components for Quadrant Visualization

### 1. **Dashboard Pie Chart** (Primary Visualization)
- Displays all 4 quadrants as colored segments
- Interactive: click segment to drill down
- Center shows aggregate score average
- Legend with quadrant names and scores

### 2. **Quadrant Detail Cards** (Expanded View)
Each card shows:
- Current score (0-100)
- Trend indicator (↑ improving, → stable, ↓ declining)
- Component breakdown (examiner/teacher/student contributions)
- Recent activities affecting this quadrant
- Actionable recommendations

### 3. **Progress Timeline**
- Filterable by quadrant
- Shows historical score changes
- Highlights key milestones and achievements
- AI feedback annotations

### 4. **Comparative Analytics** (Teacher View)
- Cohort average vs individual student
- Four quadrant radar chart
- Identify strengths and areas needing attention

---

## Benefits of Four Quadrant Model

✅ **Holistic Assessment**: Captures technical, theoretical, cultural, and artistic dimensions  
✅ **Multi-Stakeholder Input**: Balances examiner, teacher, and student perspectives  
✅ **Clear Ownership**: Designated data owners ensure accountability  
✅ **Scalable**: Applicable to 35,000+ students across RIAM programs  
✅ **AI-Compatible**: Structured data enables intelligent coaching and feedback  
✅ **Global Applicability**: Framework adaptable to music education institutions worldwide  


