---
name: converting-xctest-to-swift-testing
description: Convert an XCTest file to Swift Testing framework. Use when asked to "convert to Swift Testing", "migrate XCTest", "convert test file", "xctest to swift testing", "migrate tests to Swift Testing", or when explicitly asked to convert existing XCTest-based tests.
---

# Converting XCTest to Swift Testing

Convert an existing XCTest file to Swift Testing following Bitwarden iOS patterns.

## Step 0: Is this file convertible?

Do **NOT** convert these — leave them in XCTest and flag the issue before proceeding:

| Pattern | Why |
|---------|-----|
| **ViewInspector tests** (`import ViewInspector`) | Requires XCTest infrastructure |
| **Snapshot tests** (`disabletest_*`, `assertSnapshot`) | Depends on `BitwardenTestCase` |
| **UI automation** (`XCUIApplication`) | Not supported |
| **Performance tests** (`measure {}`, `XCTMetric`) | Not supported |
| **Objective-C tests** | Cannot use Swift Testing |
| **Alert/loading-overlay assertions** (`coordinator.alertShown` / `loadingOverlaysShown`) | Need `UI.animated = false`, set by `BitwardenTestCase.setUp()` |

## Step 1: Read the file

Note what's under test (processor, coordinator, service…), which methods use `@MainActor`, any `addTeardownBlock`, and any non-mechanical patterns needing judgment.

## Step 2: Header

- Replace `import XCTest` with `import Testing`; keep other imports. If the build fails with missing Foundation symbols, add `import Foundation` (XCTest used to re-export it).
- `class FooTests: BitwardenTestCase {` → `struct FooTests {` (drop `final`, drop the superclass).
- If methods had `@MainActor` (processor/coordinator tests), move it to the **struct** declaration. Don't add it to service tests unless the service dispatches to main.

## Step 3: Properties

Change force-unwrapped `var ...!` to `let` non-optionals:

```swift
// Before:                                  // After:
var subject: FooProcessor!                  let subject: FooProcessor
```

Drop the `services` property if it's only used in setup to build the subject; keep it (`let services: MockServiceContainer`) only if tests reference it directly.

## Step 4: Setup / teardown lifecycle

Swift Testing creates a fresh suite instance per test, so isolation is automatic.

- `setUp()` → `init()` — move setup here, drop `super.setUp()`. May be `async`/`throws`.
- `tearDown()` → **delete** — no nilling needed.
- `addTeardownBlock { }` — delete if it only nils properties; if it cleans up external resources (temp files, keychain), move it to `deinit` and make the suite a `final class` (`deinit` isn't available on `struct`).

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

## Step 5: Test methods

Drop the `test_` prefix, add `@Test`, remove per-method `@MainActor`. `async throws` signatures are unchanged.

Every `@Test` needs a `///` DocC comment that **starts with the backtick-wrapped symbol name** (including parameter labels), then a plain description:

```swift
/// `receive(_:)` updates the state when the value changes.
@Test
func receive_valueChanged_updatesState() { ... }

/// `parseCard(lines:)` extracts card numbers across multiple formats.
@Test(arguments: zip(inputs, expectedNumbers))
func parseCard_extractsCardNumber(lines: [String], expectedNumber: String) { ... }
```

## Step 6: Assertions

Use `#expect(expr)` (records failure, continues — default) and `#require(expr)` (aborts test; also unwraps optionals, replacing `XCTUnwrap`). Both take plain Swift expressions and print the operand values on failure.

| XCTest | Swift Testing |
|---|---|
| `XCTAssert(x)` / `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertFalse(x)` | `#expect(!x)` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertNotEqual(a, b)` | `#expect(a != b)` |
| `XCTAssertNil(a)` | `#expect(a == nil)` |
| `XCTAssertNotNil(a)` | `#expect(a != nil)` |
| `XCTAssertGreaterThan(a, b)` | `#expect(a > b)` (also `<`, `>=`, `<=`) |
| `try XCTUnwrap(a)` / `try XCTUnwrap(a, "msg")` | `try #require(a)` (drop the message) |
| `XCTAssertThrowsError(try expr)` | `#expect(throws: (any Error).self) { try expr }` |
| typed throw | `#expect(throws: BitwardenTestError.self) { ... }` |
| specific error value | `#expect(throws: BitwardenTestError.example) { ... }` (error must be `Equatable`) |
| `XCTAssertNoThrow(try expr)` | `#expect(throws: Never.self) { try expr }` |
| `assertAsyncThrows(error: e) { try await expr }` | `await #expect(throws: e) { try await expr }` (note `await` moves to the front) |
| `XCTFail("msg")` | `Issue.record("msg")` |

Use `grep -R "XCTAssert\|XCTUnwrap"` to find remaining legacy assertions. Use `#require` only for preconditions where continuing makes no sense.

## Step 7: Parameterized tests

Collapse tests that differ only in data into one parameterized test (each case runs independently and in parallel):

```swift
@Test("Flavor nut content is correct", arguments: zip(
    [Flavor.vanilla, .pistachio, .chocolate],
    [false, true, false]
))
func flavor_containsNuts(flavor: Flavor, expected: Bool) {
    #expect(flavor.containsNuts == expected)
}
```

- `arguments: [a, b, c]` — single collection.
- `arguments: zip(inputs, expected)` — paired one-to-one (most common).
- `arguments: collA, collB` — ⚠️ Cartesian product of every combination; use deliberately.

## Step 8: Bitwarden-specific patterns

These work identically — do not modify: `coordinator.asAnyCoordinator()`, `ServiceContainer.withMocks(...)`, `BitwardenTestError.example`/`.mock("desc")`, `coordinator.alertShown`, `coordinator.routes`, `errorReporter.errors`.

```swift
// Cast assertion
XCTAssertEqual(errorReporter.errors.last as? BitwardenTestError, .example)
#expect(errorReporter.errors.last as? BitwardenTestError == .example)

// Nil check
XCTAssertNotNil(coordinator.alertShown.last)
#expect(coordinator.alertShown.last != nil)

// Unwrap then assert
let action = try XCTUnwrap(stackNavigator.actions.last)
XCTAssertEqual(action.type, .pushed)
let action = try #require(stackNavigator.actions.last)
#expect(action.type == .pushed)
```

## Step 9: Verify

1. grep for `XCTAssert`, `setUp`, `tearDown`, `XCTestCase`, `import XCTest` — all gone.
2. Every former `test_` function has `@Test` and a `///` comment.
3. No force-unwrapped `var` properties remain.
4. `mint run swiftformat .`, then build the target.
5. Run the converted test file.

## Reference

Occasionally useful beyond a mechanical conversion:

- **Skip / gate tests**: `.disabled("reason")` (compiled, not run), `.enabled(if: condition)` (e.g. feature flags), or `@available(...)` for OS-specific tests.
- **Unordered collections**: compare as sets — `#expect(Set(tags) == Set(["ios", "swift"]))`.
- **Floating point**: `#expect(abs(result - 0.3) < 0.0001)`.
- **Completion-handler / multi-fire callbacks**: wrap in `await confirmation("desc", expectedCount: n) { confirm in ... }`. Use `expectedCount: 0` to assert an event never fires. Bridge legacy completion handlers with `withCheckedThrowingContinuation`.
- **Known bugs**: prefer `withKnownIssue { }` over `.disabled` — the test still runs and fails if the bug is fixed, prompting cleanup.
- **Serial execution**: `.serialized` on a `@Test`/`@Suite` for legacy non-thread-safe tests (temporary; goal is parallel-safe).
