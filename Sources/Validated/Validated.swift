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
    public func zip<Other, Result>(
        _ other: Validated<Other, Failure>,
        using transform: (Wrapped, Other) -> Result
    ) -> Validated<Result, Failure> {
        self.zip(other)
            .map(transform)
    }
    
    //MARK: - validate(_:)
    @inlinable
    public func validate(
        @Accumulator _ validation: (Wrapped) -> Validated<Wrapped, Failure>
    ) -> Validated<Wrapped, Failure> {
        flatMap(validation)
    }
}

public extension Validated where Failure == Error {
    @inlinable
    init(catch block: () throws -> Wrapped) {
        do {
            let value = try block()
            self = .valid(value)
        } catch {
            self = .invalid(NotEmptyArray(head: error, tail: []))
        }
    }
}

extension Validated: Equatable where Wrapped: Equatable, Failure: Equatable {
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
    //MARK: - Accumulator
    @resultBuilder
    enum Accumulator {
        public typealias Element = Validated
        
        @available(*, unavailable)
        public static func buildOptional(
            _ component: [Element]?
        ) -> NotEmptyArray<Element> {
            fatalError()
        }
        
        @inlinable
        public static func buildExpression(
            _ expression: Element
        ) -> NotEmptyArray<Element> {
            NotEmptyArray(head: expression, tail: [])
        }
        
        @inlinable
        public static func buildExpression(
            _ expression: Result<Wrapped, Failure>
        ) -> NotEmptyArray<Element> {
            buildExpression(Validated(result: expression))
        }
        
        public static func buildExpression(
            _ expression: NotEmptyArray<Element>
        ) -> NotEmptyArray<Element> {
            expression
        }
               
        @inlinable
        public static func buildBlock(
            _ components: NotEmptyArray<Element>...
        ) -> NotEmptyArray<Element> {
            var components = components
            let initial = components.removeFirst()
            return components.reduce(into: initial) { $0.append(contentsOf: $1) }
        }
    
        @inlinable
        public static func buildEither(
            first component: NotEmptyArray<Element>
        ) -> NotEmptyArray<Element> {
            component
        }
        
        @inlinable
        public static func buildEither(
            second component: NotEmptyArray<Element>
        ) -> NotEmptyArray<Element> {
            component
        }
        
        @inlinable
        public static func buildFinalResult(
            _ component: NotEmptyArray<Element>
        ) -> Element {
            component.tail.reduce(component.head) { partialResult, element in
                partialResult.zip(element) { prev, next in prev }
            }
        }
    }
}

//MARK: - Zip global
@inlinable
public func zip<V,T,E: Error>(
    _ lhs: Validated<V, E>,
    _ rhs: Validated<T, E>
) -> Validated<(V,T), E> {
    lhs.zip(rhs)
}

@inlinable
public func zip<V,T,E, R>(
    _ lhs: Validated<V, E>,
    _ rhs: Validated<T, E>,
    using transform: (V, T) -> R
) -> Validated<R, E> where E: Error {
    lhs.zip(rhs, using: transform)
}
