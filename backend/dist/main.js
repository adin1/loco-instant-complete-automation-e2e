"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const dotenv = require("dotenv");
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const express = require("express");
const http = require("http");
dotenv.config();
async function bootstrap() {
    const port = Number(process.env.PORT) || 3000;
    const expressApp = express();
    const server = http.createServer(expressApp);
    await new Promise((resolve, reject) => {
        server.listen(port, '127.0.0.1', () => {
            console.log(`HTTP server listening on http://127.0.0.1:${port}`);
            resolve();
        });
        server.on('error', reject);
    });
    console.log('Creating NestFactory...');
    const app = await core_1.NestFactory.create(app_module_1.AppModule, new platform_express_1.ExpressAdapter(expressApp), { cors: true });
    console.log('NestFactory created');
    app.useGlobalPipes(new common_1.ValidationPipe({
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
//# sourceMappingURL=main.js.map