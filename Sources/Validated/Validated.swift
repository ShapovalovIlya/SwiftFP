//
//  Validated.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation
@_exported import NotEmptyArray

@frozen
public enum Validated<Wrapped, Failure> where Failure: Swift.Error {
    case valid(Wrapped)
    case invalid(NotEmptyArray<Failure>)
    
    //MARK: - init(_:)
    @inlinable
    public init(catch block: () throws(Failure) -> Wrapped) {
        do {
            let value = try block()
            self = .valid(value)
        } catch {
            self = .invalid(NotEmptyArray(single: error))
        }
    }
    
    @inlinable
    public init(result: Result<Wrapped, Failure>) {
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
    public func joined<T>() -> Validated<T,Failure> where Wrapped == Validated<T,Failure> {
        switch self {
        case let .valid(wrapped):
            return wrapped
            
        case let .invalid(errors):
            return .invalid(errors)
        }
    }
    
    //MARK: - map(_:)
    @inlinable
    public func map<NewWrapped>(
        _ transform: (Wrapped) -> NewWrapped
    ) -> Validated<NewWrapped, Failure> {
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
    ) -> Validated<Wrapped, NewFailure> where NewFailure: Swift.Error {
        switch self {
        case let .valid(wrapped):
            return .valid(wrapped)
            
        case let .invalid(errors):
            return .invalid(transform(errors))
        }
    }
    
    @inlinable
    public func mapEachError<NewFailure>(
        _ transform: (Failure) -> NewFailure
    ) -> Validated<Wrapped, NewFailure> where NewFailure: Swift.Error {
        mapErrors { errors in
            errors.mapNotEmpty(transform)
        }
    }
    
    @inlinable
    public func asyncMap<NewWrapped>(
        _ transform: (Wrapped) async -> NewWrapped
    ) async -> Validated<NewWrapped, Failure> {
        switch self {
        case let .valid(wrapped):
            return await .valid(transform(wrapped))
            
        case let .invalid(errors):
            return .invalid(errors)
        }
    }
    
    @inlinable
    public func tryMap<NewWrapped>(
        _ transform: (Wrapped) throws -> NewWrapped
    ) -> Validated<NewWrapped, Error> {
        switch self {
        case .valid(let wrapped):
            return Validated<NewWrapped, Error> { try transform(wrapped) }
            
        case .invalid(let errors):
            return .invalid(errors.mapNotEmpty(\.self))
        }
    }
    
    //MARK: - flatMap(_:)
    @inlinable
    public func flatMap<NewWrapped>(
        _ transform: (Wrapped) -> Validated<NewWrapped, Failure>
    ) -> Validated<NewWrapped, Failure> {
        self.map(transform)
            .joined()
    }
    
    @inlinable
    public func asyncFlatMap<NewWrapped>(
        _ transform: (Wrapped) async -> Validated<NewWrapped, Failure>
    ) async -> Validated<NewWrapped, Failure> {
        await self.asyncMap(transform)
            .joined()
    }
    
    @inlinable
    public func flatMapErrors<NewFailure>(
        _ transform: (NotEmptyArray<Failure>) -> Validated<Wrapped, NewFailure>
    ) -> Validated<Wrapped, NewFailure> {
        switch self {
        case .valid(let value):
            return .valid(value)
            
        case .invalid(let errors):
            return transform(errors)
        }
    }
    
    @inlinable
    public func asyncFlatMapErrors<NewFailure>(
        _ transform: (NotEmptyArray<Failure>) async -> Validated<Wrapped, NewFailure>
    ) async -> Validated<Wrapped, NewFailure> {
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
    ) -> Validated<(Wrapped, Other), Failure> {
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
        using transform: (Wrapped, Other) -> Transformed
    ) -> Validated<Transformed, Failure> {
        self.zip(other)
            .map(transform)
    }
    
    @inlinable
    public func zip<Other>(
        _ result: Result<Other, Failure>
    ) -> Validated<(Wrapped, Other), Failure> {
        self.zip(Validated<Other, Failure>(result: result))
    }
    
    @inlinable
    public func zip<Other, Transformed>(
        _ result: Result<Other, Failure>,
        using transform: (Wrapped, Other) -> Transformed
    ) -> Validated<Transformed, Failure> {
        self.zip(result)
            .map(transform)
    }
        
    //MARK: - reduce(_:)
    @inlinable
    public func reduce<T>(
        _ transform: (Validated<Wrapped, Failure>) throws -> T
    ) rethrows -> T {
        try transform(self)
    }
    
    @inlinable
    public func accumulate(
        @Accumulator _ accumulated: (Wrapped) -> [Self]
    ) -> Validated<Wrapped, Failure> {
        flatMap { wrapped in
            accumulated(wrapped).reduce(self) { partialResult, next in
                partialResult.zip(next) { lhs, _ in lhs }
            }
        }
    }
}

//MARK: - Equatable
extension Validated: Equatable where Wrapped: Equatable, Failure: Equatable {}
extension Validated: Sendable where Wrapped: Sendable, Failure: Sendable {}
extension Validated: Hashable where Wrapped: Hashable, Failure: Hashable {}

public extension Validated {
    @resultBuilder
    enum Accumulator {
        public typealias Element = Validated
        public typealias ValidationResult = Result<Wrapped, Failure>
        
        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [expression]
        }
        
        @inlinable
        public static func buildExpression(
            _ expression: ValidationResult
        ) -> [Element] {
            buildExpression(Validated(result: expression))
        }
        
        @inlinable
        public static func buildExpression(
            _ expression: [ValidationResult]
        ) -> [Element] {
            expression.map(Validated.init(result:))
        }
        
        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            expression
        }
        
        @inlinable
        public static func buildBlock(_ components: Element...) -> [Element] {
            components
        }
        
        @inlinable
        public static func buildBlock(_ components: [Element]...) -> [Element] {
            components.flatMap(\.self)
        }
        
        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }
        
        @inlinable
        public static func buildEither(first component: [Element]) -> [Element] {
            component
        }
        
        @inlinable
        public static func buildEither(second component: [Element]) -> [Element] {
            component
        }
        
    }
}
