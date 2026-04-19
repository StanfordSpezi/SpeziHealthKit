#
# This source file is part of the Stanford Spezi open-source project
#
# SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
#
# SPDX-License-Identifier: MIT
#

from typing import Optional, Any

# def LocaleDependentUnit(*, us: str, uk: Optional[str] = None, metric: str) -> str:
#     if uk:
#         return f'LocalizedUnit(metric: {metric}, us: {us}, uk: {uk})'
#     else:
#         return f'LocalizedUnit(metric: {metric}, us: {us})'

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
        # if self.uk:
        #     return f'LocalizedUnit(metric: {self.metric}, us: {self.us}, uk: {self.uk})'
        # else:
        #     return f'LocalizedUnit(metric: {self.metric}, us: {self.us})'


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
        display_title: Optional[str],
        extra_init_params: list[tuple[str, Any]] = [],
        doc: str
    ):
        self.availability = availability
        self.identifier = identifier
        self.property_name = property_name or identifier
        self.display_title = display_title
        self.extra_init_params = [(k,v) for k,v in extra_init_params if v is not None]
        self.doc = doc
    

def quantity_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    display_title: Optional[str] = None,
    unit: str, # canonical unit. TODO maybe rename?
    display_unit: LocaleDependentUnit | None = None,
    expected_values_range: Optional[str] = None,
    doc: str
) -> SampleType:
    # # yes this whole if thing could be more elegant but this way it's clear what is going on.
    # if display_unit: # not empty
    #     if not display_unit.startswith('LocalizedUnit'): # not already localized
    #         display_unit = f'LocalizedUnit(metric: {display_unit})'
    # else: # empty
    #     # use canonical unit for display as well
    #     display_unit = f'LocalizedUnit(metric: {display_unit})'
    if not display_unit:
        display_unit = LocaleDependentUnit(us=unit, metric=unit)
    elif not display_unit.metric:
        display_unit.metric = unit
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        display_title=display_title,
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
    display_title: Optional[str] = None,
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        display_title=display_title,
        doc=doc
    )

def correlation_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    display_title: Optional[str] = None,
    associated_quantity_types: list[str],
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        display_title=display_title,
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
    display_title: Optional[str] = None,
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        display_title=display_title,
        doc=doc
    )

def characteristic_type(
    *,
    availability: Optional[Availability] = None,
    identifier: str,
    property_name: Optional[str] = None,
    display_title: Optional[str] = None,
    doc: str
) -> SampleType:
    return SampleType(
        availability=availability,
        identifier=identifier,
        property_name=property_name,
        display_title=display_title,
        doc=doc
    )


quantity_types: list[SampleType] = [
    # Activity
    quantity_type(
        identifier='stepCount',
        unit='.count()',
        doc='A quantity sample type that measures the number of steps the user has taken.'
    ),
    quantity_type(
        identifier='distanceWalkingRunning',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample type that measures the distance the user has moved by walking or running.'
    ),
    quantity_type(
        identifier='runningGroundContactTime',
        unit='.secondUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of time the runner’s foot is in contact with the ground while running.'
    ),
    quantity_type(
        identifier='runningPower',
        unit='.watt()',
        doc='A quantity sample type that measures the rate of work required for the runner to maintain their speed.'
    ),
    quantity_type(
        identifier='runningSpeed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample type that measures the runner’s speed.'
    ),
    quantity_type(
        identifier='runningStrideLength',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.foot()'),
        doc='A quantity sample type that measures the distance covered by a single step while running.'
    ),
    quantity_type(
        identifier='runningVerticalOscillation',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.inch()'),
        doc='A quantity sample type measuring pelvis vertical range of motion during a single running stride.'
    ),
    quantity_type(
        identifier='distanceCycling',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample type that measures the distance the user has moved by cycling.'
    ),
    quantity_type(
        identifier='pushCount',
        unit='.count()',
        doc='A quantity sample type that measures the number of pushes that the user has performed while using a wheelchair.'
    ),
    quantity_type(
        identifier='distanceWheelchair',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample type that measures the distance the user has moved using a wheelchair.'
    ),
    quantity_type(
        identifier='swimmingStrokeCount',
        unit='.count()',
        doc='A quantity sample type that measures the number of strokes performed while swimming.'
    ),
    quantity_type(
        identifier='distanceSwimming',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.yard()', uk='.yard()'),
        doc='A quantity sample type that measures the distance the user has moved while swimming.'
    ),
    quantity_type(
        identifier='distanceDownhillSnowSports',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample type that measures the distance the user has traveled while skiing or snowboarding.'
    ),
    quantity_type(
        identifier='basalEnergyBurned',
        unit='.largeCalorie()',
        doc='A quantity sample type that measures the resting energy burned by the user.'
    ),
    quantity_type(
        identifier='activeEnergyBurned',
        unit='.largeCalorie()',
        doc='A quantity sample type that measures the amount of active energy the user has burned.'
    ),
    quantity_type(
        identifier='flightsClimbed',
        unit='.count()',
        doc='A quantity sample type that measures the number flights of stairs that the user has climbed.'
    ),
   quantity_type(
       identifier='nikeFuel',
       unit='.count()',
       doc='A quantity sample type that measures the number of NikeFuel points the user has earned.'
   ),
    quantity_type(
        identifier='appleExerciseTime',
        unit='.minute()',
        doc='A quantity sample type that measures the amount of time the user spent exercising.'
    ),
    quantity_type(
        identifier='appleMoveTime',
        unit='.minute()',
        doc='A quantity sample type that measures the amount of time the user has spent performing activities that involve full-body movements during the specified day.'
    ),
    quantity_type(
        identifier='appleStandTime',
        unit='.hour()',
        doc='A quantity sample type that measures the amount of time the user has spent standing.'
    ),
    quantity_type(
        identifier='vo2Max',
        unit='.literUnit(with: .milli) / (.gramUnit(with: .kilo) * .minute())',
        doc='A quantity sample that measures the maximal oxygen consumption during exercise.'
    ),
    # Body Measurements
    quantity_type(
        identifier='height',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.foot()'),
        doc='A quantity sample type that measures the user’s height.'
    ),
    quantity_type(
        identifier='bodyMass',
        unit='.gramUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.pound()', uk='.pound()'),
        doc='A quantity sample type that measures the user’s weight.'
    ),
    quantity_type(
        identifier='bodyMassIndex',
        unit='.count()',
        doc='A quantity sample type that measures the user’s body mass index.'
    ),
    quantity_type(
        identifier='leanBodyMass',
        unit='.gramUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.pound()', uk='.pound()'),
        doc='A quantity sample type that measures the user’s lean body mass.'
    ),
    quantity_type(
        identifier='bodyFatPercentage',
        unit='.percent()',
        doc='A quantity sample type that measures the user’s body fat percentage.'
    ),
    quantity_type(
        identifier='waistCircumference',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.inch()'),
        doc='A quantity sample type that measures the user’s waist circumference.'
    ),
    quantity_type(
        identifier='appleSleepingWristTemperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc='A quantity sample type that records the wrist temperature during sleep.'
    ),
    # Reproductive Health
    quantity_type(
        identifier='basalBodyTemperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc='A quantity sample type that records the user’s basal body temperature.'
    ),
    # Hearing
    quantity_type(
        identifier='environmentalAudioExposure',
        unit='.decibelAWeightedSoundPressureLevel()',
        doc='A quantity sample type that measures audio exposure to sounds in the environment.'
    ),
    quantity_type(
        identifier='headphoneAudioExposure',
        unit='.decibelAWeightedSoundPressureLevel()',
        doc='A quantity sample type that measures audio exposure from headphones.'
    ),
    # Vital Signs
    quantity_type(
        identifier='heartRate',
        unit='.count() / .minute()',
        expected_values_range='0...175',
        doc='A quantity sample type that measures the user’s heart rate.'
    ),
    quantity_type(
        identifier='restingHeartRate',
        unit='.count() / .minute()',
        doc='A quantity sample type that measures the user’s resting heart rate.'
    ),
    quantity_type(
        identifier='walkingHeartRateAverage',
        unit='.count() / .minute()',
        doc='A quantity sample type that measures the user’s heart rate while walking.'
    ),
    quantity_type(
        identifier='heartRateVariabilitySDNN',
        unit='.secondUnit(with: .milli)',
        doc='A quantity sample type that measures the standard deviation of heartbeat intervals.'
    ),
    quantity_type(
        identifier='heartRateRecoveryOneMinute',
        unit='.count() / .minute()', # might not be the correct unit; docs say count, but the health app seems to use BPM?
        doc='A quantity sample that records the reduction in heart rate from the peak exercise rate to the rate one minute after exercising ended.'
    ),
    quantity_type(
        identifier='atrialFibrillationBurden',
        unit='.percent()',
        doc='A quantity type that measures an estimate of the percentage of time a person’s heart shows signs of atrial fibrillation (AFib) while wearing Apple Watch.'
    ),
    quantity_type(
        identifier='oxygenSaturation',
        property_name='bloodOxygen',
        unit='.percent()',
        expected_values_range='80...105',
        doc='A quantity sample type that measures the user’s oxygen saturation.'
    ),
    quantity_type(
        identifier='bodyTemperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc='A quantity sample type that measures the user’s body temperature.'
    ),
    quantity_type(
        identifier='bloodPressureDiastolic',
        unit='.millimeterOfMercury()',
        doc='A quantity sample type that measures the user’s diastolic blood pressure.'
    ),
    quantity_type(
        identifier='bloodPressureSystolic',
        unit='.millimeterOfMercury()',
        doc='A quantity sample type that measures the user’s systolic blood pressure.'
    ),
    quantity_type(
        identifier='respiratoryRate',
        unit='.count() / .minute()',
        doc='A quantity sample type that measures the user’s respiratory rate.'
    ),

    # Lab and Test Results
    quantity_type(
        identifier='bloodGlucose',
        unit='.gramUnit(with: .milli) / .literUnit(with: .deci)',
        doc='A quantity sample type that measures the user’s blood glucose level.'
    ),
    quantity_type(
        identifier='electrodermalActivity',
        unit='.siemenUnit(with: .micro)',
        doc='A quantity sample type that measures electrodermal activity.'
    ),
    quantity_type(
        identifier='forcedExpiratoryVolume1',
        unit='.liter()',
        doc='A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs during the first second of a forced exhalation.'
    ),
    quantity_type(
        identifier='forcedVitalCapacity',
        unit='.liter()',
        doc='A quantity sample type that measures the amount of air that can be forcibly exhaled from the lungs after taking the deepest breath possible.'
    ),
    quantity_type(
        identifier='inhalerUsage',
        unit='.count()',
        doc='A quantity sample type that measures the number of puffs the user takes from their inhaler.'
    ),
    quantity_type(
        identifier='insulinDelivery',
        unit='.internationalUnit()',
        doc='A quantity sample that measures the amount of insulin delivered.'
    ),
    quantity_type(
        identifier='numberOfTimesFallen',
        unit='.count()',
        doc='A quantity sample type that measures the number of times the user fell.'
    ),
    quantity_type(
        identifier='peakExpiratoryFlowRate',
        unit='.liter() / .minute()',
        doc='A quantity sample type that measures the user’s maximum flow rate generated during a forceful exhalation.'
    ),
    quantity_type(
        identifier='peripheralPerfusionIndex',
        unit='.percent()',
        doc='A quantity sample type that measures the user’s peripheral perfusion index.'
    ),

    # Nutrition
    quantity_type(
        identifier='dietaryBiotin',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of biotin (vitamin B7) consumed.'
    ),
    quantity_type(
        identifier='dietaryCaffeine',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of caffeine consumed.'
    ),
    quantity_type(
        identifier='dietaryCalcium',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of calcium consumed.'
    ),
    quantity_type(
        identifier='dietaryCarbohydrates',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of carbohydrates consumed.'
    ),
    quantity_type(
        identifier='dietaryChloride',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of chloride consumed.'
    ),
    quantity_type(
        identifier='dietaryCholesterol',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of cholesterol consumed.'
    ),
    quantity_type(
        identifier='dietaryChromium',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of chromium consumed.'
    ),
    quantity_type(
        identifier='dietaryCopper',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of copper consumed.'
    ),
    quantity_type(
        identifier='dietaryEnergyConsumed',
        unit='.largeCalorie()',
        doc='A quantity sample type that measures the amount of energy consumed.'
    ),
    quantity_type(
        identifier='dietaryFatMonounsaturated',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of monounsaturated fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFatPolyunsaturated',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of polyunsaturated fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFatSaturated',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of saturated fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFatTotal',
        unit='.gram()',
        doc='A quantity sample type that measures the total amount of fat consumed.'
    ),
    quantity_type(
        identifier='dietaryFiber',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of fiber consumed.'
    ),
    quantity_type(
        identifier='dietaryFolate',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of folate (folic acid) consumed.'
    ),
    quantity_type(
        identifier='dietaryIodine',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of iodine consumed.'
    ),
    quantity_type(
        identifier='dietaryIron',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of iron consumed.'
    ),
    quantity_type(
        identifier='dietaryMagnesium',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of magnesium consumed.'
    ),
    quantity_type(
        identifier='dietaryManganese',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of manganese consumed.'
    ),
    quantity_type(
        identifier='dietaryMolybdenum',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of molybdenum consumed.'
    ),
    quantity_type(
        identifier='dietaryNiacin',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of niacin (vitamin B3) consumed.'
    ),
    quantity_type(
        identifier='dietaryPantothenicAcid',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of pantothenic acid (vitamin B5) consumed.'
    ),
    quantity_type(
        identifier='dietaryPhosphorus',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of phosphorus consumed.'
    ),
    quantity_type(
        identifier='dietaryPotassium',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of potassium consumed.'
    ),
    quantity_type(
        identifier='dietaryProtein',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of protein consumed.'
    ),
    quantity_type(
        identifier='dietaryRiboflavin',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of riboflavin (vitamin B2) consumed.'
    ),
    quantity_type(
        identifier='dietarySelenium',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of selenium consumed.'
    ),
    quantity_type(
        identifier='dietarySodium',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of sodium consumed.'
    ),
    quantity_type(
        identifier='dietarySugar',
        unit='.gram()',
        doc='A quantity sample type that measures the amount of sugar consumed.'
    ),
    quantity_type(
        identifier='dietaryThiamin',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of thiamin (vitamin B1) consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminA',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of vitamin A consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminB12',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of cyanocobalamin (vitamin B12) consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminB6',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of pyridoxine (vitamin B6) consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminC',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of vitamin C consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminD',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of vitamin D consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminE',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of vitamin E consumed.'
    ),
    quantity_type(
        identifier='dietaryVitaminK',
        unit='.gramUnit(with: .micro)',
        doc='A quantity sample type that measures the amount of vitamin K consumed.'
    ),
    quantity_type(
        identifier='dietaryWater',
        unit='.literUnit(with: .milli)',
        display_unit=LocaleDependentUnit(us='.fluidOunceUS()'),
        doc='A quantity sample type that measures the amount of water consumed.'
    ),
    quantity_type(
        identifier='dietaryZinc',
        unit='.gramUnit(with: .milli)',
        doc='A quantity sample type that measures the amount of zinc consumed.'
    ),

    # Alcohol Consumption
    quantity_type(
        identifier='bloodAlcoholContent',
        unit='.percent()',
        doc='A quantity sample type that measures the user’s blood alcohol content.'
    ),
    quantity_type(
        identifier='numberOfAlcoholicBeverages',
        unit='.count()',
        doc='A quantity sample type that measures the number of standard alcoholic drinks that the user has consumed.'
    ),

    # Mobility
    quantity_type(
        identifier='appleWalkingSteadiness',
        unit='.percent()',
        doc='A quantity sample type that measures the steadiness of the user’s gait.'
    ),
    quantity_type(
        identifier='sixMinuteWalkTestDistance',
        unit='.meter()',
        doc='A quantity sample type that stores the distance a user can walk during a six-minute walk test.'
    ),
    quantity_type(
        identifier='walkingSpeed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample type that measures the user’s average speed when walking steadily over flat ground.'
    ),
    quantity_type(
        identifier='walkingStepLength',
        unit='.meterUnit(with: .centi)',
        display_unit=LocaleDependentUnit(us='.inch()'),
        doc='A quantity sample type that measures the average length of the user’s step when walking steadily over flat ground.'
    ),
    quantity_type(
        identifier='walkingAsymmetryPercentage',
        unit='.percent()',
        doc='A quantity sample type that measures the percentage of steps in which one foot moves at a different speed than the other when walking on flat ground.'
    ),
    quantity_type(
        identifier='walkingDoubleSupportPercentage',
        unit='.percent()',
        doc='A quantity sample type that measures the percentage of time when both of the user’s feet touch the ground while walking steadily over flat ground.'
    ),
    quantity_type(
        identifier='stairAscentSpeed',
        unit='.meter() / .second()',
        display_unit=LocaleDependentUnit(us='.foot() / .second()'),
        doc='A quantity sample type measuring the user’s speed while climbing a flight of stairs.'
    ),
    quantity_type(
        identifier='stairDescentSpeed',
        unit='.meter() / .second()',
        display_unit=LocaleDependentUnit(us='.foot() / .second()'),
        doc='A quantity sample type measuring the user’s speed while descending a flight of stairs.'
    ),

    # UV Exposure
    quantity_type(
        identifier='uvExposure',
        unit='.count()',
        doc='A quantity sample type that measures the user’s exposure to UV radiation.'
    ),

    # Diving
    quantity_type(
        identifier='underwaterDepth',
        unit='.meter()',
        display_unit=LocaleDependentUnit(us='.foot()'),
        doc='A quantity sample that records a person’s depth underwater.'
    ),
    quantity_type(
        identifier='waterTemperature',
        unit='.degreeCelsius()',
        display_unit=LocaleDependentUnit(us='.degreeFahrenheit()', uk='.degreeCelsius()', metric='.degreeCelsius()'),
        doc=' A quantity sample that records the water temperature.'
    ),

    # Other
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='appleSleepingBreathingDisturbances',
        unit='.count()',
        doc='A quantity sample that records breathing disturbances during sleep.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='crossCountrySkiingSpeed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records cross-country skiing speed.'
    ),
    quantity_type(
        identifier='cyclingCadence',
        unit='.count() / .minute()',
        doc='A quantity sample that records cycling cadence.'
    ),
    quantity_type(
        identifier='cyclingFunctionalThresholdPower',
        unit='.watt()',
        doc='A quantity sample that records cycling functional threshold power.'
    ),
    quantity_type(
        identifier='cyclingPower',
        unit='.watt()',
        doc='A quantity sample that records cycling power.'
    ),
    quantity_type(
        identifier='cyclingSpeed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records cycling speed.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distanceCrossCountrySkiing',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample that records cross-country skiing distance.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distancePaddleSports',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample that records paddle sports distance.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distanceRowing',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample that records rowing distance.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='distanceSkatingSports',
        unit='.meterUnit(with: .kilo)',
        display_unit=LocaleDependentUnit(us='.mile()'),
        doc='A quantity sample that records skating sports distance.'
    ),
    quantity_type(
        identifier='environmentalSoundReduction',
        unit='.decibelHearingLevel()',
        doc='A quantity sample that records environmental sound reduction.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='estimatedWorkoutEffortScore',
        unit='.count()', # TODO not sure about this one
        doc='A quantity sample that records estimated physical effort during workouts.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='paddleSportsSpeed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records paddle sports speed.'
    ),
    quantity_type(
        identifier='physicalEffort',
        unit='.kilocalorie() / (.gramUnit(with: .kilo) * .hour())',
        doc='A quantity sample that records physical effort.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='rowingSpeed',
        unit='.meterUnit(with: .kilo) / .hour()',
        display_unit=LocaleDependentUnit(us='.mile() / .hour()'),
        doc='A quantity sample that records rowing speed.'
    ),
    quantity_type(
        identifier='timeInDaylight',
        unit='.minute()',
        doc='A quantity sample that records time spent in daylight.'
    ),
    quantity_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='workoutEffortScore',
        unit='.count()', # TODO not sure about this one
        doc='A quantity sample that records workout effort.'
    )
]


category_types: list[SampleType] = [
    # Activity
    category_type(
        identifier='appleStandHour',
        doc='A category sample type that counts the number of hours in the day during which the user has stood and moved for at least one minute per hour.'
    ),
    category_type(
        identifier='lowCardioFitnessEvent',
        doc='An event that indicates the user’s VO2 max values consistently fall below a particular aerobic fitness threshold.'
    ),

    # MARK: Reproductive Health
    category_type(
        identifier='menstrualFlow',
        doc='A category sample type that records menstrual cycles.'
    ),
    category_type(
        identifier='intermenstrualBleeding',
        doc='A category sample type that records spotting outside the normal menstruation period.'
    ),
    category_type(
        identifier='infrequentMenstrualCycles',
        doc='A category sample that indicates an infrequent menstrual cycle.'
    ),
    category_type(
        identifier='irregularMenstrualCycles',
        doc='A category sample that indicates an irregular menstrual cycle.'
    ),
    category_type(
        identifier='persistentIntermenstrualBleeding',
        doc='A category sample that indicates persistent intermenstrual bleeding.'
    ),
    category_type(
        identifier='prolongedMenstrualPeriods',
        doc='A category sample that indicates a prolonged menstrual cycle.'
    ),
    category_type(
        identifier='cervicalMucusQuality',
        doc='A category sample type that records the quality of the user’s cervical mucus.'
    ),
    category_type(
        identifier='ovulationTestResult',
        doc='A category sample type that records the result of an ovulation home test.'
    ),
    category_type(
        identifier='progesteroneTestResult',
        doc='A category type that represents the results from a home progesterone test.'
    ),
    category_type(
        identifier='sexualActivity',
        doc='A category sample type that records sexual activity.'
    ),
    category_type(
        identifier='contraceptive',
        doc='A category sample type that records the use of contraceptives.'
    ),
    category_type(
        identifier='pregnancy',
        doc='A category type that records pregnancy.'
    ),
    category_type(
        identifier='pregnancyTestResult',
        doc='A category type that represents the results from a home pregnancy test.'
    ),
    category_type(
        identifier='lactation',
        doc='A category type that records lactation.'
    ),

    # Hearing
    category_type(
        identifier='environmentalAudioExposureEvent',
        doc='A category sample type that records exposure to potentially damaging sounds from the environment.'
    ),
    category_type(
        identifier='headphoneAudioExposureEvent',
        doc='A category sample type that records exposure to potentially damaging sounds from headphones.'
    ),

    # Vital Signs
    category_type(
        identifier='lowHeartRateEvent',
        doc='A category sample type for low heart rate events.'
    ),
    category_type(
        identifier='highHeartRateEvent',
        doc='A category sample type for high heart rate events.'
    ),
    category_type(
        identifier='irregularHeartRhythmEvent',
        doc='A category sample type for irregular heart rhythm events.'
    ),


    # Mobility
    category_type(
        identifier='appleWalkingSteadinessEvent',
        doc='A category sample type that records an incident where the user showed a reduced score for their gait’s steadiness.'
    ),

    # Mindfulness and Sleep

    category_type(
        identifier='mindfulSession',
        doc='A category sample type for recording a mindful session.'
    ),
    category_type(
        identifier='sleepAnalysis',
        doc='A category sample type for sleep analysis information.'
    ),
    
    # Self Care
    category_type(
        identifier='toothbrushingEvent',
        doc='A category sample type for toothbrushing events.'
    ),
    category_type(
        identifier='handwashingEvent',
        doc='A category sample type for handwashing events.'
    ),

    # Symptoms
    # Symptoms: Abdominal and Gastrointestinal
    category_type(
        identifier='abdominalCramps',
        doc='A category type that records abdominal cramps as a symptom.'
    ),
    category_type(
        identifier='bloating',
        doc='A category type that records bloating as a symptom.'
    ),
    category_type(
        identifier='constipation',
        doc='A category type that records constipation as a symptom.'
    ),
    category_type(
        identifier='diarrhea',
        doc='A category type that records diarrhea as a symptom.'
    ),
    category_type(
        identifier='heartburn',
        doc='A category type that records heartburn as a symptom.'
    ),
    category_type(
        identifier='nausea',
        doc='A category type that records nausea as a symptom.'
    ),
    category_type(
        identifier='vomiting',
        doc='A category type that records vomiting as a symptom.'
    ),
    # Symptoms: Constitutional
    category_type(
        identifier='appetiteChanges',
        doc='A category type that records changes in appetite as a symptom.'
    ),
    category_type(
        identifier='chills',
        doc='A category type that records chills as a symptom.'
    ),
    category_type(
        identifier='dizziness',
        doc='A category type that records dizziness as a symptom.'
    ),
    category_type(
        identifier='fainting',
        doc='A category type that records fainting as a symptom.'
    ),
    category_type(
        identifier='fatigue',
        doc='A category type that records fatigue as a symptom.'
    ),
    category_type(
        identifier='fever',
        doc='A category type that records fever as a symptom.'
    ),
    category_type(
        identifier='generalizedBodyAche',
        doc='A category type that records body ache as a symptom.'
    ),
    category_type(
        identifier='hotFlashes',
        doc='A category type that records hot flashes as a symptom.'
    ),
    # Symptoms: Heart and Lung
    category_type(
        identifier='chestTightnessOrPain',
        doc='A category type that records chest tightness or pain as a symptom.'
    ),
    category_type(
        identifier='coughing',
        doc='A category type that records coughing as a symptom.'
    ),
    category_type(
        identifier='rapidPoundingOrFlutteringHeartbeat',
        doc='A category type that records a rapid, pounding, or fluttering heartbeat as a symptom.'
    ),
    category_type(
        identifier='shortnessOfBreath',
        doc='A category type that records shortness of breath as a symptom.'
    ),
    category_type(
        identifier='skippedHeartbeat',
        doc='A category type that records skipped heartbeat as a symptom.'
    ),
    category_type(
        identifier='wheezing',
        doc='A category type that records wheezing as a symptom.'
    ),
    # Symptoms: Musculoskeletal
    category_type(
        identifier='lowerBackPain',
        doc='A category type that records lower back pain as a symptom.'
    ),
    # Symptoms: Neurological
    category_type(
        identifier='headache',
        doc='A category type that records headache as a symptom.'
    ),
    category_type(
        identifier='memoryLapse',
        doc='A category type that records memory lapse as a symptom.'
    ),
    category_type(
        identifier='moodChanges',
        doc='A category type that records mood changes as a symptom.'
    ),
    # Symptoms: Nose and Throat
    category_type(
        identifier='lossOfSmell',
        doc='A category type that records loss of smell as a symptom.'
    ),
    category_type(
        identifier='lossOfTaste',
        doc='A category type that records loss of taste as a symptom.'
    ),
    category_type(
        identifier='runnyNose',
        doc='A category type that records runny nose as a symptom.'
    ),
    category_type(
        identifier='soreThroat',
        doc='A category type that records sore throat as a symptom.'
    ),
    category_type(
        identifier='sinusCongestion',
        doc='A category type that records sinus congestion as a symptom.'
    ),
    # Symptoms: Reproduction
    category_type(
        identifier='breastPain',
        doc='A category type that records breast pain as a symptom.'
    ),
    category_type(
        identifier='pelvicPain',
        doc='A category type that records pelvic pain as a symptom.'
    ),
    category_type(
        identifier='vaginalDryness',
        doc='A category type that records vaginal dryness as a symptom.'
    ),
    category_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='bleedingDuringPregnancy',
        doc='A category type that records bleeding during pregnancy as a symptom.'
    ),
    category_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='bleedingAfterPregnancy',
        doc='A category type that records bleeding after pregnancy as a symptom.'
    ),
    # Symptoms: Skin and Hair
    category_type(
        identifier='acne',
        doc='A category type that records acne as a symptom.'
    ),
    category_type(
        identifier='drySkin',
        doc='A category type that records dry skin as a symptom.'
    ),
    category_type(
        identifier='hairLoss',
        doc='A category type that records hair loss as a symptom.'
    ),
    # Symptoms: Sleep
    category_type(
        identifier='nightSweats',
        doc='A category type that records night sweats as a symptom.'
    ),
    category_type(
        identifier='sleepChanges',
        doc='A category type that records sleep changes as a symptom.'
    ),
    category_type(
        availability=Availability(iOS='18.0', macOS='15.0', watchOS='11.0', visionOS='2.0'),
        identifier='sleepApneaEvent',
        doc='A category type that records sleep apnea as a symptom.'
    ),
    # Symptoms: Urinary
    category_type(
        identifier='bladderIncontinence',
        doc='A category type that records bladder incontinence as a symptom.'
    )
]


correlation_types: list[SampleType] = [
    correlation_type(
        identifier='bloodPressure',
        doc='The sample type representing blood pressure correlation samples',
        associated_quantity_types=['bloodPressureDiastolic', 'bloodPressureSystolic']
    ),
    correlation_type(
        identifier='food',
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
        doc='The activity move mode characteristic.'
    ),
    characteristic_type(
        identifier='biologicalSex',
        doc="The characteristic representing the user's biological sex."
    ),
    characteristic_type(
        identifier='bloodType',
        doc="The characteristic representing the user's blood type."
    ),
    characteristic_type(
        identifier='dateOfBirth',
        doc="The characteristic representing the user's date of birth."
    ),
    characteristic_type(
        identifier='fitzpatrickSkinType',
        doc="The characteristic representing the user's skin type."
    ),
    characteristic_type(
        identifier='wheelchairUse',
        doc="The characteristic representing the user's wheelchair use status."
    ),
]

clinical_types: list[SampleType] = [
    clinical_type(
        identifier='allergyRecord',
        doc='A type identifier for records of allergic or intolerant reactions.'
    ),
    clinical_type(
        identifier='clinicalNoteRecord',
        doc='A type identifier for records of clinical notes.'
    ),
    clinical_type(
        identifier='conditionRecord',
        doc='A type identifier for records of a condition, problem, diagnosis, or other event.'
    ),
    clinical_type(
        identifier='immunizationRecord',
        doc='A type identifier for records of the current or historical administration of vaccines.'
    ),
    clinical_type(
        identifier='labResultRecord',
        doc='A type identifier for records of lab results.'
    ),
    clinical_type(
        identifier='medicationRecord',
        doc='A type identifier for records of medication.'
    ),
    clinical_type(
        identifier='procedureRecord',
        doc='A type identifier for records of procedures.'
    ),
    clinical_type(
        identifier='vitalSignRecord',
        doc='A type identifier for records of vital signs.'
    ),
    clinical_type(
        identifier='coverageRecord',
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
            doc: str,
            hkSampleType: str,
            variant: str,
            identifier_def: Optional[str]
        ):
        self.sampleTypePropertyName = sampleTypePropertyName
        self.availability = availability
        self.hkSampleClass = hkSampleClass
        self.doc = doc
        self.hkSampleType = hkSampleType
        self.variant = variant
        self.identifier_def = identifier_def



other_sample_types = [
    OtherSampleType(
        sampleTypePropertyName='electrocardiogram',
        hkSampleClass='HKElectrocardiogram',
        doc='The electrocardiogram sample type',
        hkSampleType='HKSampleType.electrocardiogramType()',
        variant='.other',
        identifier_def='HKElectrocardiogramTypeIdentifier'
    ),
    OtherSampleType(
        sampleTypePropertyName='audiogram',
        hkSampleClass='HKAudiogramSample',
        doc='The audiogram sample type',
        hkSampleType='HKSampleType.audiogramSampleType()',
        variant='.other',
        identifier_def='HKAudiogramSampleTypeIdentifier'
    ),
    OtherSampleType(
        sampleTypePropertyName='workout',
        hkSampleClass='HKWorkout',
        doc='The workout sample type',
        hkSampleType='HKSampleType.workoutType()',
        variant='.other',
        identifier_def='HKWorkoutTypeIdentifier'
    ),
    OtherSampleType(
        sampleTypePropertyName='visionPrescription',
        hkSampleClass='HKVisionPrescription',
        doc='The vision prescription sample type',
        hkSampleType='HKSampleType.visionPrescriptionType()',
        variant='.other',
        identifier_def='HKVisionPrescriptionTypeIdentifier'
    ),
    OtherSampleType(
        availability=Availability(iOS='18.0', watchOS='11.0', macOS='15.0', visionOS='2.0'),
        sampleTypePropertyName='stateOfMind',
        hkSampleClass='HKStateOfMind',
        doc='The state of mind sample type',
        hkSampleType='HKSampleType.stateOfMindType()',
        variant='.other',
        identifier_def='HKDataTypeIdentifierStateOfMind'
    ),
    OtherSampleType(
        sampleTypePropertyName='heartbeatSeries',
        hkSampleClass='HKHeartbeatSeriesSample',
        doc='The heartbeat series sample type',
        hkSampleType='HKSeriesType.heartbeat()',
        variant='.other',
        identifier_def='HKDataTypeIdentifierHeartbeatSeries'
    ),
    OtherSampleType(
        sampleTypePropertyName='workoutRoute',
        hkSampleClass='HKWorkoutRoute',
        doc='The workout route sample type',
        hkSampleType='HKSeriesType.workoutRoute()',
        variant='.other',
        identifier_def='HKWorkoutRouteTypeIdentifier'
    ),
    OtherSampleType(
        availability=Availability(iOS='18.0', watchOS='11.0', macOS='15.0', visionOS='2.0'),
        sampleTypePropertyName='gad7',
        hkSampleClass='HKGAD7Assessment',
        doc='The GAD-7 (generalized anxiety disorder 7) score type',
        hkSampleType='HKScoredAssessmentType(.GAD7)',
        variant='.other',
        identifier_def='HKScoredAssessmentTypeIdentifier.GAD7'
    ),
    OtherSampleType(
        availability=Availability(iOS='18.0', watchOS='11.0', macOS='15.0', visionOS='2.0'),
        sampleTypePropertyName='phq9',
        hkSampleClass='HKPHQ9Assessment',
        doc='The PHQ-9 (nine-item Patient Health Questionnaire) score type',
        hkSampleType='HKScoredAssessmentType(.PHQ9)',
        variant='.other',
        identifier_def='HKScoredAssessmentTypeIdentifier.PHQ9'
    )
]
