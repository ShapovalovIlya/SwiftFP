//
//  Result.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import Foundation
@_exported import Either

public extension Result {
    //MARK: - init(_:)
    
    /// Asynchronously Creates a new result by evaluating a asynchronous throwing closure,
    /// capturing the returned value as a success, or any thrown error as a failure.
    /// - Parameter body: A asynchronous throwing closure to evaluate.
    @inlinable
    init(asyncCatch body: () async throws(Failure) -> Success) async {
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
    
    //MARK: - map(_:)
    /// Returns a new result, mapping any success value using the given throwing transformation.
    /// - Parameter transform: A throwing closure that takes the success value of this instance.
    /// - Returns: A Result instance with the result of evaluating `transformation` as the new success value
    /// if this instance represents a success.
    @inlinable
    func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Error> {
        switch self {
        case .success(let success):
            return Result<NewSuccess, Error> { try transform(success) }
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, mapping any success value using the given asynchronous throwing transformation.
    /// - Parameter transform: A asynchronous throwing closure that takes the success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform` as the new success value
    /// if this instance represents a success.
    @inlinable
    func asyncTryMap<NewSuccess>(
        _ transform: @Sendable (Success) async throws -> NewSuccess
    ) async -> Result<NewSuccess, Error> {
        switch self {
        case .success(let success):
            return await Result<NewSuccess, Error> {
                try await transform(success)
            }
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    //MARK: - apply(_:)
    
    /// Applies a function wrapped in a ‎`Result` to the value of this ‎`Result`, if both are successful.
    ///
    /// This method enables applicative-style composition for ‎`Result` types, allowing you to apply a function (wrapped in a ‎`Result`) to the success value of another ‎`Result`.
    ///
    /// - Parameter functor: A ‎`Result` containing a function from ‎`Success` to ‎`NewSuccess`. If this is a ‎`.failure`, the failure is propagated.
    /// - Returns: A ‎`Result` containing the result of applying the function to the success value, or the first encountered failure.
    /// - Note: If either ‎`self` or ‎`functor` is a ‎`.failure`, the first failure encountered is returned.
    ///
    /// ### Example:
    /// ```swift
    /// let value: Result<Int, Error> = .success(2)
    /// let function: Result<(Int) -> String, Error> = .success { "\($0 * 2)" }
    /// let result = value.apply(function) // .success("4")
    /// ```
     ///
    @inlinable
    @discardableResult
    func apply<NewSuccess>(
        _ functor: Result<(Success) -> NewSuccess, Failure>
    ) -> Result<NewSuccess, Failure> {
        functor
            .map(self.map)
            .flatMap(\.self)
    }
    
    //MARK: - zip(_:)
    
    /// Combines two ‎`Result` values into a single ‎`Result` containing a tuple of both success values, or returns the first encountered failure.
    ///
    /// The ‎`zip(_:)` method allows you to combine the success values of two ‎`Result` instances if both are ‎`.success`. If either ‎`self` or ‎`other` is a ‎`.failure`, the first failure encountered is returned.
    ///
    /// - Parameter other: Another ‎`Result` instance with the same ‎`Failure` type.
    /// - Returns: A ‎`Result` containing a tuple of both success values if both are ‎`.success`, or the first encountered failure
    ///
    /// ### Example:
    /// ```swift
    /// let a: Result<Int, Error> = .success(1)
    /// let b: Result<String, Error> = .success("hello")
    /// let zipped = a.zip(b) // .success((1, "hello"))
    ///
    /// let c: Result<Int, Error> = .failure(MyError())
    /// let d: Result<String, Error> = .success("world")
    /// let zipped2 = c.zip(d) // .failure(MyError())
    /// ```
    ///
    @inlinable
    func zip<Other>(_ other: Result<Other, Failure>) -> Result<(Success, Other), Failure> {
        flatMap { success in
            other.map { (success, $0) }
        }
    }
    
    @inlinable
    func either() -> Either<Success, Failure> {
        switch self {
        case .success(let success): return .left(success)
        case .failure(let failure): return .right(failure)
        }
    }
    
    /// Creates a `Result` of pairs built out of two underlying `Results`.
    /// - Parameters:
    ///   - lhs: The first `Result` to zip.
    ///   - rhs: The second `Result` to zip.
    /// - Returns: A `Result` of tuple pair, where the elements of pair are
    ///   corresponding `success` of `lhs` and `rhs`, or `failure` if any of instances is `failure`.
    @inlinable
    static func zip<Other>(
        _ lhs: Result<Success, Failure>,
        _ rhs: Result<Other, Failure>
    ) -> Result<(Success, Other), Failure> { lhs.zip(rhs) }
    
    /// Combines multiple ``Swift/Result`` values into a single ``Swift/Result`` containing a tuple of their unwrapped values.
    /// If **any** input is a `.failure`, the first encountered error is returned.
    ///
    /// - Parameters:
    ///   - first: The first `Result` to unwrap.
    ///   - other: A variadic list of additional `Result` values.
    /// - Returns:
    ///   - `.success` if **all** inputs are `.success`.
    ///   - `.failure` if **any** input is `.failure` (returns the first error encountered).
    ///
    /// #### Example:
    /// ```swift
    /// let a: Result<Int, Error> = .success(1)
    /// let b: Result<String, Error> = .success("Hello")
    /// let c: Result<Double, Error> = .success(3.14)
    ///
    /// let zipped = Result.zip(a, b, c) // Result<(Int, String, Double), Error>
    ///
    /// switch zipped {
    /// case .success(let (x, y, z)):
    ///     print(x, y, z) // "1 Hello 3.14"
    /// case .failure(let error):
    ///     print("Failed with error: \(error)")
    /// }
    /// ```
    ///
    /// #### Notes:
    /// 1. **Short-Circuiting**: Fails immediately on the first `.failure` (similar to `Result.flatMap`).
    /// 2. **Variadic Generics**: Requires Swift 5.9+ (or later with `enable-experimental-feature VariadicGenerics`).
    ///
    /// #### See Also:
    /// - [Swift Evolution: Parameter Packs (SE-0393)](https://github.com/apple/swift-evolution/blob/main/proposals/0393-parameter-packs.md).
    @inlinable
    static func zip<each U>(
        _ first: Result<Success, Failure>,
        _ other: repeat Result<each U, Failure>
    ) -> Result<(Success, repeat each U), Failure> {
        do {
            let unwrapped = try (first.get(), repeat (each other).get())
            return .success(unwrapped)
            
        } catch {
            return .failure(error)
        }
    }
    
    /// Converts a sequence of `Result<Success, Failure>` into a single ``Result`` containing an array of all successes,
    /// or returns the first encountered failure.
    ///
    /// - Parameter s: A sequence of `Result<Success, Failure>`.
    /// - Returns: `.success([Success])` if all elements are `.success`, or the first `.failure(Failure)` encountered.
    /// - Complexity: O(n), where n is the number of elements in the sequence.
    ///
    /// ### Example:
    /// ```swift
    /// let results: [Result<Int, MyError>] = [.success(1), .success(2), .failure(.bad), .success(4)]
    /// let sequenced = Result.sequence(results)
    /// // sequenced == .failure(.bad)
    /// ```
    ///
    /// - Note: If the sequence is empty, returns `.success([])`.
    @inlinable
    static func sequence<S: Sequence>(
        _ s: S
    ) -> Result<[Success], Failure> where S.Element == Result<Success, Failure> {
        Result<[Success], Error> {
            try s.map { try $0.get() }
        }
        .mapError { $0 as! Failure }
    }
}

public extension Result where Success == Data, Failure == Error {
    
    /// Decodes the contained Data value into a Decodable type using the provided JSONDecoder.
    ///
    /// This method operates on a Result<Data, Error> instance, attempting to decode the Data into the specified type.
    /// If the Result is a success, it tries to decode the data using the given decoder. If decoding succeeds, it returns
    /// a ‎`.success` containing the decoded value. If decoding fails, it returns a ‎`.failure` with the decoding error.
    /// If the original Result is a failure, the error is propagated.
    /// - Parameters:
    ///   - type: The type to decode from the Data. Must conform to ‎`Decodable`.
    ///   - decoder: The ‎`JSONDecoder` instance to use for decoding.
    /// - Returns: A ‎`Result` containing either the decoded value of type ‎`T` on success, or an ‎`Error` on failure.
    ///
    /// ### Example:
    ///```swift
    /// let result: Result<Data, Error> = .success(userJsonData)
    /// let userResult = result.decodeJSON(User.self, decoder: JSONDecoder())
    /// switch userResult {
    /// case .success(let user):
    ///     print("User decoded: \(user)")
    /// case .failure(let error):
    ///     print("Decoding failed with error: \(error)")
    /// }
    /// ```
    ///
    @inlinable
    func decodeJSON<T: Decodable>(
        _ type: T.Type,
        decoder: JSONDecoder
    ) -> Result<T, Error> {
        flatMap { data in
            Result<T, Error> {
                try decoder.decode(type.self, from: data)
            }
        }
    }
}

extension Result: Sendable where Success: Sendable, Failure: Sendable {
    /// Returns a new result, mapping any success value using the given asynchronous transformation.
    /// - Parameter transform: A asynchronous closure that takes the success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating `transform` as the new success value
    /// if this instance represents a success.
    @inlinable
    @Sendable
    public func asyncMap<NewSuccess>(
        _ transform: @Sendable (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await Result<NewSuccess, Failure> { await transform(success) }
            
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    /// Returns a new result, asynchronous mapping any success value using the given `transformation`
    /// and unwrapping the produced result.
    /// - Parameter transform: A asynchronous closure that takes the success value of the instance.
    /// - Returns: A `Result` instance, either from the closure or the previous `.failure`.
    @inlinable
    @Sendable
    public func asyncFlatMap<NewSuccess>(
        _ transform: @Sendable (Success) async -> Result<NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        await asyncMap(transform).flatMap(\.self)
    }
    
    /// Asynchronously returns a new result, apply `Result` functor to  success value.
    /// - Parameter functor: A `Result` functor that takes success value of this instance.
    /// - Returns: A `Result` instance with the result of evaluating stored function as the new success value.
    /// If any of given `Result` instances are failure, then produced `Result` will be failure.
    @inlinable
    @Sendable
    @discardableResult
    public func asyncApply<NewSuccess>(
        _ functor: Result<@Sendable (Success) async -> NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        await functor
            .asyncMap(self.asyncMap)
            .flatMap(\.self)
    }
}
