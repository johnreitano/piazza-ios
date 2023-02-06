//
//  WebBridgeMessage.swift
//  Piazza
//
//  Created by John Reitano on 2/5/23.
//

import Foundation

struct WebBridgeMessage {
  let type: String
  let data: [String: String]

  init?(_ message: Any) {
    if let messageDict = message as? [String: Any],
       let type = messageDict["type"] as? String,
       let data = messageDict["data"] as? [String: String] {
      self.type = type
      self.data = data
    } else {
      return nil
    }
  }
}
