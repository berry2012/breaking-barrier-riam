-- RIAM Accordo AI - Mock Data Import Script for RDS PostgreSQL
-- Imports exam results, teacher assessments, and practice logs
-- Run this after creating the schema from the specification

-- ============================================================
-- 1. TEACHERS
-- ============================================================

INSERT INTO teachers (teacher_id, cognito_user_id, email, name_first, name_last, instruments, specializations)
VALUES
  (gen_random_uuid(), 'cognito-teacher-001', 'niamh.odonnell@riam.ie', 'Niamh', 'O''Donnell', ARRAY['Violin', 'Viola'], ARRAY['Classical', 'Suzuki Method']),
  (gen_random_uuid(), 'cognito-teacher-002', 'liam.keane@riam.ie', 'Liam', 'Keane', ARRAY['Flute', 'Piccolo'], ARRAY['Classical', 'Baroque']),
  (gen_random_uuid(), 'cognito-teacher-003', 'siobhan.kelly@riam.ie', 'Siobhán', 'Kelly', ARRAY['Piano'], ARRAY['Classical', 'Contemporary']),
  (gen_random_uuid(), 'cognito-teacher-004', 'david.horan@riam.ie', 'David', 'Horan', ARRAY['Trumpet', 'Cornet'], ARRAY['Classical', 'Jazz']),
  (gen_random_uuid(), 'cognito-teacher-005', 'aisling.byrne@riam.ie', 'Aisling', 'Byrne', ARRAY['Voice'], ARRAY['Classical', 'Musical Theatre', 'Irish Traditional'])
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- 2. EXAM RESULTS (Annual Practical Assessments)
-- ============================================================

-- Student S01: Aoife Byrne (Violin, Development Stage)
INSERT INTO exam_results (student_id, exam_date, exam_type, instrument, technical_score, musical_interpretation_score, overall_grade, pieces_performed, examiner_feedback, examiner_id)
VALUES
  ('S01', '2024-06-15', 'RIAM Junior Grade 1', 'Violin', 58, 62, 'Pass', 
   '[{"title": "Twinkle Twinkle Variations A", "composer": "Suzuki", "score": 60}, {"title": "Lightly Row", "composer": "Traditional", "score": 58}]'::jsonb,
   'Posture is developing well. Continue work on bow hold and intonation. Shows good rhythmic security.',
   'examiner-001');

-- Student S02: Conor Walsh (Flute, Intermediate Stage)
INSERT INTO exam_results (student_id, exam_date, exam_type, instrument, technical_score, musical_interpretation_score, overall_grade, pieces_performed, examiner_feedback, examiner_id)
VALUES
  ('S02', '2024-06-18', 'RIAM Junior Grade 3', 'Flute', 70, 68, 'Merit', 
   '[{"title": "Bach Minuet", "composer": "J.S. Bach", "score": 72}, {"title": "Sonatina Movement", "composer": "Clementi", "score": 68}]'::jsonb,
   'Good tone production and breath control. Work on finger clarity in faster passages. Musical understanding is evident.',
   'examiner-002');

-- Student S03: Ella Murphy (Piano, Advanced Junior)
INSERT INTO exam_results (student_id, exam_date, exam_type, instrument, technical_score, musical_interpretation_score, overall_grade, pieces_performed, examiner_feedback, examiner_id)
VALUES
  ('S03', '2024-06-20', 'RIAM Junior Grade 5', 'Piano', 82, 78, 'Distinction', 
   '[{"title": "Beethoven Sonatina Op.49 No.1", "composer": "Beethoven", "score": 85}, {"title": "Burgmüller Arabesque", "composer": "Burgmüller", "score": 80}]'::jsonb,
   'Excellent technical control and hand balance. Clear understanding of Classical style. Would benefit from more dynamic contrast in slower sections.',
   'examiner-003');

-- Student S04: Rory Fitzpatrick (Trumpet, Young Artist)
INSERT INTO exam_results (student_id, exam_date, exam_type, instrument, technical_score, musical_interpretation_score, overall_grade, pieces_performed, examiner_feedback, examiner_id)
VALUES
  ('S04', '2024-06-22', 'RIAM Diploma Level 1', 'Trumpet', 92, 80, 'Distinction', 
   '[{"title": "Haydn Trumpet Concerto (1st mvt)", "composer": "Haydn", "score": 90}, {"title": "Arban Characteristic Study No.1", "composer": "Arban", "score": 94}]'::jsonb,
   'Outstanding technical ability with excellent range and articulation. Exceptional breath control. Musical interpretation could explore more emotional depth and phrase shaping.',
   'examiner-004');

-- Student S05: Saoirse Nolan (Voice, Young Artist)
INSERT INTO exam_results (student_id, exam_date, exam_type, instrument, technical_score, musical_interpretation_score, overall_grade, pieces_performed, examiner_feedback, examiner_id)
VALUES
  ('S05', '2024-06-25', 'RIAM Diploma Level 2', 'Voice', 85, 94, 'Distinction', 
   '[{"title": "Caro mio ben", "composer": "Giordani", "score": 88}, {"title": "The Parting Glass", "composer": "Traditional Irish", "score": 96}]'::jsonb,
   'Superb vocal technique with excellent breath support and diction. Outstanding emotional connection and storytelling. A mature and compelling performer.',
   'examiner-005');

-- ============================================================
-- 3. TEACHER ASSESSMENTS (Term-based)
-- ============================================================

-- S01: Aoife Byrne - Term 1 Assessment
INSERT INTO teacher_assessments (student_id, teacher_id, assessment_date, technical_proficiency, musical_expression, practice_consistency, growth_mindset, strengths, areas_for_improvement, recommended_repertoire, next_steps, lesson_context)
VALUES
  ('S01', (SELECT teacher_id FROM teachers WHERE email = 'niamh.odonnell@riam.ie'), '2024-12-10', 6, 6, 7, 8,
   'Good posture and rhythmic security. Enthusiastic learner. Regular practice evident.',
   'Bow hold needs continued attention. Intonation on D and A strings requires more careful listening.',
   'Continue Suzuki Book 1. Introduce simple folk melodies by ear.',
   'Focus on bow hold exercises daily. Slow practice with tuner for intonation. Parent to record practice for review.',
   'Regular Lesson');

-- S02: Conor Walsh - Term 1 Assessment
INSERT INTO teacher_assessments (student_id, teacher_id, assessment_date, technical_proficiency, musical_expression, practice_consistency, growth_mindset, strengths, areas_for_improvement, recommended_repertoire, next_steps, lesson_context)
VALUES
  ('S02', (SELECT teacher_id FROM teachers WHERE email = 'liam.keane@riam.ie'), '2024-12-11', 7, 7, 8, 7,
   'Steady tone production. Good listener with strong aural skills. Counts rests accurately.',
   'Finger clarity in fast passages. Needs more confidence in improvisation and creative exercises.',
   'Continue with Bach Minuets. Add simple jazz melodies for stylistic variety.',
   'Finger exercises with metronome. Introduce improvisation games in lessons. Listen to more varied repertoire.',
   'Regular Lesson');

-- S03: Ella Murphy - Term 1 Assessment
INSERT INTO teacher_assessments (student_id, teacher_id, assessment_date, technical_proficiency, musical_expression, practice_consistency, growth_mindset, strengths, areas_for_improvement, recommended_repertoire, next_steps, lesson_context)
VALUES
  ('S03', (SELECT teacher_id FROM teachers WHERE email = 'siobhan.kelly@riam.ie'), '2024-12-12', 8, 8, 9, 9,
   'Excellent hand balance and articulation. Strong understanding of harmony. Consistent, thoughtful practice.',
   'Dynamic range could be broader in slow movements. Pedaling technique needs refinement.',
   'Begin Chopin Preludes. Explore Debussy for impressionistic color.',
   'Work on rubato and phrasing in Romantic repertoire. Practice soft/loud extremes. Study pedaling videos.',
   'Regular Lesson');

-- S04: Rory Fitzpatrick - Performance Review
INSERT INTO teacher_assessments (student_id, teacher_id, assessment_date, technical_proficiency, musical_expression, practice_consistency, growth_mindset, strengths, areas_for_improvement, recommended_repertoire, next_steps, lesson_context)
VALUES
  ('S04', (SELECT teacher_id FROM teachers WHERE email = 'david.horan@riam.ie'), '2024-12-13', 9, 7, 9, 8,
   'Exceptional technical mastery. Excellent range and endurance. Disciplined practice routine.',
   'Musical expression sometimes lacks emotional depth. Could explore more phrase destinations beyond technical precision.',
   'Continue Haydn Concerto. Add Hummel Concerto. Explore modern repertoire (Arutiunian, Enescu).',
   'Listen to great brass performers (Wynton Marsalis, Alison Balsom). Compose 8-bar motifs to deepen musical intent. Work on phrase shaping.',
   'Performance Review');

-- S05: Saoirse Nolan - Mock Performance
INSERT INTO teacher_assessments (student_id, teacher_id, assessment_date, technical_proficiency, musical_expression, practice_consistency, growth_mindset, strengths, areas_for_improvement, recommended_repertoire, next_steps, lesson_context)
VALUES
  ('S05', (SELECT teacher_id FROM teachers WHERE email = 'aisling.byrne@riam.ie'), '2024-12-14', 9, 10, 10, 10,
   'Outstanding vocal technique and diction. Deeply connected to text and character. Journals about intention regularly.',
   'None significant at this stage. Continue exploring diverse repertoire.',
   'Continue art song cycle. Add contemporary Irish composers (Ina Boyle, Gerald Barry). Explore operatic arias.',
   'Prepare for upcoming recital. Refine 2-3 key words per phrase. Continue journaling character intentions.',
   'Mock Performance');

-- ============================================================
-- 4. PRACTICE LOGS (Student Self-Reporting)
-- ============================================================

-- S01: Aoife Byrne - Week of practice logs
INSERT INTO practice_logs (student_id, practice_date, duration_minutes, focus_areas, pieces_practiced, self_rating, notes)
VALUES
  ('S01', '2025-01-05', 25, ARRAY['Open strings', 'Bow hold', 'Twinkle variations'], 
   '[{"title": "Open strings exercise", "composer": "Technical", "timeSpent": 10}, {"title": "Twinkle Twinkle A", "composer": "Suzuki", "timeSpent": 15}]'::jsonb,
   3, 'Bow hold felt better today. Mom helped me check my posture.'),
  ('S01', '2025-01-06', 20, ARRAY['Lightly Row', 'Rhythm'], 
   '[{"title": "Lightly Row", "composer": "Traditional", "timeSpent": 20}]'::jsonb,
   4, 'Rhythms were easier after singing first!');

-- S02: Conor Walsh - Week of practice logs
INSERT INTO practice_logs (student_id, practice_date, duration_minutes, focus_areas, pieces_practiced, self_rating, notes)
VALUES
  ('S02', '2025-01-05', 40, ARRAY['Long tones', 'Bach Minuet', 'Scales'], 
   '[{"title": "Long tones C-D-E", "composer": "Technical", "timeSpent": 10}, {"title": "Bach Minuet", "composer": "Bach", "timeSpent": 20}, {"title": "C Major scale", "composer": "Technical", "timeSpent": 10}]'::jsonb,
   4, 'Counted rests carefully in the Minuet. Metronome helped a lot.'),
  ('S02', '2025-01-06', 35, ARRAY['Sonatina', 'Finger clarity'], 
   '[{"title": "Sonatina movement", "composer": "Clementi", "timeSpent": 25}, {"title": "Finger exercises", "composer": "Technical", "timeSpent": 10}]'::jsonb,
   3, 'Fast section still tricky. Need to slow down more.');

-- S03: Ella Murphy - Week of practice logs
INSERT INTO practice_logs (student_id, practice_date, duration_minutes, focus_areas, pieces_practiced, self_rating, notes)
VALUES
  ('S03', '2025-01-05', 60, ARRAY['Beethoven phrasing', 'Hand balance', 'Scales'], 
   '[{"title": "Beethoven Sonatina", "composer": "Beethoven", "timeSpent": 30}, {"title": "Burgmüller Arabesque", "composer": "Burgmüller", "timeSpent": 20}, {"title": "Scales and arpeggios", "composer": "Technical", "timeSpent": 10}]'::jsonb,
   4, 'Worked on shaping phrases with breathing points. Left hand lighter today.'),
  ('S03', '2025-01-07', 55, ARRAY['Slow practice', 'Pedaling'], 
   '[{"title": "Beethoven Sonatina (hands separate)", "composer": "Beethoven", "timeSpent": 40}, {"title": "Scale study", "composer": "Technical", "timeSpent": 15}]'::jsonb,
   5, 'Really productive session. Hands separate helped with tricky bars.');

-- S04: Rory Fitzpatrick - Week of practice logs
INSERT INTO practice_logs (student_id, practice_date, duration_minutes, focus_areas, pieces_practiced, self_rating, notes)
VALUES
  ('S04', '2025-01-06', 75, ARRAY['Long tones', 'Upper register', 'Haydn Concerto'], 
   '[{"title": "Long tones and lip slurs", "composer": "Technical", "timeSpent": 20}, {"title": "Haydn Concerto 1st mvt", "composer": "Haydn", "timeSpent": 40}, {"title": "Arban Study", "composer": "Arban", "timeSpent": 15}]'::jsonb,
   5, 'Upper register felt strong today. Focused on airflow and light articulation.'),
  ('S04', '2025-01-08', 80, ARRAY['Phrase shaping', 'Orchestral excerpt'], 
   '[{"title": "Haydn (phrase destinations)", "composer": "Haydn", "timeSpent": 50}, {"title": "Orchestral excerpt", "composer": "Various", "timeSpent": 30}]'::jsonb,
   4, 'Worked on 3 phrase destinations in the concerto. More musical intent emerging.');

-- S05: Saoirse Nolan - Week of practice logs
INSERT INTO practice_logs (student_id, practice_date, duration_minutes, focus_areas, pieces_practiced, self_rating, notes)
VALUES
  ('S05', '2025-01-05', 50, ARRAY['Breath support', 'Italian diction', 'Character work'], 
   '[{"title": "Breath exercises", "composer": "Technical", "timeSpent": 10}, {"title": "Caro mio ben", "composer": "Giordani", "timeSpent": 25}, {"title": "Musical theatre ballad", "composer": "Sondheim", "timeSpent": 15}]'::jsonb,
   5, 'Journaled about the character in the ballad. Clear vowels felt easier today.'),
  ('S05', '2025-01-07', 45, ARRAY['Irish traditional', 'Storytelling'], 
   '[{"title": "The Parting Glass", "composer": "Traditional", "timeSpent": 30}, {"title": "Soft entries practice", "composer": "Technical", "timeSpent": 15}]'::jsonb,
   5, 'Connected deeply to the story. Wrote key words for each phrase: longing, memory, hope.');

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Count records
SELECT 'Teachers' as table_name, COUNT(*) as count FROM teachers
UNION ALL
SELECT 'Exam Results', COUNT(*) FROM exam_results
UNION ALL
SELECT 'Teacher Assessments', COUNT(*) FROM teacher_assessments
UNION ALL
SELECT 'Practice Logs', COUNT(*) FROM practice_logs;

-- View sample data
SELECT 
  er.student_id,
  er.exam_type,
  er.instrument,
  er.overall_grade,
  er.technical_score,
  er.musical_interpretation_score
FROM exam_results er
ORDER BY er.exam_date;

COMMIT;
