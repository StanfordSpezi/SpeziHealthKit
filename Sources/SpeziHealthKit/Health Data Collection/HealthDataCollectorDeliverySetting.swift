//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Determines the data delivery settings for any ``HealthDataCollector`` used in the HealthKit module.
public enum HealthDataCollectorDeliverySetting: Hashable, Sendable {
    /// The HealthKit data is manually collected when the ``HealthKit/triggerDataSourceCollection()`` function is called.
    case manual(saveAnchor: Bool = true)
    /// The HealthKit data is collected based on the ``Start`` and constantly listens to updates while the application is running.
    /// If `saveAnchor` is enabled the `HKQueryAnchor` is persisted across multiple application launches using the user defaults.
    case continuous(Start = .automatic, saveAnchor: Bool = true)
    /// The HealthKit data is collected based on the ``Start`` and constantly listens to updates even if the application is not running.
    /// If `saveAnchor` is enabled the `HKQueryAnchor` is persisted across multiple application launches using the user defaults.
    case background(Start = .automatic, saveAnchor: Bool = true)
    
    var saveAnchor: Bool {
        switch self {
        case .manual(let saveAnchor), .continuous(_, let saveAnchor), .background(_, let saveAnchor):
            saveAnchor
        }
    }
    
    var isAutomatic: Bool {
        switch self {
        case .continuous(.automatic, _), .background(.automatic, _):
            true
        case .manual, .continuous(.manual, _), .background(.manual, _):
            false
        }
    }
    
    var isManual: Bool {
        !isAutomatic
    }
}


extension HealthDataCollectorDeliverySetting {
    /// :nodoc:
    @_documentation(visibility: internal)
    @available(*, unavailable, renamed: "manual(saveAnchor:)")
    public static func manual(safeAnchor saveAnchor: Bool) -> Self {
        .manual(saveAnchor: saveAnchor)
    }
    
    /// :nodoc:
    @_documentation(visibility: internal)
    @available(*, unavailable, renamed: "continuous(_:saveAnchor:)")
    public static func anchorQuery(_ start: Start = .automatic, saveAnchor: Bool = true) -> Self {
        .continuous(start, saveAnchor: saveAnchor)
    }
}


extension HealthDataCollectorDeliverySetting {
    /// Determines when a ``HealthDataCollector`` is started.
    public enum Start: Hashable, Sendable {
        /// The delivery is started the first time the ``HealthKit/triggerDataSourceCollection()`` function is called.
        case manual
        /// The delivery is started automatically after the user provided authorization and the application has launched.
        /// You can request authorization using the ``HealthKit/askForAuthorization()`` function.
        case automatic
        
        /// Legacy delivery setting, start after initialization
        @available(
            *,
             deprecated,
             renamed: "automatic",
             message:
        """
        Please use `.automatic`.
        """
        )
        @_documentation(visibility: internal)
        public static let afterAuthorizationAndApplicationWillLaunch: Self = .automatic
        // swiftlint:disable:previous identifier_name
        // We use a name longer than 40 characters to indicate the full depth of this setting.
    }
}
