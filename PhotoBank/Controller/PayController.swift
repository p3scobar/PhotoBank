//
//  PayController.swift
//  Sparrow
//
//  Created by Hackr on 8/10/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

class PayController: UITableViewController {
    
    var publicKey: String?
    var username: String?
    var numberCell = "numberCell"
    var currencyCell = "currencyCell"
    var amount: Decimal = 0
    
    lazy var amountInput: UILabel = {
        let width = self.view.frame.width ?? 320
        let frame = CGRect(x: 0, y: 100, width: width, height: 180)
        let view = UILabel(frame: frame)
        view.textAlignment = .center
        view.backgroundColor = .clear
        view.adjustsFontSizeToFitWidth = true
        view.font = Theme.semibold(48)
        view.textColor = .white
//        view.text = "Superlike"
        return view
    }()
    
    
    lazy var header: UIView = {
        let width = self.view.frame.width ?? 0.0
        let frame = CGRect(x: 0, y: 0, width: width, height: 260)
        let view = UIView(frame: frame)
        return view
    }()
    
    lazy var width = self.view.frame.width ?? 0.0
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Pay"
        tableView.backgroundColor = Theme.background
        header.addSubview(amountInput)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.separatorColor = Theme.border
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(InputCurrencyCell.self, forCellReuseIdentifier: currencyCell)

        tableView.tableFooterView = submitButton
        
    }
    
    @objc func handleSubmit() {
        submitButton.isLoading = true
//        dismiss(animated: true, completion: nil)
        guard let accountID = publicKey else {
            ErrorPresenter.showError(message: "No destination keypair", on: self.presentedViewController)
        return
    }
        WalletService.sendPayment(token: counterAsset, toAccountID: accountID, amount: amount) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupBlur() {
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tableView.frame
        
//        self.view.insertSubview(blurEffectView, at: 0)
        
//        self.view = blurEffectView
        blurEffectView.contentView.addSubview(tableView)
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        blurEffectView.contentView.addSubview(amountInput)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        submitButton.isLoading = false
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: currencyCell, for: indexPath) as! InputCurrencyCell
        cell.backgroundColor = Theme.black
        cell.textLabel?.textAlignment = .left
        cell.valueInput.textAlignment = .right
        setupCell(indexPath: indexPath, cell: cell)
        return cell
    }
    
    
    func setupCell(indexPath: IndexPath , cell: InputCurrencyCell) {
        cell.key = indexPath.row
        cell.delegate = self
        cell.backgroundColor = .clear
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Pay"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = Theme.semibold(22)
            cell.key = indexPath.row
            cell.valueInput.text = ""
        case 1:
            cell.textLabel?.text = "PBK"
            cell.value = 1.000
            cell.valueInput.text = "1.000"
            cell.key = indexPath.row
        default:
            break
        }

    }
    
    @objc func textFieldDidChange(key: Int, value: Decimal) {
        amount = value
        
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    lazy var submitButton: ButtonTableFooterView = {
         let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
         let view = ButtonTableFooterView(frame: frame, title: "Pay Now")
         view.delegate = self
         return view
     }()
    
    
    

}


extension PayController: InputNumberCellDelegate {
    
}



extension PayController: UITextFieldDelegate {
    
}



extension PayController: ButtonTableFooterDelegate {
   
    func didTapButton(_ button: UIButton?) {
        handleSubmit()
    }
    
    
}



