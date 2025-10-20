do $$
declare v_cluj bigint := (select id from tenants where code='cluj');
begin
  execute format('create table if not exists orders_p_cluj partition of orders for values in (%s);', v_cluj);
  execute format('create table if not exists order_events_t_%s partition of order_events for values in (%s);', v_cluj, v_cluj);
end $$;

create index if not exists idx_orders_p_cluj_status on orders_p_cluj(status);
create index if not exists idx_orders_p_cluj_created_at on orders_p_cluj(created_at);
create index if not exists idx_orders_p_cluj_origin on orders_p_cluj using gist (origin_geom);