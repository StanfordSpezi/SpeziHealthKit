//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable type_name identifier_name

import Algorithms
import Foundation
@_spi(APISupport) @_spi(Testing)
@testable import SpeziHealthKit
import Testing


@Suite
struct HKFactorizationTests {
    private typealias F = HKFactorization
    
    @Test
    func isNull() {
        #expect(F([:]).isNull)
        #expect((F([.init(dimension: .length, unitString: "m"): 1]) / F([.init(dimension: .length, unitString: "m"): 1])).isNull)
        #expect(!(F([.init(dimension: .length, unitString: "m"): 1]) / F([.init(dimension: .length, unitString: "cm"): 1])).isNull)
    }
    
    @Test
    func dimensionReduction() {
        let f1 = HKFactorization([
            .init(dimension: .length, unitString: "m"): 4,
            .init(dimension: .pressure, unitString: "atm"): 2,
            .init(dimension: .volume, unitString: "GL"): 1,
            .init(dimension: .length, unitString: "in"): -2
        ])
        #expect(f1.reducedToDimensions() == HKFactorization([
            .init(unitlessDimension: .length): 2,
            .init(unitlessDimension: .pressure): 2,
            .init(unitlessDimension: .volume): 1
        ]))
        let f2 = HKFactorization([
            .init(dimension: .length, unitString: "in"): 2,
            .init(dimension: .pressure, unitString: "atm"): 2,
            .init(dimension: .volume, unitString: "GL"): 1
        ])
        #expect(f2.reducedToDimensions() == HKFactorization([
            .init(unitlessDimension: .length): 2,
            .init(unitlessDimension: .pressure): 2,
            .init(unitlessDimension: .volume): 1
        ]))
    }
}
