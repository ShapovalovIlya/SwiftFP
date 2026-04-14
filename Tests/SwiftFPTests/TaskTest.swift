//
//  TaskTest.swift
//  SwiftFP
//
//  Created by Шаповалов Илья on 14.04.2026.
//

import Testing
import FoundationFX

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
        
        try await #expect(sut.value == 2)
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
    
    @Test func zip() async throws {
        let sut = Task.zip(
            Task { "Baz" },
            Task { 1 },
            Task { 1.1 },
            Task { true }
        )
        
        try await #expect(sut.value == ("Baz", 1, 1.1, true))
    }
    
    @Test func zipWithOther() async throws {
        let sut = Task { 1 }.zip(Task { "Baz" })
        
        try await #expect(sut.value == (1, "Baz"))
    }
    
//    @Test func sequence() async throws {
//        let sequence = [
//            Task { 1 },
//            Task { 2 },
//            Task { 3 },
//        ]
//        let sut = Task.sequence(sequence)
//        
//        try await #expect(sut.value == [1, 2, 3])
//    }
}
