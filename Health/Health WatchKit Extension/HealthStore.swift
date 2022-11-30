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

}
