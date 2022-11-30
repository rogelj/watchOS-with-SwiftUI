import SwiftUI
import HealthKit

enum Glass {
  case small, large
}

struct LogWaterButton: View {
  let title: String
  let size: Glass
  let onTap: (HKQuantity) -> Void

  var body: some View {
    Button(title, action: tapped)
  }

  init(size: Glass, onTap: @escaping (HKQuantity) -> Void) {
    switch (Locale.current.usesMetricSystem, size) {
    case (true, .small): title = "250ml"
    case (true, .large): title = "500ml"
    case (false, .small): title = "8oz"
    case (false, .large): title = "16oz"
    }

    self.onTap = onTap
    self.size = size
  }

  private func tapped() {
    let unit: HKUnit
    let value: Double

    if Locale.current.usesMetricSystem {
      unit = .literUnit(with: .milli)
      value = size == .small ? 250 : 500
    } else {
      unit = .fluidOunceUS()
      value = size == .small ? 8 : 16
    }

    let quantity = HKQuantity(unit: unit, doubleValue: value)

    onTap(quantity)
  }
}

struct LogWaterButton_Previews: PreviewProvider {
  static var previews: some View {
    LogWaterButton(size: .small) { _ in }
  }
}
