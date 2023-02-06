import UIKit
import Turbo
import SafariServices
import WebKit

class RoutingController: BaseNavigationController, PathDirectable, WebBridgeMessageHandler {
    private enum PresentationType: String {
        case advance, replace, modal
    }
    
    private static var sharedProcessPool = WKProcessPool()
    private static let modalSession = createSession()
    
    private(set) lazy var session: Session = {
        let session = Self.createSession()
        session.delegate = self
        session.webView.configuration.userContentController.add(self, name: "nativeApp")
        return session
    }()
    
    private static func createSession() -> Session {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent =
        "Piazza Turbo Native iOS"
        configuration.processPool = sharedProcessPool
        
        let session = Session(webViewConfiguration: configuration)
        session.pathConfiguration = Global.pathConfiguration
        
        return session
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearWebBarButtonItems()
        refreshWebView()
    }
    
    func refreshWebView() {
        if let vc = topViewController as? VisitableViewController {
            session.visit(vc)
        }
    }
    
    private func clearWebBarButtonItems() {
        topViewController?.navigationItem.rightBarButtonItems = []
    }
}

extension RoutingController: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        if proposal.isPathDirective {
            executePathDirective(proposal)
        } else if let tabIndex = RootViewController.tabIndexForURL(proposal.url) {
            let rootViewController =
            self.tabBarController as? RootViewController
            
            if let presentedVC = presentedViewController {
                presentedVC.dismiss(animated: true, completion: {
                    rootViewController?.switchToTab(tabIndex)
                })
            } else {
                rootViewController?.switchToTab(tabIndex)
            }
            
        } else {
            visit(proposal)
        }
        
    }
    
    func session(_ session: Session,
                 didFailRequestForVisitable visitable: Visitable,
                 error: Error) {
        if let turboError = error as? TurboError,
           turboError == .http(statusCode: 401) {
            showLoginScreen()
        } else {
            let alert = UIAlertController(
                title: NSLocalizedString("error.title", comment: ""),
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("error.ok", comment: ""),
                style: .default,
                handler: nil
            ))
            presentedViewController?.dismiss(animated: true)
            present(alert, animated: true)
        }
    }
    
    func sessionDidLoadWebView(_ session: Session) {
        //        session.webView.navigationDelegate = self
        //        session.webView.uiDelegate = self
        session.webView.attachWebBridge()
    }
    
    func sessionDidFinishRequest(_ session: Session) {
        if session == self.session {
            clearWebBarButtonItems()
        }
    }
    
    private func showLoginScreen() {
        let properties = Global.pathConfiguration.properties(for: Api.Path.login)
        let proposal = VisitProposal(
            url: Api.Path.login,
            options: VisitOptions(),
            properties: properties
        )
        
        visit(proposal)
    }
    
    func visit(_ proposal: VisitProposal) {
        let viewController = ViewControllerVendor.viewController(
            for: proposal.url,
            properties: proposal.properties
        )
        let presentation = proposal.properties["presentation"] as? String ?? "advance"
        let presentationType = PresentationType(rawValue: presentation)!
        
        navigateTo(viewController, using: presentationType)
        visit(viewController, options: proposal.options, presentationType: presentationType)
    }
    
    private func navigateTo(_ vc: UIViewController,
                            using presentationType: PresentationType) {
        switch presentationType {
        case .advance:
            presentedViewController?.dismiss(animated: true)
            pushViewController(vc, animated: true)
            
        case .replace:
            presentedViewController?.dismiss(animated: true)
            let viewControllers =
            Array(viewControllers.dropLast()) + [vc]
            setViewControllers(viewControllers, animated: false)
            
        case .modal:
            let modalNavController =
            BaseNavigationController(rootViewController: vc)
            
            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(
                    animated: true, completion: { [unowned self] in
                        self.present(modalNavController, animated: true)
                    })
            } else {
                present(modalNavController, animated: true)
            }
        }
    }
    
    private func visit(_ vc: UIViewController,
                       options: VisitOptions,
                       presentationType: PresentationType) {
        guard let visitable = vc as? Visitable else { return }
        
        switch presentationType {
        case .advance, .replace:
            Self.modalSession.delegate = nil
            session.visit(visitable, options: options)
        case .modal:
            Self.modalSession.delegate = self
            Self.modalSession.visit(visitable, options: options)
        }
    }
    
    func sessionWebViewProcessDidTerminate(_ session: Session) {}
}

extension RoutingController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler:
                 @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated {
            let url = navigationAction.request.url!
            
            if url.host == Api.rootURL.host, !url.pathExtension.isEmpty {
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true)
            } else {
                UIApplication.shared.open(url)
            }
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

extension RoutingController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(
            title: NSLocalizedString("confirm.title", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: NSLocalizedString("confirm.ok", comment: ""),
            style: .default,
            handler: { _ in
                completionHandler(true)
            }
        )
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("confirm.cancel", comment: ""),
            style: .cancel,
            handler: { _ in
                completionHandler(false)
            }
        )
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
