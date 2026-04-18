//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import FHIRModelsExtensions
import HealthKit
import ModelsR4


extension HKSample {
    /// A `ResourceProxy` containing an FHIR  `Observation` based on the concrete subclass of `HKSample`.
    ///
    /// - parameter mapping: A mapping to map `HKSample`s to corresponding FHIR observations allowing the customization of, e.g., codings and units. See ``HKSampleMapping``.
    /// - parameter issuedDate: `Instant` specifying when this version of the resource was made available. Defaults to `Date.now`.
    /// - parameter extensions: Any ``FHIRExtensionBuilder``s that should be applied to each of the produced observations.
    ///     The ``FHIRExtensionBuilder/sourceDevice-9m1t7``, ``FHIRExtensionBuilder/sourceRevision-8b3xb``, and ``FHIRExtensionBuilder/metadata`` extension builders are always enabled when creating a FHIR `Observation`s from a `HKSample`.
    /// - returns: A `ResourceProxy`containing an FHIR  `Observation` based on the concrete subclass of `HKSample`.
    /// - throws: If a specific `HKSample` type is not supported, or if the sample for some reason cannot be turned into a FHIR resource
    ///     (e.g., because it contains values that cannot be represented using the FHIR types)
    ///
    /// - Important: When mapping an array of HKSample objects into ResourceProxies, for performance reasons always prefer ``Swift/Sequence/mapIntoResourceProxies(using:extensions:)`` or ``Swift/Sequence/mapIntoResourceProxies(using:extensions:)``.
    public func resource(
        withMapping mapping: HKSampleMapping = .default,
        issuedDate: FHIRPrimitive<Instant>? = nil,
        extensions: [any FHIRExtensionBuilderProtocol] = []
    ) throws -> ResourceProxy {
        #if !os(watchOS)
        if let self = self as? HKClinicalRecord {
            // NOTE: this currently completely circumvents the extension builders.
            // might wanna look into possibly fixig that at some point.
            return try self.resource()
        }
        #endif
        var observation = Observation(
            code: CodeableConcept(),
            status: FHIRPrimitive(.final)
        )
        // Set basic elements applicable to all observations
        observation.id = self.uuid.uuidString.asFHIRStringPrimitive()
        observation.append(identifier: Identifier(id: observation.id))
        try observation.setEffective(
            startDate: self.startDate,
            endDate: self.endDate,
            timeZone: self.timeZone ?? .current
        )
        if let issuedDate {
            observation.issued = issuedDate
        } else {
            try observation.setIssued(on: Date())
        }
        if let self = self as? any FHIRObservationBuildable {
            try self.build(&observation, mapping: mapping)
        } else {
            throw HealthKitOnFHIRError.notSupported
        }
        let baseExtensions: [FHIRExtensionBuilder<HKObject>] = [
            .sourceDevice, .sourceRevision, .metadata
        ]
        for builder in baseExtensions + extensions {
            try builder.apply(typeErasedInput: self, to: &observation)
        }
        return ResourceProxy(with: observation)
    }
}


extension Sequence where Element: HKSample {
    /// Produces an Array of FHIR `ResourceProxies`.
    ///
    /// - Note: This method provides significant performance improvements as compared to calling ``HealthKit/HKSample/resource(withMapping:issuedDate:extensions:)`` for each element in the collection.
    ///
    /// - parameter mapping: A mapping to map `HKSample`s to corresponding FHIR observations allowing the customization of, e.g., codings and units. See ``HKSampleMapping``.
    /// - parameter issuedDate: `Instant` specifying when this version of the resource was made available. Defaults to `Date.now`.
    /// - parameter extensions: Any ``FHIRExtensionBuilder``s that should be applied to each of the produced observations.
    ///     The ``FHIRExtensionBuilder/sourceDevice-9m1t7``, ``FHIRExtensionBuilder/sourceRevision-8b3xb``, and ``FHIRExtensionBuilder/metadata`` extension builders are always enabled when creating a FHIR `Observation`s from a `HKSample`.
    public func mapIntoResourceProxies(
        using mapping: HKSampleMapping = .default,
        issuedDate: FHIRPrimitive<Instant>? = nil,
        extensions: [any FHIRExtensionBuilderProtocol] = []
    ) throws -> [ResourceProxy] {
        let issuedDate = try issuedDate ?? FHIRPrimitive<Instant>(try Instant(date: .now))
        return try map { try $0.resource(withMapping: mapping, issuedDate: issuedDate, extensions: extensions) }
    }
    
    /// Produces an Array of FHIR `ResourceProxies`.
    ///
    /// This function is equivalent to calling ``HealthKit/HKSample/resource(withMapping:issuedDate:extensions:)`` on every element in the sequence, and filtering out those elements for which the call raised an error.
    ///
    /// - Note: This method provides significant performance improvements as compared to calling ``HealthKit/HKSample/resource(withMapping:issuedDate:extensions:)`` on each element in the collection.
    ///
    /// - parameter mapping: A mapping to map `HKSample`s to corresponding FHIR observations allowing the customization of, e.g., codings and units. See ``HKSampleMapping``.
    /// - parameter issuedDate: `Instant` specifying when this version of the resource was made available. Defaults to `Date.now`.
    /// - parameter extensions: Any ``FHIRExtensionBuilder``s that should be applied to each of the produced observations.
    ///     The ``FHIRExtensionBuilder/sourceDevice-9m1t7``, ``FHIRExtensionBuilder/sourceRevision-8b3xb``, and ``FHIRExtensionBuilder/metadata`` extension builders are always enabled when creating a FHIR `Observation`s from a `HKSample`.
    public func compactMapIntoResourceProxies(
        using mapping: HKSampleMapping = .default,
        issuedDate: FHIRPrimitive<Instant>? = nil,
        extensions: [any FHIRExtensionBuilderProtocol] = []
    ) throws -> [ResourceProxy] {
        let issuedDate = try issuedDate ?? FHIRPrimitive<Instant>(try Instant(date: .now))
        return compactMap { try? $0.resource(withMapping: mapping, issuedDate: issuedDate, extensions: extensions) }
    }
}
