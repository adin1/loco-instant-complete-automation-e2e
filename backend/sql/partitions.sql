-- 1️⃣ Creează tenantul dacă nu există
insert into tenants (code, name)
values ('cluj', 'Cluj Tenant')
on conflict (code) do nothing;

-- 2️⃣ Creează partițiile pentru acest tenant
do $$
declare 
  v_cluj bigint;
begin
  select id into v_cluj from tenants where code = 'cluj';
  if v_cluj is null then
    raise exception 'Tenant cu codul "cluj" nu există';
  end if;

  execute format(
    'create table if not exists orders_p_cluj partition of orders for values in (%s);',
    v_cluj
  );

  execute format(
    'create table if not exists order_events_t_%s partition of order_events for values in (%s);',
    v_cluj, v_cluj
  );
end $$;

-- 3️⃣ Creează indexurile
create index if not exists idx_orders_p_cluj_status on orders_p_cluj(status);
create index if not exists idx_orders_p_cluj_created_at on orders_p_cluj(created_at);
create index if not exists idx_orders_p_cluj_origin on orders_p_cluj using gist (origin_geom);
