//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A class conforming to `DataProvider` fetches the data from a data store in the form of `DataPoint`s.
public protocol DataProvider: Sendable {
    associatedtype QueryBuilder
    
    func fetchData(for measurementType: MeasurementType, in interval: DateInterval) async throws -> [DataPoint]
}
