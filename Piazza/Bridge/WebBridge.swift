//
//  WebBridge.swift
//  Piazza
//
//  Created by John Reitano on 2/5/23.
//

import Foundation
import WebKit

extension WKWebView {
    func attachWebBridge() {
        let script = scriptNamed("bridge")!
        evaluateJavaScript(script)
    }
    
    func click(elementId: String) {
        evaluateJavaScript(
            "window.webBridge.nativeActions.click(\(elementId))"
        )
    }
    
    private func scriptNamed(_ name: String) -> String? {
        guard let filepath = Bundle.main.path(
            forResource: name, ofType: "js"
        ) else {
            return nil
        }
        
        return try? String(contentsOfFile: filepath)
    }
}

extension RoutingController {
  @objc func bridgeElementTapped(_ sender: Any) {
    if let sender = sender as? WebBarButtonItem {
      session.webView.click(elementId: sender.id)
    }
  }
}
