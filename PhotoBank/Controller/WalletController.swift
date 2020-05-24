//
//  WalletController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Foundation
import CoreNFC

class WalletController: UITableViewController {
    
    var paymentCell = "paymentCell"
    
    var payments = [Payment]() {
        didSet {
            refresh.endRefreshing()
            tableView.reloadData()
            setupFooter()
        }
    }
    
    
    lazy var header: WalletHeaderView = {
        let view = WalletHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: headerHeight))
        return view
    }()
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = refresh
        refresh.addTarget(self, action: #selector(getData), for: .valueChanged)
        tableView.tableHeaderView = header
        header.delegate = self
        tableView.alwaysBounceVertical = true
        tableView.separatorColor = Theme.border
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Theme.black

        tableView.register(PaymentCell.self, forCellReuseIdentifier: paymentCell)

        extendedLayoutIncludesOpaqueBars = true
        
        let qrIcon = UIImage(named: "qrcode")?.withRenderingMode(.alwaysTemplate)
        let qrButton = UIBarButtonItem(image: qrIcon, style: .done, target: self, action: #selector(presentCamera))
        self.navigationItem.leftBarButtonItem = qrButton
        
        let moreIcon = UIImage(named: "more")?.withRenderingMode(.alwaysTemplate)
        moreButton = UIBarButtonItem(image: moreIcon, style: .done, target: self, action: #selector(handleMoreTap))
//        signOut = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(handleSignout))
        
//        let more = UIBarButtonItem
        
        self.navigationItem.rightBarButtonItem = moreButton
        
        payments = Payment.fetchAll(in: PersistenceService.context)
        navigationItem.title = "Wallet"
    }
    
    var moreButton: UIBarButtonItem?
    
    @objc func handleMoreTap() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let signOut = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.handleSignOut()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(signOut)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    
    @objc func handleSignOut() {
        KeychainHelper.publicKey = ""
        KeychainHelper.privateSeed = ""
        KeychainHelper.mnemonic = ""
        setupFooter()
    }
    
    var session: NFCNDEFReaderSession?
    
    @objc func handlePlusTap() {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        footer.isLoading = true
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Scan a Photobank card."
        session?.begin()
        
    }
    
    lazy var footer: ButtonTableFooterView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        let view = ButtonTableFooterView(frame: frame, title: "Add Wallet")
        view.delegate = self
        return view
    }()
    
    lazy var headerHeight: CGFloat = self.view.frame.width*0.62+100
    
    func setupFooter() {
        guard walletLoggedIn() else {
            tableView.tableFooterView = footer
            header.buyButton.isHidden = true
            header.sellButton.isHidden = true
            header.frame.size.height = headerHeight-100
            navigationItem.rightBarButtonItem = nil
            return
        }
        tableView.tableFooterView = UIView()
        header.frame.size.height = headerHeight
        header.buyButton.isHidden = false
        header.sellButton.isHidden = false
        navigationItem.rightBarButtonItem = moreButton
        tableView.reloadData()
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
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        auth()
    }
    
    func auth() {
        guard KeychainHelper.publicKey != "" else {
//            setupEmptyView()
            return
        }
        getData(nil)
    }
//
//    func presentWalletLogin() {
//        let vc = WalletLoginController()
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true)
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refresh.endRefreshing()
    }
    
    func getTransactions() {
        WalletService.getPayments { (payments) in
            self.payments = payments
        }
    }
    
    var isStreaming = false
    
    func streamTransactions() {
        guard isStreaming == false else { return }
        WalletService.streamPayments { payment in
            self.isStreaming = true
            self.payments.insert(payment, at: 0)
        }
    }
    
    @objc func getData(_ refresh: UIRefreshControl?) {
        guard walletLoggedIn() else {
            refresh?.endRefreshing()
            return
        }
        refresh?.endRefreshing()
        
        print("PUBLIC KEY: \(KeychainHelper.publicKey)")
        print("SECRET KEY: \(KeychainHelper.privateSeed)")
        print("SEED: \(KeychainHelper.mnemonic)")
    }
    
    
    func getBalance() {
        WalletService.getBalance { (token) in
            self.header.token = token
            self.refresh.endRefreshing()
            self.tableView.reloadData()
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
        let vc = QRController(code: KeychainHelper.publicKey)
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }

    func presentPassphraseController() {
//        let vc = WalletLoginController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    func presentAmountController(_ publicKey: String) {
        let vc = AmountController(publicKey: publicKey)
        let nav = UINavigationController(rootViewController: vc)
        definesPresentationContext = true
        modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true, completion: nil)
    }
    
    
    lazy var emptyView: EmptyView = {
        let view = EmptyView(frame: self.view.frame)
//        view.delegate = self
        return view
    }()
    

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard walletLoggedIn(), section == 0 else { return 0 }
        return 120
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard walletLoggedIn() else { return nil }
//        return buyButton
        return nil
    }
    
    func walletLoggedIn() -> Bool {
        guard KeychainHelper.privateSeed != "" else {
            return false
        }
        
        return true
    }

}

extension WalletController: WalletHeaderDelegate {
    
    
    func handleCardTap() {
        print("header tap")
        guard KeychainHelper.privateSeed != "" else {
//            presentPassphraseController()
            return
        }
        presentQRController()
    }
    
    func presentOrderController(side: TransactionType) {
        let vc = OrderController(token: counterAsset, side: side)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }


}

extension WalletController: QRScanDelegate {
    func handleQRScan(_ code: String) {
        presentAmountController(code)
    }
    
    
//    func setupEmptyView() {
//        if KeychainHelper.publicKey == "" {
//            self.tableView.backgroundView = emptyView
//            self.tableView.tableHeaderView = nil
//            self.navigationItem.title = ""
//
//        } else {
//            self.tableView.tableHeaderView = header
//            self.tableView.backgroundView = nil
//            self.navigationItem.title = "Wallet"
//
//        }
//    }
    
    
}




extension WalletController: NFCNDEFReaderSessionDelegate {
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
        self.session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        messages.forEach { (message) in
            let records = message.records
            for r in records {
                let data = r.payload.advanced(by: 3)
                let string = String(data: data, encoding: String.Encoding.utf8) ?? ""
                DispatchQueue.main.async {
                    self.handleNFCScan(string)
                }
            }
        }
    }
    
    
    func handleNFCScan(_ string: String) {
//        let vc = WalletLoginController()
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .overFullScreen
//        present(nav, animated: true)
        WalletService.login(string) { (success) in
//            self.setupEmptyView()
            self.setupFooter()
            self.getData(nil)
        }
    }
    
    
}


extension WalletController: ButtonTableFooterDelegate {
    
    func didTapButton(_ button: UIButton?) {
        handlePlusTap()
    }
    
    
    
}
