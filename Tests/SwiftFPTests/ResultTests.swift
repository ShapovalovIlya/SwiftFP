//
//  ResultTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 10.05.2024.
//

import XCTest
import SwiftFP

final class ResultTests: XCTestCase {
    //MARK: - flatMap(_:)
    func test_asyncFlatMap_Success() async {
        let sut = await Result<Int, Error>
            .success(1)
            .flatMap(asyncAddOneSuccess(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_asyncFlatMap_Fail() async {
        let sut = await Result<Int, Error>
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
        let sut = await Result<Int, Error>
            .success(1)
            .map(asyncAddOne(_:))
        
        switch sut {
        case .success(let success):
            XCTAssertEqual(success, 2)
            
        case .failure: XCTFail()
        }
    }
    
    func test_tryMap() {
        let sut = Result<Int, Error>
            .success(1)
            .tryMap(throwError(_:))
        
        switch sut {
        case .success: XCTFail()
            
        case .failure(let failure):
            XCTAssertTrue(failure is TestFail)
        }
    }
    
    func test_asyncTryMap() async {
        
    }
}

//MARK: - Helpers
private extension ResultTests {
    struct TestFail: Error {}
    
    func throwError(_ v: Int) throws -> Int { throw TestFail() }
    func asyncAddOne(_ v: Int) async -> Int { v + 1 }
    func asyncAddOneSuccess(_ v: Int) async -> Result<Int, Error> { .success(v + 1) }
    func asyncAddOneFailure(_ v: Int) async -> Result<Int, Error> { .failure(TestFail()) }
}
