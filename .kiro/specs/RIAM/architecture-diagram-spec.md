# RIAM Accordo AI - Architecture Diagram Specification
## AWS Breaking Barriers Challenge 2026

### Overview
This document provides detailed specifications for creating the RIAM Accordo AI system architecture diagram using the latest AWS icons and visual design standards.

### Architecture Components

#### 1. Frontend Layer (User Interfaces)
**Components:**
- Student Portal (React SPA)
- Teacher Portal (React SPA) 
- Admin Portal (React SPA)

**AWS Services:**
- **Amazon CloudFront** - CDN for global content delivery
- **Amazon S3** - Static website hosting for React SPAs

**Visual Representation:**
- Three separate UI mockups showing different user interfaces
- Connected via CloudFront distribution
- Use AWS CloudFront icon (latest 2024 version)
- Use AWS S3 icon for static hosting

#### 2. API Gateway Layer
**Components:**
- Authentication & Authorization
- Route Management
- Request/Response Transformation
- Rate Limiting

**AWS Services:**
- **Amazon API Gateway** - REST API management
- **Amazon Cognito** - User authentication and authorization

**Visual Representation:**
- Central API Gateway icon receiving requests from all three frontends
- Cognito icon connected to API Gateway for auth
- Use AWS API Gateway icon (latest 2024 version)
- Use AWS Cognito icon (latest 2024 version)

#### 3. Compute Layer (Business Logic)
**Components:**
- Student Management Service
- Recording Processing Service
- AI Feedback Service
- Analytics Service
- Coaching Service

**AWS Services:**
- **AWS Lambda** - Serverless compute functions

**Visual Representation:**
- Five Lambda function icons representing different services
- Group them logically by function
- Use AWS Lambda icon (latest 2024 version)
- Label each Lambda with its specific purpose

#### 4. AI/ML Layer
**Components:**
- Audio Analysis Engine (Nova Pro)
- Conversational AI Coach (AgentCore)
- Feedback Generation
- Natural Language Processing

**AWS Services:**
- **Amazon Bedrock** - Foundation models and AI services
  - Bedrock Nova Pro for audio analysis
  - Bedrock AgentCore for conversational AI

**Visual Representation:**
- Amazon Bedrock icon prominently displayed
- Two sub-components: Nova Pro and AgentCore
- Connected to Lambda functions for AI processing
- Use AWS Bedrock icon (latest 2024 version)

#### 5. Storage Layer
**Components:**
- Student Profiles & Progress Data
- Performance Recordings (Audio/Video)
- Conversation History
- AI Feedback Results
- Static Assets & PDFs

**AWS Services:**
- **Amazon DynamoDB** - NoSQL database for student data, recordings metadata, conversations
- **Amazon RDS (PostgreSQL)** - Relational database for exam results, teacher assessments, practice logs
- **Amazon S3** - Object storage for audio/video files, PDFs, static assets

**Visual Representation:**
- DynamoDB icon for NoSQL data
- RDS PostgreSQL icon for relational data
- S3 icon for file storage
- Use latest 2024 versions of all icons
- Show data flow arrows between services

#### 6. Monitoring & Security Layer
**Components:**
- Application Monitoring
- Error Tracking
- Performance Metrics
- Security Logging

**AWS Services:**
- **Amazon CloudWatch** - Monitoring and logging
- **AWS X-Ray** - Distributed tracing
- **AWS IAM** - Identity and access management

**Visual Representation:**
- CloudWatch icon for monitoring
- X-Ray icon for tracing
- IAM icon for security
- Position as supporting services around the main architecture

### Data Flow Diagram

#### Primary User Flows

**1. Student Upload & AI Feedback Flow:**
```
Student UI → CloudFront → API Gateway → Cognito (Auth) → Lambda (Upload) → S3 (Store File) → Lambda (Process) → Bedrock Nova → DynamoDB (Store Feedback) → Student UI (Display)
```

**2. AI Coaching Conversation Flow:**
```
Student UI → API Gateway → Lambda (Coach) → Bedrock AgentCore → DynamoDB (Store Context) → Lambda (Response) → Student UI (Display)
```

**3. Teacher Validation Flow:**
```
Teacher UI → API Gateway → Lambda (Validate) → DynamoDB (Update) → RDS (Log Assessment) → Teacher UI (Confirm)
```

### Visual Design Guidelines

#### Color Scheme
- **AWS Orange**: #FF9900 (primary AWS brand color)
- **AWS Blue**: #232F3E (secondary AWS brand color)
- **Service Colors**: Use official AWS service colors from the latest icon set
- **Data Flow**: Use blue arrows (#0073BB) for data flow
- **User Interactions**: Use orange arrows (#FF9900) for user actions

#### Layout Structure
```
┌─────────────────────────────────────────────────────────────┐
│                    FRONTEND LAYER                           │
│  [Student UI]    [Teacher UI]    [Admin UI]                │
│       │              │              │                      │
│       └──────────────┼──────────────┘                      │
│                      │                                     │
│                 [CloudFront]                               │
│                      │                                     │
└──────────────────────┼─────────────────────────────────────┘
                       │
┌──────────────────────┼─────────────────────────────────────┐
│                 API LAYER                                   │
│              [API Gateway] ←→ [Cognito]                    │
│                      │                                     │
└──────────────────────┼─────────────────────────────────────┘
                       │
┌──────────────────────┼─────────────────────────────────────┐
│                COMPUTE LAYER                                │
│  [Lambda]  [Lambda]  [Lambda]  [Lambda]  [Lambda]         │
│  Student   Recording   AI       Analytics  Coaching        │
│     │         │        │           │         │            │
└─────┼─────────┼────────┼───────────┼─────────┼─────────────┘
      │         │        │           │         │
      │         │        │           │         │
┌─────┼─────────┼────────┼───────────┼─────────┼─────────────┐
│     │         │     AI/ML LAYER    │         │             │
│     │         │   [Amazon Bedrock] │         │             │
│     │         │   Nova Pro │ AgentCore       │             │
│     │         │        │           │         │             │
└─────┼─────────┼────────┼───────────┼─────────┼─────────────┘
      │         │        │           │         │
┌─────┼─────────┼────────┼───────────┼─────────┼─────────────┐
│                 STORAGE LAYER                               │
│  [DynamoDB]    [S3]         [RDS PostgreSQL]              │
│  Student Data  Audio/Video  Exam Results                   │
│  Conversations PDFs         Teacher Data                   │
│  AI Feedback   Assets       Practice Logs                  │
└─────────────────────────────────────────────────────────────┘
```

#### Icon Specifications

**AWS Service Icons (Latest 2024 Versions):**
- Amazon S3: Use the orange bucket icon
- Amazon DynamoDB: Use the blue database icon with lightning bolt
- Amazon RDS: Use the blue cylinder database icon
- AWS Lambda: Use the orange lambda symbol icon
- Amazon API Gateway: Use the purple gateway icon
- Amazon Cognito: Use the orange user authentication icon
- Amazon Bedrock: Use the purple/blue AI foundation icon
- Amazon CloudFront: Use the orange globe/CDN icon
- Amazon CloudWatch: Use the purple monitoring icon
- AWS X-Ray: Use the purple tracing icon
- AWS IAM: Use the orange shield/user icon

**Icon Sources:**
- Download from: https://aws.amazon.com/architecture/icons/
- Use SVG format for scalability
- Ensure consistent sizing (64x64px recommended)
- Maintain official AWS color schemes

#### Annotations and Labels

**Service Labels:**
- Each AWS service should be clearly labeled
- Use AWS official service names (not abbreviations)
- Include brief functional description where helpful

**Data Flow Labels:**
- Label arrows with data types: "Audio Files", "Student Data", "AI Feedback"
- Include approximate data volumes where relevant
- Show synchronous vs asynchronous flows with different arrow styles

**Performance Metrics:**
- API response times: "< 2 seconds"
- AI processing: "< 30 seconds"
- File upload: "Up to 500MB"

### Implementation Tools

#### Recommended Diagramming Tools

**1. Draw.io (diagrams.net) - FREE**
- Built-in AWS icon library (automatically updated)
- Web-based, no installation required
- Export to PNG, SVG, PDF formats
- Collaborative editing support

**2. Lucidchart - PAID**
- Professional AWS architecture templates
- Advanced styling and formatting options
- Team collaboration features
- Integration with AWS CloudFormation

**3. AWS Architecture Icons - MANUAL**
- Download official icon set from AWS
- Use with any design tool (Figma, Sketch, PowerPoint)
- Ensures latest icon versions
- Maximum customization control

#### Step-by-Step Creation Guide

**Phase 1: Setup (5 minutes)**
1. Open draw.io in web browser
2. Select "AWS Architecture" template
3. Import latest AWS icon library
4. Set canvas size to A3 landscape (420mm x 297mm)

**Phase 2: Layout Structure (15 minutes)**
1. Create horizontal layers using rectangles:
   - Frontend Layer (top)
   - API Layer
   - Compute Layer
   - AI/ML Layer
   - Storage Layer (bottom)
2. Add layer labels and background colors
3. Ensure consistent spacing and alignment

**Phase 3: Add AWS Services (20 minutes)**
1. Drag AWS service icons from library
2. Position according to layout structure
3. Add service labels below each icon
4. Group related services with subtle background boxes

**Phase 4: Data Flow Arrows (15 minutes)**
1. Add arrows showing primary data flows
2. Use different arrow styles for different data types:
   - Solid arrows: Real-time data
   - Dashed arrows: Batch processing
   - Thick arrows: High-volume data
3. Label arrows with data descriptions

**Phase 5: Styling and Polish (10 minutes)**
1. Apply consistent color scheme
2. Adjust font sizes for readability
3. Add title and subtitle
4. Include legend for arrow types
5. Add AWS logo and project branding

**Phase 6: Export and Validate (5 minutes)**
1. Export as high-resolution PNG (300 DPI)
2. Export as SVG for web use
3. Export as PDF for documentation
4. Review for accuracy and completeness

### File Deliverables

**Primary Diagram:**
- `RIAM-Architecture-Diagram.png` (high-resolution)
- `RIAM-Architecture-Diagram.svg` (web-optimized)
- `RIAM-Architecture-Diagram.pdf` (documentation)

**Source Files:**
- `RIAM-Architecture-Diagram.drawio` (editable source)

**Supporting Documents:**
- `AWS-Services-List.md` (complete service inventory)
- `Data-Flow-Specifications.md` (detailed flow descriptions)

### Quality Checklist

**Technical Accuracy:**
- [ ] All AWS services correctly represented
- [ ] Data flows logically consistent
- [ ] Service connections technically valid
- [ ] Performance metrics realistic

**Visual Design:**
- [ ] Latest AWS icons used throughout
- [ ] Consistent color scheme applied
- [ ] Clear hierarchy and grouping
- [ ] Readable labels and annotations
- [ ] Professional appearance suitable for presentation

**Completeness:**
- [ ] All system components included
- [ ] Primary user flows represented
- [ ] Security and monitoring services shown
- [ ] Scalability considerations visible
- [ ] Integration points clearly marked

### Usage Instructions

**For Hackathon Presentation:**
1. Display as full-screen slide during technical demo
2. Walk through user flows using pointer/laser
3. Highlight AI/ML components as key differentiators
4. Emphasize AWS service integration depth

**For Documentation:**
- Include in technical specification document
- Reference in deployment guides
- Use in developer onboarding materials
- Include in post-hackathon project proposals

**For Development:**
- Use as reference during implementation
- Validate service connections during testing
- Guide infrastructure as code development
- Support troubleshooting and debugging

---

## Next Steps

1. **Create the diagram** using draw.io with the specifications above
2. **Validate technical accuracy** with the requirements document
3. **Review visual design** for presentation readiness
4. **Export in multiple formats** for different use cases
5. **Integrate into project documentation** and presentation materials

This architecture diagram will serve as the visual centerpiece for demonstrating the RIAM Accordo AI system's technical sophistication and AWS integration depth during the hackathon presentation.