-- care_logs table for the Log feature
create table public.care_logs (
  id uuid primary key default gen_random_uuid(),
  care_team_id uuid not null references public.care_teams (id) on delete cascade,
  author_contact_id uuid not null references public.care_contacts (id) on delete cascade,
  content text not null default '',
  image_urls text[] not null default '{}',
  created_at timestamptz not null default now()
);

create index care_logs_team_idx on public.care_logs (care_team_id, created_at desc);

-- RLS
alter table public.care_logs enable row level security;

create policy "logs_team_read" on public.care_logs
  for select using (public.is_team_member(care_team_id));

create policy "logs_team_insert" on public.care_logs
  for insert with check (public.is_team_member(care_team_id));

create policy "logs_author_delete" on public.care_logs
  for delete using (
    author_contact_id in (
      select id from public.care_contacts
      where linked_user_id = auth.uid()
    )
  );

-- Storage bucket for log images (run once in dashboard or via Supabase CLI)
-- insert into storage.buckets (id, name, public) values ('log-images', 'log-images', false);
-- RLS for storage handled separately in Supabase Dashboard
