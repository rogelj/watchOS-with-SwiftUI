import SwiftUI
import Combine

struct ContentView: View {
  @EnvironmentObject private var season: Season
  @State private var snapshotHandler: (() -> Void)?

  private let pushViewForSnapshotPublisher = NotificationCenter
    .default
    .publisher(for: .pushViewForSnapshot)
  
  public enum Destination {
    case record
    case schedule
  }

  @State private var activeDestination: Destination?
  @State private var selectedMatchId: Match.ID?

  var body: some View {
    VStack {
      Label(season.ourTeam.name, image: season.ourTeam.logoName)

      if let match = season.nextMatch {
        NavigationLink(
          destination: ScheduleView(
            selectedMatchId: $selectedMatchId
          ),
          isActive: isDestinationActive(.schedule)
        ) {
          VStack(alignment: .leading) {
            HStack {
              Text("Next: ")
                .font(.headline)
              Text(match.opponent.name)
                .font(.body)
            }
            
            Text(match.date.formatted(.dateTime
                                        .hour()
                                        .minute()
                                        .year(.twoDigits)
                                        .month(.defaultDigits)
                                        .day(.defaultDigits)))
              .font(.subheadline)
          }
        }
      }

      NavigationLink(
        destination: RecordView(snapshotHandler: snapshotHandler),
        isActive: isDestinationActive(.record)
      ) {
        HStack {
          Text("Record: ")
            .font(.headline)
          Text(season.record())
            .font(.body)
        }
      }
      .onReceive(pushViewForSnapshotPublisher) {
        pushViewForSnapshot($0)
      }
    }
  }

  private func pushViewForSnapshot(_ notification: Notification) {
    // 1
    guard let info = try? SnapshotUserInfo.from(notification: notification) else {
      return
    }

    // 2
    snapshotHandler = info.handler
    selectedMatchId = info.matchID

    activeDestination = info.destination
  }
  private func isDestinationActive(_ destination: Destination) -> Binding<Bool> {
      .init(
        get: { activeDestination == destination },
        set: { activeDestination = $0 ? destination : nil }
      )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
