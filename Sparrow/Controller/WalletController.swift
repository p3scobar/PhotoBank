//
//  WalletController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Foundation

class WalletController: UITableViewController {
    
    var paymentCell = "paymentCell"
    
    var payments = [Payment]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setupEmptyView()
                self.refresh.endRefreshing()
            }
        }
    }
    
    func setupEmptyView() {
        if payments.count == 0 {
            self.tableView.backgroundView = emptyLabel
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    lazy var header: WalletHeaderView = {
        let view = WalletHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 280))
        return view
    }()
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        tableView.tableHeaderView = header
        tableView.alwaysBounceVertical = true
        tableView.separatorColor = Theme.border
        self.navigationItem.title = "Wallet"
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.register(PaymentCell.self, forCellReuseIdentifier: paymentCell)
//        navigationController?.navigationBar.prefersLargeTitles = true
//        NotificationCenter.default.addObserver(self, selector: #selector(handleQR(notification:)), name: NSNotification.Name(rawValue: "qrScan"), object: nil)
        
        let qrIcon = UIImage(named: "qrcode")?.withRenderingMode(.alwaysTemplate)
        let qrButton = UIBarButtonItem(image: qrIcon, style: .done, target: self, action: #selector(presentCamera))
        self.navigationItem.rightBarButtonItem = qrButton
        payments = Payment.fetchAll(in: PersistenceService.context)
        pullToRefresh()
    }
    
    @objc func presentCamera() {
        let scan = ScanController()
        scan.scanDelegate = self
        let nav = UINavigationController(rootViewController: scan)
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refresh.endRefreshing()
    }
    
    @objc func getTransactions() {
        WalletManager.fetchTransactions { payments in
            self.payments = payments
        }
    }
    
    func streamTransactions() {
        WalletManager.streamPayments { [weak self] payment in
            self?.payments.insert(payment, at: 0)
        }
    }
    
    @objc func pullToRefresh() {
        guard KeychainHelper.publicKey != "" else {
            refresh.endRefreshing()
            return
        }
        getAccountDetails()
        getTransactions()
    }
    
    
    func getAccountDetails() {
        WalletManager.getAccountDetails { (asset) in
            self.header.token = asset
        }
    }
    
    @objc func loadData() {
        if KeychainHelper.publicKey != "" {
            getAccountDetails()
            getTransactions()
            streamTransactions()
        } else {
//            header.balance = "0.000"
//            header.currencyCodeLabel.text = "Create an Account"
            setupEmptyView()
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paymentCell, for: indexPath) as! PaymentCell
        cell.payment = payments[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        vc.modalTransitionStyle = .crossDissolve
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
    

    func presentAmountController(_ publicKey: String) {
        let vc = AmountController(publicKey: publicKey)
        let nav = UINavigationController(rootViewController: vc)
        definesPresentationContext = true
        modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true, completion: nil)
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

extension WalletController: WalletHeaderDelegate {
    func handleBuy() {
        
    }
    
    func handleSell() {
        
    }
    
    func handleCardTap() {
        guard KeychainHelper.publicKey != "" else {
            presentPassphraseController()
            return
        }
        presentQRController()
    }
    
    func presentPassphraseController() {
        let vc = MnemonicController()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }
}

extension WalletController: QRScanDelegate {
    func handleQRScan(_ code: String) {
        presentAmountController(code)
    }
    
    
//    @objc func handleQR(notification: Notification) {
//        if let pk = notification.userInfo?["code"] as? String {
    
//        }
//    }
    
}
