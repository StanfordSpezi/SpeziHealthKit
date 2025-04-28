// 
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import HealthKit
import SpeziHealthKit

/// A circular progress view that displays health data in an Apple Watch style.
///
/// This component provides an animated circular progress indicator that fills based on the
/// current value compared to a target value. It can be customized with different colors, 
/// animations, and display formats.
///
/// Example:
/// ```swift
/// CircularProgressView(
///     value: 8500,
///     target: 10000,
///     metric: "Steps",
///     color: .blue,
///     unit: "steps"
/// )
/// ```
public struct CircularProgressView: View {
    private let value: Double
    private let target: Double
    private let metric: String
    private let color: Color
    private let secondaryColor: Color
    private let unit: String
    private let showAnimation: Bool
    private let lineWidth: CGFloat
    
    @State private var animatedFraction: Double = 0
    
    /// Creates a new circular progress view for health data.
    /// - Parameters:
    ///   - value: Current value of the health metric
    ///   - target: Target value for the health metric
    ///   - metric: Name of the health metric being displayed
    ///   - color: Primary color for the progress ring
    ///   - secondaryColor: Background color for the ring
    ///   - unit: Unit of measurement for display
    ///   - showAnimation: Whether to animate the progress ring on appearance
    ///   - lineWidth: Width of the progress ring
    public init(
        value: Double,
        target: Double,
        metric: String,
        color: Color = .blue,
        secondaryColor: Color = Color.gray.opacity(0.2),
        unit: String = "",
        showAnimation: Bool = true,
        lineWidth: CGFloat = 20
    ) {
        self.value = value
        self.target = target
        self.metric = metric
        self.color = color
        self.secondaryColor = secondaryColor
        self.unit = unit
        self.showAnimation = showAnimation
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(secondaryColor, lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: min(CGFloat(animatedFraction), 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Central content
            VStack {
                Text(metric)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatValue(value))
                    .font(.title)
                    .bold()
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .onAppear {
            if showAnimation {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedFraction = value / target
                }
            } else {
                animatedFraction = value / target
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}

/// Extensions to provide additional initialization options for CircularProgressView
public extension CircularProgressView {
    /// Creates a circular progress view from a health sample
    /// - Parameters:
    ///   - sample: The health kit quantity sample
    ///   - target: Target value for the health metric
    ///   - color: Primary color for the progress ring
    ///   - showAnimation: Whether to animate the progress ring on appearance
    static func from(
        sample: HKQuantitySample,
        target: Double,
        color: Color = .blue,
        showAnimation: Bool = true
    ) -> CircularProgressView {
        // Find the appropriate SampleType based on the HKQuantitySample
        let sampleType: SampleType<HKQuantitySample>?
        
        // Try to determine the sample type based on the identifier
        switch sample.quantityType.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            sampleType = .stepCount
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            sampleType = .heartRate
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
            sampleType = .activeEnergyBurned
        case HKQuantityTypeIdentifier.bloodGlucose.rawValue:
            sampleType = .bloodGlucose
        case HKQuantityTypeIdentifier.oxygenSaturation.rawValue:
            sampleType = .bloodOxygen
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            sampleType = .bodyMass
        default:
            sampleType = nil
        }
        
        let value = sample.quantity.doubleValue(for: sampleType?.displayUnit ?? .count())
        let unit = sampleType?.displayUnit.unitString ?? ""
        let metric = sampleType?.displayTitle ?? sample.quantityType.identifier
        
        return CircularProgressView(
            value: value,
            target: target,
            metric: metric,
            color: color,
            unit: unit,
            showAnimation: showAnimation
        )
    }
}

public struct ActivityRingView: View {
    private let progress: Double
    private let ringWidth: CGFloat
    private let startColor: Color
    private let endColor: Color
    
    @State private var animatedProgress: Double = 0
    
    /// Creates a new activity ring view
    /// - Parameters:
    ///   - progress: Progress from 0 to 1
    ///   - ringWidth: Width of the ring
    ///   - startColor: Start color of the gradient
    ///   - endColor: End color of the gradient
    public init(
        progress: Double,
        ringWidth: CGFloat = 15,
        startColor: Color,
        endColor: Color
    ) {
        self.progress = min(max(progress, 0), 1)
        self.ringWidth = ringWidth
        self.startColor = startColor
        self.endColor = endColor
    }
    
    public var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: ringWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(animatedProgress))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [startColor, endColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(
                        lineWidth: ringWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
        .padding(ringWidth / 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
    }
}

public struct ActivityRingsView: View {
    private let rings: [(progress: Double, colors: (start: Color, end: Color))]
    private let centerContent: AnyView?
    
    /// Creates a new activity rings view with multiple rings
    /// - Parameters:
    ///   - rings: Array of progress values and colors
    ///   - centerContent: Optional content to display in the center
    public init(
        rings: [(progress: Double, colors: (start: Color, end: Color))],
        centerContent: (any View)? = nil
    ) {
        self.rings = rings
        self.centerContent = centerContent.map { AnyView($0) }
    }
    
    public var body: some View {
        ZStack {
            ForEach(0..<rings.count, id: \.self) { index in
                ActivityRingView(
                    progress: rings[index].progress,
                    ringWidth: 15 + CGFloat(1.5 * Double(index)),
                    startColor: rings[index].colors.start,
                    endColor: rings[index].colors.end
                )
                .scaleEffect(1.0 - CGFloat(index) * 0.12)
            }
            
            if let centerContent {
                centerContent
            }
        }
    }
} 