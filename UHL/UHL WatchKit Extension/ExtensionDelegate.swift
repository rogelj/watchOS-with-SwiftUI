import WatchKit

final class ExtensionDelegate: NSObject, WKApplicationDelegate {
  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
      // 1
    backgroundTasks.forEach { task in
        // 2
      guard task is WKSnapshotRefreshBackgroundTask else {
        task.setTaskCompletedWithSnapshot(false)
        return
      }

        // 3
      print("Taking a snapshot")

        // 4
      task.setTaskCompletedWithSnapshot(true)
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
}
