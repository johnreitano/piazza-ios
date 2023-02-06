//
//  Global.swift
//  Piazza
//
//  Created by John Reitano on 1/29/23.
//

import Foundation
import Turbo

struct Global {
  static let pathConfiguration = PathConfiguration(
    sources:
      [
        .file(
          Bundle.main.url(
            forResource: "path_configuration",
            withExtension: "json"
          )!)
      ]
  )
}
