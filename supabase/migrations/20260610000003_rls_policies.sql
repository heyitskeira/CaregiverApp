-- ============================================================
-- Comprehensive RLS policies for the entire app.
-- Safe to re-run: drops existing policies before recreating.
-- ============================================================

-- ── profiles ─────────────────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own"  ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own"  ON public.profiles;

CREATE POLICY "profiles_select_own"  ON public.profiles
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "profiles_update_own"  ON public.profiles
  FOR UPDATE USING (id = auth.uid());

-- ── care_teams ───────────────────────────────────────────────
ALTER TABLE public.care_teams ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "teams_insert_auth"     ON public.care_teams;
DROP POLICY IF EXISTS "teams_select_member"   ON public.care_teams;
DROP POLICY IF EXISTS "teams_update_primary"  ON public.care_teams;
DROP POLICY IF EXISTS "teams_delete_primary"  ON public.care_teams;

-- Any authenticated user may create a care team.
CREATE POLICY "teams_insert_auth" ON public.care_teams
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "teams_select_member" ON public.care_teams
  FOR SELECT USING (public.is_team_member(id));

CREATE POLICY "teams_update_primary" ON public.care_teams
  FOR UPDATE USING (primary_caregiver_id = auth.uid());

CREATE POLICY "teams_delete_primary" ON public.care_teams
  FOR DELETE USING (primary_caregiver_id = auth.uid());

-- ── care_team_members ────────────────────────────────────────
ALTER TABLE public.care_team_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "members_insert_self"    ON public.care_team_members;
DROP POLICY IF EXISTS "members_select_team"    ON public.care_team_members;
DROP POLICY IF EXISTS "members_delete_self"    ON public.care_team_members;

-- Users can add themselves (join via invite code, or creator adding self).
CREATE POLICY "members_insert_self" ON public.care_team_members
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "members_select_team" ON public.care_team_members
  FOR SELECT USING (public.is_team_member(care_team_id));

CREATE POLICY "members_delete_self" ON public.care_team_members
  FOR DELETE USING (user_id = auth.uid());

-- ── care_recipients ──────────────────────────────────────────
ALTER TABLE public.care_recipients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "recipients_insert_member"  ON public.care_recipients;
DROP POLICY IF EXISTS "recipients_select_member"  ON public.care_recipients;
DROP POLICY IF EXISTS "recipients_update_member"  ON public.care_recipients;

CREATE POLICY "recipients_insert_member" ON public.care_recipients
  FOR INSERT WITH CHECK (public.is_team_member(care_team_id));

CREATE POLICY "recipients_select_member" ON public.care_recipients
  FOR SELECT USING (public.is_team_member(care_team_id));

CREATE POLICY "recipients_update_member" ON public.care_recipients
  FOR UPDATE USING (public.is_team_member(care_team_id));

-- ── care_contacts ────────────────────────────────────────────
ALTER TABLE public.care_contacts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "contacts_insert_member"  ON public.care_contacts;
DROP POLICY IF EXISTS "contacts_select_member"  ON public.care_contacts;
DROP POLICY IF EXISTS "contacts_update_member"  ON public.care_contacts;
DROP POLICY IF EXISTS "contacts_delete_member"  ON public.care_contacts;

CREATE POLICY "contacts_insert_member" ON public.care_contacts
  FOR INSERT WITH CHECK (public.is_team_member(care_team_id));

CREATE POLICY "contacts_select_member" ON public.care_contacts
  FOR SELECT USING (public.is_team_member(care_team_id));

CREATE POLICY "contacts_update_member" ON public.care_contacts
  FOR UPDATE USING (public.is_team_member(care_team_id));

CREATE POLICY "contacts_delete_member" ON public.care_contacts
  FOR DELETE USING (public.is_team_member(care_team_id));

-- ── care_tasks ───────────────────────────────────────────────
ALTER TABLE public.care_tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tasks_insert_member"  ON public.care_tasks;
DROP POLICY IF EXISTS "tasks_select_member"  ON public.care_tasks;
DROP POLICY IF EXISTS "tasks_update_member"  ON public.care_tasks;
DROP POLICY IF EXISTS "tasks_delete_member"  ON public.care_tasks;

CREATE POLICY "tasks_insert_member" ON public.care_tasks
  FOR INSERT WITH CHECK (public.is_team_member(care_team_id));

CREATE POLICY "tasks_select_member" ON public.care_tasks
  FOR SELECT USING (public.is_team_member(care_team_id));

CREATE POLICY "tasks_update_member" ON public.care_tasks
  FOR UPDATE USING (public.is_team_member(care_team_id));

CREATE POLICY "tasks_delete_member" ON public.care_tasks
  FOR DELETE USING (public.is_team_member(care_team_id));

-- ── task_assignees ───────────────────────────────────────────
ALTER TABLE public.task_assignees ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "assignees_insert_member"  ON public.task_assignees;
DROP POLICY IF EXISTS "assignees_select_member"  ON public.task_assignees;
DROP POLICY IF EXISTS "assignees_delete_member"  ON public.task_assignees;

CREATE POLICY "assignees_insert_member" ON public.task_assignees
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

CREATE POLICY "assignees_select_member" ON public.task_assignees
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

CREATE POLICY "assignees_delete_member" ON public.task_assignees
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

-- ── task_assignments ─────────────────────────────────────────
ALTER TABLE public.task_assignments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "assignments_insert_member"  ON public.task_assignments;
DROP POLICY IF EXISTS "assignments_select_member"  ON public.task_assignments;

CREATE POLICY "assignments_insert_member" ON public.task_assignments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

CREATE POLICY "assignments_select_member" ON public.task_assignments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

-- ── task_requests ────────────────────────────────────────────
ALTER TABLE public.task_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "requests_insert_member"  ON public.task_requests;
DROP POLICY IF EXISTS "requests_select_member"  ON public.task_requests;
DROP POLICY IF EXISTS "requests_update_member"  ON public.task_requests;
DROP POLICY IF EXISTS "requests_delete_member"  ON public.task_requests;

CREATE POLICY "requests_insert_member" ON public.task_requests
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

CREATE POLICY "requests_select_member" ON public.task_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

CREATE POLICY "requests_update_member" ON public.task_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

CREATE POLICY "requests_delete_member" ON public.task_requests
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.care_tasks t
      WHERE t.id = task_id AND public.is_team_member(t.care_team_id)
    )
  );

-- ── care_logs (already partially set in migration 000000) ────
-- Drop and recreate to ensure they use the same pattern.
ALTER TABLE public.care_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "logs_team_read"     ON public.care_logs;
DROP POLICY IF EXISTS "logs_team_insert"   ON public.care_logs;
DROP POLICY IF EXISTS "logs_author_delete" ON public.care_logs;

CREATE POLICY "logs_team_read" ON public.care_logs
  FOR SELECT USING (public.is_team_member(care_team_id));

CREATE POLICY "logs_team_insert" ON public.care_logs
  FOR INSERT WITH CHECK (public.is_team_member(care_team_id));

CREATE POLICY "logs_author_delete" ON public.care_logs
  FOR DELETE USING (
    author_contact_id IN (
      SELECT id FROM public.care_contacts
      WHERE linked_user_id = auth.uid()
    )
  );
