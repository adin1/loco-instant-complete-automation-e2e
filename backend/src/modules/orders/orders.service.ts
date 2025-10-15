import { Injectable } from '@nestjs/common';
import { PgService } from '../../infra/db/pg.service';

@Injectable()
export class OrdersService {
  constructor(private pg: PgService) {}
  async create(b: any) {
    const { customer_id, service_id, origin_lat, origin_lon, price_estimate } = b;
    const rows: any = await this.pg.query(
      `insert into orders(tenant_id, customer_id, service_id, status, origin_geom, price_estimate)
       values ((select id from tenants where code=$1), $2, $3, 'pending', ST_SetSRID(ST_MakePoint($4,$5),4326)::geography, $6)
       returning id`,
      [process.env.TENANT_CODE || 'cluj', customer_id, service_id, origin_lon, origin_lat, price_estimate]
    );
    const orderId = rows[0].id;
    await this.pg.query(
      `insert into order_events(tenant_id, order_id, event_type, payload)
       values ((select id from tenants where code=$1), $2, 'order_created', jsonb_build_object('order_id',$2))`,
      [process.env.TENANT_CODE || 'cluj', orderId]
    );
    return { id: orderId };
  }
}