---
name: converting-xctest-to-swift-testing
description: Convert an XCTest file to Swift Testing framework. Use when asked to "convert to Swift Testing", "migrate XCTest", "convert test file", "xctest to swift testing", "migrate tests to Swift Testing", or when explicitly asked to convert existing XCTest-based tests.
---

# Converting XCTest to Swift Testing

Convert an existing XCTest file to Swift Testing following Bitwarden iOS patterns.

## Before You Start — Is This File Convertible?

Do **NOT** convert these; leave them in XCTest and flag the issue before proceeding:

| Pattern | Why |
|---------|-----|
| **ViewInspector tests** | `imports ViewInspector`; requires XCTest infrastructure |
| **Snapshot tests** | `disabletest_*` functions, `assertSnapshot`/`SnapshotTesting`; depends on `BitwardenTestCase` |
| **UI automation tests** | Uses `XCUIApplication` |
| **Performance tests** | Uses `measure { ... }` or `XCTMetric` |
| **Objective-C tests** | Cannot use Swift Testing |
| **Alert/loading-overlay display asserts** | `coordinator.alertShown` / `coordinator.loadingOverlaysShown` need `UI.animated = false`, set by `BitwardenTestCase.setUp()` |

## Step 1: Read the File

Note what's under test (processor, coordinator, service…), which methods are `@MainActor`, any `addTeardownBlock` usage, and any patterns needing judgment.

## Step 2: Header

**Imports** — replace `import XCTest` with `import Testing`; keep everything else. `XCTest` re-exports `Foundation`, so add `import Foundation` if the build fails with missing Foundation symbols.

**Class → struct** — `class FooTests: BitwardenTestCase {` (and `final class …`) becomes `struct FooTests {`.

**`@MainActor`** — if test methods had `@MainActor` (processor/coordinator tests), move it to the struct declaration. Service tests usually don't need it — don't add unless the service dispatches to main.

```swift
@MainActor
struct FooProcessorTests {
```

## Step 3: Properties

Force-unwrapped `var` properties become non-optional `let`:

```swift
// Before:  var subject: FooProcessor!
// After:   let subject: FooProcessor
```

**`services`**: drop it if only used inside setup to build the subject. Keep as `let services: MockServiceContainer` if tests reference it for assertions.

## Step 4: Setup / Teardown Lifecycle

A fresh suite instance is created for **each** test, so state can't leak between tests.

| XCTest | Swift Testing |
|--------|---------------|
| `setUp()` / `setUpWithError()` | `init()` (can be `async throws`) — drop `super.setUp()` |
| `tearDown()` that only nils properties | **delete** — struct isolation handles it |
| `addTeardownBlock` that nils properties | **delete** |
| `tearDown` / `addTeardownBlock` cleaning external resources (temp files, keychain) | `deinit` — requires changing the `struct` to a `class` |

```swift
init() {
    coordinator = MockCoordinator()
    errorReporter = MockErrorReporter()
    subject = FooProcessor(
        coordinator: coordinator.asAnyCoordinator(),
        services: ServiceContainer.withMocks(errorReporter: errorReporter),
        state: FooState(),
    )
}
```

## Step 5: Test Methods

Drop the `test_` prefix, add `@Test`, and remove per-method `@MainActor` (now on the struct). `async throws` signatures are unchanged.

Every `@Test` needs a `///` DocC comment that **starts with the backtick-wrapped symbol under test** (with parameter labels), then a plain-English description:

```swift
/// `receive(_:)` updates the state when the value changes.
@Test
func receive_valueChanged_updatesState() { ... }

/// `parseCard(lines:)` extracts card numbers across multiple formats.
@Test(arguments: zip(inputs, expectedNumbers))
func parseCard_extractsCardNumber(lines: [String], expectedNumber: String) { ... }
```

## Step 6: Assertions

`#expect(...)` records a failure and continues (use for most checks). `try #require(...)` aborts the test on failure and unwraps optionals (use for preconditions). `#expect` prints the operand values on failure, so messages are rarely needed.

| XCTest | Swift Testing |
|---|---|
| `XCTAssert(expr)` / `XCTAssertTrue(a)` | `#expect(expr)` / `#expect(a)` |
| `XCTAssertFalse(a)` | `#expect(!a)` |
| `XCTAssertEqual(a, b)` / `XCTAssertNotEqual(a, b)` | `#expect(a == b)` / `#expect(a != b)` |
| `XCTAssertNil(a)` / `XCTAssertNotNil(a)` | `#expect(a == nil)` / `#expect(a != nil)` |
| `XCTAssertGreaterThan(a, b)` (and `<`, `>=`, `<=`) | `#expect(a > b)` |
| `try XCTUnwrap(a)` (drop any message) | `try #require(a)` |
| `XCTAssertThrowsError(expr)` (any error) | `#expect(throws: (any Error).self) { try expr }` |
| Typed / specific error | `#expect(throws: SomeError.self)` / `#expect(throws: SomeError.example)` (value form needs `Equatable`) |
| `XCTAssertNoThrow(try expr)` | `#expect(throws: Never.self) { try expr }` |
| `assertAsyncThrows(error: e) { try await expr }` | `await #expect(throws: e) { try await expr }` (note `await` moves to the front) |
| `XCTFail("message")` | `Issue.record("message")` |

Run `grep -R "XCTAssert\|XCTUnwrap" .` to find every legacy assertion. Since `#expect` continues on failure, group related checks in one test.

## Step 7: Parameterized Tests

Collapse repetitive tests into one `@Test(arguments:)`. Each argument set runs as an independent, parallelizable case with individual failure reporting. Use `zip(inputs, expected)` to pair inputs with outputs (plain comma-separated collections produce a Cartesian product).

```swift
@Test(arguments: zip(
    [Flavor.vanilla, .pistachio, .chocolate],
    [false, true, false]
))
func flavor_containsNuts(flavor: Flavor, expected: Bool) {
    #expect(flavor.containsNuts == expected)
}
```

## Step 8: Bitwarden-Specific Patterns

These are unchanged — do not modify: `coordinator.asAnyCoordinator()`, `ServiceContainer.withMocks(...)`, `BitwardenTestError.example` / `.mock("desc")`, `coordinator.alertShown`, `coordinator.routes`, `errorReporter.errors`.

```swift
// Cast assertion
#expect(errorReporter.errors.last as? BitwardenTestError == .example)

// Unwrap then assert
let action = try #require(stackNavigator.actions.last)
#expect(action.type == .pushed)
```

## Step 9: Verify

1. grep for `XCTAssert`, `setUp`, `tearDown`, `XCTestCase`, `import XCTest` — all gone.
2. Every former `test_` function has `@Test` and a DocC comment.
3. No force-unwrapped `var` properties remain.
4. Run `mint run swiftformat .`, build the target, and run the converted tests.
