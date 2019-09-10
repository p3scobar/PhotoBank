//
//  ConfirmPaymentController.swift
//  Sparrow
//
//  Created by Hackr on 8/6/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
//import MaterialActivityIndicator
//import SwiftySound

class ConfirmPaymentController: UITableViewController {
    
    let cellID = "cellID"
    var type: PaymentType!
    var data: [String:Any] = [:]
    var submitted = false
    
    convenience init(type: PaymentType, data: [String:Any]) {
        self.init(style: .grouped)
        self.data = data
        self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(InputTextCell.self, forCellReuseIdentifier: cellID)
        if let type = data["type"] as? PaymentType {
            title = "Confirm \(type.rawValue.capitalized)"
        }
        setupView()
        tableView.tableFooterView = footer
    }
    
    lazy var footer: ButtonTableFooterView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        let view = ButtonTableFooterView(frame: frame, title: "Confirm")
        view.delegate = self
        return view
    }()
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! InputTextCell
        cell.valueInput.isEnabled = false
        setupCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func setupCell(cell: InputTextCell, indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "To"
            if let username = data["username"] as? String {
                cell.valueInput.text = "@\(username)"
            }
        case 1:
            cell.titleLabel.text = "Amount"
            if let amount = data["amount"] as? Decimal {
                let assetCode = " ARS"
                cell.valueInput.text = amount.rounded(2) + assetCode
            }
        default:
            break
        }
    }
    
    func setupView() {
        
    }
    
    
    @objc func submitPayment() {
        switch type {
        case .send?:
            submitSend()
        default:
            break
        }
    }
    
    fileprivate func submitSend() {
        guard let accountID = data["to"] as? String,
            let amount = data["amount"] as? Decimal else {
                self.presentAlert(title: "Transaction malformed", message: "We're unable to submit this transaction.")
                return
        }
        
        footer.isLoading = true
        let token = Token.ARS
        WalletService.sendPayment(token: token, toAccountID: accountID, amount: amount) { (success) in
            if success != nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.presentAlert(title: "Error", message: "Transaction failed. Please try again.")
            }
        }
    }

    
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "Done", style: .default) { (done) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(done)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension ConfirmPaymentController: ButtonTableFooterDelegate {
    
    func didTapButton(_ button: UIButton?) {
        submitPayment()
    }
    
}
