//
//  NotEmptyArrayTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Testing
import NotEmptyArray

struct NotEmptyArrayTests {
    @Test
    func initialState() async throws {
        let sut = NotEmptyArray(head: 1, tail: [])
        
        #expect(sut.head == 1)
        #expect(sut.tail.isEmpty)
    }
    
    @Test
    func initWithEmptyArray() async throws {
        let sut = NotEmptyArray([])
        
        #expect(sut == nil)
    }
    
    @Test func initWithNotEmptyArray() async throws {
        let sut = NotEmptyArray([1,2,3])
        
        #expect(sut?.head == 1)
        #expect(sut?.tail == [2,3])
    }
    
    @Test
    func reduceInto() async throws {
        let sut = NotEmptyArray(head: 1, tail: [2,3])
            .reduce(into: 0) { $0 += $1 }
        
        #expect(sut == (1 + 2 + 3))
    }
    
    @Test
    func map() async throws {
        let sut = try #require(NotEmptyArray([0,1,2]))
            .mapNotEmpty { $0 + 1 }
        
        #expect(sut.head == 1)
        #expect(sut.tail == [2,3])
    }
}
