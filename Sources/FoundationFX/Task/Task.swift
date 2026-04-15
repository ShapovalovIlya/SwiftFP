//
//  Task.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 14.04.2026.
//

import Foundation

public extension Task where Failure == Never {
    /// Returns a new task that transforms the successful result of the current task.
    ///
    /// This non-throwing version is available when the original task cannot fail (`Failure == Never`).
    ///
    /// - Note: This transformation runs in a **non-structured context**. It does not automatically
    /// propagate cancellation. To handle cancellation, call `Task.checkCancellation()`
    /// or check `Task.isCancelled` inside the transform closure.
    ///
    /// - Parameter transform: An async closure that takes the success value of the current task.
    /// - Returns: A task that produces the transformed value and never fails.
    @inlinable
    @discardableResult
    func map<NewSuccess>(
        _ transform: sending @escaping (Success) async -> NewSuccess
    ) -> Task<NewSuccess, Failure> {
        Task<NewSuccess, Failure> {
            await transform(value)
        }
    }
    
    /// Returns a new task that transforms the result into another task and flattens the result.
    ///
    /// - Note: The new task is independent of the current task's lifecycle. Cancellation
    /// of the parent task will not be automatically signaled to the inner task.
    ///
    /// - Parameter transform: A closure that returns a new task.
    /// - Returns: A flattened task producing the final value.
    @inlinable
    @discardableResult
    func flatMap<NewSuccess>(
        _ transform: sending @escaping (Success) -> Task<NewSuccess, Failure>
    ) -> Task<NewSuccess, Failure> {
        Task<NewSuccess, Failure> {
            await transform(value).value
        }
    }
    
    /// Combines multiple tasks into a single task that produces a tuple of their results.
    ///
    /// - Note: While the tasks run in parallel, this method does not create a Task Group.
    /// If the resulting task is cancelled, the underlying tasks will continue
    /// until they independently check for cancellation.
    ///
    /// - Parameters:
    ///   - first: The initial task to combine.
    ///   - other: A variadic list of additional tasks.
    /// - Returns: A task producing a tuple of all success values.
    @inlinable
    @discardableResult
    static func zip<each U>(
        _ first: Task<Success, Failure>,
        _ other: repeat Task<each U, Failure>
    ) -> Task<(Success, repeat each U), Failure> {
        Task<(Success, repeat each U), Failure> {
            await (first.value, repeat (each other).value)
        }
    }

    /// Zips the current non-failing task with another non-failing task.
    ///
    /// - Note: While the tasks run in parallel, this method does not create a Task Group.
    /// If the resulting task is cancelled, the underlying tasks will continue
    /// until they independently check for cancellation.
    ///
    /// - Parameter other: Another non-failing task.
    /// - Returns: A non-failing task producing a tuple.
    @inlinable
    @discardableResult
    func zip<Other>(
        _ other: Task<Other, Failure>
    ) -> Task<(Success, Other), Failure> {
        Task.zip(self, other)
    }
    
    /// Transforms a collection of non-failing tasks into a single task yielding an array of results.
    ///
    /// - Parameter tasks: An array of `Task<Success, Never>`.
    /// - Returns: A task that completes when all input tasks have finished.
    @inlinable
    @discardableResult
    static func sequcence<S: Sequence>(
        _ sequence: S
    ) -> Task<[Success], Failure> where S.Element == Self, S: Sendable {
        Task<[Success], Failure> {
            await withTaskGroup { group in
                sequence.enumerated().forEach { index, task in
                    group.addTask {
                        await (index, task.value)
                    }
                }
                return await group
                    .reduce(
                        into: [Success?](repeating: nil, count: sequence.underestimatedCount)
                    ) { partialResult, result in
                        partialResult[result.0] = result.1
                    }
                    .compactMap(\.self)
            }
        }
    }
}

public extension Task {
    
    /// Returns a new task that transforms the successful result of the current task, potentially throwing an error.
    ///
    /// Due to current Swift Concurrency limitations, the resulting task's failure type is erased to `Error`.
    ///
    /// - Note: This transformation runs in a **non-structured context**. It does not automatically
    /// propagate cancellation. To handle cancellation, call `try Task.checkCancellation()`
    /// inside the transform closure.
    ///
    /// - Parameter transform: A throwing async closure that transforms the success value.
    /// - Returns: A task that produces the transformed value or throws an error.
    @inlinable
    @discardableResult
    func map<NewSuccess>(
        _ transform: sending @escaping (Success) async throws(Failure) -> NewSuccess
    ) -> Task<NewSuccess, Error> {
        Task<NewSuccess, Error> {
            try await transform(value)
        }
    }
    
    /// Returns a new task that transforms the result into another throwing task and flattens the result.
    ///
    /// - Note: The new task is independent of the current task's lifecycle. Cancellation
    /// of the parent task will not be automatically signaled to the inner task.
    ///
    /// - Parameter transform: A closure that returns a task with the same `Failure` type.
    /// - Returns: A task whose failure type is erased to `Error`.
    @inlinable
    @discardableResult
    func flatMap<NewSuccess>(
        _ transform: sending @escaping (Success) -> Task<NewSuccess, Failure>
    ) -> Task<NewSuccess, Error> {
        Task<NewSuccess, Error> {
            try await transform(value).value
        }
    }
    
    /// Combines multiple tasks into a single task that returns a tuple of their values.
    ///
    /// Use this method to execute several tasks concurrently and wait for all of them
    /// to complete. If all tasks succeed, the resulting task produces a tuple containing
    /// the individual results in the order they were provided.
    ///
    /// ### Error Handling
    /// If **any** of the tasks fail, the resulting task will throw the error of the first
    /// failed task encountered during the `await` process.
    ///
    /// ### Example
    /// ```swift
    /// let nameTask = Task { "John" }
    /// let ageTask = Task { 30 }
    /// let isMemberTask = Task { true }
    ///
    /// let combinedTask = Task.zip(nameTask, ageTask, isMemberTask)
    /// let (name, age, isMember) = try await combinedTask.value
    ///
    /// print("\(name) is \(age) years old. Member: \(isMember)")
    /// ```
    ///
    /// - Parameters:
    ///   - first: The first task to combine.
    ///   - other: A variable number of additional tasks to combine using variadic generics.
    /// - Returns: A new `Task` that returns a tuple of all success values.
    /// - Throws: An error if any of the input tasks fail.
    @inlinable
    @discardableResult
    static func zip<each U>(
        _ first: Task<Success, Failure>,
        _ other: repeat Task<each U, Failure>
    ) -> Task<(Success, repeat each U), Error> {
        Task<(Success, repeat each U), Error> {
            try await (first.value, repeat (each other).value)
        }
    }
    
    /// Combines the result of this task with another task into a tuple.
    ///
    /// This instance method provides a fluent syntax for pairing the current task's
    /// outcome with another task. It is a convenience wrapper around `Task.zip(_:_:)`.
    ///
    /// ### Chainable Concurrency
    /// Using this method allows you to zip tasks together in a more readable way when
    /// you already have an existing task reference:
    ///
    /// ```swift
    /// let userTask = Task { fetchUser() }
    /// let postsTask = Task { fetchPosts() }
    ///
    /// // Fluent syntax
    /// let combined = try await userTask.zip(postsTask).value
    /// print("User: \(combined.0), Posts: \(combined.1)")
    /// ```
    ///
    /// - Parameter other: Another task to combine with this one.
    /// - Returns: A new `Task` that returns a tuple containing results from both tasks.
    /// - Throws: An error if either this task or the `other` task fails.
    @inlinable
    @discardableResult
    func zip<Other>(
        _ other: Task<Other, Failure>
    ) -> Task<(Success, Other), Error> {
        Task.zip(self, other)
    }
    
    /// Executes a sequence of tasks concurrently and returns an array of their successful values.
    ///
    /// This method waits for all tasks to complete successfully. If any task in the sequence
    /// fails, the entire method throws the error encountered by the first failing task,
    /// and any remaining pending tasks may be cancelled.
    ///
    /// ### Order Preservation
    /// Despite concurrent execution, the returned array maintains the **original order**
    /// of the tasks provided in the input sequence.
    ///
    /// ### Comparison with `allSettled`
    /// Unlike `allSettled(_:)`, which collects both successes and failures, this method
    /// either succeeds with all values or fails entirely if a single task fails.
    ///
    /// ### Example
    /// ```swift
    /// let tasks = [taskA, taskB, taskC]
    /// do {
    ///     let results = try await Task.sequence(tasks).value
    ///     print("All tasks finished successfully: \(results)")
    /// } catch {
    ///     print("At least one task failed with error: \(error)")
    /// }
    /// ```
    ///
    /// - Parameter sequence: A sequence of tasks to execute.
    /// - Returns: A `Task` that produces an array of success values in the original order.
    /// - Throws: An error if any of the tasks in the sequence fails.
    @inlinable
    @discardableResult
    static func sequence<S: Sequence>(
        _ sequence: S
    ) -> Task<[Success], Error> where S.Element == Self, S: Sendable {
        Task<[Success], Error> {
            try await withThrowingTaskGroup { group in
                sequence.enumerated().forEach { index, task in
                    group.addTask {
                        try await (index, task.value)
                    }
                }
                
                return try await group
                    .reduce(
                        into: [Success?](repeating: nil, count: sequence.underestimatedCount)
                    ) { partialResult, result in
                        partialResult[result.0] = result.1
                    }
                    .compactMap(\.self)
            }
        }
    }
    
    /// Waits for all tasks in the sequence to settle, returning an array of their results.
    ///
    /// Use this method when you want to collect the outcomes of multiple concurrent tasks,
    /// regardless of whether they succeed or fail. Unlike `withThrowingTaskGroup`,
    /// this method ensures that every task finishes before the parent task returns.
    ///
    /// ### Result Ordering
    /// Although tasks are executed concurrently and may finish in any order, the resulting
    /// array maintains the **exact same order** as the input sequence.
    ///
    /// ### Example
    /// ```swift
    /// let tasks = [fetchDataTask, uploadImageTask, updateProfileTask]
    /// let outcomes = await Task.allSettled(tasks).value
    ///
    /// for result in outcomes {
    ///     if case .success(let value) = result {
    ///         print("Task succeeded: \(value)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter sequence: A sequence of tasks to be monitored. The elements must
    ///   conform to `Sendable` and match the current Task type.
    /// - Returns: A new `Task` that wraps an array of `Result` objects, containing
    ///   either the success value or the error for each input task.
    /// - Note: This method never throws an error directly (`Never`) because all
    ///   individual task errors are captured within the `Result` enumeration.
    @inlinable
    @discardableResult
    static func allSettled<S: Sequence>(
        _ sequence: S
    ) -> Task<[Result<Success, Failure>], Never> where S.Element == Self, S: Sendable {
        Task<[Result<Success, Failure>], Never> {
            await withTaskGroup { group in
                sequence.enumerated().forEach { index, task in
                    group.addTask {
                        await (index, task.result)
                    }
                }
                
                return await group
                    .reduce(
                        into: [Result<Success, Failure>?](repeating: nil, count: sequence.underestimatedCount)
                    ) { partialResult, element in
                        partialResult[element.0] = element.1
                    }
                    .compactMap(\.self)
            }
        }
    }
}
