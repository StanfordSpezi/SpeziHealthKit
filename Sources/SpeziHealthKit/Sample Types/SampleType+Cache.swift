//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziFoundation


@usableFromInline
enum SampleTypeCache {
    private static let lock = RecursiveRWLock()
    nonisolated(unsafe) private static var cachedSampleTypes: [String: any AnySampleType] = [:]
    
    @usableFromInline
    static func get<Sample>(
        identifier: String,
        as _: SampleType<Sample>.Type,
        default makeSampleType: @autoclosure () -> SampleType<Sample>
    ) -> SampleType<Sample> {
        lock.withWriteLock {
            if let sampleType = cachedSampleTypes[identifier] {
                // could also do an unsafeBitCast here, but this feels better.
                return sampleType as! SampleType<Sample> // swiftlint:disable:this force_cast
            } else {
                let sampleType = makeSampleType()
                cachedSampleTypes[identifier] = sampleType
                return sampleType
            }
        }
    }
}
