//
//  OptionalTests.swift
//
//
//  Created by Илья Шаповалов on 10.05.2024.
//

import XCTest
import Testing
import SwiftFP

@Suite("Optional tests")
struct OptionalTestNew {
    
    @Test("Test Optional filter", arguments: [1, 2])
    func filterWrappedValue(value: Int) async throws {
        let sut = Optional(value).filter { $0.isMultiple(of: 2) }
        
        value.isMultiple(of: 2)
        ? #expect(sut != nil)
        : #expect(sut == nil)
    }
    
    
}

final class OptionalTests: XCTestCase {
    //MARK: - apply(_:)
    func test_someValue_apply_someFunctor() {
        let functor = Optional(addOne)
        let sut = Optional(1)
            .apply(functor)
        
        XCTAssertEqual(sut, 2)
    }
    
    func test_someValue_apply_nilFunctor() {
        let functor = Optional<(Int) -> Int>.none
        let sut = Optional(1)
            .apply(functor)
        
        XCTAssertNil(sut)
    }
    
    func test_nilValue_apply_someFunctor() {
        let functor = Optional(addOne)
        let sut = Optional<Int>.none
            .apply(functor)
        
        XCTAssertNil(sut)
    }
    
    func test_someValue_asyncApply_someFunctor() async {
        let functor = Optional(asyncAddOne)
        let sut = await Optional(1)
            .asyncApply(functor)
        
        XCTAssertEqual(sut, 2)
    }
    
    func test_someValue_asyncApply_nilFunctor() async {
        let functor = Optional<@Sendable (Int) async -> Int>.none
        let sut = await Optional(1)
            .asyncApply(functor)
        
        XCTAssertNil(sut)
    }
    
    func test_nilValue_asyncApply_someFunctor() async {
        let functor = Optional(asyncAddOne)
        let sut = await Optional<Int>.none
            .asyncApply(functor)
        
        XCTAssertNil(sut)
    }
    
    //MARK: - flatMap(_:)
    func test_someValue_asyncFlatMap() async {
        let sut = await Optional(1)
            .asyncFlatMap(asyncAddOneOpt(_:))
        
        XCTAssertEqual(sut, 2)
    }
    
    func test_nilValue_asyncFlatMap() async {
        let sut = await Optional<Int>
            .none
            .asyncFlatMap(asyncAddOneOpt(_:))
        
        XCTAssertNil(sut)
    }
    
    //MARK: - map(_:)
    func test_someValue_asyncMap() async {
        let sut = await Optional(1)
            .asyncMap(asyncAddOne(_:))
        
        XCTAssertEqual(sut, 2)
    }
    
    //MARK: - zip(_:_:)
    func test_zip_someValueWithSomeValue() {
        let sut = Optional(1).zip("a")
        
        XCTAssertEqual(sut?.0, 1)
        XCTAssertEqual(sut?.1, "a")
    }
    
    func test_zip_someValueWithNil() {
        let other = Optional<String>.none
        let sut = Optional(1).zip(other)
        
        XCTAssertNil(sut)
    }
    
    func test_zip_nilWithSomeValue() {
        let other = Optional(1)
        let sut = Optional<String>.none.zip(other)
        
        XCTAssertNil(sut)
    }
    
    func test_zipGlobal_someValueWithSomeValue() {
        let sut = zip(
            Optional(1),
            Optional("a")
        )
        
        XCTAssertEqual(sut?.0, 1)
        XCTAssertEqual(sut?.1, "a")
    }
    
    func test_zipGlobal_someValueWithNil() {
        let sut = zip(
            Optional(1),
            Optional<String>.none
        )
        
        XCTAssertNil(sut)
    }
    
    func test_zipGlobal_nilWithSomeValue() {
        let sut = zip(
            Optional<Int>.none,
            Optional("a")
        )
        
        XCTAssertNil(sut)
    }
}

//MARK: - Helpers
private extension OptionalTests {
    func addOne(_ v: Int) -> Int { v + 1 }
    @Sendable func asyncAddOne(_ v: Int) async -> Int { v + 1 }
    @Sendable func asyncAddOneOpt(_ v: Int) async -> Int? { .some(v + 1) }
}
