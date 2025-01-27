//
//  Reader.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 20.11.2024.
//

import Foundation

/// The `Reader` monad (also called the Environment monad).
/// Represents a computation, which can read values from a shared environment,
/// pass values from function to function, and execute sub-computations in a modified environment.
///
/// The Reader is a pattern for returning functions as part of other functions.
/// That is, `Reader<A,B>` corresponds to a function `(A) -> B`.
///
/// `Reader` adopts `callAsFunction` method that is, an instance of `Reader` can be used as function.
///
///```swift
///let countLettersInInt = Reader<Int, String>(\.description).map(\.count)
///
///countLettersInInt(1)   // output 1
///countLettersInInt(10)  // output 2
///countLettersInInt(100) // output 3
///```
///
@frozen
@dynamicMemberLookup
public struct Reader<Environment, Result>: Sendable {
    public typealias Work = @Sendable (Environment) -> Result
    
    @usableFromInline let run: Work
    
    //MARK: - init(_:)
    @inlinable
    public init(_ run: @escaping Work) { self.run = run }
    
    //MARK: - Subscript
    @inlinable
    public subscript<T: Sendable>(
        dynamicMember keyPath: WritableKeyPath<Result, T> & Sendable
    ) -> (T) -> Self {
        { newValue in self.reduce { $0[keyPath: keyPath] = newValue } }
    }
    
    //MARK: - Public methods
    
    /// Returns the “purest” instance possible for the type
    @inlinable
    public static func pure(_ result: Result) -> Self where Result: Sendable {
        Reader { _ in result }
    }
    
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
    
    @inlinable
    public func joined<T>() -> Reader<Environment, T> where Result == Reader<Environment, T> {
        Reader<Environment, T> { env in
            self.apply(env).apply(env)
        }
    }
    
    /// Transform `Reader`'s run result, using given closure.
    ///
    /// ```swift
    /// // Create counter dependency, that store combined computation result
    /// let counter = Reader<Int, String>(\.description).map(\.count)
    ///
    /// // Evaluate dependency with different input values
    /// counter.apply(1)   // output 1
    /// counter.apply(10)  // output 2
    /// counter.apply(100) // output 3
    /// ```
    ///
    /// - Parameter transform: evaluate closure after `Reader`'s `run` property
    /// - Returns: New `Reader` instance with additional transformation on `Result`- type
    @inlinable
    public func map<NewResult>(
        _ transform: @escaping @Sendable (Result) -> NewResult
    ) -> Reader<Environment, NewResult> {
        Reader<Environment, NewResult> { transform(apply($0)) }
    }
    
    /// Transform `Reader`'s environment, using given closure.
    ///
    /// ```swift
    ///  // TO DO - Find proper code example 😀
    /// ```
    ///
    /// - Parameter transform: closure with context that returns new `Reader`'s environment.
    /// - Returns: New `Reader` with given source of environment.
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
    
    /// Evaluate given closure and wrap current functor into result `Reader`.
    ///
    ///```swift
    /// let isEvenChecker = Reader<Int, String>(\.description)
    ///     .flatMap { description in
    ///         Reader<Int, String> { environment
    ///             description
    ///                 .appending(" is even: ")
    ///                 .appending($0.isEven.description)
    ///         }
    ///     }
    ///
    /// isEvenChecker.apply(1) // output "1 is even: false"
    /// isEvenChecker.apply(2) // output "2 is even: true"
    ///```
    ///
    /// - Parameter transform: closure that takes current `Environment` and return new `Reader`
    /// - Returns: new `Reader` that is a combination of transformation over current.
    @inlinable
    public func flatMap<NewResult>(
        _ transform: @escaping @Sendable (Result) -> Reader<Environment, NewResult>
    ) -> Reader<Environment, NewResult> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func zip<Other>(
        _ other: Reader<Environment, Other>
    ) -> Reader<Environment, (Result, Other)> where Result: Sendable {
        flatMap { result in
            other.map { (result, $0) }
        }
    }
    
    @inlinable
    public func zip<Other, NewResult>(
        _ other: Reader<Environment, Other>,
        into combine: @escaping @Sendable (Result, Other) -> NewResult
    ) -> Reader<Environment, NewResult> where Result: Sendable {
        self.zip(other)
            .map(combine)
    }
    
    @inlinable
    public func reduce(
        _ process: @escaping @Sendable (inout Result) -> Void
    ) -> Self {
        map {
            var mutating = $0
            process(&mutating)
            return mutating
        }
    }
}
