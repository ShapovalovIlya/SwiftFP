//
//  Optional.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation

public extension Optional {
    
    /// Applies a given optional transformation function to the wrapped value, if both the optional and the function are non-nil.
    ///
    /// This method allows you to apply an optional transformation (a function that may or may not exist) to an optional value.
    /// If either the optional value (‎`self`) or the provided function (‎`functor`) is ‎`nil`, the result is ‎`nil`.
    /// If both are non-nil, the function is applied to the value, and the result is returned as an optional.
    /// If the function throws, the error is propagated.
    ///
    /// - Parameter functor: An optional function that takes the wrapped value as input and returns a new value, possibly throwing an error.
    /// - Returns: An optional containing the result of applying the function to the wrapped value, or ‎`nil` if either the value or the function is ‎`nil`.
    ///
    /// ### Example:
    /// ```swift
    /// let value: Int? = 5
    /// let transform: ((Int) -> String)? = { "\($0)" }
    ///
    /// let result = value.apply(transform) // result is Optional("5")
    ///
    /// let nilValue: Int? = nil
    /// let result2 = nilValue.apply(transform) // result2 is nil
    ///
    /// let nilTransform: ((Int) -> String)? = nil
    /// let result3 = value.apply(nilTransform) // result3 is nil
    /// ```
    ///
    @inlinable
    @discardableResult
    func apply<NewWrapped>(
        _ functor: Optional<(Wrapped) throws -> NewWrapped>
    ) rethrows -> Optional<NewWrapped> {
        try functor.flatMap { transform in
            try self.map(transform)
        }
    }
       
    /// Combines two optional values into a single optional tuple if both values are non-nil.
    ///
    /// This method “zips” the current optional (‎`self`) with another optional value (‎`other`). If both optionals contain values,
    /// it returns an optional containing a tuple of both values. If either optional is ‎`nil`, the result is ‎`nil`.
    ///
    /// - Parameter other: Another optional value to zip with.
    /// - Returns: An optional tuple containing the wrapped values of ‎`self` and ‎`other` if both are non-nil; otherwise, ‎`nil`.
    ///
    /// ### Example:
    /// ```swift
    /// let a: Int? = 1
    /// let b: String? = "hello"
    /// let zipped = a.zip(b) // zipped is Optional((1, "hello"))
    ///
    /// let c: Int? = nil
    /// let zipped2 = c.zip(b) // zipped2 is nil
    /// ```
    ///
    @inlinable
    func zip<U>(_ other: U?) -> Optional<(Wrapped, U)> {
        flatMap { wrapped in
            other.map { (wrapped, $0) }
        }
    }
    
    /// Filter wrapped value with given condition.
    /// - Parameter condition: A closure that takes the unwrapped value of the instance
    /// - Returns: New instance if wrapped value match given condition. Otherwise return `nil`.
    
    /// Returns the wrapped value if it satisfies the given predicate; otherwise, returns ‎`nil`.
    ///
    /// This method allows you to conditionally keep the value inside an optional based on a predicate.
    /// If the optional is non-nil and the predicate returns ‎`true`, the value is returned. If the optional is ‎`nil`
    /// or the predicate returns ‎`false`, the result is ‎`nil`. If the predicate throws an error, the error is propagated.
    ///
    /// - Parameter condition: A closure that takes the wrapped value as its argument and returns a Boolean value indicating whether the value should be kept.
    /// - Returns: The wrapped value if it exists and satisfies the predicate; otherwise, ‎`nil`.
    ///
    /// ### Example:
    ///```swift
    /// let value: Int? = 10
    /// let filtered = value.filter { $0 > 5 } // filtered is Optional(10)
    ///
     /// let filtered2 = value.filter { $0 > 20 } // filtered2 is nil
    ///
    /// let nilValue: Int? = nil
    /// let filtered3 = nilValue.filter { $0 > 5 } // filtered3 is nil
    ///```
    ///
    @inlinable
    func filter(
        _ condition: (Wrapped) throws -> Bool
    ) rethrows -> Wrapped? {
        try flatMap { try condition($0) ? $0 : nil }
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
