//
//  OptionalTests.swift
//
//
//  Created by Илья Шаповалов on 10.05.2024.
//

import XCTest
import SwiftFP

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
            .apply(functor)
        
        XCTAssertEqual(sut, 2)
    }
    
    func test_someValue_asyncApply_nilFunctor() async {
        let functor = Optional<(Int) async -> Int>.none
        let sut = await Optional(1)
            .apply(functor)
        
        XCTAssertNil(sut)
    }
    
    func test_nilValue_asyncApply_someFunctor() async {
        let functor = Optional(asyncAddOne)
        let sut = await Optional<Int>.none
            .apply(functor)
        
        XCTAssertNil(sut)
    }
    
    //MARK: - flatMap(_:)
    func test_someValue_asyncFlatMap() async {
        let sut = await Optional(1)
            .flatMap(asyncAddOneOpt(_:))
        
        XCTAssertEqual(sut, 2)
    }
    
    func test_nilValue_asyncFlatMap() async {
        let sut = await Optional<Int>
            .none
            .flatMap(asyncAddOneOpt(_:))
        
        XCTAssertNil(sut)
    }
    
    //MARK: - map(_:)
    func test_someValue_asyncMap() async {
        let sut = await Optional(1)
            .map(asyncAddOne(_:))
        
        XCTAssertEqual(sut, 2)
    }
}

//MARK: - Helpers
private extension OptionalTests {
    func addOne(_ v: Int) -> Int { v + 1 }
    func asyncAddOne(_ v: Int) async -> Int { v + 1 }
    func asyncAddOneOpt(_ v: Int) async -> Int? { .some(v + 1) }
}
