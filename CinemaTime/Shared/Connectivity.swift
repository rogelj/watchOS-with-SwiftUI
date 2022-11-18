  //
  //  Connectivity.swift
  //  CinemaTime
  //
  //  Created by J Rogel PhD on 18/11/2022.
  //

import Foundation
import WatchConnectivity

final class Connectivity: NSObject, ObservableObject {
  @Published var purchasedIds: [Int] = []
  static let shared = Connectivity()

  override private init() {
    super.init()
#if !os(watchOS)
    guard WCSession.isSupported() else {
      return
    }
#endif
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  public func send(movieIds: [Int]) {
    guard WCSession.default.activationState == .activated else {
      return
    }

      // 1
#if os(watchOS)
      // 2
    guard WCSession.default.isCompanionAppInstalled else {
      return
    }
#else
      // 3
    guard WCSession.default.isWatchAppInstalled else {
      return
    }
#endif

    let userInfo: [String: [Int]] = [
      ConnectivityUserInfoKey.purchased.rawValue: movieIds
    ]

    WCSession.default.transferUserInfo(userInfo)
  }
}

  // MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
  }

#if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
  }

  func sessionDidDeactivate(_ session: WCSession) {
      // If the person has more than one watch, and they switch,
      // reactivate their session on the new device.
    WCSession.default.activate()

  }
#endif

  func session(
    _ session: WCSession,
    didReceiveUserInfo userInfo: [String: Any] = [:]
  ) {
    let key = ConnectivityUserInfoKey.purchased.rawValue
    guard let ids = userInfo[key] as? [Int] else {
      return
    }
    self.purchasedIds = ids
  }
}

