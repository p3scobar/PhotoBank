//
//  PendingController.swift
//  Sparrow
//
//  Created by Hackr on 8/10/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import MaterialActivityIndicator

class PendingController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
    
    let indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    convenience init(accountId: String, username: String, amount: Decimal) {
        self.init()
        setupView()
        print("DESTINATION: \(accountId)")
        print("USERNAME: \(username)")
        print("AMOUNT: \(amount)")
        WalletService.sendPayment(token: reserveAsset, toAccountID: accountId, amount: amount) { (txID) in
            if let id = txID {
                self.presentAlert(title: "Success", message: "You sent \(amount) PBK to @\(username.lowercased())")
            } else {
                self.presentAlert(title: "Transaction Failed", message: "Something went wrong. Please try again.")
            }
        }
    }
    
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "Done", style: .default) { (done) in
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(done)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupView() {
        view.addSubview(indicator)
        
        indicator.widthAnchor.constraint(equalToConstant: 60).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        indicator.startAnimating()
    }
}
