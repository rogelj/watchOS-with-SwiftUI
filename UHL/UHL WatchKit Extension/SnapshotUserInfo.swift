//
//  SnapshotUserInfo.swift
//  UHL WatchKit App
//
//  Created by J Rogel PhD on 23/11/2022.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import Foundation

struct SnapshotUserInfo {
  // 1
  let handler: () -> Void

  // 2
  let destination: ContentView.Destination

  // 3
  let matchID: Match.ID?

  init(
    handler: @escaping () -> Void,
    destination: ContentView.Destination,
    matchID: Match.ID? = nil
  ) {
    self.handler = handler
    self.destination = destination
    self.matchID = matchID
  }

  // 1
  private enum Keys: String {
    case handler, destination, matchID
  }

  // 2
  func encode() -> [AnyHashable: Any] {
    return [
      Keys.handler.rawValue: handler,
      Keys.destination.rawValue: destination,
      // 3
      Keys.matchID.rawValue: matchID as Any
    ]
  }

  static func from(notification: Notification) throws -> Self {
    // 2
    guard let userInfo = notification.userInfo else {
      throw SnapshotError.noUserInfo
    }

    guard let handler = userInfo[Keys.handler.rawValue] as? () -> Void else {
      throw SnapshotError.noHandler
    }

    guard let destination = userInfo[Keys.destination.rawValue] as? ContentView.Destination else {
      throw SnapshotError.badDestination
    }

    // 3
    return .init(handler: handler,
                 destination: destination,
                 matchID: userInfo[Keys.matchID.rawValue] as? Match.ID
    )
  }
}

enum SnapshotError: Error {
  case noHandler, badDestination, badMatchID, noUserInfo
}
