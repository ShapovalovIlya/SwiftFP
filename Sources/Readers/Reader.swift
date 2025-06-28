//
//  Reader.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 20.11.2024.
//

import Foundation

/// A functional wrapper for computations that depend on a shared, read-only environment.
///
/// The ‎`Reader` type represents a computation that can read values from a shared environment and produce a result.
/// It is a common abstraction in functional programming, enabling dependency injection and composition of environment-dependent logic.
/// The environment is provided at the time of evaluation, allowing you to build pipelines of computations that are parameterized by context.
///
/// - Parameters:
///   - Environment: The type of the shared environment or context.
///   - Result: The type of the value produced by the computation.
///
/// ‎`Reader` supports functional transformations such as ‎`map`, ‎`flatMap`, and ‎`pullback`, as well as composition and zipping of multiple readers.
///
/// ### Example:
///```swift
/// // Define a Reader that extracts the count of characters from an Int's description
/// let counter = Reader<Int, String>(\.description).map(\.count)
///
/// // Evaluate with different environments
/// counter.apply(1)   // 1
/// counter.apply(10)  // 2
/// counter.apply(100) // 3
/// ```
///
/// ## Use Cases:
/// - Dependency injection: Pass dependencies through the environment instead of as explicit parameters.
/// - Configuration: Build computations that depend on runtime configuration or context.
/// - Testability: Easily swap environments for testing purposes.
///
/// - Note: The environment is read-only and must be provided at the time of evaluation.
///
@frozen
public struct Reader<Environment, Result>: Sendable {
    public typealias Work = @Sendable (Environment) -> Result
    
    @usableFromInline let run: Work
    
    //MARK: - init(_:)
    
    /// Creates a new ‎``Reader`` with the given computation.
    ///
    /// Initializes a ‎``Reader`` instance by providing a closure that describes how to compute the result from the environment.
    /// The closure is stored and later invoked when the ‎``Reader`` is evaluated with a specific environment value.
    ///
    /// - Parameter run: A closure that takes an environment value and returns a result.
    ///
    /// ### Example:
    ///```swift
    /// // Define a Reader that returns the square of an integer environment
    /// let squareReader = Reader<Int, Int> { env in env * env }
    ///
    /// // Evaluate the Reader with different environments
    /// let result1 = squareReader.apply(3) // result1 is 9
    /// let result2 = squareReader.apply(5) // result2 is 25
    /// ```
    ///
    @inlinable
    public init(_ run: @escaping Work) {
        self.run = run
    }
    
    //MARK: - Public methods
    
    /// Returns the “purest” instance possible for the type
    
    /// Creates a ‎``Reader`` that always returns the provided result, regardless of the environment.
    ///
    /// This static method is useful for lifting a constant value into the ‎``Reader`` context.
    /// The resulting ‎``Reader`` ignores its environment and always produces the same result.
    ///
    /// - Parameter result: The value to be returned by the ‎``Reader``.
    /// - Returns: A ‎``Reader`` instance that always returns ‎`result` for any environment.
    ///
    /// ### Example:
    ///```swift
    /// // Create a Reader that always returns the string "Hello"
    /// let helloReader = Reader<Int, String>.pure("Hello")
    ///
    /// // The environment is ignored; the result is always "Hello"
    /// helloReader.apply(42) // "Hello"
    /// helloReader.apply(0)  // "Hello"
    /// ```
    ///
    @inlinable
    public static func pure(_ result: Result) -> Self where Result: Sendable {
        Reader { _ in result }
    }
    
    /// Evaluates the ‎``Reader`` with the given environment and returns the result.
    ///
    /// This method executes the stored computation by providing it with the specified environment value.
    /// It is the primary way to extract the result from a ‎``Reader`` by supplying the required context.
    ///
    /// - Parameter environment: The environment value to use for the computation.
    /// - Returns: The result produced by applying the environment to the ‎``Reader``.
    ///
    /// ### Example:
    ///```swift
    /// // Define a Reader that returns the environment value doubled
    /// let doubleReader = Reader<Int, Int> { env in env * 2 }
    ///
    /// // Evaluate the Reader with a specific environment
    /// let result = doubleReader.apply(10) // result is 20
    ///```
    ///
    @Sendable
    @inlinable
    public func apply(_ environment: Environment) -> Result {
        run(environment)
    }
    
    @inlinable
    @discardableResult
    public func callAsFunction(_ environment: Environment) -> Result {
        apply(environment)
    }
    
    /// Flattens a nested ‎``Reader`` into a single ‎``Reader``.
    ///
    /// This method is used when the result of a ‎``Reader`` is itself another ‎``Reader`` with the same environment type.
    /// It returns a new ‎``Reader`` that, when evaluated, applies the environment to both the outer and inner ‎``Reader``,
    /// effectively “joining” or flattening the nested structure into a single layer.
    ///
    /// - Returns: A ‎``Reader`` that produces the final result by applying the environment to both the outer and inner ‎``Reader``.
    ///
    /// ### Example:
    ///```swift
    /// // Create a Reader that returns another Reader
    /// let nestedReader = Reader<Int, Reader<Int, String>> { env in
    ///     Reader { innerEnv in "env: \(env), innerEnv: \(innerEnv)" }
    /// }
    ///
    /// // Flatten the nested Reader
    /// let flatReader = nestedReader.joined()
    ///
    /// // Evaluate the flattened Reader
    /// let result = flatReader.apply(5) // result is "env: 5, innerEnv: 5"
    ///```
    ///
    @inlinable
    public func joined<T>() -> Reader<Environment, T> where Result == Reader<Environment, T> {
        Reader<Environment, T> { env in
            self.apply(env).apply(env)
        }
    }
    
    /// Transforms the result of the ‎``Reader`` using the provided closure.
    ///
    /// This method allows you to apply a transformation to the value produced by the ‎``Reader`` without modifying the environment.
    /// It returns a new ‎``Reader`` that, when evaluated, applies the original computation and then transforms its result using the given closure.
    ///
    /// - Parameter transform: A closure that takes the result of the ‎``Reader`` and returns a new value.
    /// - Returns: A new ‎``Reader`` instance that produces the transformed result.
    ///
    /// ### Example:
    ///```swift
    /// // Create a Reader that returns the environment as a string
    /// let stringReader = Reader<Int, String> { env in "\(env)" }
    ///
    /// // Transform the result to its character count
    /// let countReader = stringReader.map { $0.count }
    ///
    /// // Evaluate the transformed Reader
    /// let result = countReader.apply(1234) // result is 4
    ///```
    ///
    @inlinable
    public func map<NewResult>(
        _ transform: @escaping @Sendable (Result) -> NewResult
    ) -> Reader<Environment, NewResult> {
        Reader<Environment, NewResult> { transform(apply($0)) }
    }
    
    /// Transforms the environment required by the ‎``Reader`` using the provided closure.
    ///
    /// The ‎`pullback` method allows you to adapt a ‎``Reader`` that expects a specific environment type
    /// so it can be used with a different source environment.
    /// It does this by providing a function that converts the new source environment into the original environment type expected by the ‎``Reader``.
    /// This is useful for composing readers in larger applications where the environment may need to be mapped or projected from a broader context.
    ///
    /// - Parameter transform: A closure that converts a value of type ‎`Source` (the new environment) into the original ‎`Environment`.
    /// - Returns: A new ‎``Reader`` that takes the new environment type and produces the same result as the original reader.
    ///
    /// ### Example:
    ///```swift
    /// struct AppEnvironment { let userID: Int }
    ///
    /// // A Reader that expects an Int environment
    /// let userIDReader = Reader<Int, String> { id in "User ID: \(id)" }
    ///
    /// // Adapt the Reader to work with AppEnvironment
    /// let appReader = userIDReader.pullback { (env: AppEnvironment) in env.userID }
    ///
    /// // Evaluate with the new environment type
    /// let result = appReader.apply(AppEnvironment(userID: 42)) // result is "User ID: 42"
    ///```
    ///
    @inlinable
    public func pullback<Source>(
        _ transform: @escaping @Sendable (Source) -> Environment
    ) -> Reader<Source, Result> {
        Reader<Source, Environment>(transform)
            .map(self.apply)
    }
    
    @inlinable
    public func tryMap<NewResult>(
        _ transform: @escaping @Sendable (Result) throws -> NewResult
    ) -> Reader<Environment, Swift.Result<NewResult, Error>> {
        map { r in Swift.Result { try transform(r) } }
    }
    
    /// Chains computations that depend on the same environment, flattening the result into a single ‎``Reader``.
    ///
    /// The ‎`flatMap` method allows you to sequence operations where each step may produce a new ‎``Reader`` that depends on the same environment.
    /// It applies the provided transformation to the result of the current ‎``Reader``, producing a new ‎``Reader``, and then flattens the nested structure into a single ‎``Reader``.
    /// This is useful for composing multiple environment-dependent computations in a readable and functional style.
    ///
    /// - Parameter transform: A closure that takes the result of the current ‎``Reader`` and returns a new ‎``Reader`` with the same environment but a new result type.
    /// - Returns: A new ‎``Reader`` that represents the chained computation.
    ///
    /// ### Example:
    ///```swift
    /// // A Reader that returns the environment as a string
    /// let stringReader = Reader<Int, String> { env in "\(env)" }
    ///
    /// // Chain another Reader that appends extra info to the string
    /// let chainedReader = stringReader.flatMap { str in
    ///     Reader<Int, String> { env in "\(str) is even: \(env % 2 == 0)" }
    /// }
    ///
    /// // Evaluate the chained Reader
    /// let result = chainedReader.apply(4) // result is "4 is even: true"
    /// let result2 = chainedReader.apply(5) // result is "5 is even: false"
    ///```
    ///
    @inlinable
    public func flatMap<NewResult>(
        _ transform: @escaping @Sendable (Result) -> Reader<Environment, NewResult>
    ) -> Reader<Environment, NewResult> {
        self.map(transform)
            .joined()
    }
    
    /// Combines the results of two ‎``Reader`` instances into a single ‎``Reader`` that returns a tuple of both results.
    ///
    /// The ‎`zip` method allows you to run two ‎``Reader`` computations with the same environment and collect their results together.
    /// The resulting ‎``Reader`` produces a tuple containing the result of the current ‎``Reader`` and the result of the ‎`other` ‎``Reader``.
    ///
    /// - Parameter other: Another ‎``Reader`` that operates on the same environment and produces a result of type ‎`Other`.
    /// - Returns: A new ‎``Reader`` that, when evaluated, returns a tuple of both results.
    ///
    /// ### Example:
    ///```swift
    /// // A Reader that returns the environment as a string
    /// let stringReader = Reader<Int, String> { env in "\(env)" }
    ///
    /// // A Reader that returns whether the environment is even
    /// let evenReader = Reader<Int, Bool> { env in env % 2 == 0 }
    ///
    /// // Combine both Readers
    /// let zippedReader = stringReader.zip(evenReader)
    ///
    /// // Evaluate the zipped Reader
    /// let result = zippedReader.apply(4) // result is ("4", true)
    /// let result2 = zippedReader.apply(5) // result is ("5", false)
    ///```
    ///
    @inlinable
    public func zip<Other>(
        _ other: Reader<Environment, Other>
    ) -> Reader<Environment, (Result, Other)> where Result: Sendable {
        flatMap { result in
            other.map { (result, $0) }
        }
    }
    
    /// Combines the results of multiple ‎``Reader`` instances into a single‎ that returns a tuple of all results.
    ///
    /// This static ‎`zip` method allows you to run several ‎``Reader`` computations with the same environment and collect their results together.
    /// The resulting ‎``Reader`` produces a tuple containing the result of the ‎`first` ‎`Reader` and the results of each additional ‎`Reader` in ‎`other`.
    /// This is especially useful for aggregating the outputs of multiple environment-dependent computations into a single value.
    ///
    /// - Parameters:
    ///   - first: The first ‎`Reader` to evaluate.
    ///   - other: A variadic list of additional ‎`Reader` instances to evaluate with the same environment.
    /// - Returns: A new ‎`Reader` that, when evaluated, returns a tuple of all results.
    ///
    /// ### Example:
    ///```swift
    /// // Define several Readers
    /// let intReader = Reader<Int, Int> { $0 }
    /// let stringReader = Reader<Int, String> { "\($0)" }
    /// let evenReader = Reader<Int, Bool> { $0 % 2 == 0 }
    ///
    /// // Zip them together
    /// let zipped = Reader.zip(intReader, stringReader, evenReader)
    ///
    /// // Evaluate the zipped Reader
    /// let result = zipped.apply(4) // result is (4, "4", true)
    /// let result2 = zipped.apply(5) // result is (5, "5", false)
    ///```
    ///
    @inlinable
    public static func zip<each U>(
        _ first: Reader<Environment, Result>,
        _ other: repeat Reader<Environment, each U>
    ) -> Reader<Environment, (Result, repeat each U)> {
        Reader<Environment, (Result, repeat each U)> { env in
            (first.apply(env), repeat (each other).apply(env))
        }
    }
    
    /// Combines the results of two ‎``Reader`` instances using a custom combining closure.
    ///
    /// The ‎`zip(_:into:)` method allows you to run two ‎``Reader`` computations with the same environment and then merge their results
    /// into a single value using the provided ‎`combine` closure. This is useful for composing multiple environment-dependent computations
    /// and producing a single, custom result.
    ///
    /// - Parameters:
    ///   - other: Another ‎``Reader`` that operates on the same environment and produces a result of type ‎`Other`.
    ///   - combine: A closure that takes the results of both readers and combines them into a new value.
    /// - Returns: A new ‎``Reader`` that, when evaluated, returns the combined result.
    ///
    /// ### Example:
    ///```swift
    /// // A Reader that returns the environment as a string
    /// let stringReader = Reader<Int, String> { env in "\(env)" }
    ///
    /// // A Reader that returns whether the environment is even
    /// let evenReader = Reader<Int, Bool> { env in env % 2 == 0 }
    ///
    /// // Combine both Readers into a custom string
    /// let combinedReader = stringReader.zip(evenReader) { str, isEven in
    ///     "\(str) is even: \(isEven)"
    /// }
    ///
    /// // Evaluate the combined Reader
    /// let result = combinedReader.apply(4) // result is "4 is even: true"
    /// let result2 = combinedReader.apply(5) // result is "5 is even: false"
    ///```
    ///
    @inlinable
    public func zip<Other, NewResult>(
        _ other: Reader<Environment, Other>,
        into combine: @escaping @Sendable (Result, Other) -> NewResult
    ) -> Reader<Environment, NewResult> where Result: Sendable {
        self.zip(other)
            .map(combine)
    }
    
    /// Composes two ‎``Reader`` instances by feeding the result of the first as the environment for the second.
    ///
    /// The ‎`curry` method allows you to chain two ‎``Reader`` computations, where the result of the current ‎``Reader``
    /// is used as the environment for the next ‎``Reader``. This enables the construction of pipelines where the output
    /// of one computation becomes the input for the next, all within the ‎`Reader` context.
    ///
    /// - Parameter next: A ‎`Reader` that takes the result of the current ‎`Reader` as its environment and produces a new result.
    /// - Returns: A new ‎`Reader` that, when evaluated, applies the current ‎`Reader` to the environment, then applies ‎`next` to the result.
    ///
    /// ### Example:
    ///```swift
    /// // A Reader that returns the environment doubled
    /// let doubleReader = Reader<Int, Int> { $0 * 2 }
    ///
    /// // A Reader that takes an Int and returns its string description
    /// let stringReader = Reader<Int, String> { "\($0)" }
    ///
    /// // Curry the two Readers
    /// let curried = doubleReader.curry(stringReader)
    ///
    /// // Evaluate the curried Reader
    /// let result = curried.apply(5) // result is "10"
    ///```
    ///
    @inlinable
    public func curry<T>(_ next: Reader<Result, T>) -> Reader<Environment, T> {
        map(next.apply)
    }
}

public extension Reader {
    @inlinable
    static func + <T>(_ lhs: Self, _ rhs: Reader<Result, T>) -> Reader<Environment, T> {
        lhs.curry(rhs)
    }
}
