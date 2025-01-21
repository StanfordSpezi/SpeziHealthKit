# ``HealthChart``

Visualize queried Health data using a chart.

## Overview

Health samples obtained via a ``HealthKitQuery`` or statistics obtained via a ``HealthKitStatisticsQuery`` can be visualized using the `HealthChart`.

A ``HealthChart`` is populated via the ``HealthChartEntry`` type.
Each entry in a chart manages one data set which should be displayed.
Typically, you probably will want to display only a single ``SampleType`` in a chart

### Example: Visualising Blood Oxygen Samples

Use the ``HealthKitQuery`` and ``HealthKitStatisticsQuery`` property wrappers to fetch Health data for a ``SampleType`` within your view.
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
- ``HealthChart/init(interactivity:timeInterval:_:)``

### Interactivity
- ``HealthChart/makeInteractive(selection:enabledGranularities:)``

### Supporting Types
- ``HealthChartEntry``
- ``HealthChartContentBuilder``
- ``HealthChartDataPoint``
- ``HealthChartInteractivity``
- ``HealthChartTimeIntervalInput``
- ``StatisticsAggregationOption``
- ``HealthChartDrawingConfig``
- ``HealthChartGranularity``

