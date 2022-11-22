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

  public func send(
    movieIds: [Int],
    delivery: Delivery,
    replyHandler: (([String: Any]) -> Void)? = nil,
    errorHandler: ((Error) -> Void)? = nil
  ) {
    guard canSendToPeer() else { return }

    let userInfo: [String: [Int]] = [
      ConnectivityUserInfoKey.purchased.rawValue: movieIds
    ]

    switch delivery {
      case .failable:
        WCSession.default.sendMessage(
          userInfo,
        replyHandler: optionalMainQueueDispatch(handler: replyHandler),
        errorHandler: optionalMainQueueDispatch(handler: errorHandler)
        )

      case .guaranteed:
        WCSession.default.transferUserInfo(userInfo)

      case .highPriority:
        do {
          try WCSession.default.updateApplicationContext(userInfo)
        } catch {
          errorHandler?(error)
        }
    }
  }

  public func send(
    data: Data,
    replyHandler: ((Data) -> Void)? = nil,
    errorHandler: ((Error) -> Void)? = nil
  ) {
    guard canSendToPeer() else { return }

    WCSession.default.sendMessageData(
      data,
      replyHandler: optionalMainQueueDispatch(handler: replyHandler),
      errorHandler: optionalMainQueueDispatch(handler: errorHandler)
    )
  }


  private func canSendToPeer() -> Bool {
    guard WCSession.default.activationState == .activated else {
      return false
    }

#if os(watchOS)
    guard WCSession.default.isCompanionAppInstalled else {
      return false
    }
#else
    guard WCSession.default.isWatchAppInstalled else {
      return false
    }
#endif

    return true
  }

    // 1
  typealias OptionalHandler<T> = ((T) -> Void)?

    // 2
  private func optionalMainQueueDispatch<T>(
    handler: OptionalHandler<T>
  ) -> OptionalHandler<T> {
      // 3
    guard let handler = handler else {
      return nil
    }

      // 4
    return { item in
        // 5
      DispatchQueue.main.async {
        handler(item)
      }
    }
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
    update(from: userInfo)
  }

  func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
    update(from: applicationContext)
  }

    // This method is called when a message is sent with failable priority
    // *and* a reply was requested.
  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    update(from: message)

    let key = ConnectivityUserInfoKey.verified.rawValue
    replyHandler([key: true])
  }

    // This method is called when a message is sent with failable priority
    // and a reply was *not* requested.
  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any]
  ) {
    update(from: message)
  }

  func session(
    _ session: WCSession,
    didReceiveMessageData messageData: Data
  ) {
  }

  func session(
    _ session: WCSession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping (Data) -> Void
  ) {
  }

  private func update(from dictionary: [String: Any]) {
    let key = ConnectivityUserInfoKey.purchased.rawValue
    guard let ids = dictionary[key] as? [Int] else {
      return
    }
    self.purchasedIds = ids
  }
}


