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
    
    private func scriptNamed(_ name: String) -> String? {
        guard let filepath = Bundle.main.path(
            forResource: name, ofType: "js"
        ) else {
            return nil
        }
        
        return try? String(contentsOfFile: filepath)
    }
}
