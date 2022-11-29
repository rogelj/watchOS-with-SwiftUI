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
  }
}
