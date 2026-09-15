CREATE OR REPLACE FUNCTION public.audit_profiles_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_old jsonb;
  v_new jsonb;
begin
  if tg_op = 'INSERT' then
    perform public.log_audit(
      'profiles',
      new.id,
      'INSERT',
      null,
      jsonb_build_object(
        'name', new.name,
        'email', new.email,
        'role', new.role,
        'active', new.active
      ),
      null
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    v_old := jsonb_build_object(
      'name', old.name,
      'email', old.email,
      'role', old.role,
      'active', old.active
    );
    v_new := jsonb_build_object(
      'name', new.name,
      'email', new.email,
      'role', new.role,
      'active', new.active
    );

    if v_old <> v_new then
      if old.name is not distinct from new.name
         and old.email is not distinct from new.email
         and old.role is not distinct from new.role
         and old.active is distinct from new.active then
        perform public.log_audit('profiles', new.id, 'TOGGLE_ACTIVE', v_old, v_new, null);
      else
        perform public.log_audit('profiles', new.id, 'UPDATE', v_old, v_new, null);
      end if;
    end if;
    return new;
  end if;

  return null;
end;
$function$;

CREATE OR REPLACE FUNCTION public.audit_clients_changes()
  RETURNS trigger
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path = ''
  AS $function$
declare
  v_old jsonb;
  v_new jsonb;
begin
  if tg_op = 'INSERT' then
    perform public.log_audit(
      'clients',
      new.id,
      'INSERT',
      null,
      jsonb_build_object(
        'name', new.name,
        'ci', new.ci,
        'phone', new.phone,
        'nit', new.nit,
        'active', new.active
      ),
      null
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    v_old := jsonb_build_object(
      'name', old.name,
      'ci', old.ci,
      'phone', old.phone,
      'nit', old.nit,
      'active', old.active
    );
    v_new := jsonb_build_object(
      'name', new.name,
      'ci', new.ci,
      'phone', new.phone,
      'nit', new.nit,
      'active', new.active
    );

    if v_old <> v_new then
      if old.name is not distinct from new.name
         and old.ci is not distinct from new.ci
         and old.phone is not distinct from new.phone
         and old.nit is not distinct from new.nit
         and old.active is distinct from new.active then
        perform public.log_audit('clients', new.id, 'TOGGLE_ACTIVE', v_old, v_new, null);
      else
        perform public.log_audit('clients', new.id, 'UPDATE', v_old, v_new, null);
      end if;
    end if;
    return new;
  end if;

  return null;
end;
$function$;


REVOKE EXECUTE ON FUNCTION public.audit_profiles_changes()
  FROM PUBLIC, anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.audit_clients_changes()
  FROM PUBLIC, anon, authenticated, service_role;
