//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Algorithms
import Foundation
@_spi(APISupport) @_spi(Testing)
@testable import SpeziHealthKit
import Testing


@Suite
struct HKFactorizationTests {
    private typealias F = HKFactorization // swiftlint:disable:this type_name
    
    @Test
    func isNull() {
        #expect(F([:]).isNull)
        #expect((F([.init(dimension: .length, unitString: "m"): 1]) / F([.init(dimension: .length, unitString: "m"): 1])).isNull)
        #expect(!(F([.init(dimension: .length, unitString: "m"): 1]) / F([.init(dimension: .length, unitString: "cm"): 1])).isNull)
    }
    
    @Test func dimensionReduction() throws { // swiftlint:disable:this function_body_length
        func imp(
            unitString: String,
            unitFactorization: HKFactorization,
            dimensionReduction: HKFactorization,
            sourceLocation: SourceLocation = #_sourceLocation
        ) throws {
            let unit = try _HKUnit.parse(unitString)
            #expect(unit.factorization == unitFactorization, sourceLocation: sourceLocation)
            #expect(unit.factorization.reducedToDimensions() == dimensionReduction, sourceLocation: sourceLocation)
        }
        
        try imp(
            unitString: "atm",
            unitFactorization: HKFactorization([
                .init(dimension: .pressure, unitString: "atm"): 1
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 1,
                .init(unitlessDimension: .length): -1,
                .init(unitlessDimension: .time): -2
            ])
        )
        try imp(
            unitString: "atm^2",
            unitFactorization: HKFactorization([
                .init(dimension: .pressure, unitString: "atm"): 2
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 2,
                .init(unitlessDimension: .length): -2,
                .init(unitlessDimension: .time): -4
            ])
        )
        
        try imp(
            unitString: "m^4",
            unitFactorization: HKFactorization([
                .init(dimension: .length, unitString: "m"): 4
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .length): 4
            ])
        )
        
        try imp(
            unitString: "m^4*atm^1",
            unitFactorization: HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .pressure, unitString: "atm"): 1
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 1,
                .init(unitlessDimension: .length): 3,
                .init(unitlessDimension: .time): -2
            ])
        )
        
        try imp(
            unitString: "m^4*atm^2",
            unitFactorization: HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .pressure, unitString: "atm"): 2
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 2,
                .init(unitlessDimension: .length): 2,
                .init(unitlessDimension: .time): -4
            ])
        )
        
        try imp(
            unitString: "m^4*atm^2*GL",
            unitFactorization: HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .volume, unitString: "GL"): 1
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 2,
                .init(unitlessDimension: .length): 5,
                .init(unitlessDimension: .time): -4
            ])
        )
        
        try imp(
            unitString: "m^4*atm^2*GL/in^2",
            unitFactorization: HKFactorization([
                .init(dimension: .length, unitString: "m"): 4,
                .init(dimension: .pressure, unitString: "atm"): 2,
                .init(dimension: .volume, unitString: "GL"): 1,
                .init(dimension: .length, unitString: "in"): -2
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 2,
                .init(unitlessDimension: .length): 3,
                .init(unitlessDimension: .time): -4
            ])
        )
        
        try imp(
            unitString: "J",
            unitFactorization: HKFactorization([
                .init(dimension: .energy, unitString: "J"): 1
            ]),
            dimensionReduction: HKFactorization([
                .init(unitlessDimension: .mass): 1,
                .init(unitlessDimension: .length): 2,
                .init(unitlessDimension: .time): -2
            ])
        )
    }
    
    
    @Test
    func initFactorization() {
        #expect(HKFactorization([
            (.init(unitlessDimension: .length), 1),
            (.init(unitlessDimension: .length), 2)
        ]) == HKFactorization([.init(unitlessDimension: .length): 3]))
    }
}
