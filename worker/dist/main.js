"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
async function bootstrap() {
    // For a worker, we just need a long-running process; opening an HTTP port is acceptable.
    const app = await core_1.NestFactory.create(app_module_1.AppModule, { logger: ['error', 'warn', 'log'] });
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
