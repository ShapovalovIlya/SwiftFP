//
//  NotEmptyArrayTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Testing
import SwiftFP

struct NotEmptyArrayTests {
    typealias Sut = NotEmptyArray<Int>
    
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
            .map { $0 + 1 }
        
        #expect(sut.head == 1)
        #expect(sut.tail == [2,3])
    }
    
    @Test func append() async throws {
        var sut = Sut(single: 1)
        
        sut.append(2)
        
        #expect(sut.head == 1)
        #expect(sut.tail == [2])
        
        sut.append(contentsOf: [3,4])
        
        #expect(sut.head == 1)
        #expect(sut.tail == [2,3,4])
    }
    
    @Test func arithmetics() async throws {
        let sut = Sut(single: 1) + Sut(single: 1)
        
        #expect(sut.head == 1)
        #expect(sut.tail == [1])
    }
    
    @Test func elementAtIndex() async throws {
        let sut = Sut(head: 1, tail: [2,3])
        
        var element = sut.element(at: 0)
        
        #expect(element == 1)
        
        element = sut.element(at: 10)
        
        #expect(element == nil)
    }
}
