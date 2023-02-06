//
//  RootViewController.swift
//  Piazza
//
//  Created by John Reitano on 1/29/23.
//

import UIKit
import Turbo

class RootViewController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        var viewControllers = [UIViewController]()
        
        Self.tabs.forEach { tab in
            let vc = ViewControllerVendor.viewController(for: tab.url)
            viewControllers.append(RoutingController(rootViewController: vc))
        }
        
        self.viewControllers = viewControllers
    }
    
    func switchToTab(_ tabIndex: Int) {
        selectedIndex = tabIndex
        (selectedViewController as? RoutingController)?.refreshWebView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RootViewController {
    static let tabs = [
        Tab(url: Api.rootURL, icon: "house.fill", titleKey: "tab.home"),
        Tab(url: Api.Path.savedAds, icon: "bookmark.fill", titleKey: "tab.savedAds"),
        Tab(url: Api.Path.messages, icon: "message.fill", titleKey: "tab.messages"),
        Tab(url: Api.Path.myAds, icon: "rectangle.stack.badge.person.crop.fill", titleKey: "tab.myAds"),
        Tab(url: Api.Path.profile, icon: "person.fill", titleKey: "tab.profile")
    ]
    
    static func tabIndexForURL(_ url: URL) -> Int? {
        return tabs.firstIndex { $0.url == url }
    }
    
    struct Tab {
        let url: URL
        let icon: String
        let titleKey: String
    }
}

