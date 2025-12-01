"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SearchService = void 0;
const common_1 = require("@nestjs/common");
const opensearch_service_1 = require("../../infra/os/opensearch.service");
let SearchService = class SearchService {
    constructor(os) {
        this.os = os;
    }
    async searchProviders(q, lat, lon, radius = '5km') {
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
                            must: [{ multi_match: { query: q, fields: ['service_names', 'name^1.2'], operator: 'and' } }]
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
        const res = await this.os.client.search({ index: 'loco_providers', body });
        return res.body.hits.hits.map((h) => ({ id: h._id, score: h._score, ...h._source }));
    }
};
exports.SearchService = SearchService;
exports.SearchService = SearchService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [opensearch_service_1.OpenSearchService])
], SearchService);
//# sourceMappingURL=search.service.js.map