//
//  SortTest.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 14.04.2025.
//

import Testing
import SwiftFP

fileprivate struct Person: Equatable {
    let name: String
    let age: UInt8
    let male: Bool
    
    static let test: [Person] = [
        Person(name: "Baz", age: 3, male: true),
        Person(name: "Bar", age: 6, male: true),
        Person(name: "Foo", age: 9, male: false)
    ]
}



struct SortTest {

//    @Test func sortedUsingClosureComparator() async throws {
//        let sut = Person.test.sorted(by: [
//            { $0.age > $1.age },
//            { $0.name < $0.name }
//        ])
//        
//        let expected = Person.test.sorted {
//            $0.age > $1.age
//        }
//        #expect(sut == expected)
//    }

}
