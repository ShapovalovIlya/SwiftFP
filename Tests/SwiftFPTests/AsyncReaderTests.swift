//
//  AsyncReaderTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 25.01.2025.
//

import Testing
import Readers

struct AsyncReaderTests {
    typealias Sut = AsyncReader<Int, String>
    let sut = Sut(\.description)

    @Test func apply() async throws {
        await #expect(sut.apply(1) == "1")
        await #expect(sut(1) == "1")
    }
    
    @Test func usingKeyPath() async throws {
        let sut = AsyncReader<Int, IntInfo>(IntInfo.init)
            .description("baz")
        
        await #expect(sut(10).description == "baz")
    }
    
    @Test func pure() async throws {
        let sut = Sut.pure("baz")
        
        await #expect(sut.apply(1) == "baz")
    }
    
    @Test func joined() async throws {
        let sut = AsyncReader
            .pure(Sut.pure(1.description))
            .joined()
        
        await #expect(sut.apply(1) == 1.description)
    }
    
    @Test func map() async throws {
        @Sendable func asyncCount(string: String) async -> Int { string.count }
        let counter = sut.map(asyncCount(string:))
        
        await #expect(counter(123) == 3)
    }
    
    @Test func flatMap() async throws {
        @Sendable func isEvenReader(_ description: String) -> Sut {
            Sut {
                description
                    .appending(" is even: ")
                    .appending($0.isEven.description)
            }
        }
        
        let sut = sut.flatMap(isEvenReader(_:))
        
        await #expect(sut(1) == "1 is even: false")
        await #expect(sut(2) == "2 is even: true")
    }
    
    @Test func pullback() async throws {
        @Sendable func asyncDoubleToInt(_ double: Double) async -> Int { Int(double) }
        
        let sut = sut.pullback(asyncDoubleToInt(_:))
        
        await #expect(sut(2.0) == "2")
    }
    
    @Test func zip() async throws {
        let other = AsyncReader<Int, Bool>(\.isEven)
        let zipped = sut.zip(other)
        
        await #expect(zipped(1) == ("1", false))
    }
    
    @Test func zipInto() async throws {
        let isEvent = AsyncReader<Int, Bool>(\.isEven)
        let describer = AsyncReader<Int, String>(\.description)
        
        let sut = describer.zip(isEvent, into: IntInfo.asyncParse)
        
        await #expect(sut(1) == IntInfo(description: 1.description, isEvent: 1.isEven))
    }
}

private extension AsyncReaderTests {
    struct IntInfo: Equatable {
        var description: String
        var isEvent: Bool
        
        init(description: String = String(), isEvent: Bool = false) {
            self.description = description
            self.isEvent = isEvent
        }
        
        @Sendable
        init(value: Int) {
            self.description = value.description
            self.isEvent = value.isEven
        }
        
        @Sendable
        static func asyncParse(_ desc: String, isEven: Bool) async -> IntInfo {
            IntInfo(description: desc, isEvent: isEven)
        }
    }
}
