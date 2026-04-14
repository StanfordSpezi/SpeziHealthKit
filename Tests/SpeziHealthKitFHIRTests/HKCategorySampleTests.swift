//
// This source file is part of the HealthKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
@testable import SpeziHealthKitFHIR
import ModelsR4
import Testing


// swiftlint:disable file_length type_body_length
@MainActor // to work around https://github.com/apple/FHIRModels/issues/36
struct HKCategorySampleTests {
    var startDate: Date {
        get throws {
            let dateComponents = DateComponents(year: 1891, month: 10, day: 1, hour: 12, minute: 0, second: 0) // Date Stanford University opened (https://www.stanford.edu/about/history/)
            return try #require(Calendar.current.date(from: dateComponents))
        }
    }

    var endDate: Date {
        get throws {
            let dateComponents = DateComponents(year: 1891, month: 10, day: 1, hour: 12, minute: 0, second: 42)
            return try #require(Calendar.current.date(from: dateComponents))
        }
    }

    
    func createObservationFrom(
        type categoryType: HKCategoryTypeIdentifier,
        value: Int,
        metadata: [String: Any] = [:]
    ) throws -> Observation {
        let categorySample = HKCategorySample(
            type: HKCategoryType(categoryType),
            value: value,
            start: try startDate,
            end: try endDate,
            metadata: metadata
        )
        return try #require(categorySample.resource().get(if: Observation.self))
    }

    func createCategoryCoding(
        categoryType: HKCategoryTypeIdentifier,
        display: String
    ) -> Coding {
        Coding(
            code: FHIRPrimitive(stringLiteral: categoryType.rawValue),
            display: FHIRPrimitive(stringLiteral: display),
            system: FHIRPrimitive(FHIRURI(stringLiteral: SupportedCodeSystem.apple.rawValue))
        )
    }

    
    @Test(arguments: [
        (HKCategoryValueCervicalMucusQuality.dry, "1", "dry"),
        (HKCategoryValueCervicalMucusQuality.sticky, "2", "sticky"),
        (HKCategoryValueCervicalMucusQuality.creamy, "3", "creamy"),
        (HKCategoryValueCervicalMucusQuality.watery, "4", "watery"),
        (HKCategoryValueCervicalMucusQuality.eggWhite, "5", "egg white")
    ])
    func cervicalMucusQuality(value: HKCategoryValueCervicalMucusQuality, expectedCode: String, expectedDisplay: String) throws {
        let system: FHIRPrimitive<FHIRURI> = "https://developer.apple.com/documentation/healthkit/hkcategoryvaluecervicalmucusquality"
        let observation = try createObservationFrom(
            type: .cervicalMucusQuality,
            value: value.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .cervicalMucusQuality,
            display: "Cervical Mucus Quality"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: expectedCode.asFHIRStringPrimitive(),
                display: expectedDisplay.asFHIRStringPrimitive(),
                system: system
            )
        ])))
    }

    @Test(arguments: [
        (HKCategoryValueMenstrualFlow.unspecified, "1", "unspecified"),
        (HKCategoryValueMenstrualFlow.light, "2", "light"),
        (HKCategoryValueMenstrualFlow.medium, "3", "medium"),
        (HKCategoryValueMenstrualFlow.heavy, "4", "heavy"),
        (HKCategoryValueMenstrualFlow.none, "5", "none")
    ])
    func menstrualFlow(value: HKCategoryValueMenstrualFlow, expectedCode: String, expectedDisplay: String) throws {
        let system: FHIRPrimitive<FHIRURI> = "https://developer.apple.com/documentation/healthkit/hkcategoryvaluemenstrualflow"
        let observation = try createObservationFrom(
            type: .menstrualFlow,
            value: value.rawValue,
            metadata: [HKMetadataKeyMenstrualCycleStart: true]
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .menstrualFlow,
            display: "Menstrual Flow"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: expectedCode.asFHIRStringPrimitive(),
                display: expectedDisplay.asFHIRStringPrimitive(),
                system: system
            )
        ])))
    }

    @Test(arguments: [
        (HKCategoryValueOvulationTestResult.negative, "1", "negative"),
        (HKCategoryValueOvulationTestResult.luteinizingHormoneSurge, "2", "luteinizing hormone surge"),
        (HKCategoryValueOvulationTestResult.indeterminate, "3", "indeterminate"),
        (HKCategoryValueOvulationTestResult.estrogenSurge, "4", "estrogen surge")
    ])
    func ovulationTestResult(value: HKCategoryValueOvulationTestResult, expectedCode: String, expectedDisplay: String) throws {
        let system: FHIRPrimitive<FHIRURI> = "https://developer.apple.com/documentation/healthkit/hkcategoryvalueovulationtestresult"
        let observation = try createObservationFrom(
            type: .ovulationTestResult,
            value: value.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .ovulationTestResult,
            display: "Ovulation Test Result"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: expectedCode.asFHIRStringPrimitive(),
                display: expectedDisplay.asFHIRStringPrimitive(),
                system: system
            )
        ])))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        print(String(decoding: try encoder.encode(observation), as: UTF8.self))
    }

    @Test(arguments: [
        (HKCategoryValueContraceptive.unspecified, "1", "unspecified"),
        (HKCategoryValueContraceptive.implant, "2", "implant"),
        (HKCategoryValueContraceptive.injection, "3", "injection"),
        (HKCategoryValueContraceptive.intrauterineDevice, "4", "intrauterine device"),
        (HKCategoryValueContraceptive.intravaginalRing, "5", "intravaginal ring"),
        (HKCategoryValueContraceptive.oral, "6", "oral"),
        (HKCategoryValueContraceptive.patch, "7", "patch")
    ])
    func contraceptive(value: HKCategoryValueContraceptive, expectedCode: String, expectedDisplay: String) throws {
        let system: FHIRPrimitive<FHIRURI> = "https://developer.apple.com/documentation/healthkit/hkcategoryvaluecontraceptive"
        let observation = try createObservationFrom(
            type: .contraceptive,
            value: value.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .contraceptive,
            display: "Contraceptive"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: expectedCode.asFHIRStringPrimitive(),
                display: expectedDisplay.asFHIRStringPrimitive(),
                system: system
            )
        ])))
    }

    @Test(arguments: [
        (HKCategoryValueSleepAnalysis.inBed, "0", "in bed"),
        (HKCategoryValueSleepAnalysis.asleepUnspecified, "1", "asleep unspecified"),
        (HKCategoryValueSleepAnalysis.awake, "2", "awake"),
        (HKCategoryValueSleepAnalysis.asleepCore, "3", "asleep core"),
        (HKCategoryValueSleepAnalysis.asleepDeep, "4", "asleep deep"),
        (HKCategoryValueSleepAnalysis.asleepREM, "5", "asleep REM")
    ])
    func sleepAnalysis(value: HKCategoryValueSleepAnalysis, expectedCode: String, expectedDisplay: String) throws {
        let system: FHIRPrimitive<FHIRURI> = "https://developer.apple.com/documentation/healthkit/hkcategoryvaluesleepanalysis"
        let observation = try createObservationFrom(
            type: .sleepAnalysis,
            value: value.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .sleepAnalysis,
            display: "Sleep Analysis"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: expectedCode.asFHIRStringPrimitive(),
                display: expectedDisplay.asFHIRStringPrimitive(),
                system: system
            )
        ])))
    }

    @Test(arguments: [
        (HKCategoryValueAppetiteChanges.unspecified, "0", "unspecified"),
        (HKCategoryValueAppetiteChanges.noChange, "1", "no change"),
        (HKCategoryValueAppetiteChanges.decreased, "2", "decreased"),
        (HKCategoryValueAppetiteChanges.increased, "3", "increased")
    ])
    func appetiteChanges(value: HKCategoryValueAppetiteChanges, expectedCode: String, expectedDisplay: String) throws {
        let system: FHIRPrimitive<FHIRURI> = "https://developer.apple.com/documentation/healthkit/hkcategoryvalueappetitechanges"
        let observation = try createObservationFrom(
            type: .appetiteChanges,
            value: value.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .appetiteChanges,
            display: "Appetite Changes"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: expectedCode.asFHIRStringPrimitive(),
                display: expectedDisplay.asFHIRStringPrimitive(),
                system: system
            )
        ])))
    }

    @Test
    func environmentalAudioExposureEvent() throws {
        let observation = try createObservationFrom(
            type: .environmentalAudioExposureEvent,
            value: HKCategoryValueEnvironmentalAudioExposureEvent.momentaryLimit.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .environmentalAudioExposureEvent,
            display: "Environmental Audio Exposure Event"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: "1".asFHIRStringPrimitive(),
                display: "momentary limit".asFHIRStringPrimitive(),
                system: "https://developer.apple.com/documentation/healthkit/hkcategoryvalueenvironmentalaudioexposureevent".asFHIRURIPrimitive()
            )
        ])))
    }

    @Test
    func headphoneAudioExposureEvent() throws {
        let observation = try createObservationFrom(
            type: .headphoneAudioExposureEvent,
            value: HKCategoryValueHeadphoneAudioExposureEvent.sevenDayLimit.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .headphoneAudioExposureEvent,
            display: "Headphone Audio Exposure Event"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: "1".asFHIRStringPrimitive(),
                display: "seven day limit".asFHIRStringPrimitive(),
                system: "https://developer.apple.com/documentation/healthkit/hkcategoryvalueheadphoneaudioexposureevent".asFHIRURIPrimitive()
            )
        ])))
    }

    @Test
    func lowCardioFitnessEvent() throws {
        let observation = try createObservationFrom(
            type: .lowCardioFitnessEvent,
            value: HKCategoryValueLowCardioFitnessEvent.lowFitness.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .lowCardioFitnessEvent,
            display: "Low Cardio Fitness Event"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: "1".asFHIRStringPrimitive(),
                display: "low fitness".asFHIRStringPrimitive(),
                system: "https://developer.apple.com/documentation/healthkit/hkcategoryvaluelowcardiofitnessevent".asFHIRURIPrimitive()
            )
        ])))
    }
    
    @Test
    func lowCardioFitnessEventWithMetadata() throws {
        let observation = try createObservationFrom(
            type: .lowCardioFitnessEvent,
            value: HKCategoryValueLowCardioFitnessEvent.lowFitness.rawValue,
            metadata: [
                HKMetadataKeyLowCardioFitnessEventThreshold: HKQuantity(unit: HKUnit(from: "ml/(kg*min)"), doubleValue: 41)
            ]
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .lowCardioFitnessEvent,
            display: "Low Cardio Fitness Event"
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: "1".asFHIRStringPrimitive(),
                display: "low fitness".asFHIRStringPrimitive(),
                system: "https://developer.apple.com/documentation/healthkit/hkcategoryvaluelowcardiofitnessevent".asFHIRURIPrimitive()
            )
        ])))
        #expect(observation.component?.count == 1)
        let component = try #require(observation.component?.first)
        #expect(component.code.coding == [
            Coding(
                code: "HKQuantityTypeIdentifierVO2Max".asFHIRStringPrimitive(),
                display: "VO2 Max".asFHIRStringPrimitive(),
                system: SupportedCodeSystem.apple.rawValue.asFHIRURIPrimitive()
            )
        ])
        #expect(component.value == .quantity(Quantity(
            code: "mL/kg/min",
            system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
            unit: "mL/kg/min",
            value: 41.asFHIRDecimalPrimitive()
        )))
    }

    @Test
    func appleWalkingSteadinessEvent() throws {
        let values: [HKCategoryValueAppleWalkingSteadinessEvent] = [.initialLow, .initialVeryLow, .repeatLow, .repeatVeryLow]
        for value in values {
            let observation = try createObservationFrom(
                type: .appleWalkingSteadinessEvent,
                value: value.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: .appleWalkingSteadinessEvent,
                display: "Apple Walking Steadiness Event"
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
                Coding(
                    code: value.code.asFHIRStringPrimitive(),
                    display: try #require(value.display).asFHIRStringPrimitive(),
                    system: type(of: value).system
                )
            ])))
        }
    }

    @Test
    func appleWalkingSteadinessClassification() {
        let okClassification = HKAppleWalkingSteadinessClassification(
            rawValue: HKAppleWalkingSteadinessClassification.ok.rawValue
        )?.display
        #expect(okClassification == "ok")

        let lowClassification = HKAppleWalkingSteadinessClassification(
            rawValue: HKAppleWalkingSteadinessClassification.low.rawValue
        )?.display
        #expect(lowClassification == "low")

        let veryLowClassification = HKAppleWalkingSteadinessClassification(
            rawValue: HKAppleWalkingSteadinessClassification.veryLow.rawValue
        )?.display
        #expect(veryLowClassification == "very low")
    }
    
    @Test(arguments: [
        (HKCategoryTypeIdentifier.lowHeartRateEvent, "Low Heart Rate Event"),
        (HKCategoryTypeIdentifier.highHeartRateEvent, "High Heart Rate Event")
    ])
    func lowHeartRateEvent(category: HKCategoryTypeIdentifier, displayTitle: String) throws {
        let observation = try createObservationFrom(
            type: category,
            value: HKCategoryValue.notApplicable.rawValue,
            metadata: [
                HKMetadataKeyHeartRateEventThreshold: HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 47)
            ]
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: category,
            display: displayTitle
        ))
        #expect(observation.value == .string(category.rawValue.asFHIRStringPrimitive()))
        #expect(observation.component?.count == 1)
        let component = try #require(observation.component?.first)
        #expect(component.code.coding == [
            Coding(
                code: "8867-4".asFHIRStringPrimitive(),
                display: "Heart rate".asFHIRStringPrimitive(),
                system: SupportedCodeSystem.loinc.rawValue.asFHIRURIPrimitive()
            ),
            Coding(
                code: "HKQuantityTypeIdentifierHeartRate".asFHIRStringPrimitive(),
                display: "Heart Rate".asFHIRStringPrimitive(),
                system: SupportedCodeSystem.apple.rawValue.asFHIRURIPrimitive()
            )
        ])
        #expect(component.value == .quantity(Quantity(
            code: "/min",
            system: "http://unitsofmeasure.org".asFHIRURIPrimitive(),
            unit: "beats/minute",
            value: 47.asFHIRDecimalPrimitive()
        )))
    }

    @Test
    func pregnancyTestResult() throws {
        let values: [HKCategoryValuePregnancyTestResult] = [.negative, .positive, .indeterminate]
        for value in values {
            let observation = try createObservationFrom(
                type: .pregnancyTestResult,
                value: value.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: .pregnancyTestResult,
                display: "Pregnancy Test Result"
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
                Coding(
                    code: value.code.asFHIRStringPrimitive(),
                    display: try #require(value.display).asFHIRStringPrimitive(),
                    system: type(of: value).system
                )
            ])))
        }
    }
    
    @Test
    func pregnancy() throws {
        let observation = try createObservationFrom(
            type: .pregnancy,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .pregnancy,
            display: "Pregnancy"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierPregnancy".asFHIRStringPrimitive()))
    }

    @Test
    func progesteroneTestResult() throws {
        let values: [HKCategoryValueProgesteroneTestResult] = [.indeterminate, .positive, .negative]
        for value in values {
            let observation = try createObservationFrom(
                type: .progesteroneTestResult,
                value: value.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: .progesteroneTestResult,
                display: "Progesterone Test Result"
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
                Coding(
                    code: value.code.asFHIRStringPrimitive(),
                    display: try #require(value.display).asFHIRStringPrimitive(),
                    system: type(of: value).system
                )
            ])))
        }
    }
    
    @Test
    func sexualActivityNoMetadata() throws {
        let observation = try createObservationFrom(
            type: .sexualActivity,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .sexualActivity,
            display: "Sexual Activity"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierSexualActivity".asFHIRStringPrimitive()))
        #expect(observation.component == nil)
    }
    
    @Test
    func sexualActivityWithMetadata1() throws {
        let observation = try createObservationFrom(
            type: .sexualActivity,
            value: HKCategoryValue.notApplicable.rawValue,
            metadata: [
                HKMetadataKeySexualActivityProtectionUsed: true
            ]
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .sexualActivity,
            display: "Sexual Activity"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierSexualActivity".asFHIRStringPrimitive()))
        #expect(observation.component?.count == 1)
        #expect(observation.component?.first?.value == .boolean(true))
    }
    
    @Test
    func sexualActivityWithMetadata2() throws {
        let observation = try createObservationFrom(
            type: .sexualActivity,
            value: HKCategoryValue.notApplicable.rawValue,
            metadata: [
                HKMetadataKeySexualActivityProtectionUsed: false
            ]
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .sexualActivity,
            display: "Sexual Activity"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierSexualActivity".asFHIRStringPrimitive()))
        #expect(observation.component?.count == 1)
        #expect(observation.component?.first?.value == .boolean(false))
    }

    @Test
    func appleStandHour() throws {
        struct TestCase {
            let input: HKCategoryValueAppleStandHour
            let expectedOutput: Coding
        }
        let tests: [TestCase] = [
            .init(input: .stood, expectedOutput: Coding(
                code: "0".asFHIRStringPrimitive(),
                display: "stood",
                system: "https://developer.apple.com/documentation/healthkit/hkcategoryvalueapplestandhour"
            )),
            .init(input: .idle, expectedOutput: Coding(
                code: "1".asFHIRStringPrimitive(),
                display: "idle",
                system: "https://developer.apple.com/documentation/healthkit/hkcategoryvalueapplestandhour"
            ))
        ]
        for test in tests {
            let observation = try createObservationFrom(
                type: .appleStandHour,
                value: test.input.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: .appleStandHour,
                display: "Apple Stand Hour"
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [test.expectedOutput])))
        }
    }

    @Test
    func intermenstrualBleeding() throws {
        let observation = try createObservationFrom(
            type: .intermenstrualBleeding,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .intermenstrualBleeding,
            display: "Intermenstrual Bleeding"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierIntermenstrualBleeding".asFHIRStringPrimitive()))
    }

    @Test
    func infrequentMenstrualCycles() throws {
        let observation = try createObservationFrom(
            type: .infrequentMenstrualCycles,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .infrequentMenstrualCycles,
            display: "Infrequent Menstrual Cycles"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierInfrequentMenstrualCycles".asFHIRStringPrimitive()))
    }
    
    @Test
    func irregularHeartRhythmEvent() throws {
        let observation = try createObservationFrom(
            type: .irregularHeartRhythmEvent,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .irregularHeartRhythmEvent,
            display: "Irregular Heart Rhythm Event"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierIrregularHeartRhythmEvent".asFHIRStringPrimitive()))
    }

    @Test
    func irregularMenstrualCycles() throws {
        let observation = try createObservationFrom(
            type: .irregularMenstrualCycles,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .irregularMenstrualCycles,
            display: "Irregular Menstrual Cycles"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierIrregularMenstrualCycles".asFHIRStringPrimitive()))
    }

    @Test
    func persistentIntermenstrualBleeding() throws {
        let observation = try createObservationFrom(
            type: .persistentIntermenstrualBleeding,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .persistentIntermenstrualBleeding,
            display: "Persistent Intermenstrual Bleeding"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierPersistentIntermenstrualBleeding".asFHIRStringPrimitive()))
    }

    @Test
    func prolongedMenstrualPeriods() throws {
        let observation = try createObservationFrom(
            type: .prolongedMenstrualPeriods,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .prolongedMenstrualPeriods,
            display: "Prolonged Menstrual Periods"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierProlongedMenstrualPeriods".asFHIRStringPrimitive()))
    }

    @Test
    func lactation() throws {
        let observation = try createObservationFrom(
            type: .lactation,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .lactation,
            display: "Lactation"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierLactation".asFHIRStringPrimitive()))
    }

    @Test
    func handwashingEvent() throws {
        let observation = try createObservationFrom(
            type: .handwashingEvent,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .handwashingEvent,
            display: "Handwashing Event"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierHandwashingEvent".asFHIRStringPrimitive()))
    }

    @Test
    func toothbrushingEvent() throws {
        let observation = try createObservationFrom(
            type: .toothbrushingEvent,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .toothbrushingEvent,
            display: "Toothbrushing Event"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierToothbrushingEvent".asFHIRStringPrimitive()))
    }

    @Test
    func mindfulSession() throws {
        let observation = try createObservationFrom(
            type: .mindfulSession,
            value: HKCategoryValue.notApplicable.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: .mindfulSession,
            display: "Mindful Session"
        ))
        #expect(observation.value == .string("HKCategoryTypeIdentifierMindfulSession".asFHIRStringPrimitive()))
    }

    
    // MARK: Symptom Tests


    func testSymptoms(type: HKCategoryTypeIdentifier, display: String) throws {
        let values: [HKCategoryValueSeverity] = [.moderate, .unspecified, .notPresent, .severe, .mild]
        for value in values {
            let observation = try createObservationFrom(
                type: type,
                value: value.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: type,
                display: display
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
                Coding(
                    code: value.code.asFHIRStringPrimitive(),
                    display: try #require(value.display).asFHIRStringPrimitive(),
                    system: Swift.type(of: value).system
                )
            ])))
        }
    }

    @Test
    func abdominalCramps() throws {
        try testSymptoms(type: .abdominalCramps, display: "Abdominal Cramps")
    }

    @Test
    func acne() throws {
        try testSymptoms(type: .acne, display: "Acne")
    }

    @Test
    func bladderIncontinence() throws {
        try testSymptoms(type: .bladderIncontinence, display: "Bladder Incontinence")
    }

    @Test
    func bloating() throws {
        try testSymptoms(type: .bloating, display: "Bloating")
    }

    @Test
    func breastPain() throws {
        try testSymptoms(type: .breastPain, display: "Breast Pain")
    }

    @Test
    func chestTightnessOrPain() throws {
        try testSymptoms(type: .chestTightnessOrPain, display: "Chest Tightness Or Pain")
    }

    @Test
    func chills() throws {
        try testSymptoms(type: .chills, display: "Chills")
    }

    @Test
    func constipation() throws {
        try testSymptoms(type: .constipation, display: "Constipation")
    }

    @Test
    func coughing() throws {
        try testSymptoms(type: .coughing, display: "Coughing")
    }

    @Test
    func dizziness() throws {
        try testSymptoms(type: .dizziness, display: "Dizziness")
    }

    @Test
    func drySkin() throws {
        try testSymptoms(type: .drySkin, display: "Dry Skin")
    }

    @Test
    func fainting() throws {
        try testSymptoms(type: .fainting, display: "Fainting")
    }

    @Test
    func fever() throws {
        try testSymptoms(type: .fever, display: "Fever")
    }

    @Test
    func generalizedBodyAche() throws {
        try testSymptoms(type: .generalizedBodyAche, display: "Generalized Body Ache")
    }

    @Test
    func hairLoss() throws {
        try testSymptoms(type: .hairLoss, display: "Hair Loss")
    }

    @Test
    func headache() throws {
        try testSymptoms(type: .headache, display: "Headache")
    }

    @Test
    func heartburn() throws {
        try testSymptoms(type: .heartburn, display: "Heartburn")
    }

    @Test
    func hotFlashes() throws {
        try testSymptoms(type: .hotFlashes, display: "Hot Flashes")
    }

    @Test
    func lossOfSmell() throws {
        try testSymptoms(type: .lossOfSmell, display: "Loss Of Smell")
    }

    @Test
    func lossOfTaste() throws {
        try testSymptoms(type: .lossOfTaste, display: "Loss Of Taste")
    }

    @Test
    func lowerBackPain() throws {
        try testSymptoms(type: .lowerBackPain, display: "Lower Back Pain")
    }

    @Test
    func memoryLapse() throws {
        try testSymptoms(type: .memoryLapse, display: "Memory Lapse")
    }

    @Test
    func moodChanges() throws {
        let values: [HKCategoryValuePresence] = [.notPresent, .present]
        for value in values {
            let observation = try createObservationFrom(
                type: .moodChanges,
                value: value.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: .moodChanges,
                display: "Mood Changes"
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
                Coding(
                    code: value.code.asFHIRStringPrimitive(),
                    display: try #require(value.display).asFHIRStringPrimitive(),
                    system: type(of: value).system
                )
            ])))
        }
    }

    @Test
    func sleepChanges() throws {
        let values: [HKCategoryValuePresence] = [.notPresent, .present]
        for value in values {
            let observation = try createObservationFrom(
                type: .sleepChanges,
                value: value.rawValue
            )
            #expect(observation.code.coding?.first == createCategoryCoding(
                categoryType: .sleepChanges,
                display: "Sleep Changes"
            ))
            #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
                Coding(
                    code: value.code.asFHIRStringPrimitive(),
                    display: try #require(value.display).asFHIRStringPrimitive(),
                    system: type(of: value).system
                )
            ])))
        }
    }
    
    @Test(arguments: product([
        (HKCategoryTypeIdentifier.bleedingDuringPregnancy, "Bleeding During Pregnancy"),
        (HKCategoryTypeIdentifier.bleedingAfterPregnancy, "Bleeding After Pregnancy")
    ], [
        HKCategoryValueVaginalBleeding.none, .light, .medium, .heavy
    ]))
    @available(iOS 18.0, watchOS 11.0, macOS 15.0, visionOS 2.0, *)
    func pregnancyBleeding(categoryInput: (HKCategoryTypeIdentifier, String), value: HKCategoryValueVaginalBleeding) throws {
        let (category, displayTitle) = categoryInput
        let observation = try createObservationFrom(
            type: category,
            value: value.rawValue
        )
        #expect(observation.code.coding?.first == createCategoryCoding(
            categoryType: category,
            display: displayTitle
        ))
        #expect(observation.value == .codeableConcept(CodeableConcept(coding: [
            Coding(
                code: value.code.asFHIRStringPrimitive(),
                display: try #require(value.display).asFHIRStringPrimitive(),
                system: type(of: value).system
            )
        ])))
    }

    @Test
    func nausea() throws {
        try testSymptoms(type: .nausea, display: "Nausea")
    }

    @Test
    func nightSweats() throws {
        try testSymptoms(type: .nightSweats, display: "Night Sweats")
    }

    @Test
    func pelvicPain() throws {
        try testSymptoms(type: .pelvicPain, display: "Pelvic Pain")
    }

    @Test
    func rapidPoundingOrFlutteringHeartbeat() throws {
        try testSymptoms(type: .rapidPoundingOrFlutteringHeartbeat, display: "Rapid Pounding Or Fluttering Heartbeat")
    }

    @Test
    func runnyNose() throws {
        try testSymptoms(type: .runnyNose, display: "Runny Nose")
    }

    @Test
    func shortnessOfBreath() throws {
        try testSymptoms(type: .shortnessOfBreath, display: "Shortness Of Breath")
    }

    @Test
    func sinusCongestion() throws {
        try testSymptoms(type: .sinusCongestion, display: "Sinus Congestion")
    }

    @Test
    func skippedHeartbeat() throws {
        try testSymptoms(type: .skippedHeartbeat, display: "Skipped Heartbeat")
    }

    @Test
    func soreThroat() throws {
        try testSymptoms(type: .soreThroat, display: "Sore Throat")
    }

    @Test
    func vaginalDryness() throws {
        try testSymptoms(type: .vaginalDryness, display: "Vaginal Dryness")
    }

    @Test
    func vomiting() throws {
        try testSymptoms(type: .vomiting, display: "Vomiting")
    }

    @Test
    func wheezing() throws {
        try testSymptoms(type: .wheezing, display: "Wheezing")
    }
}


func product<C1: Collection, C2: Collection>(
    _ first: C1,
    _ second: C2
) -> some Collection<(C1.Element, C2.Element)> & Sendable where C1: Sendable, C2: Sendable, C1.Element: Sendable, C2.Element: Sendable {
    first.lazy.flatMap { element1 in
        second.lazy.map { element2 in
            (element1, element2)
        }
    }
}
