//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Defines the data delivery settings for any ``HealthDataCollector`` used in the HealthKit module.
public struct HealthDataCollectorDeliverySetting: Hashable, Sendable {
    /// When the data collection should start.
    public let startSetting: Start
    /// Whether the data collection should continue in the background, i.e. when the app is not running.
    public let continueInBackground: Bool
}


extension HealthDataCollectorDeliverySetting {
    /// Defines when a ``HealthDataCollector`` is started.
    public enum Start: Hashable, Sendable {
        /// The delivery is started the first time the ``HealthKit/triggerDataSourceCollection()`` function is called.
        case manual
        /// The delivery is started automatically after the user provided authorization and the application has launched.
        /// You can request authorization using the ``HealthKit/askForAuthorization()`` function.
        case automatic
    }
}
