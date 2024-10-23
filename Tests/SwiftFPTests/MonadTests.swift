//
//  MonadTests.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import XCTest
import Testing
import Monad

@Suite("Monad tests")
struct MonadTestsSuite {
    @Test
    func reduce() async throws {
        let val = 1
        let sut = Monad(val).reduce(\.description)
        
        #expect(sut == val.description)
    }
    
    @Test
    func asyncReduce() async throws {
        let sut = await Monad(1).asyncReduce(addOneAsync)
        
        #expect(sut == 2)
    }
    
    @Test
    func callAsFunction() async throws {
        let sut = Monad({ 1 })
        
        #expect(sut() == 1)
    }
    
    @Test
    func callAsFunctionWithArguments() async throws {
        let sut = Monad<(Int) -> Int>({ $0 + 1 })
        
        #expect(sut(1) == 2)
    }
}

final class MonadTests: XCTestCase {
    func test_map() {
        let sut = Monad(1)
        
        let result = sut.map(addOne(_:))
        let result2 = result.map { $0 + 2 }
        let result3 = result2.map { $0 + 3 }
        
        XCTAssertEqual(result.wrapped, 2)
        XCTAssertEqual(result2.wrapped, 4)
        XCTAssertEqual(result3.wrapped, 7)
    }
    
    func test_flatMap() {
        let sut = Monad(1)
        
        let result = sut.flatMap { Monad($0 + 1) }
       
        XCTAssertEqual(result.wrapped, 2)
    }
    
    func test_apply() {
        let functor = Monad(addOne)
        let sut = Monad(1).apply(functor)
        
        XCTAssertEqual(sut.wrapped, 2)
    }
    
    func test_asyncMap() async {
        let sut = await Monad(1).asyncMap(addOneAsync(_:))
        
        XCTAssertEqual(sut.wrapped, 2)
    }
    
    func test_asyncFlatMap() async {
        let sut = await Monad(1).asyncFlatMap(addMonadAsync)
        
        XCTAssertEqual(sut.wrapped, 2)
    }

    func test_asyncApply() async {
        let functor = Monad(addOneAsync)
        let sut = await Monad(1).asyncApply(functor)
        
        XCTAssertEqual(sut.wrapped, 2)
    }
    
    func test_zip() {
        let sut = Monad(1).zip(Monad("a"))
        
        XCTAssertEqual(sut.0, 1)
        XCTAssertEqual(sut.1, "a")
    }
    
    func test_zip_global() {
        let sut = zip(
            Monad(1),
            Monad("a")
        )
        
        XCTAssertEqual(sut.0, 1)
        XCTAssertEqual(sut.1, "a")
    }
}

private func addOne(_ val: Int) -> Int { val + 1 }
@Sendable private func addOneAsync(_ val: Int) async -> Int { val + 1 }
private func addMonadAsync(_ val: Int) async -> Monad<Int> { Monad(val + 1) }
