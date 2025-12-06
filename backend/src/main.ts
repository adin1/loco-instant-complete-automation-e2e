import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as dotenv from 'dotenv';
import { ValidationPipe } from '@nestjs/common';
import { ExpressAdapter } from '@nestjs/platform-express';
import * as express from 'express';
import * as http from 'http';
dotenv.config();

async function bootstrap() {
  const port = Number(process.env.PORT) || 3000;
  
  // Create Express app and HTTP server manually
  const expressApp = express();
  const server = http.createServer(expressApp);
  
  // Start listening BEFORE NestJS initialization
  await new Promise<void>((resolve, reject) => {
    server.listen(port, '127.0.0.1', () => {
      console.log(`HTTP server listening on http://127.0.0.1:${port}`);
      resolve();
    });
    server.on('error', reject);
  });

  console.log('Creating NestFactory...');
  const app = await NestFactory.create(
    AppModule,
    new ExpressAdapter(expressApp),
    { cors: true }
  );
  console.log('NestFactory created');

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    transformOptions: { enableImplicitConversion: true },
  }));

  await app.init();
  console.log(`API ready on http://localhost:${port}`);
}

bootstrap().catch(err => {
  console.error('Bootstrap error:', err);
  process.exit(1);
});