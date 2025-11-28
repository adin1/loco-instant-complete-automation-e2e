import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get()
  getRoot() {
    return {
      status: 'ok',
      service: 'loco-backend',
      docs: '/api/docs',
    };
  }

  @Get('healthz')
  getHealth() {
    return { status: 'ok', service: 'loco-backend' };
  }
}


