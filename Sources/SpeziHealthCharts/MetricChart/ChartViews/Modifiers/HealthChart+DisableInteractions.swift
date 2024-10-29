//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension HealthChart {
    public func disable(interactions: HealthChartInteractions) {
        self.disabledInteractions = interactions
    }
}
