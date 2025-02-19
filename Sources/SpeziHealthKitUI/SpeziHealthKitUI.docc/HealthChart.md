# ``HealthChart``

<!--
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
-->

Visualize queried Health data using a chart.

## Overview

Health samples obtained via a ``HealthKitQuery`` or statistics obtained via a ``HealthKitStatisticsQuery`` can be visualized using the `HealthChart`.

A ``HealthChart`` is populated via the ``HealthChartEntry`` type.
Each entry in a chart manages one data set which should be displayed.
Typically, you probably will want to display only a single [`SampleType`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/sampletype) in a chart

### Example: Visualising Blood Oxygen Samples

Use the ``HealthKitQuery`` and ``HealthKitStatisticsQuery`` property wrappers to fetch Health data for a [`SampleType`](https://swiftpackageindex.com/stanfordspezi/spezihealthkit/documentation/spezihealthkit/sampletype) within your view.
You then use the property wrapper's `projectedValue` to populate the chart with 

```swift
@HealthKitQuery(.bloodOxygen, timeRange: .week)
var bloodOxygenSamples

var body: some View {
    HealthChart {
        HealthChartEntry($bloodOxygenSamples, drawingConfig: .init(mode: .line, color: .blue))
    }
}
```

## Topics

### Creating a HealthChart
- ``HealthChart/init(timeInterval:_:)``

### Supporting Types
- ``HealthChartEntry``
- ``HealthChart/ContentBuilder``
- ``HealthChartDataPoint``
- ``HealthChart/TimeIntervalInput``
- ``StatisticsAggregationOption``
- ``HealthChartDrawingConfig``

