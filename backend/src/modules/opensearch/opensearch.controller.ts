import { Controller, Post, Get, Put, Delete, Body, Param, UsePipes, ValidationPipe } from '@nestjs/common';
import { OpensearchService } from './opensearch.service';
import { CreateOpensearchDto } from './create-opensearch.dto';

@Controller('opensearch')
export class OpensearchController {
  constructor(private readonly opensearchService: OpensearchService) {}

  @Post(':index/:id')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async create(
    @Param('index') index: string,
    @Param('id') id: string,
    @Body() body: CreateOpensearchDto,
  ) {
    return this.opensearchService.createDocument(index, id, body.document);
  }

  @Get(':index/:id')
  async read(@Param('index') index: string, @Param('id') id: string) {
    return this.opensearchService.getDocument(index, id);
  }

  @Put(':index/:id')
  @UsePipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }))
  async update(
    @Param('index') index: string,
    @Param('id') id: string,
    @Body() body: CreateOpensearchDto,
  ) {
    return this.opensearchService.updateDocument(index, id, body.document);
  }

  @Delete(':index/:id')
  async delete(@Param('index') index: string, @Param('id') id: string) {
    return this.opensearchService.deleteDocument(index, id);
  }

  @Post(':index/_search')
  async search(@Param('index') index: string, @Body() body: any) {
    return this.opensearchService.searchDocuments(index, body);
  }
}
