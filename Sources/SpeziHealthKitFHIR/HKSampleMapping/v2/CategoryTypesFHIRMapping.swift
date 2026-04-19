//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

public import ModelsR4
public import SpeziHealthKit


/// Controls how `HKCategorySample`s are mapped into FHIR Observations.
public typealias CategoryTypesFHIRMapping = [SampleType<HKCategorySample>: CategoryTypeFHIRMapping]


/// Controls how an `HKCategorySample` is mapped into a FHIR Observation.
///
/// ## Topics
///
/// ### Initializers
/// - ``init(codings:)``
///
/// ### Instance Properties
/// - ``codings``
public struct CategoryTypeFHIRMapping: Hashable, Sendable {
    public var codings: [Coding]
    public var categories: [Coding]
    
    public init(codings: [Coding], categories: [Coding]) {
        self.codings = codings
        self.categories = categories
    }
}


extension CategoryTypesFHIRMapping {
    /// The default FHIR mapping for HealthKit Category types
    public static let `default`: Self = HKCategoryType.allKnownCategories.reduce(into: [:]) { mapping, categoryType in
        guard let sampleType = categoryType.sampleType as? SampleType<HKCategorySample> else {
            assertionFailure("Missing FHIR mapping entry for \(HKCategoryType.self) \(categoryType)!")
            return
        }
        mapping[sampleType] = CategoryTypeFHIRMapping(
            codings: [
                Coding(
                    code: categoryType.identifier.asFHIRStringPrimitive(),
                    display: sampleType.canonicalTitle.asFHIRStringPrimitive(),
                    system: .healthKitSystem
                )
            ],
            categories: []
        )
    }
}
