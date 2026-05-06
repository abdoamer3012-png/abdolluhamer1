CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id text PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  password text NOT NULL,
  role text NOT NULL DEFAULT 'student' CHECK (role IN ('admin', 'student')),
  phone text,
  grade_id bigint,
  grade_reset_seen_version integer NOT NULL DEFAULT 0,
  email_verified boolean NOT NULL DEFAULT false,
  email_verification_code text,
  avatar_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS content_sections (
  id bigserial PRIMARY KEY,
  title text NOT NULL,
  parent_id bigint REFERENCES content_sections(id) ON DELETE CASCADE,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE users
  DROP CONSTRAINT IF EXISTS users_grade_id_fkey;

ALTER TABLE users
  ADD CONSTRAINT users_grade_id_fkey
  FOREIGN KEY (grade_id) REFERENCES content_sections(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS lessons (
  id bigserial PRIMARY KEY,
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  video_url text NOT NULL DEFAULT '',
  order_index integer NOT NULL DEFAULT 0,
  duration_minutes integer NOT NULL DEFAULT 45,
  price_amount numeric NOT NULL DEFAULT 0,
  section_id bigint REFERENCES content_sections(id) ON DELETE SET NULL,
  is_published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS price_amount numeric NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS quizzes (
  id bigserial PRIMARY KEY,
  lesson_id bigint NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  type text NOT NULL DEFAULT 'mcq',
  question text NOT NULL,
  options jsonb,
  correct_answer text NOT NULL,
  points integer NOT NULL DEFAULT 10,
  order_index integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS student_progress (
  id bigserial PRIMARY KEY,
  user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id bigint NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  completed boolean NOT NULL DEFAULT false,
  watch_percentage integer NOT NULL DEFAULT 0,
  quiz_score integer,
  quiz_total integer,
  quiz_attempts integer NOT NULL DEFAULT 0,
  last_accessed timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, lesson_id)
);

CREATE TABLE IF NOT EXISTS forum_posts (
  id bigserial PRIMARY KEY,
  user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title text NOT NULL,
  content text NOT NULL,
  image_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE forum_posts
  ADD COLUMN IF NOT EXISTS image_url text;

CREATE TABLE IF NOT EXISTS forum_comments (
  id bigserial PRIMARY KEY,
  post_id bigint NOT NULL REFERENCES forum_posts(id) ON DELETE CASCADE,
  user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);


CREATE TABLE IF NOT EXISTS app_settings (
  key text PRIMARY KEY,
  value text NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);


CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_sections_parent ON content_sections(parent_id);
CREATE INDEX IF NOT EXISTS idx_lessons_section ON lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_lesson ON quizzes(lesson_id);
CREATE INDEX IF NOT EXISTS idx_progress_user ON student_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_lesson ON student_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_user ON forum_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_post ON forum_comments(post_id);

TRUNCATE TABLE
  forum_comments,
  forum_posts,
  student_progress,
  quizzes,
  lessons,
  content_sections
RESTART IDENTITY CASCADE;

DELETE FROM users;

INSERT INTO users (
  id,
  name,
  email,
  password,
  role,
  phone,
  grade_id,
  grade_reset_seen_version,
  email_verified,
  email_verification_code,
  avatar_url
) VALUES (
  'admin-123',
  'عامر',
  'amerghool2010@gmail.com',
  '$argon2id$v=19$m=65536,t=3,p=4$Q70bNZuMEvcSZXxz3WqXvg$I5c9gdazbxq34RC8FT0yEfrytbo+3ySlg59puZ/RmYw',
  'admin',
  '',
  NULL,
  0,
  true,
  NULL,
  NULL
);

INSERT INTO app_settings (key, value, updated_at)
VALUES
  ('messaging_enabled', 'true', now()),
  ('academy_name', 'منصة عامر بالمعرفة', now()),
  ('payment_provider', 'وي باي', now()),
  ('payment_number', '01500984439', now()),
  ('payment_gateway_mode', 'mock', now()),
  ('grade_reset_version', '0', now()),
  ('feature_student_updates', 'true', now()),
  ('feature_lesson_resources', 'true', now()),
  ('feature_forum', 'true', now()),
  ('feature_honor_roll', 'true', now()),
  ('feature_ai_assistant', 'true', now()),
  ('announcements', '[]', now()),
  ('notifications', '[]', now()),
  ('lesson_files', '[]', now()),
  ('student_notes', '[]', now()),
  ('course_payments', '[]', now()),
  ('audit_logs', '[]', now()),
  ('platform_config', '{}', now())
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value,
  updated_at = now();

INSERT INTO content_sections (title, parent_id, order_index)
SELECT grade.title, NULL, grade.order_index
FROM (VALUES
  ('الأول الإعدادي', 1),
  ('الثاني الإعدادي', 2),
  ('الثالث الإعدادي', 3),
  ('الأول الثانوي', 4),
  ('الثاني الثانوي', 5),
  ('الثالث الثانوي', 6)
) AS grade(title, order_index)
WHERE NOT EXISTS (
  SELECT 1 FROM content_sections section
  WHERE section.title = grade.title AND section.parent_id IS NULL
);

INSERT INTO lessons (title, description, video_url, order_index, duration_minutes, section_id, price_amount)
SELECT
  'كورس تجريبي مجاني',
  'كورس تعريفي مجاني لتجربة المنصة قبل الاشتراك في الكورسات المدفوعة.',
  '',
  1,
  20,
  (SELECT id FROM content_sections WHERE title = 'الأول الإعدادي' AND parent_id IS NULL ORDER BY id LIMIT 1),
  0
WHERE NOT EXISTS (
  SELECT 1 FROM lessons WHERE title = 'كورس تجريبي مجاني'
);
