import { Injectable } from '@nestjs/common';
import { OpenSearchService } from '../../infra/os/opensearch.service';

@Injectable()
export class SearchService {
  constructor(private os: OpenSearchService) {}
  async searchProviders(q: string, lat: number, lon: number, radius = '5km') {
    const body = {
      size: 20,
      query: {
        function_score: {
          query: {
            bool: {
              filter: [
                { term: { tenant_code: process.env.TENANT_CODE || 'cluj' } },
                { geo_distance: { distance: radius, location: { lat, lon } } }
              ],
              must: [ { multi_match: { query: q, fields: ['service_names', 'name^1.2'], operator: 'and' } } ]
            }
          },
          boost_mode: 'sum',
          score_mode: 'sum',
          functions: [
            { gauss: { location: { origin: { lat, lon }, scale: '1000m', decay: 0.5 } } },
            { field_value_factor: { field: 'rating_avg', factor: 1.0, missing: 0 } }
          ]
        }
      },
      sort: ['_score']
    };
    // @ts-ignore
    const res = await this.os.client.search({ index: 'loco_providers', body });
    // @ts-ignore
    return res.body.hits.hits.map((h: any) => ({ id: h._id, score: h._score, ...h._source }));
  }
}