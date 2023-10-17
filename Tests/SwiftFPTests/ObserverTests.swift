//
//  ObserverTests.swift
//  
//
//  Created by Илья Шаповалов on 17.10.2023.
//

import XCTest

@testable import SwiftFP

final class ObserverTests: XCTestCase {

    func test_observerReceiveValue() {
        var sequence = [Int]()
        let observer = Observer<Int>{ sequence.append($0) }
        var observable = Observable(value: 0)
        
        observable.subscribe(on: observer)
        
        for i in 1...5 {
            observable.value = i
        }
        
        XCTAssertEqual(sequence, [1,2,3,4,5])
    }
    
    func test_() {
        var sequence = [Int]()
        var sequence2 = [Int]()
        let observer = Observer<Int> { sequence.append($0) }
        var observer2: Observer! = Observer<Int> { sequence2.append($0) }
        
        var observable = Observable(value: 0)
        observable.subscribe(on: observer)
        observable.subscribe(on: observer2)
        
        for i in 1...5 {
            observable.value = i
            
            if i == 2 {
                observer2 = nil
            }
        }
        
        XCTAssertEqual(sequence, [1,2,3,4,5])
        XCTAssertEqual(sequence2, [1, 2])
    }

}
