# CareConnect -- Local Setup Guide

Step-by-step instructions to run the full stack (PostgreSQL, Spring Boot backend, Flutter frontend) on a local machine. Tested on Windows with PowerShell.

## Prerequisites

- **Docker Desktop** -- running before you begin
- **Java JDK 17+** -- for the Spring Boot backend
- **Flutter SDK 3.38+** -- `flutter doctor` should pass
- **Chrome** -- for web target
- **Android Studio** -- for Android target (emulator + SDK)
- **Visual Studio Build Tools** -- for Windows desktop target (with "Desktop development with C++" workload)
- **Git**

---

## 1. Clone the Repository

```bash
git clone https://github.com/umgc/2026_summer_careconnect.git
cd 2026_summer_careconnect
```

---

## 2. Start PostgreSQL (Docker)

```powershell
cd backend/core/pg_docker
docker compose up -d
```

This starts PostgreSQL on **port 5432** (user: `postgres`, password: `changeme`, database: `careconnect`) and PgAdmin on port 5050.

Verify it's running:

```powershell
docker ps
```

You should see `postgres_container` and `pgadmin_container`.

---

## 3. Configure the Backend

Create the backend environment file by copying the sample:

```powershell
cd backend/core
cp sampleDotEnv.txt .env
```

Then edit `backend/core/.env` and make these two changes:

1. **`SECURITY_JWT_SECRET`** -- the sample value is a placeholder. The backend decodes this as Base64, so it must be a valid Base64 string. Use the dev default from `application-dev.properties`:

```
SECURITY_JWT_SECRET=LO3QMpyLGvU4mdLUbaFMgH5AKX+JoOAuO7y3SP1N+5pZ6d18xdUJXydVE7jMLGxoEBT4QtfMiWpSvpkFJRbPEA==
```

2. **`CARECONNECT_EMAIL_PROVIDER`** -- change from `sendgrid` to `console` so email sends are logged to the terminal instead of failing on a missing API key:

```
CARECONNECT_EMAIL_PROVIDER=console
```

The rest of the mock/placeholder values in the sample file are fine for local development.

---

## 4. Start the Backend

```powershell
cd backend/core
./mvnw spring-boot:run
```

Wait for the Spring Boot banner and `Started CareconnectApplication`. The backend runs on **http://localhost:8080**.

Quick health check (should return `401`, meaning the backend is up):

```powershell
curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/v1/api/auth/login -H "Content-Type: application/json" -d '{"email":"x","password":"x"}'
```

---

## 5. Configure the Frontend

Create a `.env` file in the frontend directory. This file must exist or the app crashes on startup, but for local dev it can be minimal:

```powershell
cd frontend
```

Create a file called `.env` in the `frontend/` directory with this single line:

```
BACKEND_URL=http://localhost:8080
```

**PowerShell note:** Do not use `echo ... > .env` -- PowerShell's `>` operator writes UTF-16LE, which causes a `FormatException: Invalid UTF-8 byte` crash at startup. Use your editor to create the file, or use:

```powershell
[IO.File]::WriteAllText("$PWD\.env", "BACKEND_URL=http://localhost:8080`n")
```

Then install dependencies:

```powershell
flutter pub get
```

---

## 6. Run the Frontend

### Web (Chrome)

```powershell
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:8080
```

**Important:** `BACKEND_URL` must be passed via `--dart-define` on the command line. The `.env` file alone does not set this variable -- the code reads it as a compile-time constant via `String.fromEnvironment()`, not from dotenv.

### Android (Emulator)

Start an emulator from Android Studio, then:

```powershell
flutter run -d emulator-5554
```

For Android, `BACKEND_URL` defaults to `http://10.0.2.2:8080` (the emulator's alias for the host machine's localhost), so `--dart-define` is optional. If the backend runs on a different port, pass it explicitly:

```powershell
flutter run -d emulator-5554 --dart-define=BACKEND_URL=http://10.0.2.2:8080
```

### Windows Desktop

```powershell
flutter run -d windows --dart-define=BACKEND_URL=http://localhost:8080
```

---

## Common Pitfalls

| Symptom | Cause | Fix |
|---|---|---|
| Backend crashes with `IllegalArgumentException: Illegal base64 character` | `SECURITY_JWT_SECRET` in `.env` is not valid Base64 | Use the Base64 string from step 3 |
| Frontend crashes immediately on startup | No `.env` file in `frontend/` | Create one, even if empty (step 5) |
| Frontend loads but can't reach the backend | `BACKEND_URL` was set in `.env` but not via `--dart-define` | Pass it on the command line: `--dart-define=BACKEND_URL=...` |
| `CARECONNECT_EMAIL_PROVIDER` errors / SendGrid 401 | Email provider set to `sendgrid` without a real API key | Set `CARECONNECT_EMAIL_PROVIDER=console` in backend `.env` |
| Android build fails with `dart:js_interop` errors | `package:web` compiled for native target | Apply the fix from the `fix/android-build-compat` branch |
| Android build fails with Kotlin metadata version error | Kotlin plugin version too old | Apply the fix from the `fix/android-build-compat` branch |

---

## What the Existing Docs Say vs. What Actually Works

The repository contains several setup guides (`frontend/README.md`, `docs/guides/local-dev-programmers-guide.md`) that may conflict with each other or reference outdated variable names. This README reflects the setup that was tested and verified to work as of May 2026.

Key differences from other docs:
- `frontend/README.md` references the `summer2025` repo, `.env.local`, and variables like `CC_BASE_URL_WEB` that no longer exist in the code.
- `local-dev-programmers-guide.md` uses a custom Docker container on port 5433 instead of the provided `docker-compose.yml` on port 5432.
- `load-env.bat` / `load-env.sh` check for variables (`CC_BASE_URL_WEB`, `CC_BASE_URL_ANDROID`, `CC_BASE_URL_OTHER`) that are not used anywhere in the Dart code.
