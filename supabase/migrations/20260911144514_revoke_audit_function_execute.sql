REVOKE EXECUTE ON FUNCTION public.log_audit(
  text,
  uuid,
  text,
  jsonb,
  jsonb,
  jsonb
) FROM PUBLIC, anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.audit_profiles_changes()
  FROM PUBLIC, anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.audit_clients_changes()
  FROM PUBLIC, anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.audit_products_changes()
  FROM PUBLIC, anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.audit_product_units_changes()
  FROM PUBLIC, anon, authenticated, service_role;

REVOKE EXECUTE ON FUNCTION public.audit_sales_payment_changes()
  FROM PUBLIC, anon, authenticated, service_role;
