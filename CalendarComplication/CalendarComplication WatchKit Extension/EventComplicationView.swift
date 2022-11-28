import SwiftUI
import EventKit

struct EventComplicationView: View {
  @ObservedObject private var eventStore = EventStore.shared

  var body: some View {
    VStack {
      if eventStore.calendarAccessGranted == false {
        Text("This app requires calendar permission.")
      } else if let event = eventStore.nextEvent {
      } else {
        Text("No more events today.")
      }
    }
    .task {
      eventStore.requestAccess()
    }
  }
}

struct EventComplicationView_Previews: PreviewProvider {
  static var previews: some View {
    EventComplicationView()
  }
}
