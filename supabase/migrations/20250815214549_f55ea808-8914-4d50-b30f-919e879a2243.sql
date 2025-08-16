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

-- 4) Triggers: auto-manage updated_at in all app tables (explicit per table)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_profiles') THEN
    CREATE TRIGGER trg_update_ts_profiles BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_associados') THEN
    CREATE TRIGGER trg_update_ts_associados BEFORE UPDATE ON public.associados FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_atendimentos') THEN
    CREATE TRIGGER trg_update_ts_atendimentos BEFORE UPDATE ON public.atendimentos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_categorias_financeiras') THEN
    CREATE TRIGGER trg_update_ts_categorias_financeiras BEFORE UPDATE ON public.categorias_financeiras FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_contribuicoes') THEN
    CREATE TRIGGER trg_update_ts_contribuicoes BEFORE UPDATE ON public.contribuicoes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_convenios') THEN
    CREATE TRIGGER trg_update_ts_convenios BEFORE UPDATE ON public.convenios FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_financeiro') THEN
    CREATE TRIGGER trg_update_ts_financeiro BEFORE UPDATE ON public.financeiro FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_historico_contribuicoes') THEN
    CREATE TRIGGER trg_update_ts_historico_contribuicoes BEFORE UPDATE ON public.historico_contribuicoes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_juridico') THEN
    CREATE TRIGGER trg_update_ts_juridico BEFORE UPDATE ON public.juridico FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_ts_logs_atendimentos') THEN
    CREATE TRIGGER trg_update_ts_logs_atendimentos BEFORE UPDATE ON public.logs_atendimentos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
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