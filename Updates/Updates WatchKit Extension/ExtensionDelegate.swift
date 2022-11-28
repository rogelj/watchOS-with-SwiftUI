import WatchKit
import ClockKit

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
  private let backgroundWorker = BackgroundWorker()

  public static func updateActiveComplications() {
    let server = CLKComplicationServer.sharedInstance()
    server.activeComplications?.forEach {
      server.reloadTimeline(for: $0)
    }
  }

  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    backgroundTasks.forEach { task in
      switch task {
        case let task as WKApplicationRefreshBackgroundTask:
          backgroundWorker.perform { updateComplications in
            if updateComplications {
              Self.updateActiveComplications()
            }

            backgroundWorker.schedule()
            task.setTaskCompletedWithSnapshot(false)
          }
        default:
          task.setTaskCompletedWithSnapshot(false)
      }
    }
  }
}
