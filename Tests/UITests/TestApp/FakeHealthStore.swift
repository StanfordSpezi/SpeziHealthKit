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
import SpeziFoundation
import UserNotifications


@Observable
final class FakeHealthStore: Module, DefaultInitializable, EnvironmentAccessible, @unchecked Sendable {
    private enum StorageKeys {
        static let backgroundPersistance = "edu.Stanford.Spezi.SpeziHealthKitHealthKitStore.backgroundPersistance"
    }
    
    // maybe rename to disableBackgroundPersistance?!
    static let collectedSamplesOnly = CommandLine.arguments.contains("--collectedSamplesOnly")
    
    private let logger = Logger(subsystem: "TestApp", category: "ExampleStandard")
    
    private(set) var samples: [HKSample] = []
    private(set) var backgroundPersistance: [BackgroundDataCollectionLogEntry] {
        didSet {
            if !FakeHealthStore.collectedSamplesOnly {
                let data = try! JSONEncoder().encode(backgroundPersistance) // swiftlint:disable:this force_try
                UserDefaults.standard.set(data, forKey: StorageKeys.backgroundPersistance)
            }
        }
    }
    
    required init() {
        if !FakeHealthStore.collectedSamplesOnly {
            let data = UserDefaults.standard.data(forKey: StorageKeys.backgroundPersistance) ?? Data()
            backgroundPersistance = (try? JSONDecoder().decode([BackgroundDataCollectionLogEntry].self, from: data)) ?? []
        } else {
            backgroundPersistance = []
        }
    }
    
    
    func configure() {
        if !FakeHealthStore.collectedSamplesOnly {
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
        content.body = Array<String> { // swiftlint:disable:this syntactic_sugar
            "Added sample \(sample.sampleType.identifier)"
            if let sample = sample as? HKQuantitySample {
                sample.quantity.description
            } else {
                #"¯\_(ツ)_/¯"#
            }
            if sample.startDate == sample.endDate {
                sample.startDate.formatted(.iso8601)
            } else {
                let start = sample.startDate.formatted(.iso8601)
                let end = sample.endDate.formatted(.iso8601)
                "\(start) – \(end)"
            }
            sample.uuid.uuidString
        }.joined(separator: " ")
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
