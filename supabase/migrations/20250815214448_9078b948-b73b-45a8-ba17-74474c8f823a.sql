-- 1) Harden update_updated_at function with explicit search_path
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

-- 2) Trigger: populate profiles (usuarios) on new auth user
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
  ) THEN
    CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  END IF;
END$$;

-- 3) Triggers: protect role changes and ensure last admin is preserved
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profiles_role_protection'
  ) THEN
    CREATE TRIGGER trg_profiles_role_protection
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.prevent_role_escalation();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_profiles_last_admin_guard'
  ) THEN
    CREATE TRIGGER trg_profiles_last_admin_guard
    BEFORE UPDATE OR DELETE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.prevent_last_admin_loss();
  END IF;
END$$;

-- 4) Triggers: auto-manage updated_at in all app tables
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT unnest(ARRAY[
    'public.profiles',
    'public.associados',
    'public.atendimentos',
    'public.categorias_financeiras',
    'public.contribuicoes',
    'public.convenios',
    'public.financeiro',
    'public.historico_contribuicoes',
    'public.juridico',
    'public.logs_atendimentos'
  ]) AS tbl
  LOOP
    -- Build a unique trigger name per table
    EXECUTE format('DO $$ BEGIN IF NOT EXISTS (
      SELECT 1 FROM pg_trigger WHERE tgname = %L
    ) THEN CREATE TRIGGER %I BEFORE UPDATE ON %s FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column(); END IF; END $$;',
      'trg_update_ts_' || replace(split_part(r.tbl, '.', 2), '"', ''),
      'trg_update_ts_' || replace(split_part(r.tbl, '.', 2), '"', ''),
      r.tbl
    );
  END LOOP;
END $$;

-- 5) Storage policies
-- Fotos bucket: public read, owner writes (path: <user_id>/...)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Public read on fotos'
  ) THEN
    CREATE POLICY "Public read on fotos"
    ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'fotos');
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Users can upload own photos to fotos'
  ) THEN
    CREATE POLICY "Users can upload own photos to fotos"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
      bucket_id = 'fotos'
      AND auth.uid()::text = (storage.foldername(name))[1]
    );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Users can manage own photos in fotos'
  ) THEN
    CREATE POLICY "Users can manage own photos in fotos"
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (
      bucket_id = 'fotos'
      AND auth.uid()::text = (storage.foldername(name))[1]
    )
    WITH CHECK (
      bucket_id = 'fotos'
      AND auth.uid()::text = (storage.foldername(name))[1]
    );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Users can delete own photos in fotos'
  ) THEN
    CREATE POLICY "Users can delete own photos in fotos"
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (
      bucket_id = 'fotos'
      AND auth.uid()::text = (storage.foldername(name))[1]
    );
  END IF;
END $$;

-- Documentos bucket: private, admins/operators full read/write, owners can read their own
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Docs: read admin/operator or owner'
  ) THEN
    CREATE POLICY "Docs: read admin/operator or owner"
    ON storage.objects
    FOR SELECT
    TO authenticated
    USING (
      bucket_id = 'documentos'
      AND (
        public.is_admin() OR public.is_operator() OR auth.uid()::text = (storage.foldername(name))[1]
      )
    );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Docs: write admin/operator'
  ) THEN
    CREATE POLICY "Docs: write admin/operator"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
      bucket_id = 'documentos' AND (public.is_admin() OR public.is_operator())
    );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Docs: update admin/operator'
  ) THEN
    CREATE POLICY "Docs: update admin/operator"
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (
      bucket_id = 'documentos' AND (public.is_admin() OR public.is_operator())
    )
    WITH CHECK (
      bucket_id = 'documentos' AND (public.is_admin() OR public.is_operator())
    );
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Docs: delete admin/operator'
  ) THEN
    CREATE POLICY "Docs: delete admin/operator"
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (
      bucket_id = 'documentos' AND (public.is_admin() OR public.is_operator())
    );
  END IF;
END $$;