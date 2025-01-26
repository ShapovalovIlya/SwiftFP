//
//  AsyncReader.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 25.01.2025.
//

import Foundation

@frozen
@dynamicMemberLookup
public struct AsyncReader<IO, Result>: Sendable where IO: Sendable,
                                                   Result: Sendable {
    public typealias Task = @Sendable (IO) async -> Result
    
    @usableFromInline let run: Task
    
    //MARK: - init(_:)
    @inlinable
    public init(_ run: @escaping Task) { self.run = run }
    
    @discardableResult
    @inlinable
    public func callAsFunction(_ io: IO) async -> Result {
        await apply(io)
    }

    //MARK: - Public methods
    @Sendable
    @inlinable
    public func apply(_ io: IO) async -> Result {
        await run(io)
    }
    
    /// Returns the “purest” instance possible for the type.
    /// - Parameter result: Value which will be used as `Reader`'s task result.
    /// - Returns: Instance of `AsyncReader`, contained `Result` value, not depending of any `IO`
    @inlinable
    public static func pure(_ result: Result) -> Self {
        AsyncReader { _ in result }
    }
    
    @inlinable
    public func joined<T>() -> AsyncReader<IO, T> where Result == AsyncReader<IO, T> {
        AsyncReader<IO, T> { io in
            await apply(io).apply(io)
        }
    }
    
    /// Transform `AsyncReader`'s task result, using given closure.
    ///
    /// ```swift
    /// // Create counter dependency, that store combined asynchronous computation result
    /// let counter = AsyncReader<Int, String>.map(asyncCount(string:))
    ///
    /// // Evaluate dependency with different input values
    /// await counter.apply(1)   // output 1
    /// await counter.apply(10)  // output 2
    /// await counter.apply(100) // output 3
    ///
    /// ```
    ///
    /// - Parameter transform: asynchronous closure that takes `AsyncReader`'s task result as input parameter.
    /// - Returns: New `AsyncReader` instance contained previous task embedded in given one.
    @inlinable
    public func map<NewResult>(
        _ task: @escaping @Sendable (Result) async -> NewResult
    ) -> AsyncReader<IO, NewResult> {
        AsyncReader<IO, NewResult> { io in
            await task(self.apply(io))
        }
    }
    
    //MARK: - Subscript
    @inlinable
    public subscript<T: Sendable>(
        dynamicMember keyPath: WritableKeyPath<Result, T> & Sendable
    ) -> (T) -> Self {
        { newValue in
            self.map { result in
                var mutating = result
                mutating[keyPath: keyPath] = newValue
                return mutating
            }
        }
    }
    
    /// <#Description#>
    ///
    ///```swift
    /// let isEvenChecker = AsyncReader<Int, String>(\.description)
    ///     .flatMap { description in
    ///         AsyncReader<Int, String> { io in
    ///             description
    ///                 .appending(" is even: ")
    ///                 .appending(io.isEven.description)
    ///         }
    ///     }
    ///
    /// isEvenChecker.apply(1) // output "1 is even: false"
    /// isEvenChecker.apply(2) // output "2 is even: true"
    ///```
    ///
    /// - Parameter task: <#task description#>
    /// - Returns: <#description#>
    @inlinable
    public func flatMap<NewResult>(
        _ task: @escaping @Sendable (Result) async -> AsyncReader<IO, NewResult>
    ) -> AsyncReader<IO, NewResult> {
        self.map(task)
            .joined()
    }
    
    @inlinable
    public func pullback<Source>(
        _ task: @escaping @Sendable (Source) async -> IO
    ) -> AsyncReader<Source, Result> {
        AsyncReader<Source, IO>(task)
            .map(self.apply)
    }
    
    /// Zip
    ///
    ///```swift
    ///let describer = AsyncReader<Int, String>(\.description)
    ///let isEven = AsyncReader<Int, Bool>(\.isEven)
    ///let combined = describer.zip(isEven)
    ///
    ///await combined.apply(1) // output ("1", false)
    ///await combined.apply(2) // output ("2", true)
    ///```
    ///
    /// - Parameter other: `AsyncReader` instance to combine.
    /// - Returns: instance of `AsyncReader` that contains task result of two upstream readers in tuple
    @inlinable
    public func zip<Other>(
        _ other: AsyncReader<IO, Other>
    ) -> AsyncReader<IO, (Result, Other)> {
        flatMap { result in
            other.map { (result, $0) }
        }
    }

    @inlinable
    public func zip<Other, Combined>(
        _ other: AsyncReader<IO, Other>,
        into combine: @escaping @Sendable (Result, Other) async -> Combined
    ) -> AsyncReader<IO, Combined> {
        self.zip(other)
            .map(combine)
    }
}
