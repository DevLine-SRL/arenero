CREATE TABLE public.login_attempts (
  email           text PRIMARY KEY,
  failed_count    integer NOT NULL DEFAULT 0,
  locked_until    timestamptz,
  last_attempt_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.login_attempts ENABLE ROW LEVEL SECURITY;


CREATE FUNCTION public.get_login_lock(p_email text)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  STABLE
  AS $function$
declare
  v_row public.login_attempts;
begin
  select * into v_row
  from public.login_attempts
  where email = lower(p_email);

  if v_row is null then
    return jsonb_build_object(
      'locked', false,
      'remaining_seconds', 0,
      'attempts_left', 5,
      'max_attempts', 5,
      'lock_minutes', 15
    );
  end if;

  if v_row.locked_until is not null and v_row.locked_until > now() then
    return jsonb_build_object(
      'locked', true,
      'remaining_seconds', greatest(0, extract(epoch from (v_row.locked_until - now()))::integer),
      'attempts_left', 0,
      'max_attempts', 5,
      'lock_minutes', 15
    );
  end if;

  return jsonb_build_object(
    'locked', false,
    'remaining_seconds', 0,
    'attempts_left', greatest(0, 5 - v_row.failed_count),
    'max_attempts', 5,
    'lock_minutes', 15
  );
end;
$function$;

CREATE FUNCTION public.register_failed_login(p_email text)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_row public.login_attempts;
  v_locked boolean := false;
  v_remaining integer := 0;
  v_attempts_left integer;
begin
  insert into public.login_attempts (email, failed_count)
  values (lower(p_email), 1)
  on conflict (email) do update
    set failed_count = public.login_attempts.failed_count + 1,
        last_attempt_at = now()
  returning * into v_row;

  if v_row.failed_count >= 5 then
    update public.login_attempts
    set locked_until = now() + interval '15 minutes',
        failed_count = 0
    where email = v_row.email
    returning * into v_row;

    v_locked := true;
    v_remaining := 15 * 60;
    v_attempts_left := 0;
  else
    v_attempts_left := 5 - v_row.failed_count;
  end if;

  return jsonb_build_object(
    'locked', v_locked,
    'remaining_seconds', v_remaining,
    'attempts_left', v_attempts_left,
    'max_attempts', 5,
    'lock_minutes', 15
  );
end;
$function$;

CREATE FUNCTION public.reset_login_attempts(p_email text)
  RETURNS void
  LANGUAGE sql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
  delete from public.login_attempts where email = lower(p_email);
$function$;

REVOKE EXECUTE ON FUNCTION public.get_login_lock(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_login_lock(text) TO anon, authenticated;

REVOKE EXECUTE ON FUNCTION public.register_failed_login(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.register_failed_login(text) TO anon, authenticated;

REVOKE EXECUTE ON FUNCTION public.reset_login_attempts(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.reset_login_attempts(text) TO authenticated;
