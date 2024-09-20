//
//  Validated.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Foundation
@_exported import NotEmptyArray

public enum Validated<Value, Failure> where Failure: Swift.Error {
    case valid(Value)
    case invalid(NotEmptyArray<Failure>)
    
    //MARK: - init(_:)
    @inlinable
    public init(_ wrapped: Value) {
        self = .valid(wrapped)
    }
    
    @inlinable
    public static func failed(_ error: Failure) -> Validated {
        .invalid(NotEmptyArray(head: error, tail: []))
    }
    
    //MARK: - flatMap(_:)
    @inlinable
    public func flatMap<NewValue>(
        _ transform: (Value) -> Validated<NewValue, Failure>
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
        _ transform: (NotEmptyArray<Failure>) -> Validated<Value, NewFailure>
    ) -> Validated<Value, NewFailure> {
        switch self {
        case .valid(let value):
            return .valid(value)
            
        case .invalid(let errors):
            return transform(errors)
        }
    }
    
    //MARK: - map(_:)
    @inlinable
    public func map<NewValue>(
        _ transform: (Value) -> NewValue
    ) -> Validated<NewValue, Failure> {
        flatMap { wrapped in
            Validated<NewValue, Failure>(transform(wrapped))
        }
    }
    
    @inlinable
    public func tryMap<NewValue>(
        _ transform: (Value) throws -> NewValue
    ) -> Validated<NewValue, Error> {
        switch self {
        case .valid(let wrapped):
            return Validated<NewValue, Error> { try transform(wrapped) }
            
        case .invalid(let errors):
            return .invalid(errors.mapNotEmpty { $0 })
        }
    }
    
    @inlinable
    public func mapErrors<NewFailure>(
        _ transform: (Failure) -> NewFailure
    ) -> Validated<Value, NewFailure> {
        flatMapErrors { errors in
            Validated<Value, NewFailure>.invalid(errors.mapNotEmpty(transform))
        }
    }
    
    //MARK: - zip(_:)
    @inlinable
    public func zip<Other>(
        _ other: Validated<Other, Failure>
    ) -> Validated<(Value, Other), Failure> {
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
    public func zip<Other, Result>(
        _ other: Validated<Other, Failure>,
        using transform: (Value, Other) -> Result
    ) -> Validated<Result, Failure> {
        self.zip(other).map(transform)
    }
}

public extension Validated where Failure == Error {
    @inlinable
    init(catch block: () throws -> Value) {
        do {
            let value = try block()
            self = .valid(value)
        } catch {
            self = .invalid(NotEmptyArray(head: error, tail: []))
        }
    }
}

extension Validated: Equatable where Value: Equatable, Failure: Equatable {
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

public extension Validated {
    @resultBuilder
    enum Accumulator {
       
        
        public static func buildBlock(_ components: Failure...) -> [Failure] {
            components
        }
    
    }
}
