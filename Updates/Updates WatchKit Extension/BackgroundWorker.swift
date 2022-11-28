//
//  BackgroundWorker.swift
//  Updates WatchKit Extension
//
//  Created by J Rogel PhD on 28/11/2022.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import Foundation
import WatchKit

final class BackgroundWorker {
  public func schedule(firstTime: Bool = false) {
    let minutes = firstTime ? 1 : 15

    let when = Calendar.current.date(
      byAdding: .minute,
      value: minutes,
      to: Date.now
    )!

    WKExtension.shared()
      .scheduleBackgroundRefresh(
        withPreferredDate: when,
        userInfo: nil
      ) { error in
        if let error = error {
          print("Unable to schedule: \(error.localizedDescription)")
        }
      }
  }

  public func perform(_ completion: (Bool) -> Void) {
    // Do the background work here
    completion(true)
  }
}
