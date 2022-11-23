import WatchKit

final class ExtensionDelegate: NSObject, WKApplicationDelegate {
  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
      // 1
    backgroundTasks.forEach { task in
        // 2
      guard let snapshot = task as? WKSnapshotRefreshBackgroundTask else {
        task.setTaskCompletedWithSnapshot(false)
        return
      }

        // 3
      print("Taking a snapshot")

      let nextSnapshotDate = nextSnapshotDate()

      let handler = {
        snapshot.setTaskCompleted(
          restoredDefaultState: false,
          estimatedSnapshotExpiration: nextSnapshotDate,
          userInfo: nil
        )
      }

      // 1
      var snapshotUserInfo: SnapshotUserInfo?

      // 2
      if lastMatchPlayedRecently() {
        snapshotUserInfo = SnapshotUserInfo(
          handler: handler,
          destination: .record
        )
      } else if let id = idForPendingMatch() {
        print("Going to schedule")
        snapshotUserInfo = SnapshotUserInfo(
          handler: handler,
          destination: .schedule,
          matchID: id
        )
      }

      // 3
      if let snapshotUserInfo = snapshotUserInfo {
        NotificationCenter.default.post(
          name: .pushViewForSnapshot,
          object: nil,
          userInfo: snapshotUserInfo.encode()
        )
      } else {
        // 4
        handler()
      }
    }
  }

  private func nextSnapshotDate() -> Date {
    // 1
    guard let nextMatch = Season.shared.nextMatch else {
      return .distantFuture
    }

    // 2
    let twoDaysLater = Calendar.current.date(
      byAdding: .day,
      value: 2,
      to: nextMatch.date
    )!

    // 3
    return Calendar.current.startOfDay(for: twoDaysLater)
  }

  private func lastMatchPlayedRecently() -> Bool {
    // 1
    guard let last = Season.shared.pastMatches().last?.date else {
      print("No last date")
      return false
    }

    print("The date is \(last.formatted()) and now is \(Date.now.formatted())")

    // 2
    return Calendar.current.isDateInYesterday(last) ||
    Calendar.current.isDateInToday(last)
  }

  private func idForPendingMatch() -> Match.ID? {
    guard let match = Season.shared.nextMatch else {
      return nil
    }

    let date = match.date
    let calendar = Calendar.current

    if calendar.isDateInTomorrow(date) || calendar.isDateInToday(date) {
      return match.id
    } else {
      return nil
    }
  }
}
