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
    
    func test_map() {
        let sut = Either<Int, Int>
            .left(1)
            .map { $0 + 1 }
        
        XCTAssertEqual(sut, .left(2))
    }
    
    func test_mapOnRightBranchReturnRightBranch() {
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
    
    func test_mapRightOnLeftBranchReturnLeftBranch() {
        let sut = Either<Int, Int>
            .left(1)
            .mapRight { $0 + 1 }
        
        XCTAssertEqual(sut, .left(1))
    }
    
    func test_flatMap() {
        let sut = Either<Int, Int>
            .left(1)
            .flatMap { .left($0.description) }
        
        XCTAssertEqual(sut, .left(1.description))
    }
    
    func test_flatMapOnRightBranchReturnRightBranch() {
        let sut = Either<Int, Int>
            .right(1)
            .flatMap { .left($0.description) }
        
        XCTAssertEqual(sut, .right(1))
    }
    
    func test_flatMapRight() {
        let sut = Either<Int, Int>
            .right(1)
            .flatMapRight { .right($0.description) }
        
        XCTAssertEqual(sut, .right(1.description))
    }
    
    func test_flatMapRightOnLeftBranchReturnLeftBranch() {
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
