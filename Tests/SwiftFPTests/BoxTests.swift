//
//  BoxTests.swift
//
//
//  Created by Илья Шаповалов on 27.01.2024.
//

import XCTest
@testable import SwiftFP

final class BoxTests: XCTestCase {
    func test_map() {
        let sut = Box(1)
        
        let result = sut.map { $0 + 1 }
        let result2 = result.map { $0 + 2 }
        let result3 = result2.map { $0 + 3 }
        
        XCTAssertEqual(result.value, 2)
        XCTAssertEqual(result2.value, 4)
        XCTAssertEqual(result3.value, 7)
    }
    
    func test_flatMap() {
        let sut = Box(1)
        
        let result = sut.flatMap { Box($0 + 1) }
        
        XCTAssertEqual(result.value, 2)
    }
    
    func test_measure_map() {
        measure {
            _ = Box(1).map { $0 + 1 }
        }
    }
    
    func test_measure_flatMap() {
        measure {
            _ = Box(1).flatMap { Box($0 + 1) }
        }
    }

}
