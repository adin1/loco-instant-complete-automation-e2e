-- =========================================================
-- EXTENSIONS
-- =========================================================
create extension if not exists postgis;
create extension if not exists citext;

-- =========================================================
-- TENANTS
-- =========================================================
create table if not exists tenants (
  id bigserial primary key,
  code text unique not null,
  name text not null,
  tz text not null default 'Europe/Bucharest',
  is_active boolean not null default true
);

-- =========================================================
-- USERS
-- =========================================================
drop table if exists users cascade;
create table users (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  role text not null check (role in ('customer','provider','admin')),
  phone_e164 text,
  email citext,
  password_hash text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (tenant_id, id),
  unique (tenant_id, phone_e164),
  unique (tenant_id, email)
);

-- =========================================================
-- PROVIDERS
-- =========================================================
drop table if exists providers cascade;
create table providers (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  user_id bigint not null,
  display_name text not null,
  rating_avg numeric(3,2) default 0,
  rating_count int default 0,
  is_verified boolean default false,
  primary key (tenant_id, id),
  unique (tenant_id, user_id),
  foreign key (tenant_id, user_id) references users(tenant_id, id)
);

-- =========================================================
-- SERVICES
-- =========================================================
drop table if exists services cascade;
create table services (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  slug text not null,
  name text not null,
  primary key (tenant_id, id),
  unique (tenant_id, slug)
);

-- =========================================================
-- PROVIDER SERVICES (BRIDGE TABLE)
-- =========================================================
drop table if exists provider_services cascade;
create table provider_services (
  tenant_id bigint not null references tenants(id),
  provider_id bigint not null,
  service_id bigint not null,
  base_price numeric(10,2),
  currency text default 'RON',
  primary key (tenant_id, provider_id, service_id),
  foreign key (tenant_id, provider_id) references providers(tenant_id, id),
  foreign key (tenant_id, service_id) references services(tenant_id, id)
);

-- =========================================================
-- LOCATIONS
-- =========================================================
drop table if exists locations cascade;
create table locations (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  owner_type text not null check (owner_type in ('provider','customer')),
  owner_id bigint not null,
  geom geography(Point, 4326) not null,
  address text,
  created_at timestamptz not null default now(),
  primary key (tenant_id, id)
);
create index if not exists idx_locations_geom on locations using gist (geom);

-- =========================================================
-- ORDERS (PARTITIONED)
-- =========================================================
drop table if exists orders cascade;
create table orders (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  customer_id bigint not null,
  provider_id bigint,
  service_id bigint not null,
  status text not null check (status in ('pending','assigned','in_progress','completed','canceled')),
  price_estimate numeric(10,2),
  currency text default 'RON',
  origin_geom geography(Point, 4326) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (tenant_id, id),
  foreign key (tenant_id, customer_id) references users(tenant_id, id),
  foreign key (tenant_id, provider_id) references providers(tenant_id, id),
  foreign key (tenant_id, service_id) references services(tenant_id, id)
) partition by list (tenant_id);

create index if not exists idx_orders_origin on orders using gist (origin_geom);

-- Example partition (create dynamically for each tenant)
-- create table orders_tenant_1 partition of orders for values in (1);

-- =========================================================
-- ORDER ITEMS
-- =========================================================
drop table if exists order_items cascade;
create table order_items (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  order_id bigint not null,
  description text,
  quantity int default 1,
  unit_price numeric(10,2),
  primary key (tenant_id, id),
  foreign key (tenant_id, order_id) references orders(tenant_id, id) on delete cascade
);

-- =========================================================
-- ORDER EVENTS (PARTITIONED)
-- =========================================================
drop table if exists order_events cascade;
create table order_events (
  id bigserial,
  tenant_id bigint not null references tenants(id),
  order_id bigint not null,
  event_type text not null,
  payload jsonb not null,
  created_at timestamptz not null default now(),
  primary key (tenant_id, id),
  foreign key (tenant_id, order_id) references orders(tenant_id, id) on delete cascade
) partition by list (tenant_id);

create index if not exists idx_order_events_order on order_events(order_id);

-- Example partition (create dynamically for each tenant)
-- create table order_events_tenant_1 partition of order_events for values in (1);

-- =========================================================
-- RLS (ROW LEVEL SECURITY)
-- =========================================================
alter table orders enable row level security;
drop policy if exists tenant_isolation on orders;
create policy tenant_isolation
  on orders
  using (tenant_id = current_setting('app.tenant_id', true)::bigint);

drop policy if exists tenant_insert on orders;
create policy tenant_insert
  on orders
  for insert
  with check (tenant_id = current_setting('app.tenant_id', true)::bigint);

-- =========================================================
-- UPDATED_AT TRIGGER
-- =========================================================
create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at := now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_orders_updated_at on orders;
create trigger trg_orders_updated_at
before update on orders
for each row execute procedure set_updated_at();
