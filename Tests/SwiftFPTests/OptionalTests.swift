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
    
    @Test(arguments: [1, nil])
    func reduce(state: Int?) async throws {
        let result = state.reduce { $0 += 1 }
        
        switch state {
        case .some(let wrapped): #expect(result == wrapped + 1)
        case .none: #expect(result == nil)
        }
    }
    
    //MARK: - replaceNill
    @Test(arguments: [1, nil])
    func replaceNil(state: Int?) async throws {
        let validState = 2
        let sut = state.replaceNil(validState)
        
        switch state {
        case .some(let val): #expect(sut == val)
        case .none: #expect(sut == validState)
        }
    }
    
    @Test(arguments: [1, nil])
    func intOrZero(_ state: Int?) async throws {
        let sut = state.orZero
        
        switch state {
        case .some(let wrapped): #expect(sut == wrapped)
        case .none: #expect(sut == .zero)
        }
    }
    
    @Test(arguments: [1.0, nil])
    func floatOrZero(_ state: Float?) async throws {
        let sut = state.orZero
        
        switch state {
        case .some(let wrapped): #expect(sut == wrapped)
        case .none: #expect(sut == .zero)
        }
    }
    
    @Test(arguments: [1.0, nil])
    func doubleOrZero(_ state: Double?) async throws {
        let sut = state.orZero
        
        switch state {
        case .some(let wrapped): #expect(sut == wrapped)
        case .none: #expect(sut == .zero)
        }
    }
    
    @Test(arguments: ["baz", nil])
    func stringOrEmpty(_ state: String?) async throws {
        let sut = state.orEmpty
        
        switch state {
        case .some(let wrapped): #expect(sut == wrapped)
        case .none: #expect(sut == "")
        }
    }
    
    @Test
    func optionalZip_someValueWithSomeValue() throws {
        let sut = Optional.zip(1, "a")
        
        let unwrapped = try #require(sut)
        
        #expect(unwrapped.0 == 1)
        #expect(unwrapped.1 == "a")
    }
    
    @Test
    func optionalZip_someValueWithNil() {
        let sut = Optional.zip(1, Optional<String>.none)
        
        #expect(sut == nil)
    }
    
    @Test
    func optionalZip_nilWithSomeValue() {
        let sut = Optional.zip(Optional<Int>.none, "a")
        
        #expect(sut == nil)
    }
    
    @Test
    func optionalZip3Values_someValues() async throws {
        let sut = Optional.zip(1, "baz", 1.1)
        
        let unwrapped = try #require(sut)
        
        #expect(unwrapped.0 == 1)
        #expect(unwrapped.1 == "baz")
        #expect(unwrapped.2 == 1.1)
    }
    
    @Test
    func optionalZip3Values_someValuesWithNil() async throws {
        let sut = Optional.zip(1, "baz", Optional<Int>.none)
        
        #expect(sut == nil)
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
}

//MARK: - Helpers
fileprivate func addOne(_ v: Int) -> Int { v + 1 }

@Sendable
fileprivate func asyncAddOne(_ v: Int) async -> Int { v + 1 }

@Sendable
fileprivate func asyncAddOneOpt(_ v: Int) async -> Int? { .some(v + 1) }
