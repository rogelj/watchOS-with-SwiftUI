import WatchKit
import SwiftUI
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView> {
  var image: Image!
  var message: String!

  override var body: NotificationView {
    return NotificationView(message: message, image: image)
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  override func didReceive(_ notification: UNNotification) {
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.

    let content = notification.request.content
    message = content.body

    let num = Int.random(in: 1...20)
    image = Image("cat\(num)")
  }
}
