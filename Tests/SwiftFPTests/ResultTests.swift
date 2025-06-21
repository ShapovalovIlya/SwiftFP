//
//  ResultTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 10.05.2024.
//

import XCTest
import Testing
import SwiftFP

@Suite("Result tests")
struct ResultTestsNew {
    enum TestError: Error, Equatable {
        case firstCase
        case failedTest
    }
    
    typealias Sut<T> = Result<T, TestError>
    
    @Test func typeZip_twoSuccess() throws {
        let sut = Result.zip(
            Sut<Int>.success(1),
            Sut<String>.success("baz")
        )
        
        let unwrapped = try sut.get()
        
        #expect(unwrapped.0 == 1)
        #expect(unwrapped.1 == "baz")
    }
    
    @Test func typeZip_successAndFailure() throws {
        let sut = Result.zip(
            Sut<Int>.success(1),
            Sut<String>.failure(.firstCase)
        )
        
        #expect(throws: TestError.self, performing: sut.get)
    }
    
    @Test func typeZip_threeSuccesses() throws {
        let sut = Result.zip(
            Sut<Int>.success(1),
            Sut<String>.success("baz"),
            Sut<Double>.success(1.1)
        )
        
        let unwrapped = try sut.get()
        
        #expect(unwrapped.0 == 1)
        #expect(unwrapped.1 == "baz")
        #expect(unwrapped.2 == 1.1)
    }
    
    @Test func typeZip_threeWithFailure() throws {
        let sut = Result.zip(
            Sut<Int>.success(1),
            Sut<String>.success("baz"),
            Sut<Double>.failure(.firstCase)
        )
        
        #expect(throws: TestError.self, performing: sut.get)
    }
    
    @Test(arguments: [Sut<Int>.success(1), .failure(.firstCase)])
    func resultToEither(_ result: Sut<Int>) async throws {
        let either = result.either()
        
        switch (result, either) {
        case let (.success(lhs), .left(rhs)):
            #expect(lhs == rhs)
            
        case let (.failure(lhs), .right(rhs)):
            #expect(lhs == rhs)
            
        default:
            throw TestError.failedTest
        }
    }
}

final class ResultTests: XCTestCase {
    typealias Sut = Result<Int, Error>
    
    //MARK: - flatMap(_:)
    func test_asyncFlatMap_Success() async {
        let sut = await Sut
            .success(1)
            .asyncFlatMap(asyncAddOneSuccess(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_asyncFlatMap_Fail() async {
        let sut = await Sut
            .success(1)
            .asyncFlatMap(asyncAddOneFailure(_:))
        
        switch sut {
        case .success: XCTFail()
            
        case .failure(let fail):
            XCTAssertTrue(fail is TestFail)
        }
    }
    
    //MARK: - map(_:)
    func test_asyncMap() async {
        let sut = await Sut
            .success(1)
            .asyncMap(asyncAddOne(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_tryMap_success() {
        let sut = Sut
            .success(1)
            .map(addOne(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_tryMap_fail() {
        let sut = Sut
            .success(1)
            .tryMap(throwError(_:))
        
        switch sut {
        case .success: XCTFail()
            
        case .failure(let failure):
            XCTAssertTrue(failure is TestFail)
        }
    }
    
    func test_asyncTryMap_success() async {
        let sut = await Sut
            .success(1)
            .asyncMap(asyncAddOne)
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_asyncTryMap_fail() async {
        let sut = await Sut
            .success(1)
            .asyncTryMap(asyncThrowError)
        
        switch sut {
        case .success: XCTFail()
            
        case .failure(let failure):
            XCTAssertTrue(failure is TestFail)
        }
    }
    
    //MARK: - apply(_:)
    func test_apply_success() {
        let functor = Result<(Int) -> Int, Error>.success(addOne(_:))
        let sut = Sut.success(1).apply(functor)
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_apply_fail() {
        let functor = Result<(Int) -> Int, Error>.success(addOne(_:))
        let sut = Sut.failure(TestFail()).apply(functor)
        
        switch sut {
        case .success: XCTFail()
            
        case .failure(let failure):
            XCTAssertTrue(failure is TestFail)
        }
    }
    
    func test_asyncApply_success() async {
        let functor = Result<@Sendable (Int) async -> Int, Error>.success(asyncAddOne(_:))
        let sut = await Sut.success(1).asyncApply(functor)
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_asyncApply_fail() async {
        let functor = Result<@Sendable (Int) async -> Int, Error>.success(asyncAddOne(_:))
        let sut = await Sut.failure(TestFail()).asyncApply(functor)
        
        switch sut {
        case .success: XCTFail()
    
        case .failure(let failure):
            XCTAssertTrue(failure is TestFail)
        }
    }
    
    //MARK: - zip(_:)
    func test_zip() {
        let other = Sut.success(1)
        let sut = Sut.success(1)
            .zip(other)
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success.0, 1)
            XCTAssertEqual(success.1, 1)
            
        case .failure: XCTFail()
        }
    }
}

//MARK: - Helpers
private extension ResultTests {
    struct TestFail: Error {}
    
    func addOne(_ v: Int) -> Int { v + 1 }
    func throwError(_ v: Int) throws -> Int { throw TestFail() }
    
    @Sendable func asyncThrowError(_ v: Int) async throws -> Int {
        throw TestFail()
    }
    
    @Sendable func asyncAddOne(_ v: Int) async -> Int { v + 1 }
    
    @Sendable func asyncAddOneSuccess(_ v: Int) async -> Result<Int, Error> {
        .success(v + 1)
    }
    
    @Sendable func asyncAddOneFailure(_ v: Int) async -> Result<Int, Error> { .failure(TestFail())
    }
}
