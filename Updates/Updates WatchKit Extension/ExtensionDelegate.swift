import WatchKit
import ClockKit

final class ExtensionDelegate: NSObject, WKExtensionDelegate {
  private let backgroundWorker = BackgroundWorker()
  private var downloads: [String: UrlDownloader] = [:]

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
        case let task as WKURLSessionRefreshBackgroundTask:
          let downloder = downloader(for: task.sessionIdentifier)
          downloder.perform { updateComplications in
            if updateComplications {
              Self.updateActiveComplications()
            }
            downloder.schedule()
            task.setTaskCompletedWithSnapshot(false)
          }
        default:
          task.setTaskCompletedWithSnapshot(false)
      }
    }
  }

  private func downloader(for identifier: String) -> UrlDownloader {
    guard let download = downloads[identifier] else {
      let downloader = UrlDownloader(identifier: identifier)
      downloads[identifier] = downloader
      return downloader
    }
    return download
  }
}
