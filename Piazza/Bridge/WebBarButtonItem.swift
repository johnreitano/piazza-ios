//
//  WebBarButtonItem.swift
//  Piazza
//
//  Created by John Reitano on 2/5/23.
//

import Foundation
import UIKit

class WebBarButtonItem: UIBarButtonItem {
    let id: String
    init?(_ data: [String: String]) {
        if let id = data["id"] {
            self.id = id
        } else {
            return nil
        }
        
        super.init()
        
        self.title = data["title"]
        self.style = .plain
        self.target = nil
        self.action = #selector(RoutingController.bridgeElementTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
