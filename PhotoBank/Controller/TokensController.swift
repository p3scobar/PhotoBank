//
//  TokensController.swift
//  PhotoBank
//
//  Created by Hackr on 4/30/20.
//  Copyright © 2020 Sugar. All rights reserved.
//

import UIKit

class TokensController: UITableViewController {
    
    private var refresh = UIRefreshControl()
    
    let tokenCell = "tokenCell"
    
    var tokens: [Token] = [] {
        didSet {
            refresh.endRefreshing()
            tableView.reloadData()
            totalAccountValue()
        }
    }

    func totalAccountValue() {
        var totalValue: Decimal = 0
        tokens.forEach{
            let balance = $0.balance
            totalValue += Decimal(string: balance) ?? 0.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallet"
        /// REDO THIS TO SHOW THE TOTAL WALLET VALUE
        
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.refreshControl = refresh
        tableView.separatorColor = Theme.border
        tableView.backgroundColor = Theme.black
        view.backgroundColor = Theme.black
        
        
        tableView.register(TokenCellDetails.self, forCellReuseIdentifier: tokenCell)
        
        refresh.addTarget(self, action: #selector(getAssets(_:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(auth), name: Notification.Name(rawValue: "login"), object: nil)
        
        let scan = UIImage(named: "qrcode")?.withRenderingMode(.alwaysTemplate)
        let scanButton = UIBarButtonItem(image: scan, style: .done, target: self, action: #selector(handleScanTap))
        self.navigationItem.leftBarButtonItem = scanButton
        
        let add = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        let addButton = UIBarButtonItem(image: add, style: .done, target: self, action: #selector(addToken))
        self.navigationItem.rightBarButtonItem = addButton
        
    }
    
//    func getPrice(_ token: Token) {
//        TokenService.getExchangeRate(token: token) { (lastPrice) in
//            self.lastPrice = lastPrice
//        }
//    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Passphrase: \(KeychainHelper.mnemonic)")
        print("Public Key: \(KeychainHelper.publicKey)")
        print("Secret Key: \(KeychainHelper.privateSeed)")
        auth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refresh.endRefreshing()
    }
    
    @objc func addToken() {
        let vc = NewAssetController(style: .grouped)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    
    @objc func handleMoreTap() {
        let vc = AccountController(style: .grouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func auth() {
        guard KeychainHelper.publicKey != "" else {
            handleLoggedOut()
            return
        }
        getAssets(nil)
    }
    
    
    func handleLoggedOut() {
        if let tabBar = self.tabBarController as? TabBar {
            tabBar.presentHomeController()
        }
    }
    
    @objc func getAssets(_ sender: UIRefreshControl?) {
        WalletService.getAccountDetails { (tokens) in
            let assets = tokens.sorted { $0.assetCode ?? "XLM" < $1.assetCode ?? "XLM" }
            self.tokens = assets
            CurrentAssets = assets
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tokenCell, for: indexPath) as! TokenCellDetails
        let token = tokens[indexPath.row]
        cell.token = token
        setColor(cell, indexPath)
        return cell
    }
    
    func setColor(_ cell: TokenCellDetails, _ indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let token = tokens[indexPath.row]
//        let vc = TokenController(token)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func handleScanTap() {
        let vc = ScanController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .overFullScreen
//        vc.delegate = self
        self.present(nav, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let token = tokens[indexPath.row]
        let balance = Decimal(string: token.balance) ?? 0.0
        return (balance > 0) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let token = tokens[indexPath.row]
        presentConfirmation(token)
    }
    
    func presentConfirmation(_ asset: Token) {
        let alert = UIAlertController(title: "Remove Asset", message: nil, preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.removeTrust(asset)
        }
        alert.addAction(no)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)
    }
    
    func removeTrust(_ token: Token) {
        WalletService.changeTrust(token: token) { (success) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func pushChangeTrustController(_ scan: Scan) {
        let vc = CustomAssetController(assetCode: scan.assetCode, issuer: scan.address)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func pushSelectTokenController(_ pk: String) {
        let vc = SelectTokenController(publicKey: pk)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }

    
}



extension TokensController: NewAssetDelegate {
    
    func handleNewAsset(_ token: Token) {
        let vc = TokenController(token)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TokensController: ScanDelegate {
    
    static func scanType(_ code: String) -> ScanType {
        return .asset
    }
    
    func handleScan(_ scan: Scan) {
         switch scan.type {
         case .asset:
             pushChangeTrustController(scan)
         case .publicKey:
            print(scan.publicKey)
             pushSelectTokenController(scan.publicKey)
         }
     }
    
}


extension ScanDelegate {
   
    
    static func scanType(code: String) -> ScanType {
        
        
        
//        if let assetCode = code["assetCode"] as? String,
//            let address = code["address"] as? String {
//            self.type = ScanType.asset
//            self.assetCode = assetCode
//            self.address = address
//        }
        
        return .publicKey
        
    }
    
    
 
    
}


