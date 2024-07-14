//
//  ResultTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 10.05.2024.
//

import XCTest
import SwiftFP

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
            .map(throwError(_:))
        
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
            .asyncMap(asyncThrowError)
        
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
    
    func test_zip_global() {
        let lhs = Sut.success(1)
        let rhs = Sut.success(2)
        
        switch zip(lhs, rhs) {
        case .success(let success):
            XCTAssertEqual(success.0, 1)
            XCTAssertEqual(success.1, 2)
            
        case .failure: XCTFail()
        }
    }
}

//MARK: - Helpers
private extension ResultTests {
    struct TestFail: Error {}
    
    func addOne(_ v: Int) -> Int { v + 1 }
    func throwError(_ v: Int) throws -> Int { throw TestFail() }
    func asyncThrowError(_ v: Int) async throws -> Int { throw TestFail() }
    @Sendable func asyncAddOne(_ v: Int) async -> Int { v + 1 }
    func asyncAddOneSuccess(_ v: Int) async -> Result<Int, Error> { .success(v + 1) }
    func asyncAddOneFailure(_ v: Int) async -> Result<Int, Error> { .failure(TestFail()) }
}
