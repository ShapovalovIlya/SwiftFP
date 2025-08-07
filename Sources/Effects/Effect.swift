//
//  Effect.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 30.11.2024.
//

import Foundation

/// A container for a deferred computation that produces a value of type `Value`.
///
/// `Effect` is a monadic type that encapsulates a computation, allowing you to
/// sequence, transform, and compose effects in a functional style. The computation
/// is only performed when `run()` is called, enabling controlled execution of side effects.
///
/// `Effect` is similar in spirit to the IO monad in functional programming, but is
/// not limited to side-effecting computations. It can be used to represent any
/// deferred or lazy computation.
///
/// - Note: Thread safety of the computation is the responsibility of the closure
///   provided to `Effect`. If you intend to use `Effect` in concurrent contexts,
///   ensure that the closure is safe to execute across threads.
///
/// ## Topics
/// - Creating Effects
/// - Running Effects
/// - Transforming Effects
/// - Composing Effects
@frozen
public struct Effect<Value> {
    @usableFromInline let work: () -> Value
    
    /// Creates an effect from a closure.
    ///
    /// - Parameter work: A closure that produces a value of type `Value` when called.
    @inlinable
    public init(_ work: @escaping () -> Value) { self.work = work }
    
    /// Executes the effect and returns its result.
    ///
    /// - Returns: The value produced by the effect's computation.
    @inlinable
    public func run() -> Value { work() }
    
    /// Creates an effect that immediately returns the provided value.
    ///
    /// - Parameter value: The value to wrap in an effect.
    /// - Returns: An effect that, when run, returns `value`.
    @inlinable
    public static func pure(_ value: Value) -> Effect<Value> {
        Effect { value }
    }
    
    /// Flattens a nested effect into a single effect.
    ///
    /// - Returns: An effect that, when run, executes the inner effect and returns its result.
    @inlinable
    public func joined<T>() -> Effect<T> where Value == Effect<T> {
        Effect<T> { self.run().run() }
    }
    
    /// Transforms the result of the effect using the given closure.
    ///
    /// Use `map(_:)` to apply a transformation to the value produced by the effect,
    /// returning a new effect that yields the transformed value when run.
    ///
    /// - Parameter transform: A closure that takes the effect's value and returns a new value.
    /// - Returns: An effect that, when run, returns the transformed value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create an effect that returns 10
    /// let effect = Effect.pure(10)
    ///
    /// // Transform the value by doubling it
    /// let doubled = effect.map { $0 * 2 }
    ///
    /// // Run the effect to get the result
    /// print(doubled.run()) // Prints "20"
    /// ```
    ///
    /// ## Example: Chaining multiple maps
    ///
    /// ```swift
    /// let effect = Effect.pure("Swift")
    /// let result = effect
    ///     .map { $0.uppercased() }
    ///     .map { "Hello, \($0)!" }
    /// print(result.run()) // Prints "Hello, SWIFT!"
    /// ```
    @inlinable
    public func map<NewValue>(
        _ transform: @escaping (Value) -> NewValue
    ) -> Effect<NewValue> {
        Effect<NewValue> { transform(self.run()) }
    }
    
    /// Chains the effect with another effect-producing closure.
    ///
    /// Use `flatMap(_:)` to sequence computations that themselves return effects,
    /// allowing you to compose multiple effects in a monadic style.
    ///
    /// - Parameter transform: A closure that takes the effect's value and returns a new effect.
    /// - Returns: An effect that, when run, executes both computations in sequence.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create an effect that returns 5
    /// let effect = Effect.pure(5)
    ///
    /// // Use flatMap to chain another effect that adds 10
    /// let chained = effect.flatMap { value in
    ///     Effect.pure(value + 10)
    /// }
    ///
    /// // Run the effect to get the result
    /// print(chained.run()) // Prints "15"
    /// ```
    ///
    /// ## Example: Sequencing effects with side effects
    ///
    /// ```swift
    /// let greet = Effect.pure("World")
    ///     .flatMap { name in
    ///         Effect { "Hello, \(name)!" }
    ///     }
    /// print(greet.run()) // Prints "Hello, World!"
    /// ```
    @inlinable
    public func flatMap<NewValue>(
        _ transform: @escaping (Value) -> Effect<NewValue>
    ) -> Effect<NewValue> {
        self.map(transform)
            .joined()
    }
    
    /// Combines this effect with another effect, producing a new effect that returns a tuple of both results.
    ///
    /// Use `zip(_:)` to run two effects in sequence and collect their results into a tuple.
    /// The resulting effect, when run, will execute both effects and return a tuple containing
    /// the result of this effect as the first element and the result of the other effect as the second element.
    ///
    /// - Parameter other: Another effect to combine with this effect.
    /// - Returns: An effect that, when run, returns a tuple of the results of both effects.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let effect1 = Effect.pure(100)
    /// let effect2 = Effect.pure("Swift")
    ///
    /// let zipped = effect1.zip(effect2)
    /// let result = zipped.run()
    /// print(result) // Prints "(100, "Swift")"
    /// ```
    @inlinable
    public func zip<Other>(
        _ other: Effect<Other>
    ) -> Effect<(Value, Other)> {
        Effect.zip(self, other)
    }
    
    /// Combines multiple effects into a single effect that returns a tuple of all results.
    ///
    /// Use `zip(_:_:)` to run several effects in sequence and collect their results into a tuple.
    /// This method supports variadic generics, allowing you to zip together any number of effects.
    ///
    /// - Parameters:
    ///   - first: The first effect to combine.
    ///   - other: Additional effects to combine with the first.
    /// - Returns: An effect that, when run, returns a tuple containing the results of all effects.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let effect1 = Effect.pure(1)
    /// let effect2 = Effect.pure("two")
    /// let effect3 = Effect.pure(3.0)
    ///
    /// let zipped = Effect.zip(effect1, effect2, effect3)
    /// let result = zipped.run()
    /// print(result) // Prints "(1, "two", 3.0)"
    /// ```
    ///
    /// ## Example: Zipping effects with computations
    ///
    /// ```swift
    /// let a = Effect { 10 }
    /// let b = Effect { 20 }
    /// let c = Effect { 30 }
    ///
    /// let zipped = Effect.zip(a, b, c)
    /// let (x, y, z) = zipped.run()
    /// print(x + y + z) // Prints "60"
    /// ```
    @inlinable
    public static func zip<each T>(
        _ first: Effect<Value>,
        _ other: repeat Effect<each T>
    ) -> Effect<(Value, repeat each T)> {
        Effect<(Value, repeat each T)> {
            (first.run(), repeat (each other).run())
        }
    }
}
