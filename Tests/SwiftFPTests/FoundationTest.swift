//
//  FoundationTest.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.03.2025.
//

import Testing
import FoundationFX

struct FoundationTest {
    
    @Test func initArrayWithAsyncSequence() async throws {
        let sequence = AsyncStream<Int> { c in
            Task {
                try await Task.sleep(for: .milliseconds(100))
                c.yield(1)
                c.finish()
            }
        }
        let sut = await Array(sequence)
        
        #expect(sut == [1])
    }
    
    @Test func initDictionaryWithAsyncSequence() async throws {
        let sequence = AsyncStream<(Int, String)> { c in
            Task {
                try await Task.sleep(for: .milliseconds(100))
                c.yield((1, 1.description))
                c.finish()
            }
        }
        let sut = await Dictionary(sequence)
        
        #expect(sut == [1: 1.description])
    }

    @Test
    func sequenceConcurrentMap() async throws {
        let duration = try await ContinuousClock().measure {
            let mutated = try await Array(repeating: 1, count: 100).concurrentMap {
                try await Task.sleep(for: .milliseconds(100))
                return $0 + $0
            }
            #expect(mutated == Array(repeating: 2, count: 100))
        }
        print(
            #function
                .appending(" ")
                .appending(
                    duration
                        .formatted(.units(allowed: [.seconds, .milliseconds]))
                )
        )
    }

    @Test func sequenceAsyncMap() async throws {
        let values = 1...100
        let duration = try await ContinuousClock().measure {
            let mutated = try await values.asyncMap {
                try await Task.sleep(for: .milliseconds(100))
                return $0.description
            }
            #expect(mutated == values.map(\.description))
        }
        print(
            #function
                .appending(" ")
                .appending(
                    duration
                        .formatted(.units(allowed: [.seconds, .milliseconds]))
                )
        ) // 10.385 sec - old, 0.103 sec - new
    }
    
    @Test func sequenceConcurrentForEach() async throws {
        let duration = try await ContinuousClock().measure {
            try await (0...100).asyncForEach { _ in
                try await Task.sleep(for: .milliseconds(100))
                
            }
        }
        print(
            #function
                .appending(" ")
                .appending(
                    duration
                        .formatted(.units(allowed: [.seconds, .milliseconds]))
                )
        ) // 10.385 sec - old, 0.103 sec - new
    }
}
