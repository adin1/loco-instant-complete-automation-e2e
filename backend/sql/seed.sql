insert into tenants(code,name) values ('cluj','Cluj-Napoca') on conflict (code) do nothing;

with t as (select id from tenants where code='cluj')
insert into services(tenant_id, slug, name) values
((select id from t),'croitorie','Croitorie'),
((select id from t),'menaj','Menaj'),
((select id from t),'auto','Auto')
on conflict do nothing;

with t as (select id from tenants where code='cluj')
insert into users(tenant_id, role, email) values
((select id from t),'provider','maria@atelier.ro'),
((select id from t),'provider','ion@auto.ro'),
((select id from t),'customer','ana@client.ro')
on conflict do nothing;