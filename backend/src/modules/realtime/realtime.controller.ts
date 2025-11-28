import { Controller, Get } from '@nestjs/common';

@Controller('realtime')
export class RealtimeController {
  @Get()
  health() {
    return { status: 'ok' };
  }
}


