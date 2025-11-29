$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
cd "C:\Users\Home\loco-instant-complete-automation-e2e.git\loco-instant-complete-automation-e2e\backend"
npm run start:dev
