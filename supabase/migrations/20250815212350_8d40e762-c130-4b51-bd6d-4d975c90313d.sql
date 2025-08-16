begin;

-- 0) Utility: updated_at trigger function already exists (public.update_updated_at_column)
--    Utility: role helpers already exist (public.is_admin, public.is_operator)

-- 1) Ensure handle_new_user trigger on auth.users exists to populate profiles (usuarios)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2) Create/Replace function to prevent non-admins from changing roles
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.tipo_usuario IS DISTINCT FROM OLD.tipo_usuario THEN
      IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Only admins can change user roles';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

-- Attach trigger to profiles table
DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_escalation
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_role_escalation();

-- 3) Prevent deleting or demoting the last admin
CREATE OR REPLACE FUNCTION public.prevent_last_admin_loss()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
DECLARE
  admin_count int;
BEGIN
  SELECT count(*) INTO admin_count FROM public.profiles WHERE tipo_usuario = 'admin';

  IF TG_OP = 'DELETE' THEN
    IF OLD.tipo_usuario = 'admin' AND admin_count <= 1 THEN
      RAISE EXCEPTION 'Não é permitido remover o último admin';
    END IF;
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.tipo_usuario IS DISTINCT FROM OLD.tipo_usuario THEN
      IF OLD.tipo_usuario = 'admin' AND NEW.tipo_usuario <> 'admin' AND admin_count <= 1 THEN
        RAISE EXCEPTION 'Não é permitido rebaixar o último admin';
      END IF;
    END IF;
    RETURN NEW;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_last_admin_loss ON public.profiles;
CREATE TRIGGER trg_prevent_last_admin_loss
BEFORE UPDATE OR DELETE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_last_admin_loss();

-- 4) Schema adjustments
-- 4.1) associados: add profissao, ensure FK to profiles, make id_usuario NOT NULL if possible
ALTER TABLE public.associados
  ADD COLUMN IF NOT EXISTS profissao text;

DO $$
BEGIN
  -- Add FK if missing
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.associados'::regclass
      AND contype = 'f'
      AND conname = 'associados_id_usuario_fkey'
  ) THEN
    ALTER TABLE public.associados
      ADD CONSTRAINT associados_id_usuario_fkey
      FOREIGN KEY (id_usuario) REFERENCES public.profiles(id) ON DELETE CASCADE;
  END IF;

  -- Set NOT NULL only if there are no NULLs (keeps migration safe)
  IF NOT EXISTS (SELECT 1 FROM public.associados WHERE id_usuario IS NULL) THEN
    ALTER TABLE public.associados ALTER COLUMN id_usuario SET NOT NULL;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_associados_id_usuario ON public.associados(id_usuario);

-- 4.2) contribuicoes: FK to associados
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.contribuicoes'::regclass
      AND contype = 'f'
      AND conname = 'contribuicoes_id_associado_fkey'
  ) THEN
    ALTER TABLE public.contribuicoes
      ADD CONSTRAINT contribuicoes_id_associado_fkey
      FOREIGN KEY (id_associado) REFERENCES public.associados(id) ON DELETE CASCADE;
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_contribuicoes_id_associado ON public.contribuicoes(id_associado);

-- 4.3) atendimentos: FK to associados and profiles (responsável)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.atendimentos'::regclass
      AND contype = 'f'
      AND conname = 'atendimentos_id_associado_fkey'
  ) THEN
    ALTER TABLE public.atendimentos
      ADD CONSTRAINT atendimentos_id_associado_fkey
      FOREIGN KEY (id_associado) REFERENCES public.associados(id) ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.atendimentos'::regclass
      AND contype = 'f'
      AND conname = 'atendimentos_id_usuario_responsavel_fkey'
  ) THEN
    ALTER TABLE public.atendimentos
      ADD CONSTRAINT atendimentos_id_usuario_responsavel_fkey
      FOREIGN KEY (id_usuario_responsavel) REFERENCES public.profiles(id) ON DELETE SET NULL;
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_atendimentos_id_associado ON public.atendimentos(id_associado);
CREATE INDEX IF NOT EXISTS idx_atendimentos_id_usuario_responsavel ON public.atendimentos(id_usuario_responsavel);

-- 4.4) financeiro: FK to profiles (responsável)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.financeiro'::regclass
      AND contype = 'f'
      AND conname = 'financeiro_id_usuario_responsavel_fkey'
  ) THEN
    ALTER TABLE public.financeiro
      ADD CONSTRAINT financeiro_id_usuario_responsavel_fkey
      FOREIGN KEY (id_usuario_responsavel) REFERENCES public.profiles(id) ON DELETE SET NULL;
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_financeiro_id_usuario_responsavel ON public.financeiro(id_usuario_responsavel);

-- 4.5) juridico: FK to profiles (responsável)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.juridico'::regclass
      AND contype = 'f'
      AND conname = 'juridico_id_usuario_responsavel_fkey'
  ) THEN
    ALTER TABLE public.juridico
      ADD CONSTRAINT juridico_id_usuario_responsavel_fkey
      FOREIGN KEY (id_usuario_responsavel) REFERENCES public.profiles(id) ON DELETE SET NULL;
  END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_juridico_id_usuario_responsavel ON public.juridico(id_usuario_responsavel);

-- 5) New support tables
CREATE TABLE IF NOT EXISTS public.categorias_financeiras (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  descricao text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.categorias_financeiras ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.historico_contribuicoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_contribuicao uuid NOT NULL REFERENCES public.contribuicoes(id) ON DELETE CASCADE,
  acao text NOT NULL,
  data_acao timestamptz NOT NULL DEFAULT now(),
  id_usuario_responsavel uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.historico_contribuicoes ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.logs_atendimentos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_atendimento uuid NOT NULL REFERENCES public.atendimentos(id) ON DELETE CASCADE,
  descricao_acao text NOT NULL,
  data_acao timestamptz NOT NULL DEFAULT now(),
  id_usuario_responsavel uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.logs_atendimentos ENABLE ROW LEVEL SECURITY;

-- 6) RLS policies
-- 6.1) Convenios: restrict to admin and operator for full CRUD
DROP POLICY IF EXISTS "Convenios admin delete" ON public.convenios;
DROP POLICY IF EXISTS "Convenios admin insert" ON public.convenios;
DROP POLICY IF EXISTS "Convenios admin update" ON public.convenios;
DROP POLICY IF EXISTS "Convenios are viewable by authenticated" ON public.convenios;
DROP POLICY IF EXISTS "Convenios select admin/operator" ON public.convenios;
DROP POLICY IF EXISTS "Convenios insert admin/operator" ON public.convenios;
DROP POLICY IF EXISTS "Convenios update admin/operator" ON public.convenios;
DROP POLICY IF EXISTS "Convenios delete admin/operator" ON public.convenios;

CREATE POLICY "Convenios select admin/operator"
ON public.convenios FOR SELECT
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Convenios insert admin/operator"
ON public.convenios FOR INSERT
WITH CHECK (public.is_admin() OR public.is_operator());

CREATE POLICY "Convenios update admin/operator"
ON public.convenios FOR UPDATE
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Convenios delete admin/operator"
ON public.convenios FOR DELETE
USING (public.is_admin() OR public.is_operator());

-- 6.2) Financeiro: admin or operator for full CRUD
DROP POLICY IF EXISTS "Financeiro admin delete" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro admin full select" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro admin insert" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro admin update" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro select admin/operator" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro insert admin/operator" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro update admin/operator" ON public.financeiro;
DROP POLICY IF EXISTS "Financeiro delete admin/operator" ON public.financeiro;

CREATE POLICY "Financeiro select admin/operator"
ON public.financeiro FOR SELECT
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Financeiro insert admin/operator"
ON public.financeiro FOR INSERT
WITH CHECK (public.is_admin() OR public.is_operator());

CREATE POLICY "Financeiro update admin/operator"
ON public.financeiro FOR UPDATE
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Financeiro delete admin/operator"
ON public.financeiro FOR DELETE
USING (public.is_admin() OR public.is_operator());

-- 6.3) Juridico: admin or operator for full CRUD
DROP POLICY IF EXISTS "Juridico admin delete" ON public.juridico;
DROP POLICY IF EXISTS "Juridico admin insert" ON public.juridico;
DROP POLICY IF EXISTS "Juridico admin select" ON public.juridico;
DROP POLICY IF EXISTS "Juridico admin update" ON public.juridico;
DROP POLICY IF EXISTS "Juridico select admin/operator" ON public.juridico;
DROP POLICY IF EXISTS "Juridico insert admin/operator" ON public.juridico;
DROP POLICY IF EXISTS "Juridico update admin/operator" ON public.juridico;
DROP POLICY IF EXISTS "Juridico delete admin/operator" ON public.juridico;

CREATE POLICY "Juridico select admin/operator"
ON public.juridico FOR SELECT
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Juridico insert admin/operator"
ON public.juridico FOR INSERT
WITH CHECK (public.is_admin() OR public.is_operator());

CREATE POLICY "Juridico update admin/operator"
ON public.juridico FOR UPDATE
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Juridico delete admin/operator"
ON public.juridico FOR DELETE
USING (public.is_admin() OR public.is_operator());

-- 6.4) Categorias financeiras: admin/operator full CRUD
DROP POLICY IF EXISTS "Categorias select admin/operator" ON public.categorias_financeiras;
DROP POLICY IF EXISTS "Categorias insert admin/operator" ON public.categorias_financeiras;
DROP POLICY IF EXISTS "Categorias update admin/operator" ON public.categorias_financeiras;
DROP POLICY IF EXISTS "Categorias delete admin/operator" ON public.categorias_financeiras;

CREATE POLICY "Categorias select admin/operator"
ON public.categorias_financeiras FOR SELECT
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Categorias insert admin/operator"
ON public.categorias_financeiras FOR INSERT
WITH CHECK (public.is_admin() OR public.is_operator());

CREATE POLICY "Categorias update admin/operator"
ON public.categorias_financeiras FOR UPDATE
USING (public.is_admin() OR public.is_operator());

CREATE POLICY "Categorias delete admin/operator"
ON public.categorias_financeiras FOR DELETE
USING (public.is_admin() OR public.is_operator());

-- 6.5) Historico contribuições: admin/operator or owner can read; admin/operator can insert via app; admin only update/delete
DROP POLICY IF EXISTS "HistContrib select admin/operator/own" ON public.historico_contribuicoes;
DROP POLICY IF EXISTS "HistContrib insert admin/operator" ON public.historico_contribuicoes;
DROP POLICY IF EXISTS "HistContrib update admin" ON public.historico_contribuicoes;
DROP POLICY IF EXISTS "HistContrib delete admin" ON public.historico_contribuicoes;

CREATE POLICY "HistContrib select admin/operator/own"
ON public.historico_contribuicoes FOR SELECT
USING (public.is_admin() OR public.is_operator() OR id_usuario_responsavel = auth.uid());

CREATE POLICY "HistContrib insert admin/operator"
ON public.historico_contribuicoes FOR INSERT
WITH CHECK (public.is_admin() OR public.is_operator());

CREATE POLICY "HistContrib update admin"
ON public.historico_contribuicoes FOR UPDATE
USING (public.is_admin());

CREATE POLICY "HistContrib delete admin"
ON public.historico_contribuicoes FOR DELETE
USING (public.is_admin());

-- 6.6) Logs atendimentos: similar
DROP POLICY IF EXISTS "LogsAtend select admin/operator/own" ON public.logs_atendimentos;
DROP POLICY IF EXISTS "LogsAtend insert admin/operator" ON public.logs_atendimentos;
DROP POLICY IF EXISTS "LogsAtend update admin" ON public.logs_atendimentos;
DROP POLICY IF EXISTS "LogsAtend delete admin" ON public.logs_atendimentos;

CREATE POLICY "LogsAtend select admin/operator/own"
ON public.logs_atendimentos FOR SELECT
USING (public.is_admin() OR public.is_operator() OR id_usuario_responsavel = auth.uid());

CREATE POLICY "LogsAtend insert admin/operator"
ON public.logs_atendimentos FOR INSERT
WITH CHECK (public.is_admin() OR public.is_operator());

CREATE POLICY "LogsAtend update admin"
ON public.logs_atendimentos FOR UPDATE
USING (public.is_admin());

CREATE POLICY "LogsAtend delete admin"
ON public.logs_atendimentos FOR DELETE
USING (public.is_admin());

-- 7) updated_at triggers for all tables
-- Existing tables
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_associados_updated_at ON public.associados;
CREATE TRIGGER update_associados_updated_at
BEFORE UPDATE ON public.associados
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_contribuicoes_updated_at ON public.contribuicoes;
CREATE TRIGGER update_contribuicoes_updated_at
BEFORE UPDATE ON public.contribuicoes
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_convenios_updated_at ON public.convenios;
CREATE TRIGGER update_convenios_updated_at
BEFORE UPDATE ON public.convenios
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_financeiro_updated_at ON public.financeiro;
CREATE TRIGGER update_financeiro_updated_at
BEFORE UPDATE ON public.financeiro
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_juridico_updated_at ON public.juridico;
CREATE TRIGGER update_juridico_updated_at
BEFORE UPDATE ON public.juridico
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_atendimentos_updated_at ON public.atendimentos;
CREATE TRIGGER update_atendimentos_updated_at
BEFORE UPDATE ON public.atendimentos
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- New tables
DROP TRIGGER IF EXISTS update_categorias_financeiras_updated_at ON public.categorias_financeiras;
CREATE TRIGGER update_categorias_financeiras_updated_at
BEFORE UPDATE ON public.categorias_financeiras
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_historico_contribuicoes_updated_at ON public.historico_contribuicoes;
CREATE TRIGGER update_historico_contribuicoes_updated_at
BEFORE UPDATE ON public.historico_contribuicoes
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_logs_atendimentos_updated_at ON public.logs_atendimentos;
CREATE TRIGGER update_logs_atendimentos_updated_at
BEFORE UPDATE ON public.logs_atendimentos
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

commit;