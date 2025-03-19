//
//  Validated.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation
@_exported import NotEmptyArray

@frozen
public enum Validated<Success, Failure> where Failure: Swift.Error {
    
    /// A valid, storing a `Success` value.
    case valid(Success)
    
    /// A invalid, storing a `NotEmptyArray` of `Failure` values.
    case invalid(NotEmptyArray<Failure>)
    
    //MARK: - init(_:)
    
    /// Creates a new validated by evaluating a throwing closure, capturing the
    /// returned value as a valid, or any thrown error as a invalid.
    ///
    /// - Parameter block: A potentially throwing closure to evaluate.
    @inlinable
    public init(catching block: () throws(Failure) -> Success) {
        do {
            let value = try block()
            self = .valid(value)
        } catch {
            self = .invalid(NotEmptyArray(single: error))
        }
    }
    
    @inlinable
    public init(result: Result<Success, Failure>) {
        switch result {
        case .success(let success):
            self = .valid(success)
            
        case .failure(let failure):
            self = .failed(failure)
        }
    }
    
    @inlinable
    public static func failed(_ error: Failure) -> Validated {
        .invalid(NotEmptyArray(single: error))
    }
    
    //MARK: - joined()
    @inlinable
    public func joined<T>() -> Validated<T,Failure> where Success == Validated<T,Failure> {
        switch self {
        case let .valid(wrapped):
            return wrapped
            
        case let .invalid(errors):
            return .invalid(errors)
        }
    }
    
    //MARK: - map(_:)
    
    /// Returns a new `Validated`, mapping any valid value using the given
    /// transformation.
    ///
    /// Use this method when you need to transform the value of a `Validated`
    /// instance when it represents a valid. The following example transforms
    /// the integer valid value of a result into a string:
    ///
    ///```swift
    /// func getNextInteger() -> Validated<Int, [Error]> { /* ... */ }
    ///
    ///let integerValidated = getNextInteger()
    ///// integerValidated == .valid(5)
    ///let stringValidated = integerResult.map { String($0) }
    ///// stringValidated == .valid("5")
    ///```
    ///
    /// - Parameter transform: A closure that takes the valid value of this
    ///   instance.
    /// - Returns: A `Validated` instance with the result of evaluating `transform`
    ///   as the new valid value if this instance represents a valid.
    @inlinable
    public func map<NewSuccess>(
        _ transform: (Success) -> NewSuccess
    ) -> Validated<NewSuccess, Failure> {
        switch self {
        case let .valid(wrapped):
            return .valid(transform(wrapped))
            
        case let .invalid(errors):
            return .invalid(errors)
        }
    }
    
    @inlinable
    public func mapErrors<NewFailure>(
        _ transform: (NotEmptyArray<Failure>) -> NotEmptyArray<NewFailure>
    ) -> Validated<Success, NewFailure> where NewFailure: Swift.Error {
        switch self {
        case let .valid(wrapped):
            return .valid(wrapped)
            
        case let .invalid(errors):
            return .invalid(transform(errors))
        }
    }
    
    /// Returns a new validated, mapping any invalid values using the given
    /// transformation.
    ///
    /// Use this method when you need to transform the value of a `Validated`
    /// instance when it represents a invalid. The following example transforms
    /// the error value of a validated by wrapping it in a custom `Error` type:
    ///
    ///```swift
    /// struct DatedError: Error {
    ///     var error: Error
    ///     var date: Date
    ///
    ///     init(_ error: Error) {
    ///         self.error = error
    ///         self.date = Date()
    ///     }
    /// }
    ///
    /// let validated: Validated<Int, Error> = // ...
    /// // validated == .invalid([<error value>])
    /// let resultWithDatedError = result.mapError { DatedError($0) }
    /// // validated == .invalid([DatedError(error: <error value>, date: <date>)])
    ///```
    ///
    /// - Parameter transform: A closure that takes the each element in invalid value of the
    ///   instance.
    /// - Returns: A `Validated` instance with the result of evaluating `transform`
    ///   as the new failure value if this instance represents a invalid.
    @inlinable
    public func mapError<NewFailure>(
        _ transform: (Failure) -> NewFailure
    ) -> Validated<Success, NewFailure> where NewFailure: Swift.Error {
        mapErrors { errors in
            errors.map(transform)
        }
    }
    
    @inlinable
    public func asyncMap<NewSuccess>(
        _ transform: (Success) async -> NewSuccess
    ) async -> Validated<NewSuccess, Failure> {
        switch self {
        case let .valid(wrapped):
            return await .valid(transform(wrapped))
            
        case let .invalid(errors):
            return .invalid(errors)
        }
    }
    
    @inlinable
    public func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Validated<NewSuccess, Error> {
        switch self {
        case .valid(let wrapped):
            return Validated<NewSuccess, Error> { try transform(wrapped) }
            
        case .invalid(let errors):
            return .invalid(errors.map(\.self))
        }
    }
    
    //MARK: - flatMap(_:)
    
    /// Returns a new validated, mapping any valid value using the given
    /// transformation and unwrapping the produced result.
    ///
    /// Use this method to avoid a nested validated when your transformation
    /// produces another `Validated` type.
    ///
    /// In this example, note the difference in the result of using `map` and
    /// `flatMap` with a transformation that returns an validated type.
    ///
    ///```swift
    ///func getNextInteger() -> Validated<Int, [Error]> {
    ///    .valid(4)
    ///}
    ///func getNextAfterInteger(_ n: Int) -> Validated<Int, Validated> {
    ///    .valid(n + 1)
    ///}
    ///
    ///let result = getNextInteger().map { getNextAfterInteger($0) }
    ///// result == .valid(.success(5))
    ///
    ///let result = getNextInteger().flatMap { getNextAfterInteger($0) }
    ///// result == .valid(5)
    ///```
    ///
    /// - Parameter transform: A closure that takes the valid value of the instance.
    /// - Returns: A `Validated` instance, either from the closure or the previous `.invalid`.
    @inlinable
    public func flatMap<NewSuccess>(
        _ transform: (Success) -> Validated<NewSuccess, Failure>
    ) -> Validated<NewSuccess, Failure> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func asyncFlatMap<NewSuccess>(
        _ transform: (Success) async -> Validated<NewSuccess, Failure>
    ) async -> Validated<NewSuccess, Failure> {
        await self.asyncMap(transform)
            .joined()
    }
    
    @inlinable
    public func flatMapErrors<NewFailure>(
        _ transform: (NotEmptyArray<Failure>) -> Validated<Success, NewFailure>
    ) -> Validated<Success, NewFailure> {
        switch self {
        case .valid(let value):
            return .valid(value)
            
        case .invalid(let errors):
            return transform(errors)
        }
    }
    
    @inlinable
    public func asyncFlatMapErrors<NewFailure>(
        _ transform: (NotEmptyArray<Failure>) async -> Validated<Success, NewFailure>
    ) async -> Validated<Success, NewFailure> {
        switch self {
        case .valid(let wrapped):
            return .valid(wrapped)
            
        case .invalid(let errors):
            return await transform(errors)
        }
    }
    
    //MARK: - zip(_:)
    @inlinable
    public func zip<Other>(
        _ other: Validated<Other, Failure>
    ) -> Validated<(Success, Other), Failure> {
        switch (self, other) {
        case let (.valid(lhs), .valid(rhs)):
            return .valid((lhs, rhs))
            
        case let (.valid, .invalid(errors)):
            return .invalid(errors)
            
        case let (.invalid(errors), .valid):
            return .invalid(errors)
            
        case let (.invalid(lhs), .invalid(rhs)):
            return .invalid(lhs + rhs)
        }
    }
    
    @inlinable
    public func zip<Other, Transformed>(
        _ other: Validated<Other, Failure>,
        using transform: (Success, Other) -> Transformed
    ) -> Validated<Transformed, Failure> {
        self.zip(other)
            .map(transform)
    }
    
    @inlinable
    public func zip<Other>(
        _ result: Result<Other, Failure>
    ) -> Validated<(Success, Other), Failure> {
        self.zip(Validated<Other, Failure>(result: result))
    }
    
    @inlinable
    public func zip<Other, Transformed>(
        _ result: Result<Other, Failure>,
        using transform: (Success, Other) -> Transformed
    ) -> Validated<Transformed, Failure> {
        self.zip(result)
            .map(transform)
    }

    @inlinable
    public init(_ state: Success, @Validator build: () -> [Validator.Element]) {
        let errors = build()
            .map { $0(state) }
            .reduce(into: [Failure]()) { errors, result in
                switch result {
                case .success: return
                case .failure(let error): errors.append(error)
                }
            }
        if errors.isEmpty {
            self = .valid(state)
            return
        }
        self = .invalid(NotEmptyArray(errors)!)
    }
}

//MARK: - Equatable
extension Validated: Equatable where Success: Equatable, Failure: Equatable {}
extension Validated: Sendable where Success: Sendable, Failure: Sendable {}
extension Validated: Hashable where Success: Hashable, Failure: Hashable {}

public extension Validated {
    @resultBuilder
    enum Validator {
        public typealias ValidationResult = Result<Success, Failure>
        public typealias Element = (Success) -> ValidationResult

        @inlinable
        public static func buildBlock(_ components: Element...) -> [Element] {
            components
        }

        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }
    }
}
