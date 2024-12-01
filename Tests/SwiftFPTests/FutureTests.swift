//
//  Test.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Testing
import Future

struct FutureTests {
    typealias Sut = Future<Int>
    static let arguments = [1,2,3,4,5]
    
    @Test(arguments: arguments)
    func run(_ value: Int) async throws {
        let sut = Sut { value }
        
        await #expect(sut.run() == value)
    }

    @Test(arguments: arguments)
    func pure(_ value: Int) async throws {
        let sut = Sut.pure(value)
        
        await #expect(sut.run() == value)
    }

    @Test(arguments: arguments)
    func joined(_ value: Int) async throws {
        let sut = Future.pure(Sut.pure(value)).joined()
        
        await #expect(sut.run() == value)
    }
    
    @Test(arguments: arguments)
    func map(_ value: Int) async throws {
        @Sendable
        func longDescription(_ value: Int) async -> String {
            value.description
        }
        let sut = Sut.pure(value).map(longDescription)
        
        await #expect(sut.run() == value.description)
    }
    
    @Test(arguments: arguments)
    func flatMap(_ value: Int) async throws {
        @Sendable
        func futureDescription(_ value: Int) async -> Future<String> {
            Future.pure(value.description)
        }
        let sut = Sut.pure(value).flatMap(futureDescription)
        
        await #expect(sut.run() == value.description)
    }
    
    @Test
    func zip() async throws {
        let other = Future.pure("baz")
        let sut = Sut.pure(1).zip(other)
        
        await #expect(sut.run() == (1, "baz"))
    }
    
    @Test
    func zipInto() async throws {
        let other = Sut.pure(1)
        let sut = Sut.pure(2).zip(other) { $0 + $1 }
        
        await #expect(sut.run() == 3)
    }
}
