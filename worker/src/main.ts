import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap(): Promise<void> {
  // For a worker, we just need a long-running process; opening an HTTP port is acceptable.
  const app = await NestFactory.create(AppModule, { logger: ['error', 'warn', 'log'] });
  const port = process.env.PORT ? Number(process.env.PORT) : 3001;
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`Worker started and listening on port ${port}`);
}

bootstrap().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Failed to bootstrap worker', err);
  process.exit(1);
});


