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
      try await healthStore!.requestAuthorization(toShare: [brushingCategoryType],
                                                  read: [brushingCategoryType])
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

}
