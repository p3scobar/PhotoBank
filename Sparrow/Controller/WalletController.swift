//
//  WalletController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Foundation
import Pulley

class WalletController: UIViewController, WalletHeaderDelegate, UITableViewDataSource, UITableViewDelegate, PulleyDrawerViewControllerDelegate {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: self.view.frame)
        view.alwaysBounceHorizontal = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 36
        view.clipsToBounds = true
        return view
    }()
    
    lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.frame.height-40)
        let view = UITableView(frame: frame)
        view.layer.cornerRadius = 28
//        view.clipsToBounds = true
        return view
    }()
    
    var paymentCell = "paymentCell"
    
    var payments = [Payment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setupEmptyView()
            }
        }
    }
    
    func setupEmptyView() {
        if payments.count == 0 {
            self.tableView.backgroundView = emptyLabel
        } else {
            self.tableView.backgroundView = nil
        }
        print(payments.count)
    }
    
    lazy var cardView: WalletHeaderView = {
        let view = WalletHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.delegate = self
//        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 240))
        view.addSubview(scrollView)
        scrollView.addSubview(cardView)
        scrollView.addSubview(tableView)
        scrollView.sendSubview(toBack: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        self.navigationItem.title = "Wallet"
        tableView.showsVerticalScrollIndicator = false

        tableView.tableFooterView = UIView()
        tableView.register(PaymentCell.self, forCellReuseIdentifier: paymentCell)
        navigationController?.navigationBar.prefersLargeTitles = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleQR(notification:)), name: NSNotification.Name(rawValue: "qrScan"), object: nil)
        tableView.isScrollEnabled = false
        tableView.contentInset.top = 220
        tableView.contentInset.bottom = 80
        payments = Payment.fetchAll(in: PersistenceService.context)
        loadData()
        if let pulley = self.parent as? PulleyViewController {
            pulley.delegate = self
            pulley.view.backgroundColor = .clear
            pulley.drawerBackgroundVisualEffectView = nil
            pulley.shadowOpacity = 0.0
            pulley.backgroundDimmingOpacity = 0.0
            pulley.initialDrawerPosition = .open
            pulley.drawerTopInset = 20
            pulley.drawerCornerRadius = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(KeychainHelper.publicKey)
        print(KeychainHelper.privateSeed)
        loadData()
    }
    
    
    
    func fetchTransactions() {
        WalletManager.fetchTransactions { [weak self] payments in
            self?.payments = payments
        }
    }
    
    func streamTransactions() {
        WalletManager.streamPayments { [weak self] payment in
            self?.payments.insert(payment, at: 0)
        }
    }
    
    @objc func pullToRefresh() {
        if KeychainHelper.publicKey != "" {
            getAccountDetails()
            fetchTransactions()
        }
    }
    
    
    func getAccountDetails() {
        WalletManager.getAccountDetails { (balance) in
            DispatchQueue.main.async {
                self.cardView.balance = balance
                self.cardView.currencyCodeLabel.text = "BNK"
            }
        }
    }
    
    @objc func loadData() {
        if KeychainHelper.publicKey != "" {
            getAccountDetails()
            fetchTransactions()
        } else {
            cardView.balance = "0.000"
            cardView.currencyCodeLabel.text = "Create an Account"
            setupEmptyView()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paymentCell, for: indexPath) as! PaymentCell
        cell.payment = payments[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let payment = payments[indexPath.row]
        presentReceiptController(payment)
//        let vc = TransactionController(payment: payment)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func handleQRTap() {
        if KeychainHelper.publicKey == "" {
            presentMnemonicController()
        } else if KeychainHelper.privateSeed == "" {
            presentRecoveryController()
        } else {
            presentQRController()
        }
    }
    
    func presentReceiptController(_ payment: Payment) {
        definesPresentationContext = true
        let vc = ReceiptController(payment: payment)
        vc.payment = payment
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }
    
    func presentQRController() {
        let vc = QRController()
        present(vc, animated: true, completion: nil)
    }

    func presentMnemonicController() {
        let vc = MnemonicController(style: .plain)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    func presentRecoveryController() {
        let vc = RecoveryController(style: .plain)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    
    @objc func handleQR(notification: Notification) {
        if let pk = notification.userInfo?["code"] as? String {
            presentAmountController(pk)
        }
        if let drawer = self.parent as? PulleyViewController {
            drawer.setDrawerPosition(position: .open, animated: true)
        }
    }
    
    func presentAmountController(_ publicKey: String) {
        let vc = AmountController(publicKey: publicKey)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        DispatchQueue.main.async {
            if drawer.drawerPosition == PulleyPosition.open {
                print("Drawer open")
                self.tableView.isScrollEnabled = true
            } else {
                print("Drawer not open")
                self.tableView.isScrollEnabled = false
            }
        }
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264
    }
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 80))
        label.text = "No transactions yet."
        label.textColor = Theme.lightGray
        label.font = Theme.semibold(18)
        label.textAlignment = .center
        return label
    }()
    
}

