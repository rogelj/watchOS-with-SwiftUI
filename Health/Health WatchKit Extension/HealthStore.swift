//
//  HealthStore.swift
//  Health WatchKit Extension
//
//  Created by J Rogel PhD on 29/11/2022.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import Foundation
import HealthKit

final class HealthStore {
  static let shared = HealthStore()
  private var healthStore: HKHealthStore?

  private init() {
    guard HKHealthStore.isHealthDataAvailable() else {
      return
    }

    healthStore = HKHealthStore()

    Task {
      try await healthStore!.requestAuthorization(toShare: [brushingCategoryType, waterQuantityType],
                                                  read: [brushingCategoryType, waterQuantityType, bodyMassType])

      await MainActor.run {
        NotificationCenter.default.post(name:.healthStoreLoaded, object: nil)
      }
    }
  }

  private func save(_ sample: HKSample) async throws {
    guard let healthStore = healthStore else {
      throw HKError(.errorHealthDataUnavailable)
    }

    let _: Bool = try await withCheckedThrowingContinuation {
      continuation in

      healthStore.save(sample) { _, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        continuation.resume(returning: true)
      }
    }
  }

  private let brushingCategoryType = HKCategoryType.categoryType(forIdentifier: .toothbrushingEvent)!

  func logBrushing(startDate: Date) async throws {
    let status = healthStore?.authorizationStatus(for: brushingCategoryType)

    guard status == .sharingAuthorized else {
      return
    }

    let sample = HKCategorySample(type: brushingCategoryType, value: HKCategoryValue.notApplicable.rawValue,
                                  start: startDate, end: Date.now)

    try await save(sample)
  }

  private let waterQuantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!

  private let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!

  var isWaterEnabled: Bool {
    let status = healthStore?.authorizationStatus(for: waterQuantityType)
    return status == .sharingAuthorized
  }

  func logWater(quantity: HKQuantity) async throws {
    guard isWaterEnabled else {
      return
    }

    let sample = HKQuantitySample(type: waterQuantityType, quantity: quantity, start: Date.now, end: Date.now)

    try await save(sample)
  }

  // Determine current body mass
  private func currentBodyMass() async throws -> Double? {
    guard let healthStore = healthStore else {
      throw HKError(.errorHealthDataUnavailable)
    }

    let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
        guard let latest = samples?.first as? HKQuantitySample else {
          continuation.resume(returning: nil)
          return
        }

        let pounds = latest.quantity.doubleValue(for: .pound())
        continuation.resume(returning: pounds)
      }

      healthStore.execute(query)
    }
  }

  // How much water has been drunk today
  private func drankToday() async throws -> (
    ounces: Double,
    amount: Measurement<UnitVolume>
  ) {
    guard let healthStore = healthStore else {
      throw HKError(.errorHealthDataUnavailable)
    }

    let start = Calendar.current.startOfDay(for: Date.now)

    let predicate = HKQuery.predicateForSamples(withStart: start, end: Date.now, options: .strictStartDate)

    return try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsQuery(quantityType: waterQuantityType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum
      ) {
        _, statistics, _ in
        guard let quantity = statistics?.sumQuantity() else {
          continuation.resume(returning: (0, .init(value: 0, unit: .liters))
          )
          return
        }

        let ounces = quantity.doubleValue(for: .fluidOunceUS())
        let liters = quantity.doubleValue(for: .liter())

        continuation.resume(returning: (ounces, .init(value: liters, unit: .liters))
        )
      }

      healthStore.execute(query)
    }
  }

  // what to display in terms of water consumption
  func currentWaterStatus() async throws -> (Measurement<UnitVolume>, Double?) {
    let (ounces, measurement) = try await drankToday()

    guard let mass = try? await currentBodyMass() else {
      return (measurement, nil)
    }

    let goal = mass / 2.0
    let percentComplete = ounces / goal

    return (measurement, percentComplete)
  }

}