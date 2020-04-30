//
//  MnemonicController.swift
//  Sparrow
//
//  Created by Hackr on 8/5/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import stellarsdk

class PassphraseController: UITableViewController {

    var controller: WalletController?

    let cellId = "cellId"
    var mnemonic: String = KeychainHelper.mnemonic

    lazy var header: UIView = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240)
        let view = UIView(frame: frame)
        var instructionsLabel: UITextView = {
            let view = UITextView(frame: frame)
            view.textContainerInset = UIEdgeInsets(top: 30, left: 16, bottom: 10, right: 16)
            view.backgroundColor = Theme.lightBackground
            view.font = UIFont.boldSystemFont(ofSize: 18)
            view.text = "This is your 12 word passphrase. It is the only way to access your account. We do not store this data, therefore, if you lose your passphrase, we cannot recover your funds. Store your passphrase securely in multiple locations, and do not share it with anyone."
            return view
        }()
        view.addSubview(instructionsLabel)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if mnemonic == "" { mnemonic = Wallet.generate12WordMnemonic() }
        tableView.tableHeaderView = header
        tableView.allowsSelection = false
        tableView.separatorColor = Theme.border
        tableView.backgroundColor = Theme.lightBackground
        
        self.navigationItem.title = "Secret Phrase"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        self.navigationController?.navigationBar.prefersLargeTitles = true

        if isModal {
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(handleContinue))
//            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        }
        setupFooter()
    }
    
    func setupFooter() {
        if KeychainHelper.privateSeed == "" {
            tableView.tableFooterView = footer
        } else {
            tableView.tableFooterView = nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.font = Theme.semibold(20)
        let words = mnemonic.components(separatedBy: .whitespaces)
        if words.count > 1 {
            let word = words[indexPath.row]
            cell.textLabel?.text = word
        }
        return cell
    }


    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

//    @objc func handleContinue() {
//        DispatchQueue.global(qos: .background).async {
//            WalletService.generateKeyPair(mnemonic: self.mnemonic) { (keyPair) in
//                let publicKey = keyPair.accountId
//                guard let privateSeed = keyPair.secretSeed else { return }
//
//                KeychainHelper.mnemonic = self.mnemonic
//                KeychainHelper.publicKey = publicKey
//                KeychainHelper.privateSeed = privateSeed
//
//                UserService.updatePublicKey(pk: publicKey, completion: { (_) in })
//
//                WalletService.createStellarTestAccount(accountID: publicKey, completion: { (response) in
//                    DispatchQueue.main.async {
//                        self.dismiss(animated: true, completion: {
//                            self.controller?.loadData()
//                        })
//                    }
//                })
//            }
//        }
//    }

    var isModal: Bool {
        return presentingViewController != nil ||
            navigationController?.presentingViewController?.presentedViewController === navigationController ||
            tabBarController?.presentingViewController is UITabBarController
    }

    lazy var footer: ButtonTableFooterView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 120)
        let view = ButtonTableFooterView(frame: frame, title: "Continue")
        view.delegate = self
        view.backgroundColor = Theme.lightBackground
        return view
    }()
    
}


extension PassphraseController: ButtonTableFooterDelegate {
    
    func didTapButton(_ button: UIButton?) {
        footer.isLoading = true
        let passphrase = mnemonic
        WalletService.generateKeyPair(mnemonic: passphrase) { (keyPair) in
            let publicKey = keyPair.accountId
            guard let secretKey = keyPair.secretSeed else {
                print("NO SECRET KEY")
                return
            }
            KeychainHelper.publicKey = publicKey
            KeychainHelper.privateSeed = secretKey
            KeychainHelper.mnemonic = self.mnemonic
            
            UserService.updatePublicKey(completion: { (_) in })
            WalletService.createStellarTestAccount(accountID: publicKey, completion: { (something) in
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    
}
