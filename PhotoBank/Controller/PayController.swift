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

class PayController: UIViewController {
    
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
    
    lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 400, width: width, height: width)
        let view = UITableView(frame: frame)
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.tableFooterView = UIView()
        return view
    }()
    
 
    
//    convenience init(_ publicKey: String) {
//        self.publicKey = publicKey
//        self.init()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBlur()
        self.navigationItem.title = "Pay"
    
        header.addSubview(amountInput)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.separatorColor = Theme.border
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(InputCurrencyCell.self, forCellReuseIdentifier: currencyCell)

//        tableView.tableFooterView = UIView()
        
//        if isModal {
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
//        }
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(handlePay))
        

//        view.addSubview(amountInput)
//        tableView.tableFooterView = footer
    }
    
//    lazy var footer: TableFooterView = {
//        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
//        let view = TableFooterView(frame: frame, title: "Confirm")
//        view.delegate = self
//        return view
//    }()
    
    @objc func handlePay() {
        guard let accountID = publicKey else {
            ErrorPresenter.showError(message: "No destination keypair", on: self.presentedViewController)
        return
    }
        WalletService.sendPayment(token: counterAsset, toAccountID: accountID, amount: amount) { (_) in
//            self.dismiss(animated: true, completion: nil)
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
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        view.resignFirstResponder()
//    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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
            cell.textLabel?.text = "User"
            cell.valueInput.text = "$\(username)"
            cell.key = indexPath.row
        case 1:
            cell.textLabel?.text = "XLM"
            cell.value = 1.000
            cell.key = indexPath.row
        default:
            break
        }

    }
    
    @objc func textFieldDidChange(key: Int, value: Decimal) {
        amount = value
        print("Key: \(key)")
        print("Value updated: \(value)")
        
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func presentAlertController(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(done)
//        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleCancel() {
//        dismiss(animated: true, completion: nil)
    }
    
    
//    var isModal: Bool {
//        return presentingViewController != nil ||
//            navigationController?.presentingViewController?.presentedViewController === navigationController ||
//            tabBarController?.presentingViewController is UITabBarController
//    }
    
    
    lazy var signupButton: UIButton = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64)
        let button = UIButton(frame: frame)
        button.setTitle("Confirm Order", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Theme.semibold(20)
        button.backgroundColor = Theme.black
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    lazy var confirmButton: UIButton = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)
        let button = UIButton(frame: frame)
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Theme.semibold(20)
        button.backgroundColor = Theme.tint
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    override var inputAccessoryView: UIView? {
//        return confirmButton
//    }
    
    
    
    @objc func handleConfirm() {

    }
    
    
}


extension PayController: InputNumberCellDelegate {
    
}



extension PayController: UITextFieldDelegate {
    
}


extension PayController: UITableViewDataSource {
    
}


extension PayController: UITableViewDelegate {
    
}


extension PayController: TableFooterDelegate {
   
    func didTapButton() {
        handlePay()
    }
    
    
}



