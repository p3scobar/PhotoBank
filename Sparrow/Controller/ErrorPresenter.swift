//
//  ErrorPresenter.swift
//  Sparrow
//
//  Created by Hackr on 11/9/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit

class ErrorPresenter {
    
    static func showError(message: String, on viewController: UIViewController?, dismissAction: ((UIAlertAction) -> Void)? = nil) {
        weak var vc = viewController
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error",
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: dismissAction))
            vc?.present(alertController, animated: true)
        }
    }
}
