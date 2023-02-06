import Foundation
import WebKit

protocol WebBridgeMessageHandler  {
    func processBridgeMessage(_ message: WebBridgeMessage)
}

extension WebBridgeMessageHandler where Self: RoutingController {
    func processBridgeMessage(_ message: WebBridgeMessage) {
        switch message.type {
        case "render":
            render(message.data)
        default:
            print("Unknown bridge message")
        }
    }
    
    private func render(_ data: [String: String]) {
        if data["component"] == "bar_button",
           let barButtonItem = WebBarButtonItem(data) {
            
            var barButtonItems = currentWebBarButtonItems
            
            barButtonItems.removeAll { $0.id == barButtonItem.id }
            barButtonItems
                .insert(barButtonItem, at: Int(data["index"] ?? "0")!)
            
            topViewController?.navigationItem.rightBarButtonItems =
            barButtonItems
        } else {
            print("Unsupported component: \(data["component"] ?? "")")
        }
    }
    
    private var currentWebBarButtonItems: [WebBarButtonItem] {
        let items = topViewController?.navigationItem.rightBarButtonItems ?? []
        return items.compactMap { $0 as? WebBarButtonItem }
    }
}

extension RoutingController: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if let bridgeMessage = WebBridgeMessage(message.body) {
            processBridgeMessage(bridgeMessage)
        } else {
            print("Failed to parse message: \(message.body)")
        }
    }
}
