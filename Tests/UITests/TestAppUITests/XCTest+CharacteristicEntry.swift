//
// This source file is part of the Stanford XCTHealthKit open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// NOTE: it might be a good idea to move this into XCTHealthKit at some point.


import HealthKit
import XCTest
import XCTHealthKit


/// Characteristics whoch should be entered into the health app.
public struct CharacteristicsDefinition {
    /// The blood type that should be entered, if any.
    ///
    /// Specifying `nil` will cause this field to get skipped; the current value will remain unchanged.
    public let bloodType: HKBloodType?
    
    /// The date of birth that should be entered, if any.
    ///
    /// Specifying `nil` will cause this field to get skipped; the current value will remain unchanged.
    public let dateOfBirth: DateComponents?
    
    /// The biological sex that should be entered, if any.
    ///
    /// Specifying `nil` will cause this field to get skipped; the current value will remain unchanged.
    public let biologicalSex: HKBiologicalSex?
    
    /// The skin type that should be entered, if any.
    ///
    /// Specifying `nil` will cause this field to get skipped; the current value will remain unchanged.
    public let skinType: HKFitzpatrickSkinType?
    
    /// The wheelchair use that should be entered, if any.
    ///
    /// Specifying `nil` will cause this field to get skipped; the current value will remain unchanged.
    public let wheelchairUse: HKWheelchairUse?
    
    /// Creates a new characteristics input definition object
    public init(
        bloodType: HKBloodType? = nil,
        dateOfBirth: DateComponents? = nil,
        biologicalSex: HKBiologicalSex? = nil,
        skinType: HKFitzpatrickSkinType? = nil,
        wheelchairUse: HKWheelchairUse? = nil
    ) {
        self.bloodType = bloodType
        self.dateOfBirth = dateOfBirth
        self.biologicalSex = biologicalSex
        self.skinType = skinType
        self.wheelchairUse = wheelchairUse
    }
}


extension XCTestCase {
    private static let monthNames = [
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ]
    private static func monthName(for value: Int) -> String {
        monthNames[value - 1]
    }
    
    /// Launches the Health app and enters the specified characteristics entries.
    @MainActor
    public func launchHealthAppAndEnterCharacteristics( // swiftlint:disable:this function_body_length cyclomatic_complexity
        _ characteristics: CharacteristicsDefinition
    ) throws {
        let healthApp = XCUIApplication.healthApp
        healthApp.launch()
        handleHealthAppOnboardingIfNecessary(healthApp)
        
        XCTAssert(healthApp.buttons["Profile"].waitForExistence(timeout: 2))
        healthApp.buttons["Profile"].tryToTapReallySoftlyMaybeThisWillMakeItWork()
        healthApp.cells["Health Details"].tap()
        healthApp.navigationBars["Health Details"].buttons["Edit"].tap()
        
        if let dateOfBirth = characteristics.dateOfBirth {
            healthApp.cells["Date of Birth"].tap()
            let picker = healthApp.pickers.firstMatch
            XCTAssert(picker.waitForExistence(timeout: 2))
            // This is far from perfect (we're looking at the locale of the test runner, rather than the simulator/device,
            // which could be completely different, but it's the best we've got.
            let pickerWheelsMapping: [Calendar.Component: Int]
            switch Locale.current.identifier {
            case "en_US":
                pickerWheelsMapping = [.month: 0, .day: 1, .year: 2]
            default:
                // If we're not running in the en_US locale, we just assume day/month/year
                pickerWheelsMapping = [.day: 0, .month: 1, .year: 2]
            }
            if let month = dateOfBirth.month {
                picker.pickerWheels
                    .element(boundBy: try XCTUnwrap(pickerWheelsMapping[.month]))
                    .adjust(toPickerWheelValue: Self.monthName(for: month))
            }
            if let day = dateOfBirth.day {
                picker.pickerWheels
                    .element(boundBy: try XCTUnwrap(pickerWheelsMapping[.day]))
                    .adjust(toPickerWheelValue: String(day))
            }
            if let year = dateOfBirth.year {
                picker.pickerWheels
                    .element(boundBy: try XCTUnwrap(pickerWheelsMapping[.year]))
                    .adjust(toPickerWheelValue: String(year))
            }
            healthApp.cells["Date of Birth"].tap()
        }
        
        if let biologicalSex = characteristics.biologicalSex {
            healthApp.cells["Sex"].tap()
            let picker = healthApp.pickers.firstMatch.pickerWheels.firstMatch
            switch biologicalSex {
            case .notSet:
                picker.adjust(toPickerWheelValue: "")
            case .male:
                picker.adjust(toPickerWheelValue: "Male")
            case .female:
                picker.adjust(toPickerWheelValue: "Female")
            case .other:
                picker.adjust(toPickerWheelValue: "Other")
            @unknown default:
                XCTFail("Unhandled biological sex value: \(biologicalSex)")
            }
            healthApp.cells["Sex"].tap()
        }
        
        if let bloodType = characteristics.bloodType {
            healthApp.cells["Blood Type"].tap()
            let picker = healthApp.pickers.firstMatch.pickerWheels.firstMatch
            switch bloodType {
            case .notSet:
                picker.adjust(toPickerWheelValue: "")
            case .aPositive:
                picker.adjust(toPickerWheelValue: "A+")
            case .aNegative:
                picker.adjust(toPickerWheelValue: "A-")
            case .bPositive:
                picker.adjust(toPickerWheelValue: "B+")
            case .bNegative:
                picker.adjust(toPickerWheelValue: "B-")
            case .abPositive:
                picker.adjust(toPickerWheelValue: "AB+")
            case .abNegative:
                picker.adjust(toPickerWheelValue: "AB-")
            case .oPositive:
                picker.adjust(toPickerWheelValue: "O+")
            case .oNegative:
                picker.adjust(toPickerWheelValue: "O-")
            @unknown default:
                XCTFail("Unhandled blood type value: \(bloodType)")
            }
            healthApp.cells["Blood Type"].tap()
        }
        
        if let skinType = characteristics.skinType {
            healthApp.cells["Fitzpatrick Skin Type"].tap()
            let picker = healthApp.pickers.firstMatch.pickerWheels.firstMatch
            switch skinType {
            case .notSet:
                picker.adjust(toPickerWheelValue: "")
            case .I:
                picker.adjust(toPickerWheelValue: "Type I")
            case .II:
                picker.adjust(toPickerWheelValue: "Type II")
            case .III:
                picker.adjust(toPickerWheelValue: "Type III")
            case .IV:
                picker.adjust(toPickerWheelValue: "Type IV")
            case .V:
                picker.adjust(toPickerWheelValue: "Type V")
            case .VI:
                picker.adjust(toPickerWheelValue: "Type VI")
            @unknown default:
                XCTFail("Unhandled skin type value: \(skinType)")
            }
            healthApp.cells["Fitzpatrick Skin Type"].tap()
        }
        
        if let wheelchairUse = characteristics.wheelchairUse {
            healthApp.cells["Wheelchair"].tap()
            let picker = healthApp.pickers.firstMatch.pickerWheels.firstMatch
            switch wheelchairUse {
            case .notSet:
                picker.adjust(toPickerWheelValue: "")
            case .no:
                picker.adjust(toPickerWheelValue: "No")
            case .yes:
                picker.adjust(toPickerWheelValue: "Yes")
            @unknown default:
                XCTFail("Unhandled wheelchair use value: \(wheelchairUse)")
            }
            healthApp.cells["Wheelchair"].tap()
        }
        
        healthApp.navigationBars["Health Details"].buttons["Done"].tap()
        healthApp.navigationBars["Health Details"].buttons["Profile"].tap()
        healthApp.navigationBars.firstMatch.buttons["Done"].tap()
    }
}


extension XCUIElement {
    func tryToTapReallySoftlyMaybeThisWillMakeItWork() {
        if isHittable {
            tap()
        } else {
            coordinate(withNormalizedOffset: .zero).tap()
        }
    }
}
