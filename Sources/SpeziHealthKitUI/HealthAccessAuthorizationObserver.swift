//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@_spi(APISupport) import SpeziHealthKit
import SwiftUI


@propertyWrapper
struct HealthAccessAuthorizationObserver: DynamicProperty {
    @Observable
    fileprivate final class Storage: @unchecked Sendable {
        final class ActionBox {
            var imp: @Sendable () async -> Void
            init(_ imp: @escaping @Sendable () async -> Void) {
                self.imp = imp
            }
        }
        final class Entry {
            let task: Task<Void, Never>
            let action: ActionBox
            init(task: Task<Void, Never>, action: ActionBox) {
                self.task = task
                self.action = action
            }
        }
        
        @ObservationIgnored var entries: [HealthKit.DataAccessRequirements: Entry] = [:]
        nonisolated init() {}
        deinit {
            // not sure who else is retaining the tasks, but we need to explicitly cancel them here for some reason...
            for (_, entry) in entries {
                entry.task.cancel()
            }
        }
    }
    
    @Environment(HealthKit.self) private var healthKit
    @State private var storage = Storage()
    
    var wrappedValue: Self {
        self
    }
    
    init() {}
    
    @MainActor
    func observeAuthorizationChanges(for accessReqs: HealthKit.DataAccessRequirements, _ handler: @escaping @Sendable () async -> Void) {
        if let entry = storage.entries[accessReqs] {
            entry.action.imp = handler
        } else {
            let actionBox = Storage.ActionBox(handler)
            let task = Task { [healthKit, actionBox] in
                let stream = healthKit.observeAuthenticationEvents(matching: accessReqs)
                for await _ in stream {
                    await actionBox.imp()
                }
            }
            let entry = Storage.Entry(task: task, action: actionBox)
            storage.entries[accessReqs] = entry
        }
    }
}
