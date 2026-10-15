# AGENTS.md

# Flutter Production Engineering, QA & AI Agent Rules

This document defines the engineering workflow, architecture, coding standards, testing strategy, security requirements, quality gates, Git workflow, CI/CD expectations, release process, and AI-agent behavior for this Flutter project.

The goal is to build software that is:

- Correct
- Maintainable
- Testable
- Secure
- Performant
- Accessible
- Reliable
- Observable
- Easy to release
- Simple enough to understand

---

# 1. Priority of Rules

When rules conflict, use this priority:

```text
1. Explicit user requirement
2. Project-specific requirement
3. Existing project constraints
4. This AGENTS.md
5. General Flutter/Dart best practices
```

Project-specific requirements override default architectural preferences.

Example:

If this file recommends Repository layers but the project explicitly requires:

```text
"No Repository layer"
```

Do not introduce a Repository.

Never impose architecture against an explicit project requirement.

---

# 2. Core Engineering Principles

Always prefer:

- Simple over clever
- Explicit over magical
- Small changes over large rewrites
- Testable over tightly coupled
- Clear responsibilities over excessive abstraction
- Root-cause fixes over temporary patches
- Measurable optimization over premature optimization
- Reuse when it improves maintainability
- Simplicity when reuse adds unnecessary complexity
- Evidence over assumptions

Do not introduce complexity without a clear reason.

---

# 3. AI Agent Rules

The AI agent must behave as an engineering assistant, not as an uncontrolled code generator.

## 3.1 Inspect Before Modifying

Before modifying an existing feature:

1. Inspect relevant files.
2. Understand the current architecture.
3. Identify dependencies.
4. Understand existing behavior.
5. Identify existing tests.
6. Identify project constraints.
7. Then make the smallest necessary change.

Never rewrite existing code blindly.

---

## 3.2 Never Fabricate Results

The agent must NEVER claim that:

- Tests passed
- A build succeeded
- Code was executed
- A file exists
- A package behaves a certain way
- A bug was reproduced
- Security was verified
- CI passed
- Performance improved

unless this was actually verified.

If something was not verified, say:

> Not verified.

---

## 3.3 Never Fabricate APIs

Do not invent:

- Package APIs
- Flutter APIs
- Firebase APIs
- Supabase APIs
- Methods
- Classes
- Configuration fields
- Tool results

If uncertain, inspect the existing code, documentation, package version, or project configuration before relying on it.

---

## 3.4 Preserve Existing Behavior

When modifying existing functionality:

- Preserve unrelated behavior.
- Avoid unnecessary refactoring.
- Avoid changing public APIs without reason.
- Avoid changing architecture without justification.
- Avoid changing dependencies without need.

A bug fix should fix the bug, not redesign the entire application.

---

## 3.5 Scope Control

Only modify files necessary for the requested task.

Do not:

- Rename unrelated files.
- Reformat unrelated code.
- Upgrade unrelated dependencies.
- Rewrite unrelated architecture.
- Change unrelated UI.

If unrelated technical debt is discovered, report it instead of silently expanding scope.

---

# 4. Development Modes

Use the appropriate mode automatically.

```text
EXPLORE
    ↓
SPECIFICATION
    ↓
TASK BREAKDOWN
    ↓
IMPLEMENTATION / TDD
    ↓
DEBUGGING
    ↓
REFACTORING
    ↓
CODE REVIEW
    ↓
SECURITY REVIEW
    ↓
QA REVIEW
    ↓
RELEASE
```

---

# 5. Mode 1 — Explore

Use when requirements are unclear.

The agent should:

1. Understand the problem.
2. Inspect the existing project.
3. Identify constraints.
4. Identify affected features.
5. Identify risks.
6. Ask high-value questions.
7. Propose possible approaches.

Do not write production code prematurely.

---

# 6. Mode 2 — Specification

For non-trivial features, create a concise specification before implementation.

The specification should contain:

## Problem

What problem are we solving?

## Goal

What should the user be able to accomplish?

## User Story

```text
As a [user],
I want [action],
so that [benefit].
```

## Functional Requirements

List expected behavior.

## Non-Functional Requirements

Consider:

- Performance
- Security
- Accessibility
- Reliability
- Localization
- Offline behavior
- Privacy

## Acceptance Criteria

Acceptance criteria must be testable.

Example:

```text
Given valid note data
When the user saves the note
Then the note is stored
And the note list displays the new note.
```

---

# 7. Mode 3 — Task Breakdown

Break large work into small independently verifiable tasks.

Example:

```text
Feature: Authentication

1. Define validation rules
2. Implement authentication service
3. Implement authentication state
4. Implement login UI
5. Implement navigation behavior
6. Add unit tests
7. Add Cubit tests
8. Add widget tests
9. Review security
10. Run QA checks
```

Each task should be small enough to understand and verify independently.

---

# 8. Mode 4 — Implementation

Implementation should be incremental.

Preferred cycle:

```text
Small Change
↓
Run Relevant Test
↓
Verify
↓
Next Change
```

Do not make hundreds of unrelated changes before verification.

---

# 9. TDD Mode

When TDD is explicitly requested, strictly follow:

```text
RED
↓
Write failing test
↓
GREEN
↓
Minimum implementation
↓
REFACTOR
↓
Run tests
```

Do not write the entire implementation first and tests afterward when TDD is explicitly required.

Tests should describe behavior rather than implementation details.

---

# 10. Project Context

The default technology preferences for this project family are:

```text
Flutter
Dart
Cubit / BLoC
GetIt
go_router
Firebase and/or Supabase
SQLite / Floor when required
MVVM when required
Clean Architecture when justified
TDD
Unit Testing
Widget Testing
Integration Testing
QA-oriented development
```

These are preferences, not absolute requirements.

The actual project requirements always take priority.

---

# 11. Architecture

Prefer feature-first organization.

Typical structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── helpers/
│   ├── network/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   └── feature_name/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       │
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       │
│       └── presentation/
│           ├── cubit/
│           ├── pages/
│           └── widgets/
│
├── injection/
├── routes/
└── main.dart
```

Adapt the architecture to project complexity.

---

# 12. Anti-Overengineering Rule

Do NOT automatically create:

- Repository
- UseCase
- Service
- Interface
- Abstract class
- Factory
- Design pattern
- Additional package

unless it provides meaningful value.

For a small CRUD application:

```text
UI
↓
Cubit / ViewModel
↓
DAO / Service
```

may be completely appropriate.

For a complex application:

```text
Presentation
↓
Domain
↓
Data
↓
Data Source
```

may be justified.

Architecture must match complexity.

---

# 13. MVVM

When MVVM is required:

```text
View
↓
ViewModel / Cubit
↓
Data Access Layer
↓
Data Source
```

The View must not contain business logic.

Avoid putting these directly inside widgets:

- Database operations
- API calls
- Firebase operations
- Complex validation
- Business rules

---

# 14. Clean Architecture

When Clean Architecture is required:

```text
Presentation
↓
Domain
↓
Data
```

Dependencies should point inward.

Domain should not directly depend on:

- Flutter UI
- Firebase
- Dio
- Floor
- SharedPreferences
- Platform-specific APIs

unless there is a deliberate architectural reason.

---

# 15. State Management

Preferred:

- Cubit for simple state
- BLoC for event-driven complexity

Avoid unnecessary `setState` for application-level state.

Important features should explicitly handle applicable states:

```text
Initial
Loading
Success
Empty
Error
```

Avoid excessive boolean combinations:

```text
isLoading
isError
isSuccess
isEmpty
```

when a clearer state model is available.

---

# 16. Cubit / BLoC Rules

Use meaningful method names:

```dart
loadNotes()
createNote()
updateNote()
deleteNote()
login()
logout()
```

Avoid:

```dart
process()
handle()
doSomething()
```

Cubit/BLoC should not contain UI-specific responsibilities such as:

```dart
BuildContext
showDialog()
ScaffoldMessenger
```

when those can remain in the presentation layer.

---

# 17. Dependency Injection

Use `get_it` when dependency injection is required.

Centralize registrations.

Example:

```dart
final sl = GetIt.instance;
```

Prefer injected dependencies.

Dependencies should be replaceable during testing.

Do not create multiple unmanaged global instances of the same service.

---

# 18. Navigation

Use `go_router` when it is part of the project architecture.

Keep routes centralized.

Avoid scattering raw route strings throughout widgets.

Navigation should remain outside business logic.

---

# 19. Data Layer

External data sources should be isolated.

Examples:

```text
REST API
Firebase
Supabase
SQLite
Floor
SharedPreferences
Local Files
```

should not be directly accessed from UI widgets.

When mapping is required:

```text
Data Model
↓
Domain Entity
↓
Presentation
```

---

# 20. Validation

Input validation must be explicit.

Rules:

- Trim input where appropriate.
- Reject empty values.
- Reject whitespace-only values.
- Validate formats.
- Validate required fields.
- Handle invalid values safely.

Example:

```dart
final value = controller.text.trim();

if (value.isEmpty) {
  // validation error
}
```

Do not duplicate identical validation logic unnecessarily.

---

# 21. Error Taxonomy

When useful, distinguish errors such as:

```text
ValidationError
NetworkError
TimeoutError
AuthenticationError
AuthorizationError
DatabaseError
PermissionError
ParsingError
NotFoundError
UnknownError
```

Map technical errors to meaningful application states.

Do not expose raw technical errors directly to end users.

---

# 22. Async and Lifecycle Safety

Always consider:

- Loading
- Failure
- Cancellation
- Widget lifecycle
- Disposed controllers
- Stream subscriptions
- Timers
- Race conditions

Dispose resources when required:

- TextEditingController
- AnimationController
- StreamSubscription
- Timer
- ScrollController
- FocusNode

Avoid memory leaks.

---

# 23. Race Conditions and Duplicate Actions

For actions such as:

- Login
- Payment
- Save
- Delete
- Upload
- API requests

consider:

- Double taps
- Duplicate requests
- Stale responses
- Concurrent operations
- Out-of-order responses

Disable or guard actions when appropriate.

Do not allow stale responses to overwrite newer state without justification.

---

# 24. Single Source of Truth

Avoid maintaining the same business data independently in multiple places.

Define a clear source of truth.

Example:

```text
Database
↓
Repository / Data Layer
↓
Cubit
↓
UI
```

Avoid inconsistent duplicated state unless synchronization is intentional.

---

# 25. Local Database Rules

When using SQLite/Floor:

- Keep database access outside widgets.
- Use DAOs appropriately.
- Handle database errors.
- Validate database operations.
- Consider migrations when schema changes.
- Avoid blocking the UI thread.
- Test important database behavior.

---

# 26. Database Migration Rules

Any schema change must consider existing users.

Examples:

- New column
- Removed column
- Renamed field
- Changed data type
- New table
- Index changes

Before shipping a schema change:

1. Identify existing data.
2. Define migration strategy.
3. Test upgrade from previous version.
4. Test fresh installation.
5. Test rollback implications when relevant.

Never assume users start with an empty database.

---

# 27. Offline and Network Resilience

For network-dependent applications, explicitly define behavior for:

- No internet
- Slow internet
- Timeout
- Server errors
- Retry
- Partial failure
- Cached data

Avoid infinite retries.

Retries should use reasonable limits and backoff when appropriate.

Prevent duplicate network requests.

If offline-first behavior is required, define:

```text
Local source
↓
Synchronization
↓
Conflict handling
↓
Remote source
```

---

# 28. Firebase Rules

When Firebase is used, review:

- Authentication
- Firestore/Realtime Database rules
- Storage rules
- User ownership
- Read permissions
- Write permissions
- Delete permissions

Never rely on Flutter client code for authorization.

Backend security rules must enforce access control.

---

# 29. Supabase Rules

When Supabase is used, review:

- Authentication
- Row Level Security
- Policies
- Ownership
- Insert permissions
- Update permissions
- Delete permissions
- Storage policies

Never assume hiding a UI action provides security.

---

# 30. API Rules

For API-based applications:

- Use HTTPS in production.
- Handle HTTP status codes.
- Handle timeouts.
- Validate responses.
- Handle malformed responses.
- Protect authentication tokens.
- Avoid exposing secrets.
- Never trust client-side authorization.

---

# 31. Security

Never commit:

- Passwords
- Private keys
- API secrets
- Service account credentials
- Authentication tokens
- Production credentials

Never hardcode production secrets into source code.

Use appropriate environment/configuration mechanisms.

---

# 32. Mobile Security

For security-sensitive applications, review relevant OWASP mobile security principles.

Check:

- Authentication
- Authorization
- Session management
- Token handling
- Secure storage
- Input validation
- API security
- Sensitive data exposure
- Logging
- Network communication
- Firebase/Supabase rules

Client-side validation is never sufficient authorization.

---

# 33. Authentication

Authentication flows should explicitly handle:

```text
Loading
Authenticated
Unauthenticated
Authentication failure
Session expiration
Logout
```

Consider:

- Token expiration
- Refresh behavior
- Invalid credentials
- Account disabled
- Network failure
- Logout cleanup

Do not store credentials insecurely.

---

# 34. Logging and Observability

Avoid uncontrolled `print()` statements in production.

Never log:

- Passwords
- Access tokens
- Refresh tokens
- API keys
- Sensitive personal information

Logs should contain useful diagnostic context without exposing sensitive information.

For production applications, consider:

- Crash reporting
- Error monitoring
- Structured logs
- Performance monitoring

---

# 35. Privacy

Consider:

- What user data is collected?
- Why is it collected?
- Where is it stored?
- Who can access it?
- How long is it retained?
- Can the user delete it?

Do not collect data without a clear product requirement.

Minimize sensitive data collection.

---

# 36. UI Quality

Avoid giant widgets.

Prefer meaningful component boundaries.

Example:

```text
Page
├── Header
├── Content
├── Form
├── EmptyState
└── ActionButton
```

Create reusable widgets when reuse improves maintainability.

Do not create abstractions only to reduce file length.

---

# 37. Responsive Design

When applicable, support:

- Small phones
- Large phones
- Tablets
- Web
- Desktop

Do not design around one hardcoded screen size.

Avoid arbitrary device-specific conditions without a real requirement.

---

# 38. Localization

When localization is required:

- Support RTL/LTR.
- Avoid hardcoded user-facing strings.
- Use localization resources.
- Handle Arabic correctly.
- Handle English correctly.
- Consider pluralization and formatting.

Do not build translations by fragile string concatenation.

---

# 39. Accessibility

When applicable:

- Provide semantic labels.
- Support text scaling.
- Maintain sufficient contrast.
- Avoid relying only on color.
- Maintain reasonable touch targets.
- Ensure keyboard/focus behavior is usable.
- Test important flows with accessibility considerations.

---

# 40. Performance

Avoid unnecessary rebuilds.

Prefer:

```dart
const
```

where appropriate.

Use lazy rendering for large collections:

```text
ListView.builder
GridView.builder
```

Be careful with:

- Large images
- Expensive calculations
- Repeated API calls
- Repeated database queries
- Large synchronous operations
- Excessive rebuilds
- Memory usage

Do not optimize without evidence when optimization adds unnecessary complexity.

---

# 41. Performance Budgets

For performance-sensitive applications, define measurable targets where practical.

Examples:

```text
Startup time
API response expectation
Memory usage
Frame performance
Image size
Database query time
```

Do not claim performance improvements without measurement.

---

# 42. Package Management

Before adding a package:

1. Is it actually needed?
2. Can Flutter/Dart solve it natively?
3. Is it maintained?
4. Is it compatible with the SDK?
5. Does it introduce security concerns?
6. Does it add unnecessary complexity?

Do not add packages for trivial functionality.

---

# 43. Dependency Upgrade Policy

Do not perform large dependency upgrades without reason.

Before upgrading:

1. Review changelog.
2. Check breaking changes.
3. Check Flutter/Dart compatibility.
4. Run tests.
5. Run analysis.
6. Verify the build.
7. Review affected APIs.

Do not combine unrelated dependency upgrades with feature work unless necessary.

---

# 44. Environment Management

Separate environments when appropriate:

```text
Development
Staging
Production
```

Never accidentally connect development builds to production services.

Environment-specific configuration should be explicit.

Consider:

```text
API base URL
Firebase project
Supabase project
Feature flags
Logging level
Analytics configuration
```

Production credentials must never be committed.

---

# 45. Feature Flags

Use feature flags for risky or staged releases when appropriate.

Preferred lifecycle:

```text
Feature OFF
↓
Development testing
↓
Staging
↓
Limited release
↓
Monitoring
↓
Full release
```

Do not leave abandoned feature flags indefinitely.

---

# 46. Architecture Decision Records

For important architectural decisions, use ADRs.

Example:

```text
docs/adr/
├── 001-state-management.md
├── 002-local-storage.md
└── 003-authentication.md
```

An ADR should contain:

```text
Context
Decision
Alternatives
Consequences
```

Use ADRs for decisions that future developers may question.

---

# 47. Testing Strategy

Testing levels:

```text
Unit Tests
↓
Cubit/BLoC Tests
↓
Widget Tests
↓
Integration Tests
```

## Unit Tests

Use for:

- Validators
- UseCases
- Services
- Business logic
- Data transformations

## Cubit/BLoC Tests

Test:

- Initial state
- Loading
- Success
- Empty
- Error
- State transitions
- Edge cases

## Widget Tests

Test:

- User interactions
- Validation
- Buttons
- Rendering
- Important UI states

## Integration Tests

Use for critical end-to-end flows.

---

# 48. Regression Testing

Every important bug fix should include a regression test when practical.

Process:

```text
Bug
↓
Reproduce
↓
Failing regression test
↓
Fix
↓
Passing test
```

---

# 49. Test Quality

Tests must verify real behavior.

Bad:

```dart
expect(true, true);
```

Good:

```text
Given invalid input
When createNote is called
Then an error state is emitted.
```

Avoid excessive mocking.

Do not test implementation details unnecessarily.

---

# 50. Test Pyramid

Prefer a healthy distribution:

```text
        Integration
       /           \
    Widget        Widget
    -------------------
      Unit / Cubit
    -------------------
```

Most business logic should be covered by fast unit/Cubit tests.

Use integration tests for critical user journeys rather than every tiny behavior.

---

# 51. Debugging Mode

When debugging:

```text
1. Reproduce
2. Observe
3. Collect evidence
4. Isolate
5. Identify root cause
6. Create regression test
7. Fix
8. Run relevant tests
9. Run full tests
10. Run static analysis
11. Review
```

Do not randomly change multiple unrelated files.

---

# 52. Code Simplification Mode

When simplifying:

- Preserve behavior.
- Remove unnecessary duplication.
- Reduce nesting.
- Improve naming.
- Remove unnecessary abstractions.
- Keep architecture understandable.

Do not introduce abstraction merely because code can technically be abstracted.

---

# 53. QA Checklist

Before considering a feature complete, test:

## Functional

- Happy path
- Invalid input
- Empty input
- Missing data
- Error response
- Retry
- Cancel
- Duplicate action

## UI

- Loading
- Success
- Error
- Empty state
- Overflow
- Responsive layout
- Back navigation
- Keyboard/focus

## Permissions

Test:

- Permission granted
- Permission denied
- Permission denied permanently
- Permission unavailable

## Network

Test:

- Online
- Offline
- Slow connection
- Timeout
- Server error

## Authentication

Test:

- Valid login
- Invalid login
- Logout
- Expired session
- Unauthorized access

---

# 54. Edge Case Thinking

For every feature ask:

```text
What if the value is empty?
What if the value is null?
What if the user taps twice?
What if the network disappears?
What if the API returns malformed data?
What if the database is empty?
What if permission is denied?
What if the user goes back?
What if the user closes the app?
What if the request takes too long?
What if two requests run simultaneously?
```

Handle relevant cases intentionally.

---

# 55. Git Strategy

Use focused branches.

Preferred examples:

```text
feature/authentication
feature/notes-crud
fix/location-permission
hotfix/payment-crash
refactor/notes-state
test/authentication
```

Avoid unclear branches such as:

```text
test
new
changes
final
final2
```

---

# 56. Commit Convention

Prefer Conventional Commits:

```text
feat: add note creation
fix: handle location permission denial
test: add notes cubit tests
refactor: simplify note validation
docs: update setup guide
chore: update dependencies
perf: reduce unnecessary rebuilds
security: harden authentication flow
```

Commits should be:

- Small
- Focused
- Descriptive
- Related to one logical change

---

# 57. Pull Request Rules

A PR should include:

## Summary

What changed?

## Why

Why was it needed?

## Testing

What was tested?

## Screenshots

Include when UI changes are relevant.

## Risks

Mention important risks.

## Checklist

```text
- [ ] Requirements satisfied
- [ ] Tests added/updated
- [ ] Existing tests pass
- [ ] Analyze passes
- [ ] No secrets committed
- [ ] No unrelated changes
```

Do not merge a PR with failing required checks.

---

# 58. CI/CD Quality Gates

When CI is configured, verify:

```text
dart format
↓
flutter analyze
↓
flutter test
↓
Build verification
```

For important projects, also consider:

```text
Coverage
Security checks
Dependency audit
Integration tests
```

Never claim CI passed unless the actual result was verified.

---

# 59. Release Checklist

Before production release:

## Code

- [ ] Formatting passes
- [ ] Static analysis passes
- [ ] Unit tests pass
- [ ] Widget tests pass where applicable
- [ ] Integration tests pass where applicable

## Security

- [ ] No secrets committed
- [ ] Authentication reviewed
- [ ] Authorization reviewed
- [ ] API/Firebase/Supabase rules reviewed
- [ ] Sensitive logs removed

## UX

- [ ] Loading states
- [ ] Error states
- [ ] Empty states
- [ ] Offline behavior
- [ ] RTL/LTR
- [ ] Accessibility

## Performance

- [ ] No obvious unnecessary rebuilds
- [ ] Large lists optimized
- [ ] Images reviewed
- [ ] Network/database operations reviewed
- [ ] Memory/resource lifecycle reviewed

## Build

- [ ] Production configuration verified
- [ ] Production build verified
- [ ] Correct environment selected
- [ ] Version/build number updated

---

# 60. Rollback Strategy

If a release causes a critical problem:

```text
Detect
↓
Assess impact
↓
Stop rollout
↓
Rollback / disable feature
↓
Investigate root cause
↓
Add regression test
↓
Fix
↓
Verify
↓
Release again
```

Do not rush a second release without understanding the failure.

---

# 61. Database Release Safety

Before releasing database changes:

- Test fresh installation.
- Test upgrade from previous version.
- Test migration.
- Verify existing user data.
- Verify rollback implications.
- Verify app behavior after migration.

Never assume production starts with an empty database.

---

# 62. Documentation

Document important:

- Setup instructions
- Environment configuration
- Architecture decisions
- Complex business rules
- Database migrations
- Release procedures
- Known limitations

Keep documentation close to the project.

---

# 63. README Requirements

For projects intended for other developers, README should explain:

```text
Project Overview
Features
Architecture
Requirements
Installation
Environment Setup
Running the App
Testing
Build
Deployment
Known Limitations
```

Do not document commands that have not been verified.

---

# 64. Definition of Done

A feature is complete only when applicable items are satisfied:

- [ ] Requirements understood
- [ ] Acceptance criteria satisfied
- [ ] Architecture appropriate
- [ ] Validation implemented
- [ ] Loading state handled
- [ ] Success state handled
- [ ] Error state handled
- [ ] Empty state handled
- [ ] Important edge cases covered
- [ ] Tests added
- [ ] Regression tests added for bug fixes
- [ ] `dart format` completed
- [ ] `flutter analyze` passes
- [ ] Tests pass
- [ ] No sensitive credentials committed
- [ ] Security reviewed
- [ ] Performance considered
- [ ] Accessibility considered
- [ ] Localization considered where applicable
- [ ] No unrelated changes
- [ ] Code reviewed

---

# 65. Final Code Review

Every significant feature must be reviewed across five primary dimensions:

## 1. Correctness

Does it satisfy the requirements?

## 2. Readability

Can another developer understand it easily?

## 3. Architecture

Are responsibilities located in the correct layers?

## 4. Security

Are authentication, authorization, validation, secrets, and sensitive data handled safely?

## 5. Performance

Are unnecessary rebuilds, operations, queries, and resource leaks avoided?

---

# 66. Final Engineering Gate

Before declaring a task complete, ask:

```text
Does it work?
Is it tested?
Is it understandable?
Is it secure?
Is it performant enough?
Is the architecture justified?
Did we avoid unnecessary complexity?
Did we preserve existing behavior?
Did we verify our claims?
```

If an important answer is:

```text
No
```

or:

```text
Unknown
```

do not silently declare the task complete.

Clearly communicate what remains unverified.

---

# 67. Final Rule

The best implementation is not the one with the most architecture.

The best implementation is the simplest implementation that:

- Correctly solves the problem
- Satisfies the requirements
- Can be tested
- Can be maintained
- Is secure
- Performs adequately
- Can be safely released
- Can be understood by another developer

Always optimize for long-term engineering quality, not code volume.