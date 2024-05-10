//
//  EitherTests.swift
//  
//
//  Created by Шаповалов Илья on 17.04.2024.
//

import XCTest
@testable import SwiftFP

final class EitherTests: XCTestCase {
    func test_leftState() {
        let bool = true
        let sut = Either<Int, Int> {
            if bool { return .left(1) }
            return .right(0)
        }
        
        XCTAssertEqual(sut, .left(1))
    }
    
    func test_rightState() {
        let bool = false
        let sut = Either<Int, Int> {
            if bool { return .left(1) }
            return .right(0)
        }
        
        XCTAssertEqual(sut, .right(0))
    }
    
    //MARK: - map(_:)
    func test_map() {
        let sut = Either<Int, Int>
            .left(1)
            .map { $0 + 1 }
        
        XCTAssertEqual(sut, .left(2))
    }
    
    func test_map_OnRightBranch_ReturnRightBranch() {
        let sut = Either<Int, Int>
            .right(1)
            .map { $0 + 1 }
        
        XCTAssertEqual(sut, .right(1))
    }
    
    func test_mapRight() {
        let sut = Either<Int, Int>
            .right(1)
            .mapRight { $0 + 1 }
        
        XCTAssertEqual(sut, .right(2))
    }
    
    func test_mapRight_OnLeftBranch_ReturnLeftBranch() {
        let sut = Either<Int, Int>
            .left(1)
            .mapRight { $0 + 1 }
        
        XCTAssertEqual(sut, .left(1))
    }
    
    //MARK: - flatMap(_:)
    func test_flatMap() {
        let sut = Either<Int, Int>
            .left(1)
            .flatMap { .left($0.description) }
        
        XCTAssertEqual(sut, .left(1.description))
    }
    
    func test_asyncFlatMap() async {
        let sut = await Either<Int, Int>
            .left(1)
            .flatMap(asyncAddOneToLeft(_:))
        
        XCTAssertEqual(sut, .left(2))
    }
    
    func test_flatMap_OnRightBranch_ReturnRightBranch() {
        let sut = Either<Int, Int>
            .right(1)
            .flatMap { .left($0.description) }
        
        XCTAssertEqual(sut, .right(1))
    }
    
    //MARK: - flatMapRight(_:)
    func test_flatMapRight() {
        let sut = Either<Int, Int>
            .right(1)
            .flatMapRight { .right($0.description) }
        
        XCTAssertEqual(sut, .right(1.description))
    }
    
    func test_asyncFlatMapRight() async {
        let sut = await Either<Int, Int>
            .right(1)
            .flatMapRight(asyncAddOneToRight)
        
        XCTAssertEqual(sut, .right(2))
    }
    
    func test_flatMapRight_OnLeftBranch_ReturnLeftBranch() {
        let sut = Either<Int, Int>
            .left(1)
            .flatMapRight { .right($0.description) }
        
        XCTAssertEqual(sut, .left(1))
    }
    
    func test_flatMapEitherToNewValue() {
        let sut = Either<Int, Int>
            .left(0)
            .flatMap { _ in 1 }
        
        XCTAssertEqual(sut, 1)
    }
    
    //MARK: - apply(_:)
    func test_apply() {
        let descriptor = Either<(Int) -> String, Int>
            .left(\.description)
        let sut = Either<Int, Int>
            .left(1)
            .apply(descriptor)
        
        XCTAssertEqual(sut, .left(1.description))
    }
    
    func test_applyToRightBranchReturnRightBranch() {
        let descriptor = Either<(Int) -> String, Int>
            .left(\.description)
        let sut = Either<Int, Int>
            .right(1)
            .apply(descriptor)
        
        XCTAssertEqual(sut, .right(1))
    }
    
    func test_applyApplicative_WithRightBranch_ReturnApplicativeRightBranch() {
        let descriptor = Either<(Int) -> String, Int>
            .right(1)
        let sut = Either<Int, Int>
            .left(0)
            .apply(descriptor)
        
        XCTAssertEqual(sut, .right(1))
    }
    
    func test_applyRight() {
        let descriptor = Either<Int, (Int) -> String>
            .right(\.description)
        let sut = Either<Int, Int>
            .right(1)
            .applyRight(descriptor)
        
        XCTAssertEqual(sut, .right(1.description))
    }
    
    func test_applyRight_ApplicativeWithLeftBranch_ReturnApplicativeLeftBranch() {
        let descriptor = Either<Int, (Int) -> String>
            .left(1)
        let sut = Either<Int, Int>
            .right(0)
            .applyRight(descriptor)
        
        XCTAssertEqual(sut, .left(1))
    }
}

private extension EitherTests {
    //MARK: - Helpers
    func addOne(_ v: Int) async -> Int { v + 1 }
    func asyncAddOneToLeft(_ v: Int) async -> Either<Int,Int> { .left(v + 1) }
    func asyncAddOneToRight(_ v: Int) async -> Either<Int,Int> { .right(v + 1) }
}
