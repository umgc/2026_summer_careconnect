# Unit Testing Guide — CareConnect Java Backend

This guide covers how to write, structure, and run unit tests for the Spring Boot
backend at `backend/core`. It is written against the libraries and conventions
already present in `pom.xml` and the existing test suite.

---

## Table of Contents

1. [Stack at a Glance](#1-stack-at-a-glance)
2. [Test Properties and Profiles](#2-test-properties-and-profiles)
3. [Choosing the Right Test Style](#3-choosing-the-right-test-style)
4. [Pure Unit Tests with Mockito](#4-pure-unit-tests-with-mockito)
5. [Controller Tests with MockMvc](#5-controller-tests-with-mockmvc)
6. [Fixture Builders](#6-fixture-builders)
7. [Naming and Structure Conventions](#7-naming-and-structure-conventions)
8. [What to Assert](#8-what-to-assert)
9. [Common Pitfalls](#9-common-pitfalls)
10. [Running Tests](#10-running-tests)

---

## 1. Stack at a Glance

| Library | Version | Purpose |
|---|---|---|
| **JUnit 5** (Jupiter) | via `spring-boot-starter-test` | Test runner, `@Test`, `@Nested`, lifecycle hooks |
| **Mockito 5** | 5.21.0 + bundled | Creating mocks, stubs, argument captors, verification |
| **AssertJ** | via `spring-boot-starter-test` | Fluent assertions (`assertThat(...)`) |
| **Spring MockMvc** | via `spring-boot-starter-test` | HTTP-layer testing without a real server |
| **Spring Security Test** | managed | `@WithMockUser`, `SecurityMockMvcRequestPostProcessors` |
| **H2** | managed (test scope) | In-memory database for tests that need JPA |
| **Hamcrest** | via `spring-boot-starter-test` | JSON path matchers used with MockMvc |

You do **not** need to add any of these to `pom.xml`; they are already on the
test classpath.

---

## 2. Test Properties and Profiles

Two property files live under `src/test/resources/`:

| File | Loaded when |
|---|---|
| `application.properties` | Every test run — suppresses all logging |
| `application-test.properties` | When `@ActiveProfiles("test")` is set, or for full-context tests |

`application-test.properties` handles everything required to start the
application context without real infrastructure:

- Swaps PostgreSQL for an **H2 in-memory database** (`jdbc:h2:mem:testdb`)
- Disables **Flyway** (DDL managed by Hibernate `create-drop` instead)
- Stubs all external credentials (JWT secret, Stripe keys, AWS keys, OAuth
  client IDs, etc.)
- Disables all AWS services, telemetry, and scheduled tasks

For pure unit tests (no Spring context) you do not need to reference these
files at all — Mockito handles everything.

---

## 3. Choosing the Right Test Style

Pick the **narrowest** style that verifies what you need:

```
Service / utility logic  →  Pure Mockito unit test         (fastest, no Spring)
Controller HTTP layer    →  @WebMvcTest + MockMvc           (MVC slice only)
JPA repository queries   →  @DataJpaTest + H2               (JPA slice only)
Full Spring context      →  @SpringBootTest                 (slowest — avoid)
```

Most tests in this codebase use one of the first two styles. Full
`@SpringBootTest` tests should be reserved for integration tests that genuinely
require the complete application context (e.g., end-to-end call flow scenarios).

---

## 4. Pure Unit Tests with Mockito

Use this style for services, config classes, startup components, security
utilities, and any class whose collaborators can be injected.

### 4.1 Two ways to initialise mocks

**Option A — `@ExtendWith(MockitoExtension.class)` (preferred)**

```java
@ExtendWith(MockitoExtension.class)
class GamificationControllerTest {

    @Mock
    private GamificationService gamificationService;

    @Mock
    private SecurityUtil securityUtil;

    @InjectMocks
    private GamificationController controller;

    @Test
    void awardXp_returns200_withUpdatedProgress() {
        XPProgress progress = mock(XPProgress.class);
        when(gamificationService.awardXp(42L, 50)).thenReturn(progress);

        ResponseEntity<?> response = controller.awardXp(Map.of("userId", 42L, "amount", 50));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isSameAs(progress);
    }
}
```

The extension initialises `@Mock` fields before each test and tears them down
after — no manual setup required.

**Option B — `MockitoAnnotations.openMocks(this)` in `@BeforeEach`**

Use this when you need to capture the `AutoCloseable` returned by `openMocks`
(e.g., to assert in `@AfterEach` that no unexpected interactions occurred), or
when the class cannot use JUnit extensions.

```java
class AchievementInitializerTest {

    @Mock
    private AchievementRepository achievementRepository;

    @InjectMocks
    private AchievementInitializer achievementInitializer;

    private AutoCloseable mocks;

    @BeforeEach
    void setUp() {
        mocks = MockitoAnnotations.openMocks(this);
    }

    @AfterEach
    void tearDown() throws Exception {
        mocks.close();
    }
}
```

### 4.2 Constructing mocks inline

For one-off collaborators that are not injected:

```java
DataSource dataSource = mock(DataSource.class);
Connection connection = mock(Connection.class);
when(dataSource.getConnection()).thenReturn(connection);
```

### 4.3 Stubbing

```java
// Return a value
when(repo.findByTitle("First Login")).thenReturn(Optional.of(achievement));

// Return different values on successive calls
when(dataSource.getConnection())
    .thenReturn(connection)                               // first call
    .thenThrow(new RuntimeException("pool exhausted"));  // second call

// Void methods
doNothing().when(allergyService).deactivateAllergy(1L);
doThrow(new IllegalArgumentException("not found"))
    .when(allergyService).deleteAllergy(99L);

// Answer (compute a return value from arguments)
when(repo.save(any(Achievement.class)))
    .thenAnswer(invocation -> invocation.getArgument(0));
```

### 4.4 Argument matchers

```java
// Match any instance
when(repo.save(any(Achievement.class))).thenReturn(saved);

// Match any string
when(repo.findByTitle(anyString())).thenReturn(Optional.empty());

// Exact value
when(service.getXpProgress(42L)).thenReturn(Optional.of(progress));

// Custom predicate
when(repo.save(argThat(a -> "First Login".equals(a.getTitle()))))
    .thenReturn(saved);

// Exact value in a mixed call (must wrap all args in matchers)
when(service.updateAllergy(eq(1L), any(AllergyDTO.class))).thenReturn(updated);
```

### 4.5 Verification

```java
// Called exactly once with any argument
verify(repo).save(any(Achievement.class));

// Called N times
verify(repo, times(5)).save(any(Achievement.class));

// Never called
verify(statement, never()).executeUpdate(anyString());

// Called at least N times
verify(repo, atLeast(3)).save(any(Achievement.class));

// No interactions at all
verifyNoInteractions(dataSource);
```

### 4.6 ArgumentCaptor

Use an `ArgumentCaptor` to inspect the exact value passed to a mock:

```java
ArgumentCaptor<Achievement> captor = ArgumentCaptor.forClass(Achievement.class);
when(repo.save(captor.capture())).thenAnswer(inv -> inv.getArgument(0));

initializer.initAchievements();

List<Achievement> saved = captor.getAllValues();
assertThat(saved).hasSize(5);
assertThat(saved).extracting(Achievement::getTitle)
    .containsExactlyInAnyOrder(
        "First Login", "Made a Friend", "Added Family Member",
        "First Post Created", "5-Day Streak");
```

### 4.7 Lenient stubs

By default Mockito 5 fails tests with unused stubs. Use `lenient()` only for
stubs set up in `@BeforeEach` that are not exercised by every test:

```java
lenient().when(mockUser.getEmail()).thenReturn("test@example.com");
```

Do **not** use `lenient()` as a blanket workaround for unexpected stub warnings —
that defeats the purpose. Instead, move stubs that are only needed by some tests
into those tests directly.

---

## 5. Controller Tests with MockMvc

Use `@WebMvcTest` to test the HTTP layer of a single controller. It starts only
the MVC slice — no database, no service implementations.

### 5.1 Class-level setup

```java
@WebMvcTest(AllergyController.class)
@AutoConfigureMockMvc(addFilters = false)   // disable security filters
class AllergyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    // Replace every Spring bean the controller depends on:
    @MockitoBean private AllergyService allergyService;
    @MockitoBean private UserRepository userRepository;
    @MockitoBean private PatientRepository patientRepository;
    @MockitoBean private SecurityUtil securityUtil;
    @MockitoBean private AuthorizationService authorizationService;
}
```

`@MockitoBean` (Spring Boot 3.4+) replaces the named bean in the application
context with a Mockito mock for the duration of the test class.

> **Note:** `addFilters = false` disables the security filter chain so you can
> set the `SecurityContextHolder` manually per test. This lets each test
> precisely control which user is active without running OAuth or JWT filters.

### 5.2 Simulating a logged-in user

Set up the `SecurityContextHolder` directly:

```java
private void mockSecurityContext(String email, User user) {
    Authentication auth = mock(Authentication.class);
    when(auth.getName()).thenReturn(email);
    SecurityContext ctx = mock(SecurityContext.class);
    when(ctx.getAuthentication()).thenReturn(auth);
    SecurityContextHolder.setContext(ctx);
    when(userRepository.findByEmail(email)).thenReturn(Optional.of(user));
}
```

Always clear it in `@AfterEach`:

```java
@AfterEach
void tearDown() {
    SecurityContextHolder.clearContext();
}
```

### 5.3 Making requests and asserting responses

```java
// GET
mockMvc.perform(get("/v1/api/allergies/patient/10"))
    .andExpect(status().isOk())
    .andExpect(jsonPath("$.message", is("Allergies retrieved successfully")))
    .andExpect(jsonPath("$.data[0].allergen", is("Penicillin")));

// POST with JSON body
mockMvc.perform(post("/v1/api/allergies")
        .contentType(MediaType.APPLICATION_JSON)
        .content(objectMapper.writeValueAsString(allergyDto)))
    .andExpect(status().isCreated())
    .andExpect(jsonPath("$.data.severity", is("SEVERE")));

// PATCH / DELETE
mockMvc.perform(patch("/v1/api/allergies/1/deactivate"))
    .andExpect(status().isOk())
    .andExpect(jsonPath("$.message", is("Allergy deactivated successfully")));

mockMvc.perform(delete("/v1/api/allergies/1"))
    .andExpect(status().isOk());
```

Common status matchers: `isOk()` (200), `isCreated()` (201), `isBadRequest()` (400),
`isForbidden()` (403), `isNotFound()` (404), `isInternalServerError()` (500).

### 5.4 What to cover in a controller test

For every endpoint test at minimum:

| Scenario | Status |
|---|---|
| Happy path — valid input, authorised user | 2xx |
| Resource not found | 404 |
| Unauthorised access (wrong user/role) | 403 |
| Bad input / business rule violation | 400 |
| Unexpected service exception | 500 |

---

## 6. Fixture Builders

Shared test fixtures live in `src/test/java/com/careconnect/testsupport/fixtures/`.

```java
import com.careconnect.testsupport.fixtures.TaskFixtures;
import com.careconnect.testsupport.fixtures.PatientFixtures;

Task task      = TaskFixtures.taskWithId(42L);
Patient patient = PatientFixtures.basicPatient();
TaskDtoV2 dto  = TaskFixtures.taskDtoForCreate();
```

Use these instead of constructing model objects inline across multiple test
classes. When a model's constructor or required fields change, you update the
fixture once rather than every test that uses it.

If you need a fixture that does not yet exist, add it to the appropriate class
in `testsupport/fixtures/` rather than duplicating inline setup.

---

## 7. Naming and Structure Conventions

### Test class name
Mirror the production class name with a `Test` suffix:
`AllergyController` → `AllergyControllerTest`

### Test method name
Use the pattern `methodName_condition_expectedOutcome`:

```
createAllergy_success
createAllergy_forbidden
createAllergy_duplicateAllergy_badRequest
run_SkipsLoadingWhenUsersExist
awardXp_returns200_withUpdatedProgress
```

### `@DisplayName`
Add `@DisplayName` on controller tests to make MockMvc output readable:

```java
@Test
@DisplayName("POST /v1/api/allergies - admin creates allergy, returns 201")
void createAllergy_success() { ... }
```

### `@Nested` for grouping
Group tests by method or scenario using `@Nested`:

```java
@Nested
@DisplayName("requirePermission")
class RequirePermissionTests {
    @Test void shouldThrowWhenUserIsNull() { ... }
    @Test void shouldPassWhenUserHasPermission() { ... }
}
```

### Arrange / Act / Assert comments
Structure test bodies with inline comments to make intent clear, especially for
longer tests:

```java
@Test
void run_SkipsLoadingWhenUsersExist() throws Exception {
    // Arrange
    when(statement.executeQuery(anyString())).thenReturn(resultSet);
    when(resultSet.next()).thenReturn(true);
    when(resultSet.getInt(1)).thenReturn(5);

    // Act
    assertDoesNotThrow(() -> loader.run());

    // Assert
    verify(statement, atLeastOnce()).executeQuery("SELECT COUNT(*) FROM users");
    verify(statement, never()).executeUpdate(anyString());
}
```

---

## 8. What to Assert

### Use AssertJ for object assertions

```java
assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
assertThat(response.getBody()).isSameAs(progress);
assertThat(achievements).hasSize(5);
assertThat(achievements).extracting(Achievement::getTitle).containsExactlyInAnyOrder(...);
```

### Use JUnit assertions for simple checks

```java
assertNotNull(achievement.getTitle());
assertEquals("First Login", achievement.getTitle());
assertDoesNotThrow(() -> loader.run());
assertThrows(UnauthorizedException.class, () -> service.requirePermission(null, perm));
```

### Use MockMvc JSON path matchers for HTTP responses

```java
.andExpect(status().isOk())
.andExpect(jsonPath("$.message", is("Allergy created successfully")))
.andExpect(jsonPath("$.data.allergen", is("Penicillin")))
.andExpect(jsonPath("$.data").isArray())
.andExpect(jsonPath("$.error").exists())
```

---

## 9. Common Pitfalls

**UnnecessaryStubbingException**
A stub was set up but never called. Move it into the specific test that needs it,
or use `lenient()` only if it is intentionally shared setup.

**`@MockBean` vs `@MockitoBean`**
This project uses Spring Boot 3.4+. The correct annotation is `@MockitoBean`
(from `org.springframework.test.context.bean.override.mockito`). The old
`@MockBean` still works but is deprecated — use `@MockitoBean` in new code.

**`@InjectMocks` injection failures**
Mockito injects mocks by type. If the production class has multiple fields of
the same type, injection may go to the wrong field. In that case, construct the
class manually in `@BeforeEach`:

```java
DevDataLoader loader = new DevDataLoader(dataSource, true);
```

**Missing `@MockitoBean` in `@WebMvcTest`**
If a `@WebMvcTest` fails with `NoSuchBeanDefinitionException` or context load
failure, the controller has a dependency that is not mocked. Add a
`@MockitoBean` for each missing type.

**H2 / Flyway conflicts**
Full-context tests that activate the `test` profile use H2 with
`spring.flyway.enabled=false`. If you see Flyway running against H2 and failing,
check that `@ActiveProfiles("test")` is present or that your test
`application-test.properties` is being picked up.

**Security context leaking between tests**
Always call `SecurityContextHolder.clearContext()` in `@AfterEach` when tests
set it manually. Failure to do so causes flaky test ordering issues.

---

## 10. Running Tests

Run the full test suite from `backend/core/`:

```bash
mvn test
```

Run a single test class:

```bash
mvn test -Dtest=AllergyControllerTest
```

Run a single test method:

```bash
mvn test -Dtest=AllergyControllerTest#createAllergy_success
```

Run all tests in a package:

```bash
mvn test -Dtest="com.careconnect.controller.*"
```

Skip tests (compile only):

```bash
mvn test-compile -DskipTests
```

Coverage reports are generated automatically at `target/site/jacoco/index.html`
by the JaCoCo plugin whenever `mvn test` completes.
