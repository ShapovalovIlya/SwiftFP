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
            .flatMap(asyncAddOneSuccess(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_asyncFlatMap_Fail() async {
        let sut = await Sut
            .success(1)
            .flatMap(asyncAddOneFailure(_:))
        
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
            .map(asyncAddOne(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_tryMap_success() {
        let sut = Sut
            .success(1)
            .tryMap(addOne(_:))
        
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
            .tryMap(asyncAddOne)
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_asyncTryMap_fail() async {
        let sut = await Sut
            .success(1)
            .tryMap(asyncThrowError)
        
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
}

//MARK: - Helpers
private extension ResultTests {
    struct TestFail: Error {}
    
    func addOne(_ v: Int) -> Int { v + 1 }
    func throwError(_ v: Int) throws -> Int { throw TestFail() }
    func asyncThrowError(_ v: Int) async throws -> Int { throw TestFail() }
    func asyncAddOne(_ v: Int) async -> Int { v + 1 }
    func asyncAddOneSuccess(_ v: Int) async -> Result<Int, Error> { .success(v + 1) }
    func asyncAddOneFailure(_ v: Int) async -> Result<Int, Error> { .failure(TestFail()) }
}
