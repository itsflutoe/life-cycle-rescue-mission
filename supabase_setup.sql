-- ============================================================
-- Animal Life Cycle Rescue Mission - Supabase Setup SQL
-- Run this entire script in the Supabase SQL Editor
-- ============================================================

-- 1. Enable required extensions (usually already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create tables
CREATE TABLE IF NOT EXISTS public.game_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_code TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  display_name TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT false,
  joined_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.game_sessions(id) ON DELETE CASCADE,
  participant_id UUID NOT NULL REFERENCES public.participants(id) ON DELETE CASCADE,
  question_id TEXT NOT NULL,
  answer TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  points INTEGER NOT NULL,
  answered_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (participant_id, question_id)
);

-- 3. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_participants_session ON public.participants(session_id);
CREATE INDEX IF NOT EXISTS idx_participants_user ON public.participants(user_id);
CREATE INDEX IF NOT EXISTS idx_answers_session ON public.answers(session_id);
CREATE INDEX IF NOT EXISTS idx_answers_participant ON public.answers(participant_id);
CREATE INDEX IF NOT EXISTS idx_game_sessions_code ON public.game_sessions(session_code);

-- 4. Enable Row Level Security
ALTER TABLE public.game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answers ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for game_sessions
-- Anyone (including anon) can read active sessions (needed to look up session by code)
CREATE POLICY "Anyone can read active sessions"
  ON public.game_sessions
  FOR SELECT
  USING (is_active = true);

-- Anyone can insert a new session (teacher creates sessions without login for simplicity)
CREATE POLICY "Anyone can create sessions"
  ON public.game_sessions
  FOR INSERT
  WITH CHECK (true);

-- Anyone can update sessions (for closing/resetting) - acceptable for classroom demo
CREATE POLICY "Anyone can update sessions"
  ON public.game_sessions
  FOR UPDATE
  USING (true);

-- 6. RLS Policies for participants
-- Authenticated users can insert their own participant row
CREATE POLICY "Authenticated users can join as participant"
  ON public.participants
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can read their own participant record
CREATE POLICY "Users can read own participant"
  ON public.participants
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Anyone can read participants (teacher dashboard needs to see all for a session)
-- For classroom demo this is acceptable; in production tighten with session ownership
CREATE POLICY "Anyone can read participants for session"
  ON public.participants
  FOR SELECT
  USING (true);

-- Users can update only their own participant (score, completed)
CREATE POLICY "Users can update own participant"
  ON public.participants
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Allow delete for reset (teacher)
CREATE POLICY "Anyone can delete participants for reset"
  ON public.participants
  FOR DELETE
  USING (true);

-- 7. RLS Policies for answers
-- Authenticated users can insert their own answers
CREATE POLICY "Authenticated users can insert answers"
  ON public.answers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.participants p
      WHERE p.id = participant_id AND p.user_id = auth.uid()
    )
  );

-- Users can read their own answers
CREATE POLICY "Users can read own answers"
  ON public.answers
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.participants p
      WHERE p.id = participant_id AND p.user_id = auth.uid()
    )
  );

-- Anyone can read answers (teacher dashboard)
CREATE POLICY "Anyone can read answers for session"
  ON public.answers
  FOR SELECT
  USING (true);

-- No update/delete of answers by students (immutable)
-- Allow delete for session reset
CREATE POLICY "Anyone can delete answers for reset"
  ON public.answers
  FOR DELETE
  USING (true);

-- 8. Enable Realtime for live dashboard
-- Add tables to the supabase_realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.participants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.answers;
ALTER PUBLICATION supabase_realtime ADD TABLE public.game_sessions;

-- 9. Grant basic privileges (RLS still applies)
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.game_sessions TO anon, authenticated;
GRANT INSERT, UPDATE ON public.game_sessions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.participants TO anon, authenticated;
GRANT SELECT, INSERT, DELETE ON public.answers TO anon, authenticated;

-- ============================================================
-- IMPORTANT: Also enable Anonymous Sign-Ins in Supabase Dashboard
-- Authentication → Providers → Anonymous Sign-Ins → Enable
-- ============================================================
