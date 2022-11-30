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
            .padding()
          } else {
            Text("Please enable water tracking in Apple Health.")
          }
        }
      }
    }

  private func logWater(quantity: HKQuantity) {
    Task {
      try await HealthStore.shared.logWater(quantity: quantity)
    }
  }
}

struct WaterView_Previews: PreviewProvider {
    static var previews: some View {
        WaterView()
    }
}
