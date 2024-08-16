//
//  KeyPathTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 16.08.2024.
//

import Testing
import SwiftFP

struct KeyPathTests {
    let sut = Optional("baz")

    @Test func invertedOperator() async throws {
        let condition = try #require(sut.map(!\.isEmpty) as Bool?)
        #expect(condition)
    }

    @Test func equalityOperator() async throws {
        let condition = try #require(sut.map(\.isEmpty == false) as Bool?)
        #expect(condition)
    }
    
    @Test func notEqualOperator() async throws {
        let condition = try #require(sut.map(\.isEmpty != true) as Bool?)
        #expect(condition)
    }
}
