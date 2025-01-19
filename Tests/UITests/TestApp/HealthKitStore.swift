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
final class HealthKitStore: Module, DefaultInitializable, EnvironmentAccessible, @unchecked Sendable {
    private enum StorageKeys {
        static let backgroundPersistance = "edu.Stanford.Spezi.SpeziHealthKitHealthKitStore.backgroundPersistance"
    }
    
    // TODO what does this do exactly?
    // TODO rename to disableBackgroundPersistance?!
    static let collectedSamplesOnly = CommandLine.arguments.contains("--collectedSamplesOnly")
    
    private let logger = Logger(subsystem: "TestApp", category: "ExampleStandard")
    
    private(set) var samples: [HKSample] = []
    private(set) var backgroundPersistance: [BackgroundDataCollectionLogEntry] {
        didSet {
            if !HealthKitStore.collectedSamplesOnly {
                let data = try! JSONEncoder().encode(backgroundPersistance)
                UserDefaults.standard.set(data, forKey: StorageKeys.backgroundPersistance)
            }
        }
    }
    
    required init() {
        if !HealthKitStore.collectedSamplesOnly {
            let data = UserDefaults.standard.data(forKey: StorageKeys.backgroundPersistance) ?? Data()
            backgroundPersistance = (try? JSONDecoder().decode([BackgroundDataCollectionLogEntry].self, from: data)) ?? []
        } else {
            backgroundPersistance = []
        }
    }
    
    
    func configure() {
        if !HealthKitStore.collectedSamplesOnly {
            Task {
                try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            }
        }
    }
    
    @MainActor
    func add(sample: HKSample) async {
        logger.debug("Added sample: \(sample.debugDescription)")
        
        samples.append(sample)
        backgroundPersistance.insert(.init(sample), at: 0)
        
        let content = UNMutableNotificationContent()
        content.title = "Spezi HealthKit Test App"
        content.body = "Added sample \(sample.sampleType.description) (\(sample.uuid.uuidString) at \(Date.now.formatted(date: .numeric, time: .complete)): \((sample as? HKQuantitySample)?.quantity.description ?? "Unknown")"
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    @MainActor
    func remove(sample: HKDeletedObject) async {
        logger.debug("Removed sample: \(sample.debugDescription)")
        if let index = samples.firstIndex(where: { $0.uuid == sample.uuid }) {
            samples.remove(at: index)
        }
        backgroundPersistance.insert(.init(sample), at: 0)
        
        let content = UNMutableNotificationContent()
        content.title = "Spezi HealthKit Test App"
        content.body = "Removed sample: \(sample.uuid) at \(Date.now.formatted(date: .numeric, time: .complete))"
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
}



// MARK: Background Persistence

enum BackgroundDataCollectionLogEntry: Codable, Hashable {
    case added(id: UUID, type: String, date: ClosedRange<Date>, quantity: String?)
    case removed(id: UUID)
    
    
    init(_ sample: HKSample) {
        self = .added(
            id: sample.uuid,
            type: sample.sampleType.identifier,
            date: sample.startDate...sample.endDate,
            quantity: (sample as? HKQuantitySample)?.quantity.description
        )
    }
    
    init(_ object: HKDeletedObject) {
        self = .removed(id: object.uuid)
    }
}
