//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SwiftUI


/// Requirement for every HealthKit Data Source.
public protocol HealthKitDataSource {
    /// The data source's sample type
    var sampleType: HKSampleType { get }
    
    /// Whether the data source is currently active.
    @MainActor
    var isActive: Bool { get }
    
    /// Called after the used was asked for authorization.
    @MainActor
    func askedForAuthorization() async
    
    /// Called to start the automatic data collection.
    @MainActor
    func startAutomaticDataCollection() async
    
    /// Called to trigger the manual data collection.
    @MainActor
    func triggerManualDataSourceCollection() async
}
