# CareConnect – Copilot Instructions

## Project Overview
CareConnect is a full-stack healthcare app with a **Flutter frontend** (`frontend/`) and a **Spring Boot 3.4.5 backend** (`backend/core/`). It supports roles (ADMIN > CAREGIVER > PATIENT > FAMILY_MEMBER), real-time communication via WebSocket, AI chat, EVV, gamification, payments, and more.

---

## Build, Run & Test Commands

### Frontend (Flutter)
```bash
cd frontend
flutter pub get                        # Install dependencies
flutter analyze                        # Lint (uses flutter_lints)
flutter test                           # Run all tests
flutter test test/<file>_test.dart     # Run a single test file
flutter run                            # Run on default device
flutter run -d chrome                  # Run as web app
```

After changing `.arb` localization files:
```bash
flutter gen-l10n
```

After updating `@GenerateMocks` annotations:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Backend (Spring Boot)
```bash
cd backend/core
./run-dev.sh                           # Recommended: loads .env and starts with dev profile
# Or manually:
./load-env.sh mvn spring-boot:run -Dspring.profiles.active=dev
./mvnw test                            # Run all backend tests
./mvnw -Dtest=MyTestClass test         # Run a single test class
```

Swagger UI (when running): `http://localhost:8080/swagger-ui.html`

---

## Architecture

### Frontend (`frontend/lib/`)
- **State management**: `provider` package (`lib/providers/`)
- **Navigation**: `go_router` – all routes defined in `lib/config/router/app_router.dart`
- **HTTP**: `ApiClient` singleton (`lib/services/api_client.dart`) using Dio, auto-attaches JWT Bearer token from `AuthTokenManager`
- **Feature modules**: `lib/features/<feature>/` – each feature typically has `presentation/pages/`, `presentation/widgets/`, and service calls via `lib/services/`
- **Environment values**: all accessed via functions in `lib/config/env_constant.dart` (e.g., `getBackendBaseUrl()`, `getOpenAIKey()`). Never read `String.fromEnvironment` directly in feature code

### Backend (`backend/core/src/main/java/com/careconnect/`)
- **Layered architecture**: `controller` → `service` → `repository` (Spring Data JPA)
- **Database**: PostgreSQL (Docker via `pg_docker/`). Flyway migrations in `src/main/resources/db/migration/` (versioned `V<n>__description.sql`)
- **Auth**: JWT via `JwtAuthenticationFilter` + `JwtTokenProvider`. Use the `@RequirePermission(Permission.XYZ)` annotation on controller methods for fine-grained authorization
- **Roles & Permissions**: `Role.java` (enum), `Permission.java` (enum), enforced via `PermissionAspect` (AOP). Role hierarchy: `ADMIN > CAREGIVER > PATIENT > FAMILY_MEMBER`
- **Profiles**: `dev` (local Postgres, mocked external services, console email), `prod` (AWS SSM config, real services), `test`
- **AWS Lambda deployment**: `CcLambdaHandler.java` is the Lambda entry point; the app can run as both a regular Spring Boot app and a Lambda

---

## Key Conventions

### Environment Variables
- **Frontend**: all values are injected at compile time via `--dart-define=KEY=VALUE`. The `.env` file in `frontend/` is loaded by shell scripts (`load-env.sh` / `load-env.bat`) which pass values as `--dart-define`. **Always use the getter functions from `lib/config/env_constant.dart`** — never call `String.fromEnvironment` directly in feature code.
- **Backend**: loaded from `.env` file (via `spring.config.import=optional:file:.env[.properties]`) and resolved by `ParameterStoreService` (falls back to raw value if SSM is unavailable).

### Backend Dev Profile
When running with `-Dspring.profiles.active=dev`:
- Email is logged to console instead of sent
- Flyway is **disabled** (`ddl-auto=update` instead)
- OpenAI, DeepSeek, Stripe are disabled by default
- AWS features no-op gracefully if credentials are absent
- Dev JWT secret has a default; do not reuse in production

### Backend Security
Annotate controller methods with `@RequirePermission`:
```java
@GetMapping("/{id}")
@RequirePermission(Permission.VIEW_ASSIGNED_PATIENTS)
public ResponseEntity<?> getPatient(@PathVariable Long id) { ... }
```

### Testing Norms (`TESTING_NORMS.md`)
- **Prefer shared fixtures** over ad-hoc inline setup
- Unit tests must not have live DB/network dependencies
- Backend fixtures live in: `backend/core/src/test/java/com/careconnect/testsupport/fixtures/`
- Frontend fixtures and pump helpers live in: `frontend/test/test_support/`
- Use the `pumpCareConnectApp(tester, widget, providers: [...])` helper for Flutter widget tests
- Non-trivial test bodies use `// Arrange`, `// Act`, `// Assert` comments

### Localization
- Strings live in `frontend/lib/l10n/app_<locale>.arb` (e.g., `app_en.arb`, `app_es.arb`)
- Use a **feature-based prefix** for keys (e.g., `"login_tagline"`, `"dashboard_welcome"`)
- Access via `AppLocalizations.of(context)!.keyName`

### Database Migrations
- Add new Flyway files to `backend/core/src/main/resources/db/migration/` as `V<next_number>__description.sql`
- Flyway is disabled in the `dev` profile — use `ddl-auto=update` for local iteration, write the migration file for production

### WebSocket
- Backend supports both local Spring WebSocket and AWS API Gateway WebSocket (auto-detected via `AWS_WEBSOCKET_API_ENDPOINT` env var)
- Frontend WebSocket URLs are derived from `BACKEND_URL` in `env_constant.dart` — use the helper functions (`getChatWebSocketUrl()`, `getWebSocketNotificationUrl()`, etc.)
