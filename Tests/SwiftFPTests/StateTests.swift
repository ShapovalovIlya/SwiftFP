//
//  StateTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 01.12.2024.
//

import Testing
import State

struct StateTests {
    typealias Sut = State<Int, String>
    
    @Test func reduce() async throws {
        let sut = Sut { ($0, $0.description) }
        
        #expect(sut.reduce(1) == (1, "1"))
    }
    
    @Test func pure() async throws {
        let sut = Sut.pure("baz")
        
        #expect(sut.reduce(1) == (1, "baz"))
    }
    
    @Test func joined() async throws {
        let nested = State<Int, Bool>.pure(true)
        let sut = State.pure(nested).joined()
        
        #expect(sut.reduce(1) == (1, true))
    }
    
    @Test func map() async throws {
        let sut = Sut.pure("baz").map(\.count)
        
        #expect(sut.reduce(1) == (1,3))
    }
    
    @Test func flatMap() async throws {
        func counterState(_ str: String) -> State<Int, Bool> {
            State.pure(str.isEmpty)
        }
        let sut = Sut.pure("baz").flatMap(counterState)
        
        #expect(sut.reduce(1) == (1,false))
    }
    
    @Test func pullback() async throws {
        func counter(_ string: String) -> Int { string.count }
        let sut = Sut.pure("baz").pullback(counter(_:))
        
        #expect(sut.reduce("foo") == ("foo", "baz"))
    }
}
