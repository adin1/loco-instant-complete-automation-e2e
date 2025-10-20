create extension if not exists postgis;
create extension if not exists citext;

create table if not exists tenants (
  id bigserial primary key,
  code text unique not null,
  name text not null,
  tz   text not null default 'Europe/Bucharest',
  is_active boolean not null default true
);

create table if not exists users (
  id bigserial primary key,
  tenant_id bigint references tenants(id) not null,
  role text not null check (role in ('customer','provider','admin')),
  phone_e164 text unique,
  email citext unique,
  password_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists providers (
  id bigserial primary key,
  tenant_id bigint references tenants(id) not null,
  user_id bigint references users(id) unique not null,
  display_name text not null,
  rating_avg numeric(3,2) default 0,
  rating_count int default 0,
  is_verified boolean default false
);

create table if not exists services (
  id bigserial primary key,
  tenant_id bigint references tenants(id) not null,
  slug text unique not null,
  name text not null
);

create table if not exists provider_services (
  provider_id bigint references providers(id),
  service_id bigint references services(id),
  base_price numeric(10,2),
  currency text default 'RON',
  primary key (provider_id, service_id)
);

create table if not exists locations (
  id bigserial primary key,
  tenant_id bigint references tenants(id) not null,
  owner_type text not null check (owner_type in ('provider','customer')),
  owner_id bigint not null,
  geom geography(Point, 4326) not null,
  address text,
  created_at timestamptz not null default now()
);
create index if not exists idx_locations_geom on locations using gist (geom);

create table if not exists orders (
  id bigserial primary key,
  tenant_id bigint references tenants(id) not null,
  customer_id bigint references users(id) not null,
  provider_id bigint references providers(id),
  service_id bigint references services(id) not null,
  status text not null check (status in ('pending','assigned','in_progress','completed','canceled')),
  price_estimate numeric(10,2),
  currency text default 'RON',
  origin_geom geography(Point, 4326) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
) partition by list (tenant_id);
create index if not exists idx_orders_origin on orders using gist (origin_geom);

create table if not exists order_items (
  id bigserial primary key,
  order_id bigint references orders(id) on delete cascade,
  description text,
  quantity int default 1,
  unit_price numeric(10,2)
);

create table if not exists order_events (
  id bigserial primary key,
  tenant_id bigint references tenants(id) not null,
  order_id bigint references orders(id) on delete cascade,
  event_type text not null,
  payload jsonb not null,
  created_at timestamptz not null default now()
) partition by list (tenant_id);
create index if not exists idx_order_events_order on order_events(order_id);

alter table orders enable row level security;
drop policy if exists tenant_isolation on orders;
create policy tenant_isolation on orders using (tenant_id = current_setting('app.tenant_id', true)::bigint);
create policy tenant_insert on orders for insert with check (tenant_id = current_setting('app.tenant_id', true)::bigint);

create or replace function set_updated_at() returns trigger as $$
begin new.updated_at := now(); return new; end; $$ language plpgsql;
drop trigger if exists trg_orders_updated_at on orders;
create trigger trg_orders_updated_at before update on orders for each row execute procedure set_updated_at();