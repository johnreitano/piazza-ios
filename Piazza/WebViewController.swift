//
//  WebViewController.swift
//  Piazza
//
//  Created by John Reitano on 1/29/23.
//

import UIKit
import Turbo

class WebViewController: VisitableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDismissButton()
    }
    
    override func visitableDidRender() {
        navigationItem.title = visitableView.webView?.title
    }
    
    private func configureDismissButton() {
        if presentingViewController != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissModal)
            )
        }
    }
    
    @objc func dismissModal() {
        dismiss(animated: true)
    }
}
