
ALTER TABLE public.profiles
  ADD COLUMN last_seen_at timestamptz;

CREATE FUNCTION public.touch_last_seen()
  RETURNS timestamptz
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
  update public.profiles
  set last_seen_at = now()
  where id = (select auth.uid()) and active = true
  returning last_seen_at;
$function$;

REVOKE EXECUTE ON FUNCTION public.touch_last_seen() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.touch_last_seen() TO authenticated;
