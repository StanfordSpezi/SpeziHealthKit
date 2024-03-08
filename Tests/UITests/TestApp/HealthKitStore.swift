//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@preconcurrency import HealthKit
import OSLog
import Spezi
import UserNotifications


@Observable
class HealthKitStore: Module, DefaultInitializable, EnvironmentAccessible {
    private enum StorageKeys {
        static let backgroundPersistance = "HealthKitStore.backgroundPersistance"
    }
    
    private let logger = Logger(subsystem: "TestApp", category: "ExampleStandard")
    
    private(set) var samples: [HKSample] = []
    private(set) var backgroundPersistance: [String] {
        didSet {
            UserDefaults.standard.setValue(backgroundPersistance.rawValue, forKey: StorageKeys.backgroundPersistance)
        }
    }
    
    required init() {
        backgroundPersistance = UserDefaults.standard.string(forKey: StorageKeys.backgroundPersistance).flatMap { [String].init(rawValue: $0) } ?? []
    }
    
    
    func configure() {
        Task {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        }
    }
    
    func add(sample: HKSample) async {
        samples.append(sample)
        
        logger.debug("Added sample: \(sample.debugDescription)")
        
        backgroundPersistance.append("Added sample \(sample.sampleType.description) (\(sample.uuid.uuidString)) at \(Date.now.formatted(date: .numeric, time: .complete)): \((sample as? HKQuantitySample)?.quantity.description ?? "Unknown")")
        
        let content = UNMutableNotificationContent()
        content.title = "Spezi HealthKit Test App"
        content.body = "Added sample \(sample.sampleType.description) (\(sample.uuid.uuidString) at \(Date.now.formatted(date: .numeric, time: .complete)): \((sample as? HKQuantitySample)?.quantity.description ?? "Unknown")"
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    func remove(sample: HKDeletedObject) async {
        if let index = samples.firstIndex(where: { $0.uuid == sample.uuid }) {
            samples.remove(at: index)
        }
        
        logger.debug("Removed sample: \(sample.debugDescription)")
        
        backgroundPersistance.append("Removed sample: \(sample.uuid) at \(Date.now.formatted(date: .numeric, time: .complete))")
        
        let content = UNMutableNotificationContent()
        content.title = "Spezi HealthKit Test App"
        content.body = "Removed sample: \(sample.uuid) at \(Date.now.formatted(date: .numeric, time: .complete))"
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
