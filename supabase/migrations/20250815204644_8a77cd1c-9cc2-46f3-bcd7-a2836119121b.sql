-- Enums
create type public.tipo_usuario as enum ('admin', 'operador', 'associado');
create type public.associado_status as enum ('ativo','inativo','suspenso');
create type public.financeiro_tipo as enum ('receita','despesa');
create type public.contribuicao_status as enum ('pendente','pago','atrasado');
create type public.convenio_status as enum ('ativo','encerrado');
create type public.juridico_tipo as enum ('contrato','ata','regulamento','outro');
create type public.atendimento_status as enum ('em_andamento','concluido');

-- Timestamp trigger function
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Profiles table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text,
  email text,
  telefone text,
  tipo_usuario public.tipo_usuario not null default 'associado',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Helper functions for roles
create or replace function public.current_user_role()
returns public.tipo_usuario
language sql
stable
security definer
set search_path = public
as $$
  select tipo_usuario from public.profiles where id = auth.uid();
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select current_user_role() = 'admin'), false);
$$;

create or replace function public.is_operator()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((select current_user_role() = 'operador'), false);
$$;

-- Profiles RLS
create policy "Users can view their own profile" on public.profiles
for select to authenticated
using (id = auth.uid());

create policy "Admins can view all profiles" on public.profiles
for select to authenticated
using (public.is_admin());

create policy "Users can update their own profile" on public.profiles
for update to authenticated
using (id = auth.uid());

create policy "Admins can update all profiles" on public.profiles
for update to authenticated
using (public.is_admin());

-- Insert handled by trigger. Prevent direct inserts by clients
create policy "Disable direct insert into profiles" on public.profiles
for insert to authenticated with check (false);

create trigger update_profiles_updated_at
before update on public.profiles
for each row execute function public.update_updated_at_column();

-- Trigger to create profile on new auth user
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, nome, email, telefone)
  values (new.id, new.raw_user_meta_data ->> 'nome', new.email, new.raw_user_meta_data ->> 'telefone');
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Associados
create table if not exists public.associados (
  id uuid primary key default gen_random_uuid(),
  id_usuario uuid references auth.users(id) on delete set null,
  nome_completo text not null,
  cpf text not null unique,
  telefone text,
  endereco text,
  instrumento text,
  foto_url text,
  data_ingresso date,
  status public.associado_status not null default 'ativo',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.associados enable row level security;

create trigger update_associados_updated_at
before update on public.associados
for each row execute function public.update_updated_at_column();

-- Associados policies
create policy "Associados select by role or own" on public.associados
for select to authenticated
using (public.is_admin() or public.is_operator() or id_usuario = auth.uid());

create policy "Associados insert admin or operator" on public.associados
for insert to authenticated
with check (public.is_admin() or public.is_operator());

create policy "Associados update admin/operator or own" on public.associados
for update to authenticated
using (public.is_admin() or public.is_operator() or id_usuario = auth.uid());

create policy "Associados delete admin only" on public.associados
for delete to authenticated
using (public.is_admin());

-- Financeiro
create table if not exists public.financeiro (
  id uuid primary key default gen_random_uuid(),
  tipo public.financeiro_tipo not null,
  descricao text,
  valor numeric(12,2) not null,
  categoria text,
  data_lancamento date not null,
  id_usuario_responsavel uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.financeiro enable row level security;

create trigger update_financeiro_updated_at
before update on public.financeiro
for each row execute function public.update_updated_at_column();

create policy "Financeiro admin full select" on public.financeiro
for select to authenticated
using (public.is_admin());

create policy "Financeiro admin insert" on public.financeiro
for insert to authenticated
with check (public.is_admin());

create policy "Financeiro admin update" on public.financeiro
for update to authenticated
using (public.is_admin());

create policy "Financeiro admin delete" on public.financeiro
for delete to authenticated
using (public.is_admin());

-- Contribuicoes
create table if not exists public.contribuicoes (
  id uuid primary key default gen_random_uuid(),
  id_associado uuid not null references public.associados(id) on delete cascade,
  valor numeric(12,2) not null,
  data_pagamento date,
  status public.contribuicao_status not null default 'pendente',
  recibo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.contribuicoes enable row level security;

create trigger update_contribuicoes_updated_at
before update on public.contribuicoes
for each row execute function public.update_updated_at_column();

create policy "Contribuicoes select admin/operator or own" on public.contribuicoes
for select to authenticated
using (
  public.is_admin() or public.is_operator() or
  exists (
    select 1 from public.associados a
    where a.id = contribuicoes.id_associado and a.id_usuario = auth.uid()
  )
);

create policy "Contribuicoes insert admin/operator" on public.contribuicoes
for insert to authenticated
with check (public.is_admin() or public.is_operator());

create policy "Contribuicoes update admin/operator" on public.contribuicoes
for update to authenticated
using (public.is_admin() or public.is_operator());

create policy "Contribuicoes delete admin" on public.contribuicoes
for delete to authenticated
using (public.is_admin());

-- Convenios
create table if not exists public.convenios (
  id uuid primary key default gen_random_uuid(),
  nome_parceiro text not null,
  descricao text,
  beneficios text,
  data_inicio date,
  data_fim date,
  status public.convenio_status not null default 'ativo',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.convenios enable row level security;

create trigger update_convenios_updated_at
before update on public.convenios
for each row execute function public.update_updated_at_column();

create policy "Convenios are viewable by authenticated" on public.convenios
for select to authenticated using (true);

create policy "Convenios admin insert" on public.convenios
for insert to authenticated with check (public.is_admin());

create policy "Convenios admin update" on public.convenios
for update to authenticated using (public.is_admin());

create policy "Convenios admin delete" on public.convenios
for delete to authenticated using (public.is_admin());

-- Juridico
create table if not exists public.juridico (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  tipo_documento public.juridico_tipo not null,
  arquivo_url text not null,
  data_upload timestamptz not null default now(),
  id_usuario_responsavel uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.juridico enable row level security;

create trigger update_juridico_updated_at
before update on public.juridico
for each row execute function public.update_updated_at_column();

create policy "Juridico admin select" on public.juridico
for select to authenticated using (public.is_admin());
create policy "Juridico admin insert" on public.juridico
for insert to authenticated with check (public.is_admin());
create policy "Juridico admin update" on public.juridico
for update to authenticated using (public.is_admin());
create policy "Juridico admin delete" on public.juridico
for delete to authenticated using (public.is_admin());

-- Atendimentos
create table if not exists public.atendimentos (
  id uuid primary key default gen_random_uuid(),
  id_associado uuid not null references public.associados(id) on delete cascade,
  descricao text not null,
  status public.atendimento_status not null default 'em_andamento',
  data_abertura timestamptz not null default now(),
  data_conclusao timestamptz,
  id_usuario_responsavel uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.atendimentos enable row level security;

create trigger update_atendimentos_updated_at
before update on public.atendimentos
for each row execute function public.update_updated_at_column();

create policy "Atendimentos select admin/operator or own" on public.atendimentos
for select to authenticated
using (
  public.is_admin() or public.is_operator() or
  exists (
    select 1 from public.associados a
    where a.id = atendimentos.id_associado and a.id_usuario = auth.uid()
  )
);

create policy "Atendimentos insert admin/operator or own" on public.atendimentos
for insert to authenticated
with check (
  public.is_admin() or public.is_operator() or
  exists (
    select 1 from public.associados a
    where a.id = atendimentos.id_associado and a.id_usuario = auth.uid()
  )
);

create policy "Atendimentos update admin/operator" on public.atendimentos
for update to authenticated using (public.is_admin() or public.is_operator());
create policy "Atendimentos delete admin" on public.atendimentos
for delete to authenticated using (public.is_admin());

-- Storage buckets for documents and photos
insert into storage.buckets (id, name, public) values ('documentos','documentos', false)
on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('fotos','fotos', true)
on conflict (id) do nothing;

-- Storage policies
-- Fotos: public read, admin/operator write
create policy "Public can read fotos" on storage.objects
for select using (bucket_id = 'fotos');

create policy "Admin/Operator can upload fotos" on storage.objects
for insert to authenticated
with check (bucket_id = 'fotos' and (public.is_admin() or public.is_operator()));

create policy "Admin/Operator can update fotos" on storage.objects
for update to authenticated
using (bucket_id = 'fotos' and (public.is_admin() or public.is_operator()));

create policy "Admin/Operator can delete fotos" on storage.objects
for delete to authenticated
using (bucket_id = 'fotos' and (public.is_admin() or public.is_operator()));

-- Documentos: admin only
create policy "Admin can read documentos" on storage.objects
for select to authenticated using (bucket_id = 'documentos' and public.is_admin());

create policy "Admin can upload documentos" on storage.objects
for insert to authenticated with check (bucket_id = 'documentos' and public.is_admin());

create policy "Admin can update documentos" on storage.objects
for update to authenticated using (bucket_id = 'documentos' and public.is_admin());

create policy "Admin can delete documentos" on storage.objects
for delete to authenticated using (bucket_id = 'documentos' and public.is_admin());
