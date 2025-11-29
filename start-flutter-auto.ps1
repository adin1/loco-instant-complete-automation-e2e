$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";C:\flutter\bin"
cd "C:\Users\Home\loco-instant-complete-automation-e2e.git\loco-instant-complete-automation-e2e\frontend\loco_instant_flutter"
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
