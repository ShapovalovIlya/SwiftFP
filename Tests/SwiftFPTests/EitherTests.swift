//
//  EitherTests.swift
//  
//
//  Created by Шаповалов Илья on 17.04.2024.
//

import XCTest
import Testing
@testable import SwiftFP

@Suite("Either tests")
struct EitherTestsSuite {
    typealias Sut = Either<Int, String>
    
    //MARK: - mocks
    private static let states = Array<Sut>(arrayLiteral: .left(1), .right("baz"))
    
    //MARK: - tests
    @Test("Initial state for branching initialization", arguments: [true, false])
    func initialState(condition: Bool) async throws {
        let sut = Sut {
            condition ? .left(1) : .right("baz")
        }
        #expect(condition ? sut == .left(1) : sut == .right("baz"))
    }

    @Test("map(_:) on different branches", arguments: states)
    func mapEither(initialState: Sut) async throws {
        let sut = initialState.map { $0 + 1 }
        
        switch initialState {
        case let .left(val):
            #expect(sut == .left(val + 1))
        case .right:
            #expect(sut == initialState)
        }
    }
    
    @Test("mapRight(_:) on different branches", arguments: states)
    func mapRightEither(initialState: Sut) async throws {
        let sut = initialState.mapRight(\.capitalized)
        
        switch initialState {
        case .left:
            #expect(sut == initialState)
            
        case let .right(string):
            #expect(sut == .right(string.capitalized))
        }
    }
}

final class EitherTests: XCTestCase {
    
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
            .asyncFlatMap(asyncAddOneToLeft(_:))
        
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
            .asyncFlatMapRight(asyncAddOneToRight)
        
        XCTAssertEqual(sut, .right(2))
    }
    
    func test_flatMapRight_OnLeftBranch_ReturnLeftBranch() {
        let sut = Either<Int, Int>
            .left(1)
            .flatMapRight { .right($0.description) }
        
        XCTAssertEqual(sut, .left(1))
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
