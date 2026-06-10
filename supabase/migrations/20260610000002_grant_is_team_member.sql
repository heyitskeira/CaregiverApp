-- Grant execute on is_team_member to roles used by Supabase Auth
GRANT EXECUTE ON FUNCTION public.is_team_member(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_team_member(uuid) TO anon;
GRANT EXECUTE ON FUNCTION public.is_team_member(uuid) TO service_role;
