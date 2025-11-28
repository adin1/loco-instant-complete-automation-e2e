import { Module } from '@nestjs/common';
import { SearchService } from './search.service';
import { SearchController } from './search.controller';
import { InfraModule } from '../../infra/infra.module';

@Module({
  imports: [InfraModule],
  providers: [SearchService],
  controllers: [SearchController],
})
export class SearchModule {}
