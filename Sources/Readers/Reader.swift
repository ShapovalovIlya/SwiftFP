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
public struct Reader<Environment, Result> {
    @usableFromInline let run: (Environment) -> Result
    
    //MARK: - init(_:)
    @inlinable
    public init(_ run: @escaping (Environment) -> Result) { self.run = run }
    
    /// Returns the “purest” instance possible for the type
    @inlinable
    public static func pure(_ result: Result) -> Self {
        Reader { _ in result }
    }
    
    @inlinable
    public func apply(_ environment: Environment) -> Result {
        run(environment)
    }
    
    @inlinable
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
    /// counter.run(1)   // output 1
    /// counter.run(10)  // output 2
    /// counter.run(100) // output 3
    ///
    /// ```
    ///
    /// - Parameter transform: evaluate closure after `Reader`'s `run` property
    /// - Returns: New `Reader` instance with additional transformation on `Result`- type
    @inlinable
    public func map<NewResult>(
        _ transform: @escaping (Result) -> NewResult
    ) -> Reader<Environment, NewResult> {
        Reader<Environment, NewResult> { transform(apply($0)) }
    }
    
    /// Evaluate given closure and wrap current functor into result `Reader`.
    ///
    ///```swift
    ///
    /// let isEvenChecker = Reader<Int, String>(\.description)
    ///     .flatMap { description in
    ///         Reader<Int, String> { environment
    ///             description
    ///                 .appending(" is even: ")
    ///                 .appending($0.isEven.description)
    ///         }
    ///     }
    ///
    /// isEvenChecker.run(1) // output "1 is even: false"
    /// isEvenChecker.run(2) // output "2 is even: true"
    ///
    ///```
    ///
    /// - Parameter transform: closure that takes current `Environment` and return new `Reader`
    /// - Returns: new `Reader` that is a combination of transformation over current.
    @inlinable
    public func flatMap<NewResult>(
        _ transform: @escaping (Result) -> Reader<Environment, NewResult>
    ) -> Reader<Environment, NewResult> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func zip<Other>(
        _ other: Reader<Environment, Other>
    ) -> Reader<Environment, (Result, Other)> {
        flatMap { result in
            other.map { (result, $0) }
        }
    }
    
    @inlinable
    public func zip<Other, NewResult>(
        _ other: Reader<Environment, Other>,
        into combine: @escaping (Result, Other) -> NewResult
    ) -> Reader<Environment, NewResult> {
        self.zip(other)
            .map(combine)
    }
}
