#
# This source file is part of the Stanford Spezi open-source project
#
# SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#

from typing import Optional, Any


class LocaleDependentUnit(object):
    def __init__(self, *, us: str, uk: str | None = None, metric: str | None = None): # TODO move metric to the front?!
        self.metric = metric
        self.us = us
        self.uk = uk
    
    def to_str(self) -> str:
        components: list[tuple[str, str | None]] = [
            ('metric', self.metric),
            ('us', self.us),
            ('uk', self.uk)
        ]
        components: list[tuple[str, str]] = list(filter(lambda x: x[1], components))
        args = map(lambda x: f'{x[0]}: {x[1]}', components)
        return f'LocalizedUnit({', '.join(args)})'


class Availability(object):
    def __init__(self, *, iOS: Optional[str] = None, macOS: Optional[str] = None, watchOS: Optional[str] = None, visionOS: Optional[str] = None):
        self.iOS = iOS
        self.macOS = macOS
        self.watchOS = watchOS
        self.visionOS = visionOS
    
    def components(self) -> list[str]:
        components: list[str] = []
        if self.iOS is not None:
            components.append(f'iOS {self.iOS}')
        if self.macOS is not None:
            components.append(f'macOS {self.macOS}')
        if self.watchOS is not None:
            components.append(f'watchOS {self.watchOS}')
        if self.visionOS is not None:
            components.append(f'visionOS {self.visionOS}')
        return components


class SampleType(object):
    def __init__(
        self,
        *,
        availability: Optional[Availability] = None,
        identifier: str,
        property_name: Optional[str],
        canonical_title: str,
        extra_init_params: list[tuple[str, Any]] = [],
        doc: str
    ):
        self.availability = availability
        self.identifier = identifier
        self.property_name = property_name or identifier
        self.canonical_title = canonical_title
        self.extra_init_params = [(k,v) for k,v in extra_init_params if v is not None]
        self.doc = doc
    

def quantity_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    canonical_title: str,
    unit: str, # canonical unit. TODO maybe rename?
    display_unit: LocaleDependentUnit | None = None,
    expected_values_range: Optional[str] = None,
    doc: str
) -> SampleType:
    if not display_unit:
        display_unit = LocaleDependentUnit(us=unit, metric=unit)
    elif not display_unit.metric:
        display_unit.metric = unit
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        canonical_title=canonical_title,
        extra_init_params=[
            ('canonicalUnit', unit),
            ('displayUnits', display_unit.to_str() if display_unit else unit),
            ('expectedValuesRange', expected_values_range)
        ],
        doc=doc
    )

def category_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    canonical_title: str,
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        canonical_title=canonical_title,
        doc=doc
    )

def correlation_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    canonical_title: str,
    associated_quantity_types: list[str],
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        canonical_title=canonical_title,
        extra_init_params=[
            ('associatedQuantityTypes', '[' + (', '.join(map(lambda t: f'.{t}', associated_quantity_types))) + ']')
        ],
        doc=doc
    )
    
def clinical_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    canonical_title: str,
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        canonical_title=canonical_title,
        doc=doc
    )

def characteristic_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    canonical_title: str,
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        canonical_title=canonical_title,
        doc=doc
    )


quantity_types: list[SampleType] = [
    # Activity
    quantity_type(
        identifier='stepCount',
        canonical_title='Step Count',
        unit='.count()',
        doc='A quantity sample type that measures the number of steps the user has taken.'
    ),
    quantity_type(
        identifier='distanceWalkingRunning',
        canonical_title='Distance Walking/Running',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample type that measures the distance the user has moved by walking or running.'
    ),
    quantity_type(
        identifier='runningGroundContactTime',
        canonical_title='Ground Contact Time', # TODO put running in title?
        unit='.secondUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of time the runner’s foot is in contact with the ground while running.'
    ),
    quantity_type(
        identifier='runningPower',
        canonical_title='Running Power',
        unit='.watt()',
        doc='A quantity sample type that measures the rate of work required for the runner to maintain their speed.'
    ),
    quantity_type(
        identifier='runningSpeed',
        canonical_title='Running Speed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample type that measures the runner’s speed.'
    ),
    quantity_type(
        identifier='runningStrideLength',
        canonical_title='Running Stride Length',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.foot()'),
        doc='A quantity sample type that measures the distance covered by a single step while running.'
    ),
    quantity_type(
        identifier='runningVerticalOscillation',
        canonical_title='Running Vertical Oscillation',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.inch()'),
        doc='A quantity sample type measuring pelvis vertical range of motion during a single running stride.'
    ),
    quantity_type(
        identifier='distanceCycling',
        canonical_title='Cycling Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample type that measures the distance the user has moved by cycling.'
    ),
    quantity_type(
        identifier='pushCount',
        canonical_title='Wheelchair Push Count',
        unit='.count()',
        doc='A quantity sample type that measures the number of pushes that the user has performed while using a wheelchair.'
    ),
    quantity_type(
        identifier='distanceWheelchair',
        canonical_title='Wheelchair Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample type that measures the distance the user has moved using a wheelchair.'
    ),
    quantity_type(
        identifier='swimmingStrokeCount',
        canonical_title='Swimming Stroke Count',
        unit='.count()',
        doc='A quantity sample type that measures the number of strokes performed while swimming.'
    ),
    quantity_type(
        identifier='distanceSwimming',
        canonical_title='Swimming Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.yard()', uk='.yard()'),
        doc='A quantity sample type that measures the distance the user has moved while swimming.'
    ),
    quantity_type(
        identifier='distanceDownhillSnowSports',
        canonical_title='Downhill Snow Sports Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample type that measures the distance the user has traveled while skiing or snowboarding.'
    ),
    quantity_type(
        identifier='basalEnergyBurned',
        canonical_title='Basal Energy Burned',
        unit='.largeCalorie()',
        doc='A quantity sample type that measures the resting energy burned by the user.'
    ),
    quantity_type(
        identifier='activeEnergyBurned',
        canonical_title='Active Energy Burned',
        unit='.largeCalorie()',
        doc='A quantity sample type that measures the amount of active energy the user has burned.'
    ),
    quantity_type(
        identifier='flightsClimbed',
        canonical_title='Flights Climbed',
        unit='.count()',
        doc='A quantity sample type that measures the number flights of stairs that the user has climbed.'
    ),
   quantity_type(
       identifier='nikeFuel',
       canonical_title='NikeFuel',
       unit='.count()',
       doc='A quantity sample type that measures the number of NikeFuel points the user has earned.'
   ),
    quantity_type(
        identifier='appleExerciseTime',
        canonical_title='Apple Exercise Time',
        unit='.minute()',
        doc='A quantity sample type that measures the amount of time the user spent exercising.'
    ),
    quantity_type(
        identifier='appleMoveTime',
        canonical_title='Apple Move Time',
        unit='.minute()',
        doc='A quantity sample type that measures the amount of time the user has spent performing activities that involve full-body movements during the specified day.'
    ),
    quantity_type(
        identifier='appleStandTime',
        canonical_title='Apple Stand Time',
        unit='.minute()',
        doc='A quantity sample type that measures the amount of time the user has spent standing.'
    ),
    quantity_type(
        identifier='vo2Max',
        canonical_title='VO2Max',
        unit='.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())',
        doc='A quantity sample that measures the maximal oxygen consumption during exercise.'
    ),
    # Body Measurements
    quantity_type(
        identifier='height',
        canonical_title='Height',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.foot()'),
        doc='A quantity sample type that measures the user’s height.'
    ),
    quantity_type(
        identifier='bodyMass',
        canonical_title='Body Mass',
        unit='.gramUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.pound()', uk='.pound()'),
        doc='A quantity sample type that measures the user’s weight.'
    ),
    quantity_type(
        identifier='bodyMassIndex',
        canonical_title='BMI',
        unit='.count()',
        doc='A quantity sample type that measures the user’s body mass index.'
    ),
    quantity_type(
        identifier='leanBodyMass',
        canonical_title='Lean Body Mass',
        unit='.gramUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.pound()', uk='.pound()'),
        doc='A quantity sample type that measures the user’s lean body mass.'
    ),
    quantity_type(
        identifier='bodyFatPercentage',
        canonical_title='Body Fat Percentage',
        unit='.percent()',
        doc='A quantity sample type that measures the user’s body fat percentage.'
    ),
    quantity_type(
        identifier='waistCircumference',
        canonical_title='Waist Circumference',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.inch()'),
        doc='A quantity sample type that measures the user’s waist circumference.'
    ),
    quantity_type(
        identifier='appleSleepingWristTemperature',
        canonical_title='Apple Sleeping Wrist Temperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc='A quantity sample type that records the wrist temperature during sleep.'
    ),
    # Reproductive Health
    quantity_type(
        identifier='basalBodyTemperature',
        canonical_title='Basal Body Temperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc='A quantity sample type that records the user’s basal body temperature.'
    ),
    # Hearing
    quantity_type(
        identifier='environmentalAudioExposure',
        canonical_title='Environmental Audio Exposure',
        unit='.decibelAWeightedSoundPressureLevel()',
        doc='A quantity sample type that measures audio exposure to sounds in the environment.'
    ),
    quantity_type(
        identifier='headphoneAudioExposure',
        canonical_title='Headphone Audio Exposure',
        unit='.decibelAWeightedSoundPressureLevel()',
        doc='A quantity sample type that measures audio exposure from headphones.'
    ),
    # Vital Signs
    quantity_type(
        identifier='heartRate',
        canonical_title='Heart Rate',
        unit='.count() / .minute()',
        expected_values_range='0...175',
        doc='A quantity sample type that measures the user’s heart rate.'
    ),
    quantity_type(
        identifier='restingHeartRate',
        canonical_title='Resting Heart Rate',
        unit='.count() / .minute()',
        doc='A quantity sample type that measures the user’s resting heart rate.'
    ),
    quantity_type(
        identifier='walkingHeartRateAverage',
        canonical_title='Walking Heart Rate Average',
        unit='.count() / .minute()',
        doc='A quantity sample type that measures the user’s heart rate while walking.'
    ),
    quantity_type(
        identifier='heartRateVariabilitySDNN',
        canonical_title='Heart Rate Variability SDNN',
        unit='.secondUnit(with: .milli)',
        doc='A quantity sample type that measures the standard deviation of heartbeat intervals.'
    ),
    quantity_type(
        identifier='heartRateRecoveryOneMinute',
        canonical_title='Heart Rate Recovery (1 min)',
        unit='.count() / .minute()', # might not be the correct unit; docs say count, but the health app seems to use BPM?
        doc='A quantity sample that records the reduction in heart rate from the peak exercise rate to the rate one minute after exercising ended.'
    ),
    quantity_type(
        identifier='atrialFibrillationBurden',
        canonical_title='AFib Burden',
        unit='.percent()',
        doc='A quantity type that measures an estimate of the percentage of time a person’s heart shows signs of atrial fibrillation (AFib) while wearing Apple Watch.'
    ),
    quantity_type(
        identifier='oxygenSaturation',
        canonical_title='Oxygen Saturation',
        property_name='bloodOxygen',
        unit='.percent()',
        expected_values_range='80...105',
        doc='A quantity sample type that measures the user’s oxygen saturation.'
    ),
    quantity_type(
        identifier='bodyTemperature',
        canonical_title='Body Temperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc='A quantity sample type that measures the user’s body temperature.'
    ),
    quantity_type(
        identifier='bloodPressureDiastolic',
        canonical_title='Blood Pressure (Diastolic)',
        unit='.millimeterOfMercury()',
        doc='A quantity sample type that measures the user’s diastolic blood pressure.'
    ),
    quantity_type(
        identifier='bloodPressureSystolic',
        canonical_title='Blood Pressure (Systolic)',
        unit='.millimeterOfMercury()',
        doc='A quantity sample type that measures the user’s systolic blood pressure.'
    ),
    quantity_type(
        identifier='respiratoryRate',
        canonical_title='Respiratory Rate',
        unit='.count() / .minute()',
        doc='A quantity sample type that measures the user’s respiratory rate.'
    ),

    # Lab and Test Results
    quantity_type(
        identifier='bloodGlucose',
        canonical_title='Blood Glucose',
        unit='.gramUnit(with: .milli) / .literUnit(with: .deci)',
        doc='A quantity sample type that measures the user’s blood glucose level.'
    ),
    quantity_type(
        identifier='electrodermalActivity',
        canonical_title='Electrodermal Activity',
        unit='.siemenUnit(with: .micro)',
        doc='A quantity sample type that measures electrodermal activity.'
    ),
    quantity_type(
        identifier='forcedExpiratoryVolume1',
        canonical_title='Forced Expiratory Volume (1 sec)',
        unit='.liter()',
        doc='A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs during the first second of a forced exhalation.'
    ),
    quantity_type(
        identifier='forcedVitalCapacity',
        canonical_title='Forced Vital Capacity',
        unit='.liter()',
        doc='A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs after taking the deepest breath possible.'
    ),
    quantity_type(
        identifier='inhalerUsage',
        canonical_title='Inhaler Usage',
        unit='.count()',
        doc='A quantity sample type that measures the number of puffs the user takes from their inhaler.'
    ),
    quantity_type(
        identifier='insulinDelivery',
        canonical_title='Insulin Delivery',
        unit='.internationalUnit()',
        doc='A quantity sample that measures the amount of insulin delivered.'
    ),
    quantity_type(
        identifier='numberOfTimesFallen',
        canonical_title='Number of Times Fallen',
        unit='.count()',
        doc='A quantity sample type that measures the number of times the user fell.'
    ),
    quantity_type(
        identifier='peakExpiratoryFlowRate',
        canonical_title='Peak Expiratory Flow Rate',
        unit='.liter() / .minute()',
        doc='A quantity sample type that measures the user’s maximum flow rate generated during a forceful exhalation.'
    ),
    quantity_type(
        identifier='peripheralPerfusionIndex',
        canonical_title='Peripheral Perfusion Index',
        unit='.percent()',
        doc='A quantity sample type that measures the user’s peripheral perfusion index.'
    ),

    # Nutrition
    quantity_type(
        identifier='dietaryBiotin',
        canonical_title='Dietary Biotin Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of biotin (vitamin B7) consumed.'
    ),
    quantity_type(
        identifier='dietaryCaffeine',
        canonical_title='Dietary Caffeine Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of caffeine consumed.'
    ),
    quantity_type(
        identifier='dietaryCalcium',
        canonical_title='Dietary Calcium Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of calcium consumed.'
    ),
    quantity_type(
        identifier='dietaryCarbohydrates',
        canonical_title='Dietary Carbohydrates Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of carbohydrates consumed.'
    ),
    quantity_type(
        identifier='dietaryChloride',
        canonical_title='Dietary Chloride Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of chloride consumed.'
    ),
    quantity_type(
        identifier='dietaryCholesterol',
        canonical_title='Dietary Cholesterol Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of cholesterol consumed.'
    ),
    quantity_type(
        identifier='dietaryChromium',
        canonical_title='Dietary Chromium Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of chromium consumed.'
    ),
    quantity_type(
        identifier='dietaryCopper',
        canonical_title='Dietary Copper Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of copper consumed.'
    ),
    quantity_type(
        identifier='dietaryEnergyConsumed',
        canonical_title='Dietary Energy Consumed',
        unit='.largeCalorie()',
        doc='A quantity sample type that measures the amount of energy consumed.'
    ),
    quantity_type(
        identifier='dietaryFatMonounsaturated',
        canonical_title='Dietary Monounsaturated Fat Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of monounsaturated fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFatPolyunsaturated',
        canonical_title='Dietary Polyunsaturated Fat Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of polyunsaturated fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFatSaturated',
        canonical_title='Dietary Saturated Fat Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of saturated fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFatTotal',
        canonical_title='Dietary Total Fat Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the total amount of fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFiber',
        canonical_title='Dietary Fiber Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of fiber consumed.'
    ),
    quantity_type(
        identifier='dietaryFolate',
        canonical_title='Dietary Folate Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of folate (folic acid) consumed.'
    ),
    quantity_type(
        identifier='dietaryIodine',
        canonical_title='Dietary Iodine Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of iodine consumed.'
    ),
    quantity_type(
        identifier='dietaryIron',
        canonical_title='Dietary Iron Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of iron consumed.'
    ),
    quantity_type(
        identifier='dietaryMagnesium',
        canonical_title='Dietary Magnesium Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of magnesium consumed.'
    ),
    quantity_type(
        identifier='dietaryManganese',
        canonical_title='Dietary Manganese Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of manganese consumed.'
    ),
    quantity_type(
        identifier='dietaryMolybdenum',
        canonical_title='Dietary Molybdenum Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of molybdenum consumed.'
    ),
    quantity_type(
        identifier='dietaryNiacin',
        canonical_title='Dietary Niacin Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of niacin (vitamin B3) consumed.'
    ),
    quantity_type(
        identifier='dietaryPantothenicAcid',
        canonical_title='Dietary Pantothenic Acid Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of pantothenic acid (vitamin B5) consumed.'
    ),
    quantity_type(
        identifier='dietaryPhosphorus',
        canonical_title='Dietary Phosphorus Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of phosphorus consumed.'
    ),
    quantity_type(
        identifier='dietaryPotassium',
        canonical_title='Dietary Potassium Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of potassium consumed.'
    ),
    quantity_type(
        identifier='dietaryProtein',
        canonical_title='Dietary Protein Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of protein consumed.'
    ),
    quantity_type(
        identifier='dietaryRiboflavin',
        canonical_title='Dietary Riboflavin Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of riboflavin (vitamin B2) consumed.'
    ),
    quantity_type(
        identifier='dietarySelenium',
        canonical_title='Dietary Selenium Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of selenium consumed.'
    ),
    quantity_type(
        identifier='dietarySodium',
        canonical_title='Dietary Sodium Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of sodium consumed.'
    ),
    quantity_type(
        identifier='dietarySugar',
        canonical_title='Dietary Sugar Intake',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of sugar consumed.'
    ),
    quantity_type(
        identifier='dietaryThiamin',
        canonical_title='Dietary Thiamin Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of thiamin (vitamin B1) consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminA',
        canonical_title='Dietary Vitamin A Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of vitamin A consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminB12',
        canonical_title='Dietary Vitamin B12 Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of cyanocobalamin (vitamin B12) consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminB6',
        canonical_title='Dietary Vitamin B6 Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of pyridoxine (vitamin B6) consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminC',
        canonical_title='Dietary Vitamin C Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of vitamin C consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminD',
        canonical_title='Dietary Vitamin D Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of vitamin D consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminE',
        canonical_title='Dietary Vitamin E Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of vitamin E consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminK',
        canonical_title='Dietary Vitamin K Intake',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of vitamin K consumed.'
    ),
    quantity_type(
        identifier='dietaryWater',
        canonical_title='Dietary Water Intake',
        unit='.liter()',
        display_unit=LocaleDependentUnit(us='.fluidOunceUS()', metric='.literUnit(with: .milli)'),
        doc='A quantity sample type that measures the amount of water consumed.'
    ),
    quantity_type(
        identifier='dietaryZinc',
        canonical_title='Dietary Zinc Intake',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of zinc consumed.'
    ),

    # Alcohol Consumption
    quantity_type(
        identifier='bloodAlcoholContent',
        canonical_title='Blood Alcohol Content',
        unit='.percent()',
        doc='A quantity sample type that measures the user’s blood alcohol content.'
    ),
    quantity_type(
        identifier='numberOfAlcoholicBeverages',
        canonical_title='Number of Alcoholic Beverages',
        unit='.count()',
        doc='A quantity sample type that measures the number of standard alcoholic drinks that the user has consumed.'
    ),

    # Mobility
    quantity_type(
        identifier='appleWalkingSteadiness',
        canonical_title='Apple Walking Steadiness',
        unit='.percent()',
        doc='A quantity sample type that measures the steadiness of the user’s gait.'
    ),
    quantity_type(
        identifier='sixMinuteWalkTestDistance',
        canonical_title='6 Minute Walk Test Distance',
        unit='.meter()',
        doc='A quantity sample type that stores the distance a user can walk during a six-minute walk test.'
    ),
    quantity_type(
        identifier='walkingSpeed',
        canonical_title='Walking Speed',
        unit='.meter() / .second()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()', metric='.meterUnit(with: .kilo) / .hour()'),
        doc='A quantity sample type that measures the user’s average speed when walking steadily over flat ground.'
    ),
    quantity_type(
        identifier='walkingStepLength',
        canonical_title='Walking Step Length',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.inch()'),
        doc='A quantity sample type that measures the average length of the user’s step when walking steadily over flat ground.'
    ),
    quantity_type(
        identifier='walkingAsymmetryPercentage',
        canonical_title='Walking Asymmetry Percentage',
        unit='.percent()',
        doc='A quantity sample type that measures the percentage of steps in which one foot moves at a different speed than the other when walking on flat ground.'
    ),
    quantity_type(
        identifier='walkingDoubleSupportPercentage',
        canonical_title='Walking Double Support Percentage',
        unit='.percent()',
        doc='A quantity sample type that measures the percentage of time when both of the user’s feet touch the ground while walking steadily over flat ground.'
    ),
    quantity_type(
        identifier='stairAscentSpeed',
        canonical_title='Stair Ascent Speed',
        unit='.meter() / .second()',
        display_unit=LocaleDependentUnit(us='.foot() / .second()'),
        doc='A quantity sample type measuring the user’s speed while climbing a flight of stairs.'
    ),
    quantity_type(
        identifier='stairDescentSpeed',
        canonical_title='Stair Descent Speed',
        unit='.meter() / .second()',
        display_unit=LocaleDependentUnit(us='.foot() / .second()'),
        doc='A quantity sample type measuring the user’s speed while descending a flight of stairs.'
    ),

    # UV Exposure
    quantity_type(
        identifier='uvExposure',
        canonical_title='UV Exposure',
        unit='.count()',
        doc='A quantity sample type that measures the user’s exposure to UV radiation.'
    ),

    # Diving
    quantity_type(
        identifier='underwaterDepth',
        canonical_title='Underwater Depth',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.foot()'),
        doc='A quantity sample that records a person’s depth underwater.'
    ),
    quantity_type(
        identifier='waterTemperature',
        canonical_title='Water Temperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc=' A quantity sample that records the water temperature.'
    ),

    # Other
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='appleSleepingBreathingDisturbances',
        canonical_title='Apple Sleeping Breathing Disturbances',
        unit='.count()',
        doc='A quantity sample that records breathing disturbances during sleep.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='crossCountrySkiingSpeed',
        canonical_title='Cross Country Skiing Speed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records cross-country skiing speed.'
    ),
    quantity_type(
        identifier='cyclingCadence',
        canonical_title='Cycling Cadence',
        unit='.count() / .minute()',
        doc='A quantity sample that records cycling cadence.'
    ),
    quantity_type(
        identifier='cyclingFunctionalThresholdPower',
        canonical_title='Cycling Functional Threshold Power',
        unit='.watt()',
        doc='A quantity sample that records cycling functional threshold power.'
    ),
    quantity_type(
        identifier='cyclingPower',
        canonical_title='Cycling Power',
        unit='.watt()',
        doc='A quantity sample that records cycling power.'
    ),
    quantity_type(
        identifier='cyclingSpeed',
        canonical_title='Cycling Speed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records cycling speed.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distanceCrossCountrySkiing',
        canonical_title='Cross-Country Skiing Speed',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample that records cross-country skiing distance.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distancePaddleSports',
        canonical_title='Paddle Sports Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample that records paddle sports distance.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distanceRowing',
        canonical_title='Rowing Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample that records rowing distance.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distanceSkatingSports',
        canonical_title='Skating Sports Distance',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.mile()', metric='.meterUnit(with: .kilo)'),
        doc='A quantity sample that records skating sports distance.'
    ),
    quantity_type(
        identifier='environmentalSoundReduction',
        canonical_title='Environmental Sound Reduction',
        unit='.decibelHearingLevel()',
        doc='A quantity sample that records environmental sound reduction.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='estimatedWorkoutEffortScore',
        canonical_title='Estimated Workout Effort',
        unit='.count()', # TODO not sure about this one
        doc='A quantity sample that records estimated physical effort during workouts.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='paddleSportsSpeed',
        canonical_title='Paddle Sports Speed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records paddle sports speed.'
    ),
    quantity_type(
        identifier='physicalEffort',
        canonical_title='Physical Effort',
        unit='.kilocalorie() / (.gramUnit(with: .kilo) * .hour())',
        doc='A quantity sample that records physical effort.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='rowingSpeed',
        canonical_title='Rowing Speed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records rowing speed.'
    ),
    quantity_type(
        identifier='timeInDaylight',
        canonical_title='Time in Daylight',
        unit='.minute()',
        doc='A quantity sample that records time spent in daylight.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='workoutEffortScore',
        canonical_title='Workout Effort',
        unit='.count()', # TODO not sure about this one
        doc='A quantity sample that records workout effort.'
    )
]


category_types: list[SampleType] = [
    # Activity
    category_type(
        identifier='appleStandHour',
        canonical_title='Apple Stand Hour',
        doc='A category sample type that counts the number of hours in the day during which the user has stood and moved for at least one minute per hour.'
    ),
    category_type(
        identifier='lowCardioFitnessEvent',
        canonical_title='Low Cardio Fitness Event',
        doc='An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold.'
    ),

    # MARK: Reproductive Health
    category_type(
        identifier='menstrualFlow',
        canonical_title='Menstrual Flow',
        doc='A category sample type that records menstrual cycles.'
    ),
    category_type(
        identifier='intermenstrualBleeding',
        canonical_title='Intermenstrual Bleeding',
        doc='A category sample type that records spotting outside the normal menstruation period.'
    ),
    category_type(
        identifier='infrequentMenstrualCycles',
        canonical_title='Infrequent Menstrual Cycles',
        doc='A category sample that indicates an infrequent menstrual cycle.'
    ),
    category_type(
        identifier='irregularMenstrualCycles',
        canonical_title='Irregular Menstrual Cycles',
        doc='A category sample that indicates an irregular menstrual cycle.'
    ),
    category_type(
        identifier='persistentIntermenstrualBleeding',
        canonical_title='Persistent Intermenstrual Bleeding',
        doc='A category sample that indicates persistent intermenstrual bleeding.'
    ),
    category_type(
        identifier='prolongedMenstrualPeriods',
        canonical_title='Prolonged Menstrual Periods',
        doc='A category sample that indicates a prolonged menstrual cycle.'
    ),
    category_type(
        identifier='cervicalMucusQuality',
        canonical_title='Cervical Mucus Quality',
        doc='A category sample type that records the quality of the user’s cervical mucus.'
    ),
    category_type(
        identifier='ovulationTestResult',
        canonical_title='Ovulation Test Result',
        doc='A category sample type that records the result of an ovulation home test.'
    ),
    category_type(
        identifier='progesteroneTestResult',
        canonical_title='Progesterone Test Result',
        doc='A category type that represents the results from a home progesterone test.'
    ),
    category_type(
        identifier='sexualActivity',
        canonical_title='Sexual Activity',
        doc='A category sample type that records sexual activity.'
    ),
    category_type(
        identifier='contraceptive',
        canonical_title='Contraceptive',
        doc='A category sample type that records the use of contraceptives.'
    ),
    category_type(
        identifier='pregnancy',
        canonical_title='Pregnancy',
        doc='A category type that records pregnancy.'
    ),
    category_type(
        identifier='pregnancyTestResult',
        canonical_title='Pregnancy Test Result',
        doc='A category type that represents the results from a home pregnancy test.'
    ),
    category_type(
        identifier='lactation',
        canonical_title='Lactation',
        doc='A category type that records lactation.'
    ),

    # Hearing
    category_type(
        identifier='environmentalAudioExposureEvent',
        canonical_title='Environmental Audio Exposure Event',
        doc='A category sample type that records exposure to potentially damaging sounds from the environment.'
    ),
    category_type(
        identifier='headphoneAudioExposureEvent',
        canonical_title='Headphone Audio Exposure Event',
        doc='A category sample type that records exposure to potentially damaging sounds from headphones.'
    ),

    # Vital Signs
    category_type(
        identifier='lowHeartRateEvent',
        canonical_title='Low Heart Rate Event',
        doc='A category sample type for low heart rate events.'
    ),
    category_type(
        identifier='highHeartRateEvent',
        canonical_title='High Heart Rate Event',
        doc='A category sample type for high heart rate events.'
    ),
    category_type(
        identifier='irregularHeartRhythmEvent',
        canonical_title='Irregular Heart Rhythm Event',
        doc='A category sample type for irregular heart rhythm events.'
    ),


    # Mobility
    category_type(
        identifier='appleWalkingSteadinessEvent',
        canonical_title='Apple Walking Steadiness Event',
        doc='A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness.'
    ),

    # Mindfulness and Sleep

    category_type(
        identifier='mindfulSession',
        canonical_title='Mindful Session',
        doc='A category sample type for recording a mindful session.'
    ),
    category_type(
        identifier='sleepAnalysis',
        canonical_title='Sleep Analysis',
        doc='A category sample type for sleep analysis information.'
    ),
    
    # Self Care
    category_type(
        identifier='toothbrushingEvent',
        canonical_title='Toothbrushing Event',
        doc='A category sample type for toothbrushing events.'
    ),
    category_type(
        identifier='handwashingEvent',
        canonical_title='Handwashing Event',
        doc='A category sample type for handwashing events.'
    ),

    # Symptoms
    # Symptoms: Abdominal and Gastrointestinal
    category_type(
        identifier='abdominalCramps',
        canonical_title='Abdominal Cramps',
        doc='A category type that records abdominal cramps as a symptom.'
    ),
    category_type(
        identifier='bloating',
        canonical_title='Bloating',
        doc='A category type that records bloating as a symptom.'
    ),
    category_type(
        identifier='constipation',
        canonical_title='Constipation',
        doc='A category type that records constipation as a symptom.'
    ),
    category_type(
        identifier='diarrhea',
        canonical_title='Diarrhea',
        doc='A category type that records diarrhea as a symptom.'
    ),
    category_type(
        identifier='heartburn',
        canonical_title='Heartburn',
        doc='A category type that records heartburn as a symptom.'
    ),
    category_type(
        identifier='nausea',
        canonical_title='Nausea',
        doc='A category type that records nausea as a symptom.'
    ),
    category_type(
        identifier='vomiting',
        canonical_title='Vomiting',
        doc='A category type that records vomiting as a symptom.'
    ),
    # Symptoms: Constitutional
    category_type(
        identifier='appetiteChanges',
        canonical_title='Appetite Changes',
        doc='A category type that records changes in appetite as a symptom.'
    ),
    category_type(
        identifier='chills',
        canonical_title='Chills',
        doc='A category type that records chills as a symptom.'
    ),
    category_type(
        identifier='dizziness',
        canonical_title='Dizziness',
        doc='A category type that records dizziness as a symptom.'
    ),
    category_type(
        identifier='fainting',
        canonical_title='Fainting',
        doc='A category type that records fainting as a symptom.'
    ),
    category_type(
        identifier='fatigue',
        canonical_title='Fatigue',
        doc='A category type that records fatigue as a symptom.'
    ),
    category_type(
        identifier='fever',
        canonical_title='Fever',
        doc='A category type that records fever as a symptom.'
    ),
    category_type(
        identifier='generalizedBodyAche',
        canonical_title='Generalized Body Ache',
        doc='A category type that records body ache as a symptom.'
    ),
    category_type(
        identifier='hotFlashes',
        canonical_title='Hot Flashes',
        doc='A category type that records hot flashes as a symptom.'
    ),
    # Symptoms: Heart and Lung
    category_type(
        identifier='chestTightnessOrPain',
        canonical_title='Chest Tightness/Pain',
        doc='A category type that records chest tightness or pain as a symptom.'
    ),
    category_type(
        identifier='coughing',
        canonical_title='Coughing',
        doc='A category type that records coughing as a symptom.'
    ),
    category_type(
        identifier='rapidPoundingOrFlutteringHeartbeat',
        canonical_title='Rapid/Pounding/Fluttering Heartbeat',
        doc='A category type that records a rapid, pounding, or fluttering heartbeat as a symptom.'
    ),
    category_type(
        identifier='shortnessOfBreath',
        canonical_title='Shortness of Breath',
        doc='A category type that records shortness of breath as a symptom.'
    ),
    category_type(
        identifier='skippedHeartbeat',
        canonical_title='Skipped Heartbeat',
        doc='A category type that records skipped heartbeat as a symptom.'
    ),
    category_type(
        identifier='wheezing',
        canonical_title='Wheezing',
        doc='A category type that records wheezing as a symptom.'
    ),
    # Symptoms: Musculoskeletal
    category_type(
        identifier='lowerBackPain',
        canonical_title='Lower Back Pain',
        doc='A category type that records lower back pain as a symptom.'
    ),
    # Symptoms: Neurological
    category_type(
        identifier='headache',
        canonical_title='Headache',
        doc='A category type that records headache as a symptom.'
    ),
    category_type(
        identifier='memoryLapse',
        canonical_title='Memory Lapse',
        doc='A category type that records memory lapse as a symptom.'
    ),
    category_type(
        identifier='moodChanges',
        canonical_title='Mood Changes',
        doc='A category type that records mood changes as a symptom.'
    ),
    # Symptoms: Nose and Throat
    category_type(
        identifier='lossOfSmell',
        canonical_title='Loss of Smell',
        doc='A category type that records loss of smell as a symptom.'
    ),
    category_type(
        identifier='lossOfTaste',
        canonical_title='Loss of Taste',
        doc='A category type that records loss of taste as a symptom.'
    ),
    category_type(
        identifier='runnyNose',
        canonical_title='Runny Nose',
        doc='A category type that records runny nose as a symptom.'
    ),
    category_type(
        identifier='soreThroat',
        canonical_title='Sore Throat',
        doc='A category type that records sore throat as a symptom.'
    ),
    category_type(
        identifier='sinusCongestion',
        canonical_title='Sinus Congestion',
        doc='A category type that records sinus congestion as a symptom.'
    ),
    # Symptoms: Reproduction
    category_type(
        identifier='breastPain',
        canonical_title='Breast Pain',
        doc='A category type that records breast pain as a symptom.'
    ),
    category_type(
        identifier='pelvicPain',
        canonical_title='Pelvic Pain',
        doc='A category type that records pelvic pain as a symptom.'
    ),
    category_type(
        identifier='vaginalDryness',
        canonical_title='Vaginal Dryness',
        doc='A category type that records vaginal dryness as a symptom.'
    ),
    category_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='bleedingDuringPregnancy',
        canonical_title='Bleeding During Pregnancy',
        doc='A category type that records bleeding during pregnancy as a symptom.'
    ),
    category_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='bleedingAfterPregnancy',
        canonical_title='Bleeding After Pregnancy',
        doc='A category type that records bleeding after pregnancy as a symptom.'
    ),
    # Symptoms: Skin and Hair
    category_type(
        identifier='acne',
        canonical_title='Acne',
        doc='A category type that records acne as a symptom.'
    ),
    category_type(
        identifier='drySkin',
        canonical_title='Dry Skin',
        doc='A category type that records dry skin as a symptom.'
    ),
    category_type(
        identifier='hairLoss',
        canonical_title='Hair Loss',
        doc='A category type that records hair loss as a symptom.'
    ),
    # Symptoms: Sleep
    category_type(
        identifier='nightSweats',
        canonical_title='Night Sweats',
        doc='A category type that records night sweats as a symptom.'
    ),
    category_type(
        identifier='sleepChanges',
        canonical_title='Sleep Changes',
        doc='A category type that records sleep changes as a symptom.'
    ),
    category_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='sleepApneaEvent',
        canonical_title='Sleep Apnea Event',
        doc='A category type that records sleep apnea as a symptom.'
    ),
    # Symptoms: Urinary
    category_type(
        identifier='bladderIncontinence',
        canonical_title='Bladder Incontinence',
        doc='A category type that records bladder incontinence as a symptom.'
    )
]


correlation_types: list[SampleType] = [
    correlation_type(
        identifier='bloodPressure',
        canonical_title='Blood Pressure',
        doc='The sample type representing blood pressure correlation samples',
        associated_quantity_types=['bloodPressureDiastolic', 'bloodPressureSystolic']
    ),
    correlation_type(
        identifier='food',
        canonical_title='Food',
        doc='Food correlation types combine any number of nutritional samples into a single food object.',
        associated_quantity_types=[
            # As defined [here](https://developer.apple.com/documentation/healthkit/data_types/nutrition_type_identifiers)
            # Macronutrients
            'dietaryEnergyConsumed',
            'dietaryCarbohydrates',
            'dietaryFiber',
            'dietarySugar',
            'dietaryFatTotal',
            'dietaryFatMonounsaturated',
            'dietaryFatPolyunsaturated',
            'dietaryFatSaturated',
            'dietaryCholesterol',
            'dietaryProtein',
            # Vitamins
            'dietaryVitaminA',
            'dietaryThiamin',
            'dietaryRiboflavin',
            'dietaryNiacin',
            'dietaryPantothenicAcid',
            'dietaryVitaminB6',
            'dietaryBiotin',
            'dietaryVitaminB12',
            'dietaryVitaminC',
            'dietaryVitaminD',
            'dietaryVitaminE',
            'dietaryVitaminK',
            'dietaryFolate',
            # Minerals
            'dietaryCalcium',
            'dietaryChloride',
            'dietaryIron',
            'dietaryMagnesium',
            'dietaryPhosphorus',
            'dietaryPotassium',
            'dietarySodium',
            'dietaryZinc',
            # Hydration
            'dietaryWater',
            # Caffeination
            'dietaryCaffeine',
            # Ultratrace Minerals
            'dietaryChromium',
            'dietaryCopper',
            'dietaryIodine',
            'dietaryManganese',
            'dietaryMolybdenum',
            'dietarySelenium'
        ]
    )
]


characteristic_types: list[SampleType] = [
    characteristic_type(
        identifier='activityMoveMode',
        canonical_title='Activity Move Mode',
        doc='The activity move mode characteristic.'
    ),
    characteristic_type(
        identifier='biologicalSex',
        canonical_title='Biological Sex',
        doc="The characteristic representing the user's biological sex."
    ),
    characteristic_type(
        identifier='bloodType',
        canonical_title='Blood Type',
        doc="The characteristic representing the user's blood type."
    ),
    characteristic_type(
        identifier='dateOfBirth',
        canonical_title='Date of Birth',
        doc="The characteristic representing the user's date of birth."
    ),
    characteristic_type(
        identifier='fitzpatrickSkinType',
        canonical_title='Fitzpatrick Skin Type',
        doc="The characteristic representing the user's skin type."
    ),
    characteristic_type(
        identifier='wheelchairUse',
        canonical_title='Wheelchair Use',
        doc="The characteristic representing the user's wheelchair use status."
    ),
]

clinical_types: list[SampleType] = [
    clinical_type(
        identifier='allergyRecord',
        canonical_title='Allergy Record',
        doc='A type identifier for records of allergic or intolerant reactions.'
    ),
    clinical_type(
        identifier='clinicalNoteRecord',
        canonical_title='Clinical Note Record',
        doc='A type identifier for records of clinical notes.'
    ),
    clinical_type(
        identifier='conditionRecord',
        canonical_title='Condition Record',
        doc='A type identifier for records of a condition, problem, diagnosis, or other event.'
    ),
    clinical_type(
        identifier='immunizationRecord',
        canonical_title='Immunization Record',
        doc='A type identifier for records of the current or historical administration of vaccines.'
    ),
    clinical_type(
        identifier='labResultRecord',
        canonical_title='Lab Result Record',
        doc='A type identifier for records of lab results.'
    ),
    clinical_type(
        identifier='medicationRecord',
        canonical_title='Medication Record',
        doc='A type identifier for records of medication.'
    ),
    clinical_type(
        identifier='procedureRecord',
        canonical_title='Procedure Record',
        doc='A type identifier for records of procedures.'
    ),
    clinical_type(
        identifier='vitalSignRecord',
        canonical_title='Vital Sign Record',
        doc='A type identifier for records of vital signs.'
    ),
    clinical_type(
        identifier='coverageRecord',
        canonical_title='Coverage Record',
        doc='A type identifier for records containing information about the user’s insurance coverage.'
    )
]


gen_inputs = [
    ('Quantity', 'Quantities', 'HKQuantitySample', 'HKQuantityType', 'quantity', quantity_types),
    ('Category', 'Categories', 'HKCategorySample', 'HKCategoryType', 'category', category_types),
    ('Correlation', 'Correlations', 'HKCorrelation', 'HKCorrelationType', 'correlation', correlation_types),
    ('Clinical Record', 'Clinical Records', 'HKClinicalRecord', 'HKClinicalType', 'clinical', clinical_types)
]




class OtherSampleType:
    def __init__(
            self,
            *,
            availability: Optional[Availability] = None,
            sampleTypePropertyName: str,
            hkSampleClass: str,
            canonical_title: str,
            doc: str,
            hkSampleType: str,
            variant: str,
            identifier_def: Optional[str]
        ):
        self.sampleTypePropertyName = sampleTypePropertyName
        self.availability = availability
        self.hkSampleClass = hkSampleClass
        self.canonical_title = canonical_title
        self.doc = doc
        self.hkSampleType = hkSampleType
        self.variant = variant
        self.identifier_def = identifier_def



other_sample_types = [
    OtherSampleType(
        sampleTypePropertyName='electrocardiogram',
        hkSampleClass='HKElectrocardiogram',
        canonical_title='ECG',
        doc='The electrocardiogram sample type',
        hkSampleType='HKSampleType.electrocardiogramType()',
        variant='.other',
        identifier_def='HKElectrocardiogramTypeIdentifier'
    ),
    OtherSampleType(
        sampleTypePropertyName='audiogram',
        hkSampleClass='HKAudiogramSample',
        canonical_title='Audiogram',
        doc='The audiogram sample type',
        hkSampleType='HKSampleType.audiogramSampleType()',
        variant='.other',
        identifier_def='HKAudiogramSampleTypeIdentifier'
    ),
    OtherSampleType(
        sampleTypePropertyName='workout',
        hkSampleClass='HKWorkout',
        canonical_title='Workout',
        doc='The workout sample type',
        hkSampleType='HKSampleType.workoutType()',
        variant='.other',
        identifier_def='HKWorkoutTypeIdentifier'
    ),
    OtherSampleType(
        sampleTypePropertyName='visionPrescription',
        hkSampleClass='HKVisionPrescription',
        canonical_title='Vision Prescription',
        doc='The vision prescription sample type',
        hkSampleType='HKSampleType.visionPrescriptionType()',
        variant='.other',
        identifier_def='HKVisionPrescriptionTypeIdentifier'
    ),
    OtherSampleType(
        availability=Availability(iOS='18.0', watchOS='11.0', macOS='15.0', visionOS='2.0'),
        sampleTypePropertyName='stateOfMind',
        hkSampleClass='HKStateOfMind',
        canonical_title='State of Mind',
        doc='The state of mind sample type',
        hkSampleType='HKSampleType.stateOfMindType()',
        variant='.other',
        identifier_def='HKDataTypeIdentifierStateOfMind'
    ),
    OtherSampleType(
        sampleTypePropertyName='heartbeatSeries',
        hkSampleClass='HKHeartbeatSeriesSample',
        canonical_title='Heartbeat Series',
        doc='The heartbeat series sample type',
        hkSampleType='HKSeriesType.heartbeat()',
        variant='.other',
        identifier_def='HKDataTypeIdentifierHeartbeatSeries'
    ),
    OtherSampleType(
        sampleTypePropertyName='workoutRoute',
        hkSampleClass='HKWorkoutRoute',
        canonical_title='Workout Route',
        doc='The workout route sample type',
        hkSampleType='HKSeriesType.workoutRoute()',
        variant='.other',
        identifier_def='HKWorkoutRouteTypeIdentifier'
    ),
    OtherSampleType(
        availability=Availability(iOS='18.0', watchOS='11.0', macOS='15.0', visionOS='2.0'),
        sampleTypePropertyName='gad7',
        hkSampleClass='HKGAD7Assessment',
        canonical_title='GAD-7',
        doc='The GAD-7 (generalized anxiety disorder 7) score type',
        hkSampleType='HKScoredAssessmentType(.GAD7)',
        variant='.other',
        identifier_def='HKScoredAssessmentTypeIdentifier.GAD7'
    ),
    OtherSampleType(
        availability=Availability(iOS='18.0', watchOS='11.0', macOS='15.0', visionOS='2.0'),
        sampleTypePropertyName='phq9',
        hkSampleClass='HKPHQ9Assessment',
        canonical_title='PHQ-9',
        doc='The PHQ-9 (nine-item Patient Health Questionnaire) score type',
        hkSampleType='HKScoredAssessmentType(.PHQ9)',
        variant='.other',
        identifier_def='HKScoredAssessmentTypeIdentifier.PHQ9'
    )
]
