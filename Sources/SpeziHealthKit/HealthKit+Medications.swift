//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(HealthKit)

import Foundation
import HealthKit


extension HealthKit {
    /// Prompts the user to select which medications the app may read, which also grants access to their ``SampleType/medicationDoseEvent`` samples.
    ///
    /// - parameter predicate: Restricts which medications are presented to the user.
    /// - Important: HealthKit always presents its selection UI, even if the user already responded to a previous request.
    @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
    @available(watchOS, unavailable)
    @MainActor
    public func askForMedicationsAuthorization(predicate: NSPredicate? = nil) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        try await healthStore.requestPerObjectReadAuthorization(for: .userAnnotatedMedicationType(), predicate: predicate)
        notifyMedicationsAuthorizationObservers()
    }
}

#endif
