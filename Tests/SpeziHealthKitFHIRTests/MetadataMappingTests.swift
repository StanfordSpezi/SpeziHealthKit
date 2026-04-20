//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import ModelsR4
@testable import SpeziHealthKitFHIR
import Testing


@Suite
struct MetadataMappingTests {
    @Test
    func metadataHandling() throws {
        func imp<T>(_: T.Type, _ value: T, sourceLocation: SourceLocation = #_sourceLocation) throws -> ModelsR4.Extension.ValueX {
            let metadataKey = "edu.stanford.SpeziHealthKitFHIRTests.TestMetadataEntry"
            let sample = HKQuantitySample(
                type: HKQuantityType(.stepCount),
                quantity: HKQuantity(unit: .count(), doubleValue: 17),
                start: .now,
                end: .now,
                metadata: [metadataKey: value]
            )
            let resource = try sample.resource()
            let observation = try #require(resource.get(if: Observation.self), sourceLocation: sourceLocation)
            let metadataExt = try #require(
                observation.extensions(for: "https://bdh.stanford.edu/fhir/defs/metadata").first, sourceLocation: sourceLocation
            )
            let exts = metadataExt.extensions(
                for: "https://bdh.stanford.edu/fhir/defs/metadata/edu.stanford.SpeziHealthKitFHIRTests.TestMetadataEntry"
            )
            return try #require(exts.first?.value, sourceLocation: sourceLocation)
        }
        
        #expect(try imp(String.self, "Hey") == .string("Hey"))
        #expect(try imp(NSString.self, "Hey") == .string("Hey"))
        #expect(try imp(Bool.self, false) == .boolean(false))
        #expect(try imp(Bool.self, true) == .boolean(true))
        #expect(
            try imp(Date.self, .referenceDate) == .dateTime(FHIRPrimitive(DateTime(date: .referenceDate)))
        )
        #expect(try imp(Double.self, 0) == .decimal(0.asFHIRDecimalPrimitive()))
        #expect(try imp(Double.self, 1) == .decimal(1.asFHIRDecimalPrimitive()))
        #expect(try imp(Float.self, 0) == .decimal(0.asFHIRDecimalPrimitive()))
        #expect(try imp(Float.self, 1) == .decimal(1.asFHIRDecimalPrimitive()))
        #expect(try imp(CGFloat.self, 0) == .decimal(0.asFHIRDecimalPrimitive()))
        #expect(try imp(CGFloat.self, 1) == .decimal(1.asFHIRDecimalPrimitive()))
        #expect(try imp(Int.self, 0) == .decimal(0.asFHIRDecimalPrimitive()))
        #expect(try imp(Int.self, 1) == .decimal(1.asFHIRDecimalPrimitive()))
        #expect(try imp(Int.self, 2) == .decimal(2.asFHIRDecimalPrimitive()))
        
        #expect(try imp(NSNumber.self, .init(value: 0)) == .decimal(0.asFHIRDecimalPrimitive()))
        #expect(try imp(NSNumber.self, .init(value: 1)) == .decimal(1.asFHIRDecimalPrimitive()))
        #expect(try imp(NSNumber.self, .init(value: 2)) == .decimal(2.asFHIRDecimalPrimitive()))
        #expect(try imp(NSNumber.self, .init(value: 0.0)) == .decimal(0.asFHIRDecimalPrimitive()))
        #expect(try imp(NSNumber.self, .init(value: 1.0)) == .decimal(1.asFHIRDecimalPrimitive()))
        #expect(try imp(NSNumber.self, .init(value: 2.0)) == .decimal(2.asFHIRDecimalPrimitive()))
        #expect(try imp(NSNumber.self, .init(value: false)) == .boolean(false))
        #expect(try imp(NSNumber.self, .init(value: true)) == .boolean(true))
    }
}


extension Date {
    fileprivate static let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
}
