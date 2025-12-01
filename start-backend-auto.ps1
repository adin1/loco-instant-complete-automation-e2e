$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Set environment variables for Prisma and database
$env:DATABASE_URL = "postgresql://postgres:postgres@localhost:5433/loco"
$env:REDIS_HOST = "localhost"
$env:REDIS_PORT = "6379"
$env:JWT_SECRET = "loco-instant-secret-key-2024"
$env:PORT = "3000"
$env:NODE_ENV = "development"

cd "C:\Users\Home\loco-instant-complete-automation-e2e.git\loco-instant-complete-automation-e2e\backend"
npm run start:dev
