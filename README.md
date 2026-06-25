# SwiftFP

Functional programming primitives for Swift.

## Requirements

- Swift 6.4+
- iOS 13+ / macOS 10.15+

## Installation

```swift
// Swift Package Manager
.package(url: "https://github.com/ShapovalovIlya/SwiftFP.git", from: "1.0.0")
```

Each module can be imported independently, or use the aggregate `SwiftFP` target to get everything:

```swift
import Either
import Monad
import Validated
// ... or simply:
import SwiftFP
```

## Modules

### Either

A disjoint union representing a value of one of two possible types — commonly used for error handling and branching logic.

```swift
let success: Either<Int, String> = .left(42)
let failure: Either<Int, String> = .right("Error message")

let result = success.map { $0 * 2 }        // .left(84)
let chained = success.flatMap { .left($0 + 10) }  // .left(52)
```

### Monad

A generic value wrapper that provides `map`, `flatMap`, `apply`, and `zip` for functional composition. Supports `@dynamicMemberLookup` for direct property access.

```swift
let value = Monad(42)
let doubled = value.map { $0 * 2 }          // Monad(84)
let chained = value.flatMap { Monad($0 + 10) }  // Monad(52)

@dynamicMemberLookup usage:
let person = Monad(Person(name: "John", age: 30))
let name = person.name  // "John"
```

### NotEmptyArray

An array guaranteed to contain at least one element (`head` + `tail`), ensuring non-empty collections at compile time.

```swift
let list = NotEmptyArray<Int>(head: 1, tail: [2, 3])
let doubled = list.map { $0 * 2 }           // NotEmptyArray([2, 4, 6])
let combined = list + NotEmptyArray(single: 4)  // NotEmptyArray([1, 2, 3, 4])
```

### Validated

Accumulates multiple validation errors instead of short-circuiting on the first failure. Uses `NotEmptyArray` to store errors.

```swift
let validated: Validated<Int, MyError> = .valid(42)
let result = validated.map { $0 * 2 }       // .valid(84)

// Multiple errors are collected, not short-circuited:
let combined = validated1.zip(validated2)   // errors from both sides merged
```

Includes a `@resultBuilder` (`Validator`) for DSL-style validation:

```swift
let result = Validated(user) {
    { $0.name.isEmpty ? .failure(.emptyName) : .success($0) }
    { $0.age < 0 ? .failure(.invalidAge) : .success($0) }
}
```

### Reader

A functional abstraction for dependency injection. Represents a computation that reads from a shared, read-only environment.

```swift
struct AppConfig {
    let apiEndpoint: String
    let isDebug: Bool
}

let endpointReader = Reader<AppConfig, String> { $0.apiEndpoint }
let debugReader = Reader<AppConfig, String> { $0.isDebug ? "ON" : "OFF" }

let summary = endpointReader.zip(debugReader) { ep, dbg in
    "Endpoint: \(ep), Debug: \(dbg)"
}

let config = AppConfig(apiEndpoint: "https://api.example.com", isDebug: true)
summary.apply(config)  // "Endpoint: https://api.example.com, Debug: ON"
```

`AsyncReader` provides the same pattern for async/Sendable contexts.

### Effect

A deferred computation monad (similar to an IO monad). The wrapped closure executes only when `run()` is called.

```swift
let hello = Effect.pure("Hello, Effect!")
let excited = hello.map { $0 + " 🎉" }
let greet = excited.flatMap { msg in
    Effect { msg.uppercased() }
}

greet.run()  // "HELLO, EFFECT! 🎉"
```

### State

A state transformer monad that threads state through computations, returning both a new state and a value.

```swift
let increment: State<Int, Int> = State { state in (state + 1, state + 1) }
let result = increment.reduce(0)  // (environment: 1, value: 1)
```

### Future

A lazy async monad wrapping `@Sendable () async -> Value`. Runs when `run()` is awaited. Supports parallel execution via `zip`.

```swift
let future = Future {
    try? await Task.sleep(for: .seconds(1))
    return 42
}

let result = await future.run()  // 42

// Parallel execution:
let combined = future1.zip(future2)  // both run concurrently
```

### Zipper

A cursor-based data structure for navigating and editing collections with `previous`/`current`/`next` slices.

```swift
let zipper = Zipper(previous: ["a"], current: "b", next: ["c", "d"])
var mutable = zipper
mutable.forward()
mutable.current  // "c"
```

### FoundationFX

Extensions on Swift Foundation types:

- **Sequence**: `asyncMap`, `concurrentMap`, `concurrentForEach`, `asyncAdapter`, `grouped(by:)`, `sorted(by:)`
- **Result**: `tryMap`, `asyncMap`, `asyncFlatMap`, `apply`, `zip`, `sequence`, `decodeJSON`
- **Optional**: `apply`, `zip`, `filter`, `replaceNil`, `orZero`, `orEmpty`, `orFalse`, `asyncMap`, `asyncFlatMap`
- **Task**: `map`, `flatMap`, `zip`, `sequence`, `allSettled`
- **LazySequence**: `apply`, `unique`

```swift
// Concurrent async mapping with order preservation:
let urls = [url1, url2, url3]
let data = try await urls.asyncMap { try await fetch($0) }

// Result zipping:
let a: Result<Int, Error> = .success(1)
let b: Result<String, Error> = .success("hello")
let combined = a.zip(b)  // .success((1, "hello"))

// Optional utilities:
let value: Int? = nil
value.orZero      // 0
value.orEmpty     // [] (for array types)
```

### SwiftFP Utilities

- **`compose` / `tryCompose`** — Function composition (2–4 functions)
- **`>>>`** — Pipeline operator: `{ f } >>> { g }` produces `{ g(f($0)) }`
- **`ObjectFactory<T>`** — Builder pattern via `@dynamicMemberLookup` for value types
- **`RefObjectFactory<T>`** — Same for reference types (`AnyObject`)
- **KeyPath operators** — `!`, `==`, `!=`, `>` on KeyPaths produce `(T) -> Bool` predicates:

```swift
let unread = articles.filter(!\.isRead)
let fullLength = articles.filter(\.category == .fullLength)
```

