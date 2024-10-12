//
//  ZipperTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 12.10.2024.
//

import Testing
import Zipper

struct ZipperTestsTests {
    let sut: Zipper<Int>
    
    init() throws {
        sut = try #require(Zipper([1,2,3]))
    }

    @Test
    func initFromSequence() async throws {
        #expect(sut.current == 1)
        #expect(sut.previous.isEmpty)
        #expect(sut.next == [2,3])
        #expect(sut.count == 3)
        #expect(sut.first == 1)
        #expect(sut.last == 3)
        #expect(sut.array == [1,2,3])
    }
    
    @Test
    func initFromEmptySequence() async throws {
        let sut = Zipper([Int]())
        
        #expect(sut == nil)
    }
    
    @Test
    func initWithSelection() async throws {
        let sut = Zipper([1,2,3], setCurrent: { $0 == 2 })
        
        let unwrapped = try #require(sut)
        
        #expect(unwrapped.previous == [1])
        #expect(unwrapped.current == 2)
        #expect(unwrapped.next == [3])
    }
        
    @Test
    func mapZipper() async throws {
        let sut = sut.mapZipper(\.description)
        
        #expect(sut.array == ["1","2","3"])
    }

}
