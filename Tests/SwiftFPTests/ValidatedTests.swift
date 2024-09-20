//
//  ValidatedTests.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 19.09.2024.
//

import Testing
import Validated

struct ValidatedTests {
    enum StubError: Error, Equatable {}
    
    @Test
    func initialState() async throws {
        let sut = Validated<Int, StubError>.valid(1)
        
        #expect(sut == .valid(1))
    }
}
