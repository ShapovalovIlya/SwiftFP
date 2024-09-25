//
//  Validated.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation
@_exported import NotEmptyArray

public enum Validated<Wrapped, Failure> where Failure: Swift.Error {
    case valid(Wrapped)
    case invalid(NotEmptyArray<Failure>)
    
    //MARK: - init(_:)
    @inlinable
    public init(_ wrapped: Wrapped) {
        self = .valid(wrapped)
    }
    
    @inlinable
    public init(catch block: () throws(Failure) -> Wrapped) {
        do {
            let value = try block()
            self = .valid(value)
        } catch {
            self = .invalid(NotEmptyArray(head: error, tail: []))
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
        .invalid(NotEmptyArray(head: error, tail: []))
    }
    
    //MARK: - flatMap(_:)
    @inlinable
    public func flatMap<NewValue>(
        _ transform: (Wrapped) -> Validated<NewValue, Failure>
    ) -> Validated<NewValue, Failure> {
        switch self {
        case .valid(let value):
            return transform(value)
            
        case .invalid(let errors):
            return .invalid(errors)
        }
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
    
    //MARK: - map(_:)
    @inlinable
    public func map<NewWrapped>(
        _ transform: (Wrapped) -> NewWrapped
    ) -> Validated<NewWrapped, Failure> {
        flatMap { wrapped in
            Validated<NewWrapped, Failure>(transform(wrapped))
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
            return .invalid(errors.mapNotEmpty { $0 })
        }
    }
    
    @inlinable
    public func mapErrors<NewFailure>(
        _ transform: (Failure) -> NewFailure
    ) -> Validated<Wrapped, NewFailure> {
        flatMapErrors { errors in
            Validated<Wrapped, NewFailure>.invalid(errors.mapNotEmpty(transform))
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
        _ transform: (Validated<Wrapped, Failure>) -> T
    ) -> T {
        transform(self)
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
extension Validated: Equatable where Wrapped: Equatable,
                                     Failure: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.valid(wrapped1) ,.valid(wrapped2)):
            return wrapped1 == wrapped2
            
        case let (.invalid(errors1), .invalid(errors2)):
            return errors1 == errors2
            
        default: return false
        }
    }
}

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
