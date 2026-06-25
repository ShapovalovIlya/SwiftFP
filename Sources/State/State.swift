//
//  State.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Foundation

public struct State<Environment, Value> {
    public typealias Reducer = (Environment) -> (environment: Environment, value: Value)
    
    @usableFromInline let reducer: Reducer
    
    /// Creates a state transformer from a reducer closure.
    /// - Parameter reducer: A closure that takes the current environment and returns a new environment along with a produced value.
    @inlinable
    public init(_ reducer: @escaping (Environment) -> (Environment, Value)) {
        self.reducer = reducer
    }

    /// Runs the state transformer with the given initial environment.
    /// - Parameter environment: The initial state to thread through the computation.
    /// - Returns: A tuple containing the final environment and the produced value.
    @inlinable
    public func reduce(
        _ environment: Environment
    ) -> (environment: Environment, value: Value) {
        reducer(environment)
    }
    
    /// Returns the “purest” instance possible for the type
    @inlinable
    public static func pure(_ value: Value) -> Self {
        State { env in (env, value) }
    }
    
    @inlinable
    public func joined<T>() -> State<Environment, T> where Value == State<Environment, T> {
        State<Environment, T> { env in
            let (newEnv, sub) = self.reduce(env)
            return sub.reduce(newEnv)
        }
    }
    
    @inlinable
    public func map<T>(
        _ transform: @escaping (Value) -> T
    ) -> State<Environment, T> {
        State<Environment, T> { env in
            let (newEnv, val) = self.reduce(env)
            return (newEnv, transform(val))
        }
    }
    
    @inlinable
    public func flatMap<T>(
        _ transform: @escaping (Value) -> State<Environment, T>
    ) -> State<Environment, T> {
        self.map(transform)
            .joined()
    }
    
    /// Transforms the environment required by this state transformer using the provided closure.
    ///
    /// Use `pullback` to adapt a `State` that expects a specific environment type
    /// so it can be used with a different source environment.
    ///
    /// - Parameter transform: A closure that converts a value of type `T` into the original `Environment`.
    /// - Returns: A new `State` that takes the new environment type and produces the same result.
    @inlinable
    public func pullback<T>(
        _ transform: @escaping (T) -> Environment
    ) -> State<T, Value> {
        State<T, Value> { source in
            let env = transform(source)
            return (source, reduce(env).value)
        }
    }
}
