import { IsObject } from 'class-validator';

export class CreateOpensearchDto {
  @IsObject()
  document: Record<string, any>;
}
