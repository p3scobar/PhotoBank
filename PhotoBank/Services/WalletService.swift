//
//  WalletService.swift
//  Sparrow
//
//  Created by Hackr on 8/5/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import stellarsdk
import Alamofire
import Firebase
//import FirebaseFunctions

struct WalletService {
    
    static func login(_ passphrase: String, completion: @escaping (Bool) -> Void) {
        generateKeyPair(mnemonic: passphrase, completion: { (keyPair) in
            guard let keyPair = keyPair else {
                completion(false)
                return
            }
            KeychainHelper.publicKey = keyPair.accountId
            KeychainHelper.privateSeed = keyPair.secretSeed
            KeychainHelper.mnemonic = passphrase
            
            NotificationCenter.default.post(name: Notification.Name("login"), object: nil, userInfo: [:])
//            UserService.login {
//                completion(true)
//            }
            completion(true)
        })
    }
    
    static func signUp(completion: @escaping () -> Void) {
        #if DEV
        createTESTAccount {
            DispatchQueue.main.async {
                completion()
                UserService.signup {
                    
                }
            }
        }
        #else
        createRealAccount {
            DispatchQueue.main.async {
                completion()
            }
        }
        #endif
    }
    
    
    static func signOut(completion: @escaping () -> Void) {
        Payment.deleteAll()
        KeychainHelper.publicKey = ""
        KeychainHelper.privateSeed = ""
        KeychainHelper.privateSeed = ""
        CurrentUser.name = ""
        CurrentUser.email = ""
        CurrentUser.username = ""
        Payment.deleteAll()
//        Trade.deleteAll()
        completion()
    }
    
    static func generateKeyPair(mnemonic: String, completion: @escaping (KeyPair?) -> Void) {
        let keyPair = try? Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0)
        completion(keyPair)
    }
 
    
    static func createRealAccount(completion: @escaping () -> Void) {
        let passphrase = Wallet.generate12WordMnemonic()
        KeychainHelper.mnemonic = passphrase
        guard let keyPair = try? Wallet.createKeyPair(mnemonic: passphrase, passphrase: nil, index: 0) else { return }
        KeychainHelper.publicKey = keyPair.accountId
        KeychainHelper.privateSeed = keyPair.secretSeed
        
        let data = ["publicKey":keyPair.accountId]
//        UserService.signup {
//            UserService.updateUserInfo(values: data, vc: nil) { _ in
//                completion()
//            }
//        }
    }
    
    
    static func createTESTAccount(completion: @escaping () -> Void) {
        let passphrase = Wallet.generate12WordMnemonic()
        generateKeyPair(mnemonic: passphrase) { (keyPair) in
            let accountID = keyPair?.accountId ?? ""
            Stellar.sdk.accounts.createTestAccount(accountId: accountID) { (response) -> (Void) in
                switch response {
                case .success:
                    KeychainHelper.mnemonic = passphrase
                    KeychainHelper.publicKey = accountID
                    KeychainHelper.privateSeed = keyPair?.secretSeed ?? ""
                    completion()
                case .failure(let error):
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
//
//
//    static func getAssets(type completion: @escaping ([Asset]) -> Void) {
//        Stellar.sdk.assets.getAssets { (response) in
//            switch response {
//            case .failure(let error):
//                print(error.localizedDescription)
//                break
//            case .success(let details):
//                var assets: [Asset] = []
//                let record = details.records
//                record.forEach({ (data) in
//                    let assetCode = data.assetCode ?? ""
//                    let issuer = data.assetIssuer ?? ""
//                    let asset = Asset(type: type), code: code, issuer: issuer)
//
//                })
//
//
//                DispatchQueue.main.async {
//                    completion(tokens)
//                }
//            }
//        }
//    }
    
    static func getAssets(_ limit: Int, completion: @escaping ([Token]) -> Void) {
        Stellar.sdk.assets.getAssets(order:Order.descending, limit: 100) { (response) -> (Void) in
            var assets: [Token] = []
            switch response {
            case .success(details: let pageResponse):
                pageResponse.records.forEach({ (record) in
                    
                    let type = record.assetType
                    let issuer = record.assetIssuer
                    let code = record.assetCode
                    let asset = Token(assetType: type, assetCode: code, assetIssuer: issuer, balance: "")
                    
                    assets.append(asset)
                })
                DispatchQueue.main.async {
                    completion(assets)
                }
            case .failure(error: let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func calculateAccountValue(_ tokens: [Token]) {
////        accountValue = 0.0
//        tokens.forEach { token in
//            let balance = Decimal(string: token.balance) ?? 0.0
//            let assetCode = token.assetCode ?? "XLM"
//            let baseCode = baseAsset.assetCode ?? "XLM"
//            guard assetCode != baseCode else {
//                accountValue += balance
//                return
//            }
//            TokenService.getLastPrice(token: token) { (price) in
//                token.lastPrice = price
//                accountValue += Decimal(string: token.balance) ?? 0.0
//            }
////            let value = balance*lastPrice
//        }
    }
    
    static func getAccountDetails(completion: @escaping ([Token]) -> Swift.Void) {
        let accountId = KeychainHelper.publicKey
        Stellar.sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                var tokens = [Token]()
                accountDetails.balances.forEach({ (asset) in
                    let token = Token(response: asset)
                    tokens.append(token)
                    if token.isNative {
                        token.assetCode = "XLM"
                    }
                    calculateAccountValue(tokens)
                })
                DispatchQueue.main.async {
                    completion(tokens)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion([])
                }
                print(error.localizedDescription)
            }
        }
    }
    
    
    static func getBalance(completion: @escaping (Token) -> Swift.Void) {
        let accountId = KeychainHelper.publicKey
        Stellar.sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                accountDetails.balances.forEach({ (asset) in
                    let token = Token(response: asset)
                    if token.assetCode == counterAsset.assetCode,
                        token.assetIssuer == counterAsset.assetIssuer {
                        DispatchQueue.main.async {
                            completion(token)
                        }
                    }
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    static func changeTrust(token: Token, completion: @escaping (Bool) -> Void) {
        
        guard let issuer = token.assetIssuer,
            let assetCode = token.assetCode else { return }
        let publicKey = KeychainHelper.publicKey
        let secretKey = KeychainHelper.privateSeed
        
        guard let sourceKeyPair = try? KeyPair(secretSeed: secretKey),
            let issuerKeyPair = try? KeyPair(accountId: issuer) else {
                DispatchQueue.main.async {
                    print("FAILED TO GENERATE ISSUER KEYPAIR")
                    completion(false)
                }
                return
        }
        
        let assetType = (assetCode.count <= 4) ? AssetType.ASSET_TYPE_CREDIT_ALPHANUM4 : AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
        guard let asset = Asset(type: assetType, code: assetCode, issuer: issuerKeyPair) else {
            DispatchQueue.main.async {
                print("Failed go generate asset")
                completion(false)
            }
            return
        }
        
        Stellar.sdk.accounts.getAccountDetails(accountId: publicKey) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                do {
                    let changeTrustOperation = ChangeTrustOperation(sourceAccount: sourceKeyPair, asset: asset, limit: nil)
                    
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [changeTrustOperation],
                                                      memo: nil,
                                                      timeBounds: nil)
                    
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)
                    
                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction, response: { (response) -> (Void) in
                        
                        DispatchQueue.main.async {
                            switch response {
                            case .success(_):
                                completion(true)
                            case .failure(let error):
                                print(error.localizedDescription)
                                completion(false)
                                
                            default:
                                break
                            }
                        }
                        
                    })
                    
                }
                catch {
                    completion(false)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    ////
    
    static func getPayments(completion: @escaping ([Payment]) -> Swift.Void) {
        let accountId = KeychainHelper.publicKey
        guard accountId != "" else { return }
        var payments = [Payment]()
        Stellar.sdk.payments.getPayments(forAccount: accountId, from: nil, order: Order.descending, limit: 200) { (response) -> (Void) in
            switch response {
            case .success(let details):
                for record in details.records {
                    print(record)
                    if let payment = record as? PaymentOperationResponse {
                        let publicKey = KeychainHelper.publicKey
                        let isReceived = payment.from != publicKey ? true : false
                        let payment = Payment.findOrCreatePayment(id: payment.id,
                                                                  assetCode: payment.assetCode ?? "XLM",
                                                                  issuer: payment.assetIssuer ?? "",
                                                                  amount: payment.amount,
                                                                  to: payment.to,
                                                                  from: payment.from,
                                                                  timestamp: payment.createdAt, isReceived: isReceived,
                                                                  in: PersistenceService.context)
                        payments.append(payment)
                       // figureUnreadCount(payment)
                    }
                }
                DispatchQueue.main.async {
                    completion(payments)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func figureUnreadCount(_ payment: Payment) {
//        guard let date = payment.timestamp,
////            let lastUpdated = CurrentUser.paymentsUpdated else { return }
//        if date > lastUpdated {
////            CurrentUser.unreadCount += 1
//        }
    }
    
    
    static var streamItem:OperationsStreamItem? = nil
    
    static func streamPayments(completion: @escaping (Payment) -> Swift.Void) {
        let accountID = KeychainHelper.publicKey
        
        streamItem = Stellar.sdk.payments.stream(for: .paymentsForAccount(account: accountID, cursor: nil))
        
        streamItem?.onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(let id, let operationResponse):
                if let paymentResponse = operationResponse as? PaymentOperationResponse {
                    
                    let isReceived = paymentResponse.from != accountID ? true : false
                    
                    let payment = Payment.findOrCreatePayment(id: id,
                                                              assetCode: paymentResponse.assetCode ?? "XLM",
                                                              issuer: paymentResponse.assetIssuer ?? "",
                                                              amount: paymentResponse.amount,
                                                              to: paymentResponse.to,
                                                              from: paymentResponse.from,
                                                              timestamp: paymentResponse.createdAt,
                                                              isReceived: isReceived,
                                                              in: PersistenceService.context)
                    completion(payment)
                    
                }
            case .error(let err):
                print(err?.localizedDescription ?? "Error")
            }
        }
    }
    
    
    static func sendPayment(token: Token, toAccountID: String, amount: Decimal, completion: @escaping (Bool) -> Void) {
        
        guard KeychainHelper.privateSeed != "",
            let sourceKeyPair = try? KeyPair(secretSeed: KeychainHelper.privateSeed) else {
                DispatchQueue.main.async {
                    print("NO SOURCE KEYPAIR")
                    completion(false)
                }
                return
        }
        
        guard let destinationKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: toAccountID), privateKey: nil) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        Stellar.sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            
            switch response {
            case .success(let accountResponse):
                do {
                    let asset = token.toRawAsset()
                    
                    let paymentOperation = PaymentOperation(sourceAccount: sourceKeyPair,
                                                            destination: destinationKeyPair,
                                                            asset: asset,
                                                            amount: amount)
                    
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [paymentOperation],
                                                      memo: nil,
                                                      timeBounds:nil)
                    
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)
                    
                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                        switch response {
                        case .success(_):
                            DispatchQueue.main.async {
                                completion(true)
                                print(response)
//                               NotificationService.pushNotification(toId: toAccountID, message: "New Payment!")
                            }
                        case .failure(let error):
                            
                            let xdr = try! transaction.getTransactionHash(network: Stellar.network)
                            print(xdr)
                            
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        default:
                            break
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        print("FAILED TO GET ACCOUNT")
                        completion(false)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    
    
    static func trustlineExists(assetCode: String, issuer: String, completion: @escaping (Bool) -> Void) {
        getAccountDetails { (tokens) in
            tokens.forEach({ (token) in
                guard let tokenAssetCode = token.assetCode,
                    let tokenIssuer = token.assetIssuer else {
                        print("NO ISSUER OR NO ASSET CODE")
                        return
                }
                if tokenAssetCode == assetCode && tokenIssuer == issuer {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    
    
}

