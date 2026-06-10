-- Use auth.uid() IS NOT NULL instead of auth.role() = 'authenticated'
-- which can behave inconsistently depending on session state.
DROP POLICY IF EXISTS "teams_insert_auth" ON public.care_teams;

CREATE POLICY "teams_insert_auth" ON public.care_teams
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
