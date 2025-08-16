-- Phase 1: Prevent privilege escalation and ensure profile population

-- 1) Create/Replace function to prevent non-admins from changing roles
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- Only admins can change tipo_usuario
    IF NEW.tipo_usuario IS DISTINCT FROM OLD.tipo_usuario THEN
      IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Only admins can change user roles';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

-- 2) Attach trigger to profiles table
DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_escalation
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_role_escalation();

-- 3) Ensure new auth users populate public.profiles automatically
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4) Ensure at least one admin exists (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles WHERE tipo_usuario = 'admin'
  ) THEN
    UPDATE public.profiles
       SET tipo_usuario = 'admin'
     WHERE id IN (
       SELECT id FROM public.profiles ORDER BY created_at ASC LIMIT 1
     );
  END IF;
END $$;

-- Phase 2: Data Access Control adjustments

-- 5) Restrict convenios visibility to admins and operators only
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'convenios'
      AND policyname = 'Convenios are viewable by authenticated'
  ) THEN
    EXECUTE 'DROP POLICY "Convenios are viewable by authenticated" ON public.convenios';
  END IF;
END $$;

CREATE POLICY "Convenios select admin/operator"
ON public.convenios
FOR SELECT
USING (public.is_admin() OR public.is_operator());
