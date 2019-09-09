//
//  PaymentController.swift
//  Sparrow
//
//  Created by Hackr on 9/8/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit
import UIKit

class PaymentController: UITableViewController {
    
    var username = "" {
        didSet {
            tableView.reloadData()
        }
    }
    
    let cellId = "cellId"
    var payment: Payment!
    
    
    lazy var header: PaymentHeader = {
        let view = PaymentHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240))
        view.payment = payment
        return view
    }()
    
    func fetchUser() {
        guard let publicKey = otherUserKey() else { return }
        print("OTHER USERS PUBLIC KEY: \(publicKey)")
        UserService.getUserWithPublicKey(publicKey) { (user) in
            self.header.user = user
            self.tableView.reloadData()
        }
    }
    
    func otherUserKey() -> String? {
        let fromKey = payment?.from ?? ""
        let currentPubKey = KeychainHelper.publicKey
        return (fromKey != currentPubKey) ? payment?.from : payment?.to
    }
    
    convenience init(payment: Payment) {
        self.init(style: .plain)
        self.payment = payment
        self.header.payment = payment
        fetchUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = header
        tableView.separatorColor = Theme.border
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InputTextCell.self, forCellReuseIdentifier: cellId)
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 120))
        tableView.allowsSelection = false
        
        self.navigationItem.title = "Transaction"
        extendedLayoutIncludesOpaqueBars = true
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! InputTextCell
        cell.valueInput.isEnabled = false
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Type"
            cell.valueInput.text = payment.isReceived ? "Receive " : "Send"
        case 1:
            cell.textLabel?.text = "Amount"
            cell.valueInput.text = payment.amount?.rounded(3) ?? ""
        case 2:
            cell.textLabel?.text = "Native Amount"
            let value = (Decimal(string: payment.amount ?? "") ?? 0.0)
            cell.valueInput.text = value.rounded(2)
        case 3:
            cell.textLabel?.text = "Asset"
            cell.valueInput.text = payment.assetCode ?? ""
        case 4:
            cell.textLabel?.text = "Date"
            let date = payment.timestamp
            cell.valueInput.text = date?.asString()
        default:
            break
        }
        return cell
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}


