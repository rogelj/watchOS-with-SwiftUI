  //
  //  WaterView.swift
  //  Health WatchKit App
  //
  //  Created by J Rogel PhD on 30/11/2022.
  //  Copyright © 2022 Ray Wenderlich. All rights reserved.
  //

import SwiftUI
import HealthKit

struct WaterView: View {
  @State private var consumed = ""
  @State private var percent = ""

  var body: some View {
    ScrollView {
      VStack {
        if HealthStore.shared.isWaterEnabled {
          Text("Add water")
            .font(.headline)

          HStack {
            LogWaterButton(size: .small) { logWater(quantity: $0) }
            LogWaterButton(size: .large) { logWater(quantity: $0) }
          }
          .padding(.bottom)

          HStack {
            Text("Today:")
              .font(.headline)
            Text(consumed)
              .font(.body)
          }

          HStack {
            Text("Goal:")
              .font(.headline)
            Text(percent)
              .font(.body)
          }
        } else {
          Text("Please enable water tracking in Apple Health.")
        }
      }
    }
    .task {
      await updateStatus()
    }
  }

  private func logWater(quantity: HKQuantity) {
    Task {
      try await HealthStore.shared.logWater(quantity: quantity)
      await updateStatus()
    }
  }

  private func updateStatus() async {
    guard let (measurement, percent) = try? await HealthStore.shared.currentWaterStatus()
    else {
      consumed = "0"
      percent = "Unknown"
      return
    }

    consumed = consumedFormat.string(from: measurement)

    self.percent = percent?.formatted(.percent.precision(.fractionLength(0))) ?? "Unknown"
  }

  private let consumedFormat: MeasurementFormatter = {
    var fmt = MeasurementFormatter()
    fmt.unitOptions = .naturalScale
    return fmt
  }()
}
struct WaterView_Previews: PreviewProvider {
  static var previews: some View {
    WaterView()
  }
}
