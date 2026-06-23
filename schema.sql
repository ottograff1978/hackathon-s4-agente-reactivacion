-- Hackathon S4 - Schema
-- Ejecutar en Supabase -> SQL Editor -> Run

create table if not exists cuentas (
  id                bigint generated always as identity primary key,
  empresa           text not null,
  contacto          text not null,
  email             text,
  etapa             text default 'prospecto',
  ultimo_contacto   date,
  dias_sin_contacto integer,
  estatus_agente    text default 'pendiente',   -- pendiente | contactado | omitido
  mensaje_generado  text,
  verificado        boolean default false,
  intentos          integer default 0,
  costo_usd         numeric(10,6) default 0,
  notas_verificacion text,
  updated_at        timestamptz default now()
);

create table if not exists corridas (
  id                   bigint generated always as identity primary key,
  ejecutada_en         timestamptz default now(),
  carril               text,
  cuentas_procesadas   integer default 0,
  cuentas_contactadas  integer default 0,
  costo_total_usd      numeric(10,6) default 0,
  disparador           text default 'manual'    -- manual | schedule
);

alter table cuentas disable row level security;
alter table corridas disable row level security;

GRANT SELECT, UPDATE ON public.cuentas TO anon;
GRANT SELECT, INSERT ON public.corridas TO anon;
