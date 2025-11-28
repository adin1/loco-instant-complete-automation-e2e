import { Module } from '@nestjs/common';
import { OpensearchService } from './opensearch.service';
import { OpensearchController } from './opensearch.controller';
import { OpensearchModule as NestjsOpensearchModule } from 'nestjs-opensearch';

@Module({
  imports: [
    NestjsOpensearchModule.forRoot({
      node: process.env.OPENSEARCH_NODE || 'http://localhost:9200',
      auth: {
        username: process.env.OPENSEARCH_USERNAME || 'admin',
        password: process.env.OPENSEARCH_PASSWORD || 'admin',
      },
    })
  ],
  providers: [OpensearchService],
  controllers: [OpensearchController]
})
export class OpensearchModule {}
