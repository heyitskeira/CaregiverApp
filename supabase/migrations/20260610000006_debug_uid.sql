CREATE OR REPLACE FUNCTION public.debug_uid()
RETURNS text LANGUAGE sql SECURITY INVOKER AS
$$ SELECT COALESCE(auth.uid()::text, 'NULL:role=' || auth.role()); $$;

GRANT EXECUTE ON FUNCTION public.debug_uid() TO anon, authenticated, service_role;
