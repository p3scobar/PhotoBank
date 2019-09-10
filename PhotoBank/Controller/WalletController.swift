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
                self.refresh.endRefreshing()
                self.tableView.reloadData()
                self.setupEmptyView()
                self.setupFooter()
            }
        }
    }
    
    
    lazy var header: WalletHeaderView = {
        let view = WalletHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 260))
        return view
    }()
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        tableView.tableHeaderView = header
        tableView.alwaysBounceVertical = true
        tableView.separatorColor = Theme.border
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Theme.lightBackground

        tableView.register(PaymentCell.self, forCellReuseIdentifier: paymentCell)
        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        NotificationCenter.default.addObserver(self, selector: #selector(handleQR(notification:)), name: NSNotification.Name(rawValue: "qrScan"), object: nil)
        
        let qrIcon = UIImage(named: "qrcode")?.withRenderingMode(.alwaysTemplate)
        let qrButton = UIBarButtonItem(image: qrIcon, style: .done, target: self, action: #selector(presentCamera))
        self.navigationItem.rightBarButtonItem = qrButton
        payments = Payment.fetchAll(in: PersistenceService.context)
        pullToRefresh()
        setupTitle()
    }
    
    func setupTitle() {
        self.navigationItem.title = (KeychainHelper.privateSeed != "") ? "Wallet" : "Setup Wallet"
        if KeychainHelper.privateSeed == "" {
            header.titleLabel.text = ""
            header.balanceLabel.text = "Welcome"
            header.currencyLabel.text = "Tap to Setup Wallet"
        } else {
            footer.buttonTitle = "Buy"
        }
    }
    
    func setupFooter() {
        if KeychainHelper.privateSeed == "" {
            tableView.tableFooterView = footer
        } else {
            tableView.tableFooterView = UIView()
        }
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
        getAccountDetails()
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refresh.endRefreshing()
    }
    
    @objc func getTransactions() {
        WalletService.fetchTransactions { payments in
            self.payments = payments
        }
    }
    
    func streamTransactions() {
        WalletService.streamPayments { payment in
            self.payments.insert(payment, at: 0)
        }
    }
    
    @objc func pullToRefresh() {
        print("PUBLIC KEY: \(KeychainHelper.publicKey)")
        print("SECRET KEY: \(KeychainHelper.privateSeed)")
        print("SEED: \(KeychainHelper.mnemonic)")
        getAccountDetails()
        getTransactions()
        setupTitle()
        setupFooter()
        refresh.endRefreshing()
    }
    
    
    func getAccountDetails() {
        WalletService.getAccountDetails { (asset) in
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        view.endEditing(true)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: paymentCell, for: indexPath) as! PaymentCell
        let payment = payments[indexPath.row]
        cell.payment = payment
        fetchUser(payment, cell)
        return cell
    }
    
    func fetchUser(_ payment: Payment, _ cell: PaymentCell) {
        guard let id = payment.otherUserKey() else {
            print("Wallet Controller – No public key to fetch user")
            return
        }
        UserService.fetchUser(userId: id) { (user) in
            cell.user = user
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let payment = payments[indexPath.row]
//        presentReceiptController(payment)
        let vc = PaymentController(payment: payment)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func handleQRTap() {
        if KeychainHelper.publicKey == "" {
            presentPassphraseController()
        } else if KeychainHelper.privateSeed == "" {
            presentPassphraseController()
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

    func presentPassphraseController() {
        let vc = PassphraseController()
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    lazy var footer: FooterLoginView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180)
        let view = FooterLoginView(frame: frame, title: "Login")
        view.delegate = self
        return view
    }()
    
    lazy var buyButton: ButtonTableFooterView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        let view = ButtonTableFooterView(frame: frame, title: "Buy")
        view.delegate = self
        return view
    }()
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard walletLoggedIn(), section == 0 else { return 0 }
        return 120
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard walletLoggedIn() else { return nil }
        return buyButton
    }
    
    func walletLoggedIn() -> Bool {
        guard KeychainHelper.privateSeed != "" else {
            return false
        }
        return true
    }

}

extension WalletController: WalletHeaderDelegate {
    
    func handleBuy() {
        let token = Token.ARS
        let vc = OrderController(token: token, side: .buy)
        let nav = UINavigationController(rootViewController: vc)
        self.tabBarController?.present(nav, animated: true, completion: nil)
    }
    
    func handleSell() {
        
    }
    
    func handleCardTap() {
        print("header tap")
        guard KeychainHelper.privateSeed != "" else {
            presentPassphraseController()
            return
        }
        presentQRController()
    }
    
    func presentOrderController() {
        let token = Token.ARS
        let vc = OrderController(token: token, side: .buy)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }


}

extension WalletController: QRScanDelegate {
    func handleQRScan(_ code: String) {
        presentAmountController(code)
    }
    
    
    func setupEmptyView() {
        if payments.count == 0 {
            self.tableView.backgroundView = emptyLabel
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    
}



extension WalletController: ButtonTableFooterDelegate {
    
    func didTapButton(_ button: UIButton?) {
        print("DID TAP BUTTON")
        if button == buyButton.button {
            presentOrderController()
        } else if button == footer.button {
            footer.isLoading = true
            WalletService.login(footer.passphrase) { (success) in
                self.pullToRefresh()
            }
        }
    }
    
    
}
