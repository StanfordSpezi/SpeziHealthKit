//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension HKSample {
    /// Gets the `TimeZone` from the sample's metadata if available
    /// - Returns: A `TimeZone` if the metadata contains a valid HKMetadataKeyTimeZone value, otherwise nil
    internal var timeZone: TimeZone? {
        guard let timeZoneIdentifier = metadata?[HKMetadataKeyTimeZone] as? String else {
            return nil
        }
        return TimeZone(identifier: timeZoneIdentifier)
    }
}
