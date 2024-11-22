//
//  Reader.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 20.11.2024.
//

import Foundation

/// The Reader is a pattern for returning functions as part of other functions.
/// That is,`Reader<A, B>` corresponds to a function `(A) -> B`.
public struct Reader<Environment, Result> {
    public let run: (Environment) -> Result
    
    @inlinable
    public init(_ run: @escaping (Environment) -> Result) { self.run = run }
    
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
        Reader<Environment, NewResult> { transform(run($0)) }
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
        Reader<Environment, NewResult> { env in
            map(transform).run(env).run(env)
        }
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
        into: @escaping (Result, Other) -> NewResult
    ) -> Reader<Environment, NewResult> {
        self.zip(other)
            .map(into)
    }
}
