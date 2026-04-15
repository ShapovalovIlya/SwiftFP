//
//  TaskTest.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 14.04.2026.
//

import Testing
import FoundationFX
import Foundation

struct TaskTest {
    
    @Test func resultSuccessToTask() async throws {
        let sut = Result<Int, Never>
            .success(1)
            .task()
        
        await #expect(sut.value == 1)
    }
    
    @Test func resultFailureToTask() async throws {
        let sut = Result<Int, CancellationError>
            .failure(CancellationError())
            .task()
        
        await #expect(throws: CancellationError.self) {
            try await sut.value
        }
    }

    @Test func mapNeverError() async throws {
        let sut = Task { 1 }.map { $0 + 1 }
        
        await #expect(sut.value == 2)
    }

    @Test func mapWithError() async throws {
        let sut = Task<Int, Error> { 1 }.map { _ in
            throw CancellationError()
        }
        
        await #expect(throws: CancellationError.self) {
            try await sut.value
        }
    }
    
    @Test func flatMapNewerError() async throws {
        let sut = Task { 1 }.flatMap { val in
            Task { val + 1 }
        }
        
        await #expect(sut.value == 2)
    }
    
    @Test func flatMapWithError() async throws {
        let sut = Task { 1 }.flatMap { val in
            Task {
                throw CancellationError()
            }
        }
        
        await #expect(throws: CancellationError.self) {
            try await sut.value
        }
    }
    
    @Test("zip combines different types into a tuple")
    func zipSuccess() async throws {
        // Создаем задачи с разными типами данных
        let task1 = Task { "Swift" }        // Task<String, Never>
        let task2 = Task { 2024 }           // Task<Int, Never>
        let task3 = Task { true }           // Task<Bool, Never>
        
        // Act
        let result = await Task.zip(task1, task2, task3).value
        
        // Assert
        #expect(result.0 == "Swift")
        #expect(result.1 == 2024)
        #expect(result.2 == true)
    }

    @Test("zip throws error if any task fails")
    func zipFailure() async throws {
        enum TestError: Error { case failure }
        
        let task1 = Task<String, Error> { "All good" }
        let task2 = Task<Int, Error> { throw TestError.failure }
        
        // Act & Assert
        await #expect(throws: TestError.failure) {
            try await Task.zip(task1, task2).value
        }
    }
    
    @Test("zip executes tasks concurrently")
    func zipConcurrency() async throws {
        let start = Date()
        
        let task1 = Task { try await Task.sleep(for: .milliseconds(100)); return 1 }
        let task2 = Task { try await Task.sleep(for: .milliseconds(100)); return 2 }
        
        // Act
        _ = try await Task.zip(task1, task2).value
        let duration = Date().timeIntervalSince(start)
        
        // Проверяем, что задачи выполнялись параллельно (~100мс),
        // а не последовательно (200мс+)
        #expect(duration < 0.15)
    }
    
    @Test("Instance zip combines two tasks of different types")
    func instanceZipSuccess() async throws {
        // Создаем первую задачу (self)
        let taskA = Task { "Hello" }
        // Создаем вторую задачу (other)
        let taskB = Task { 42 }
        
        // Act
        // Вызываем метод как экземплярный: taskA.zip(taskB)
        let combinedTask = taskA.zip(taskB)
        let result = await combinedTask.value
        
        // Assert
        #expect(result.0 == "Hello")
        #expect(result.1 == 42)
    }

    @Test("Instance zip propagates error from either task")
    func instanceZipFailure() async {
        enum TestError: Error { case secondTaskFailed }
        
        let taskA = Task<String, Error> { "Success" }
        let taskB = Task<Int, Error> { throw TestError.secondTaskFailed }
        
        // Act & Assert
        await #expect(throws: TestError.secondTaskFailed) {
            try await taskA.zip(taskB).value
        }
    }
    
    @Test("Instance zip runs tasks in parallel")
    func instanceZipIsConcurrent() async throws {
        let taskA = Task {
            try await Task.sleep(for: .milliseconds(100))
            return "A"
        }
        let taskB = Task {
            try await Task.sleep(for: .milliseconds(100))
            return "B"
        }
        
        let start = Date()
        
        // Act
        _ = try await taskA.zip(taskB).value
        
        let duration = Date().timeIntervalSince(start)
        
        // Если задачи идут параллельно, время будет ~0.1с, а не ~0.2с
        #expect(duration < 0.15)
    }

    @Test("allSettled preserves the original order of results")
    func allSettledPreservesOrder() async throws {
        // Создаем задачи с разной задержкой, чтобы они завершались не по порядку
        let task1 = Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 сек
            return "First"
        }
        let task2 = Task {
            return "Second" // Завершится мгновенно
        }
        let task3 = Task {
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 сек
            return "Third"
        }
        
        let tasks = [task1, task2, task3]
        
        // Act
        let results = await Task.allSettled(tasks).value
        
        // Assert
        #expect(results.count == 3)
        
        // Проверяем, что несмотря на разное время выполнения, порядок сохранен
        if case .success(let value1) = results[0] { #expect(value1 == "First") }
        if case .success(let value2) = results[1] { #expect(value2 == "Second") }
        if case .success(let value3) = results[2] { #expect(value3 == "Third") }
    }
    
    @Test("allSettled captures both successes and failures")
    func allSettledCapturesFailures() async {
        enum TestError: Error { case boom }
        
        let successTask = Task<String, Error> { "Success" }
        let failureTask = Task<String, Error> { throw TestError.boom }
        
        let tasks = [successTask, failureTask]
        
        // Act
        let results = await Task.allSettled(tasks).value
        
        // Assert
        #expect(results.count == 2)
        
        switch results[0] {
        case .success(let val): #expect(val == "Success")
        case .failure: Issue.record("First task should have succeeded")
        }
        
        switch results[1] {
        case .success: Issue.record("Second task should have failed")
        case .failure(let error): #expect(error as? TestError == .boom)
        }
    }
    
    @Test("allSettled works with empty sequence")
    func allSettledEmptySequence() async {
        let tasks: [Task<String, Never>] = []
        
        let results = await Task.allSettled(tasks).value
        
        #expect(results.isEmpty)
    }

    @Test("sequence returns all values in correct order when successful")
    func sequenceSuccess() async throws {
        // Создаем задачи с разной задержкой
        let task1 = Task {
            try await Task.sleep(for: .milliseconds(50))
            return 1
        }
        let task2 = Task<Int, Error> { 2 } // Мгновенная задача
        let task3 = Task {
            try await Task.sleep(for: .milliseconds(10))
            return 3
        }
        
        let tasks: [Task<Int, Error>] = [task1, task2, task3]
        
        // Act
        let results = try await Task.sequence(tasks).value
        
        // Assert
        #expect(results == [1, 2, 3]) // Порядок должен строго соответствовать входному
    }
    
    @Test("sequence throws the first error encountered and stops")
    func sequenceFailure() async throws {
        enum TestError: Error, Equatable { case accessDenied }
        
        let task1 = Task<String, Error> { "OK" }
        let task2 = Task<String, Error> { throw TestError.accessDenied }
        let task3 = Task {
            try await Task.sleep(for: .seconds(1))
            return "Too Late"
        }
        
        let tasks: [Task<String, Error>] = [task1, task2, task3]
        
        // Act & Assert
        // Ожидаем, что метод выбросит ошибку, так как task2 упала
        await #expect(throws: TestError.accessDenied) {
            try await Task.sequence(tasks).value
        }
    }
    
    @Test("sequence with empty input returns empty array")
    func sequenceEmpty() async throws {
        let tasks: [Task<Int, Error>] = []
        
        let results = try await Task.sequence(tasks).value
        
        #expect(results.isEmpty)
    }
}
