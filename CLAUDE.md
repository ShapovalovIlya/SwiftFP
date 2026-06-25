# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftFP is a functional programming library for Swift, providing monadic abstractions and FP utilities as a Swift Package Manager library. It targets iOS 13+ and macOS 10.15+, built with Swift tools version 6.4.

## Build and Test

```bash
swift build          # Build all modules
swift test           # Run all 152 tests across 16 suites
swift test --filter EitherTests  # Run a single test suite
```

## Module Architecture

The package is organized as **10 independent submodule libraries** plus **1 aggregate `SwiftFP` library** that re-exports all submodules via `@_exported`. Each submodule can be imported standalone.

### Submodule dependency graph

```
Either  Monad  NotEmptyArray  Zipper  Readers  Effects  State  Future
  |                         |            ^
  v                         v            |
FoundationFX            Validated ------+
```

- **FoundationFX** depends on Either
- **Validated** depends on NotEmptyArray
- All other modules are leaf dependencies with no inter-module dependencies

### Module summary

| Module | Description |
|---|---|
| **Either** | Disjoint union (`Left`/`Right`) with `map`/`flatMap` on both branches, `asyncMap`/`asyncFlatMap`, applicative `apply`, `fold`, and `Result` interop |
| **Monad** | Generic value wrapper with `map`/`flatMap`/`apply`/`zip`, `@dynamicMemberLookup` for property access, `mutate` for in-place modifications |
| **NotEmptyArray** | Array guaranteed to have at least one element (`head` + `tail`). Supports `map`, concatenation (`+`/`+=`), and `Sequence` conformance |
| **Validated** | Accumulates multiple errors (as `NotEmptyArray<Failure>`) instead of short-circuiting. Has a `@resultBuilder` called `Validator` for DSL-style validation. `zip` merges errors from both sides |
| **Zipper** | Cursor-based collection traversal with `previous`/`current`/`next`, `forward()`/`backward()`, `mapZipper`, and `Collection` conformance |
| **Readers** | `Reader<Environment, Result>` monad for dependency injection with `map`/`flatMap`/`pullback`/`curry`/`zip`. `AsyncReader` is the async/Sendable variant |
| **Effects** | `Effect<Value>` — deferred computation monad (like an IO monad). Computations run only when `run()` is called. Supports `map`/`flatMap`/variadic `zip` |
| **State** | `State<Environment, Value>` — state transformer monad. Reducer returns `(Environment, Value)`. Supports `map`/`flatMap`/`pullback` |
| **Future** | `Future<Value>` — lazy async monad. Wraps `@Sendable () async -> Value`. Runs when `run()` is awaited. `zip` executes both futures in parallel via `async let` |
| **FoundationFX** | Extensions on Foundation types: `Sequence` (async/concurrent map/forEach, `asyncAdapter`, `grouped`, `set`, `sorted(by:)`), `Result` (`tryMap`, `asyncMap`, `zip`, `sequence`, `decodeJSON`), `Optional` (`apply`, `zip`, `filter`, `replaceNil`, `orZero`, `orEmpty`, `asyncMap`), `Task` (functional `map`/`flatMap`/`zip`/`sequence`/`allSettled`), `LazySequence` (`apply`, `unique`) |

### SwiftFP (aggregate) utilities

Beyond re-exporting submodules, the aggregate `SwiftFP` module adds:

- **`compose` / `tryCompose`** — Function composition for 2–4 functions
- **`>>>`** — Pipeline operator (`{ rhs(lhs($0)) }`)
- **`Witness<T>`** — Phantom/marker type
- **`ObjectFactory<T>`** — Builder-pattern struct via `@dynamicMemberLookup` for value types
- **`RefObjectFactory<T>`** — Same pattern for reference types (`AnyObject`)
- **KeyPath operators** — `!`, `==`, `!=`, `>` on KeyPaths to produce `(T) -> Bool` predicates (e.g., `articles.filter(!\.isRead)`)

## Conventions

- All types are marked `@frozen` where possible
- All public methods are marked `@inlinable` for zero-cost abstraction
- Swift settings enable `StrictConcurrency` and `InferIsolatedConformances`
- Monadic types follow a consistent API: `pure()`, `joined()`, `map()`, `flatMap()`, `zip()`
- Package.swift uses a `Submodule` enum to DRY up target/product definitions
- Tests are in a single `SwiftFPTests` target that imports the aggregate `SwiftFP` library
