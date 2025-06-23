//
//  Optional.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation

public extension Optional {
    /// Evaluates given  function when both `Optional` instances of function and value are not `nil`,
    /// passing the unwrapped value as a parameter.
    /// - Parameter functor: A `Optional` function that takes the unwrapped value of the instance.
    /// - Returns: The result of the given function. If some of this instances is nil, returns nil.
    @inlinable
    @discardableResult
    func apply<NewWrapped>(
        _ functor: Optional<(Wrapped) throws -> NewWrapped>
    ) rethrows -> Optional<NewWrapped> {
        try functor.flatMap { transform in
            try self.map(transform)
        }
    }
       
    /// Zip two optional values.
    /// - Parameter other: optional value to combine with
    /// - Returns: `Optional tuple` containing two upstream values in tuple or `nil` if any of them is `nil`
    @inlinable
    func zip<U>(_ other: U?) -> Optional<(Wrapped, U)> {
        flatMap { wrapped in
            other.map { (wrapped, $0) }
        }
    }
    
    /// Filter wrapped value with given condition.
    /// - Parameter condition: A closure that takes the unwrapped value of the instance
    /// - Returns: New instance if wrapped value match given condition. Otherwise return `nil`.
    @inlinable
    func filter(
        _ condition: (Wrapped) throws -> Bool
    ) rethrows -> Wrapped? {
        try flatMap { try condition($0) ? $0 : nil }
    }
    
    /// Evaluates given closure, passing current value as parameter.
    /// - Parameter body: A closure that takes current wrapped value
    /// - Returns: result of execution as new type.
    @inlinable
    func reduce(_ process: (inout Wrapped) throws -> Void) rethrows -> Self {
        try map {
            var mutating = $0
            try process(&mutating)
            return mutating 
        }
    }
    
    /// Replace `nil` with given value.
    @inlinable
    func replaceNil(_ other: Wrapped) -> Wrapped {
        switch self {
        case .none: return other
        case .some(let wrapped): return wrapped
        }
    }
    
    /// Attempts to unwrap and combine the `first` optional value with one or more `other` optional values into a tuple.
    /// If **any** of the inputs are `nil`, the method returns `nil`.
    ///
    /// ### Example:
    ///```swift
    ///let a: Int? = 1
    ///let b: String? = "Hello"
    ///let c: Double? = 3.14
    ///if let zipped = Optional.zip(a, b, c) {
    ///    print(zipped) // (1, "Hello", 3.14)
    ///} else {
    ///    print("One or more values were nil")
    ///}
    ///```
    ///
    /// ### See Also:
    /// Swift Evolution [SE-0393: Parameter Packs](https://github.com/apple/swift-evolution/blob/main/proposals/0393-parameter-packs.md).
    ///
    /// - Parameters:
    ///   - first: The first optional value to unwrap.
    ///   - other: A variadic list of additional optional values.
    /// - Returns:
    ///   - A tuple containing all unwrapped values if **all** inputs are non-`nil`. Or `nil` if **any** input is `nil`.
    @inlinable
    static func zip<each U>(
        _ first: Wrapped?,
        _ other: repeat (each U)?
    ) -> (Wrapped, repeat each U)? {
        do {
            return try (first.unwrap(), repeat (each other).unwrap())
        } catch {
            return nil
        }
    }
}

extension Optional {
    struct Termination: Error {}
    
    @usableFromInline
    func unwrap() throws -> Wrapped {
        guard let self else {
            throw Termination()
        }
        return self
    }
}

public extension Optional where Wrapped: Sendable {
    /// Evaluates the given asynchronous closure when this Optional instance is not nil, passing the unwrapped value as a parameter.
    /// - Parameter asyncTransform: A asynchronous closure that takes the unwrapped value of the instance.
    /// - Returns: The result of the given closure. If this instance is nil, returns nil.
    @inlinable
    func asyncFlatMap<U>(
        _ transform: @Sendable (Wrapped) async throws -> U?
    ) async rethrows -> U? {
        switch self {
        case .none:
            return .none
            
        case .some(let wrapped):
            return try await transform(wrapped)
        }
    }
    
    /// Evaluates the given asynchronous closure when this Optional instance is not nil, passing the unwrapped value as a parameter.
    /// - Parameter asyncTransform: A asynchronous closure that takes the unwrapped value of the instance.
    /// - Returns: The result of the given closure. If this instance is nil, returns nil.
    @inlinable
    func asyncMap<U>(
        _ transform: @Sendable (Wrapped) async throws -> U
    ) async rethrows -> U? {
        try await asyncFlatMap(transform)
    }
    
    /// Evaluates given asynchronous function when both `Optional` instances of function and value are not `nil`,
    /// passing the unwrapped value as a parameter.
    /// - Parameter functor: A `Optional`asynchronous function that takes the unwrapped value of the instance.
    /// - Returns: The result of the given function. If some of this instances is nil, returns nil.
    @inlinable
    @discardableResult
    func asyncApply<NewWrapped>(
        _ functor: Optional<@Sendable (Wrapped) async throws -> NewWrapped>
    ) async rethrows -> Optional<NewWrapped> {
        try await functor.asyncFlatMap { transform in
            try await self.asyncMap(transform)
        }
    }
}

public extension Optional where Wrapped: BinaryInteger {
    
    /// If this instance is `nil`, returns zero.
    @inlinable var orZero: Wrapped {
        replaceNil(.zero)
    }
}

public extension Optional where Wrapped: BinaryFloatingPoint {
    
    /// If this instance is `nil`, returns zero.
    @inlinable var orZero: Wrapped {
        replaceNil(.zero)
    }
}

public extension Optional where Wrapped == String {
    
    /// If this instance is `nil`, returns empty string.
    @inlinable var orEmpty: Wrapped {
        replaceNil(String())
    }
}

public extension Optional where Wrapped: ExpressibleByArrayLiteral {
    
    /// If this instance is `nil`, returns empty collection.
    @inlinable var orEmpty: Wrapped {
        replaceNil([])
    }
}

public extension Optional where Wrapped: ExpressibleByDictionaryLiteral {
    
    /// If this instance is `nil`, returns empty collection.
    @inlinable var orEmpty: Wrapped {
        replaceNil([:])
    }
}

public extension Optional where Wrapped == Bool {
    
    /// If this instance is `nil`, returns `false`
    @inlinable var orFalse: Wrapped { self.replaceNil(false) }
    
    /// If this instance is `nil`, returns `true`
    @inlinable var orTrue: Wrapped { self.replaceNil(true) }
}
