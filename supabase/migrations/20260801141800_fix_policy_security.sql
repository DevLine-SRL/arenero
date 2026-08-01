-- Migration: fix policy and function security
-- Atomic: only patches existing leaks, no new features.

SET check_function_bodies = false;

-- 1. Fix mutable search_path on SECURITY DEFINER functions

CREATE OR REPLACE FUNCTION public.is_active()
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and active = true
  );
$function$;

CREATE OR REPLACE FUNCTION public.is_admin()
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$function$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
begin
  insert into public.profiles (id, email, name)
  values (new.id, new.email, new.raw_user_meta_data->>'name');
  return new;
end;
$function$;

-- 2. Limit who can EXECUTE the functions

REVOKE EXECUTE ON FUNCTION public.is_active() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_active() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO supabase_auth_admin;

-- 3. Restrict policies to authenticated (anon no longer matches any policy)
--    and fix initplan so auth.uid()/is_admin() are not re-evaluated per row.

ALTER POLICY "Admin can insert" ON public.profiles
  TO authenticated
  WITH CHECK (public.is_admin());

ALTER POLICY "Admin can update" ON public.profiles
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

ALTER POLICY "Read own or admin read all" ON public.profiles
  TO authenticated
  USING ((id = (select auth.uid())) OR (select public.is_admin()));
