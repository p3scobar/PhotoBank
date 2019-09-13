//
//  WalletService.swift
//  Sparrow
//
//  Created by Hackr on 8/5/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import stellarsdk
import Firebase
import Alamofire

struct WalletService {
    
    static let mnemonic = Wallet.generate12WordMnemonic()
    static var keyPair: KeyPair?
    
    static func generateKeyPair(mnemonic: String, completion: @escaping (KeyPair) -> Void) {
        print(mnemonic)
        let keyPair = try! Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0)
        completion(keyPair)
    }
    
    
    /// CREATE TEST ACCOUNT
    
    static func createStellarTestAccount(accountID:String, completion: @escaping (Any?) -> Swift.Void) {
        DispatchQueue.global(qos: .background).async {
            Stellar.sdk.accounts.createTestAccount(accountId: accountID) { (response) -> (Void) in
                switch response {
                case .success(let details):
                    changeTrust(completion: { (trusted) in
                        print("Trustline set: \(trusted)")
                        DispatchQueue.main.async {
                            completion(details)
                            
                        }
                    })
                case .failure(let error):
                    completion(nil)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func authenticate() {
        guard KeychainHelper.publicKey != "" else {
            print("NO PUBLIC KEY!")
            
            return
        }
    }
    
    static func getAccountDetails(completion: @escaping (Token?) -> Swift.Void) {
        DispatchQueue.global(qos: .background).async {
            let accountId = KeychainHelper.publicKey
            Stellar.sdk.accounts.getAccountDetails(accountId: accountId) { response -> (Void) in
                switch response {
                case .success(let accountDetails):
                    accountDetails.balances.forEach({ (asset) in
                        let token = Token(response: asset)
                        let assetCode = reserveAsset.assetCode ?? "PBK"
                        if token.assetCode == assetCode {
                            DispatchQueue.main.async {
                                completion(token)
                            }
                        }
                    })
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    static func changeTrust(completion: @escaping (Bool) -> Void) {
        guard let sourceKeyPair = try? KeyPair(secretSeed: KeychainHelper.privateSeed) else {
            completion(false)
            return
        }
        
        let asset = reserveAsset.toRawAsset()
        
        Stellar.sdk.accounts.getAccountDetails(accountId: KeychainHelper.publicKey) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                do {
                    let changeTrustOperation = ChangeTrustOperation(sourceAccount: sourceKeyPair, asset: asset, limit: 10000000000)
                    
                    let transaction = try Transaction(sourceAccount: accountResponse,
                                                      operations: [changeTrustOperation],
                                                      memo: nil,
                                                      timeBounds: nil)
                    
                    try transaction.sign(keyPair: sourceKeyPair, network: Stellar.network)
                    
                    try Stellar.sdk.transactions.submitTransaction(transaction: transaction, response: { (response) -> (Void) in
                        switch response {
                        case .success(_):
                            completion(true)
                        case .failure(let error):
                            print(error.localizedDescription)
                            completion(false)
                        }
                    })
                    
                }
                catch {
                    completion(false)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
        
    }
    
    
    static func fetchAssets(completion: @escaping ([String]) -> Swift.Void) {
        Stellar.sdk.assets.getAssets { (response) -> (Void) in
            switch response {
            case .success(let details):
                for asset in details.records {
                    let assetResponse = asset as AssetResponse
                    print("Asset Amount: \(assetResponse.amount)")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
//    static func fetchTransactions(completion: @escaping ([Payment]) -> Void) {
//        DispatchQueue.global(qos: .background).async {
//            let urlString = "\(baseUrl)/payments"
//            let url = URL(string: urlString)!
//            let token = Model.shared.token
//            let headers: HTTPHeaders = ["Authorization":"Bearer \(token)"]
//            let params: Parameters = [:]
//            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//print(response)
//                var payments = [Payment]()
//                guard let json = response.result.value as? [String:Any],
//                    let resp = json["response"] as? [String:Any],
//                    let results = resp["payments"] as? [[String:Any]] else { return }
//                results.forEach({ (data) in
//                    let id = data["_id"] as? String ?? ""
//                    let payment = Payment.findOrCreatePayment(id: id, data: data, in: PersistenceService.context)
//                    payments.append(payment)
//                })
//                completion(payments)
//            }
//        }
//    }
    
    
    static func fetchTransactions(completion: @escaping ([Payment]) -> Swift.Void) {
        DispatchQueue.global(qos: .background).async {
            let accountId = KeychainHelper.publicKey
            guard accountId != "" else { return }
            var payments = [Payment]()
            Stellar.sdk.payments.getPayments(forAccount: accountId, from: nil, order: Order.descending, limit: 50) { (response) -> (Void) in
                switch response {
                case .success(let details):
                    for payment in details.records {
                        if let paymentResponse = payment as? PaymentOperationResponse {
                            print(paymentResponse)
                            let isReceived = paymentResponse.from != accountId ? true : false
                            let date = paymentResponse.createdAt
                            let amount = paymentResponse.amount
                            let assetCode = paymentResponse.assetCode ?? ""
                            let data = ["amount":amount,
                                        "id":paymentResponse.id,
                                        "to": paymentResponse.to,
                                        "from": paymentResponse.from,
                                        "timestamp":date,
                                        "assetCode":assetCode,
                                        "isReceived":isReceived] as [String : Any]
                            let payment = Payment.findOrCreatePayment(id: paymentResponse.id, data: data, in: PersistenceService.context)
                            payments.append(payment)

                            print("$$ TRANSACTION FETCHED $$:")
                            print("Amount: \(paymentResponse.amount)")
                            print("ID: \(paymentResponse.id)")
                        }
                        DispatchQueue.main.async {
                            completion(payments)
                        }
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        completion([])
                    }
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    
    static func streamPayments(completion: @escaping (Payment) -> Swift.Void) {
        let accountID = KeychainHelper.publicKey
//        guard let publicKey = baseAsset.assetIssuer else {
//            print("FAILED TO STREAM PAYEnTS:S ")
//            return
//        }
        let issuingAccountKeyPair = try? KeyPair(accountId:  accountID)
        
        
        Stellar.sdk.payments.stream(for: .paymentsForAccount(account: accountID, cursor: "now")).onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response(let id, let operationResponse):
                if let paymentResponse = operationResponse as? PaymentOperationResponse {
                    
                    
                    let isReceived = paymentResponse.from != accountID ? true : false
                    let date = paymentResponse.createdAt
                    let amount = paymentResponse.amount
                    let data = ["amount":amount,
                                "id":paymentResponse.id,
                                "date":date,
                                "isReceived":isReceived] as [String : Any]
                    let payment = Payment.findOrCreatePayment(id: paymentResponse.id, data: data, in: PersistenceService.context)
                    DispatchQueue.main.async {
                        completion(payment)
                    }
                    
                    print("Payment of \(paymentResponse.amount) PBK from \(paymentResponse.sourceAccount) received -  id \(id)" )
                }
            case .error(let err):
                print(err!.localizedDescription)
            }
        }
    }
    
    
    

    static func sendPayment(token: Token, toAccountID: String, amount: Decimal, completion: @escaping (String?) -> Void) {
        
        guard KeychainHelper.privateSeed != "",
            let sourceKeyPair = try? KeyPair(secretSeed: KeychainHelper.privateSeed) else {
                DispatchQueue.main.async {
                    print("NO SOURCE KEYPAIR")
                    completion(nil)
                }
                return
        }
        
        guard let destinationKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: toAccountID), privateKey: nil) else {
            DispatchQueue.main.async {
                print(" NO DESTINATION KEYPAIR")
                completion(nil)
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
                        case .success(let data):
                            DispatchQueue.main.async {
                                completion("somekey")
                                print(data)
                            }
                        case .failure(let error):
                            
                            let xdr = try! transaction.getTransactionHash(network: Stellar.network)
                            print(xdr)
                            
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        print("FAILED TO GET ACCOUNT")
                        completion(nil)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    
    
    
    static func adPayout(_ id: String, completion: @escaping (Bool) -> Void) {
        
        let token = Token.native
        let amount = Decimal(string: "0.25") ?? 0.0
        let publicKey = KeychainHelper.publicKey
        
        let issuerSK = "SC7CV7ZRGN3DUHG2EXVYSVX3F2RIZ76EQV73PNJHXQU47TN5A4XTQMWV"
        
        guard let sourceKeyPair = try? KeyPair(secretSeed: issuerSK) else {
                DispatchQueue.main.async {
                    print("NO SOURCE KEYPAIR")
                    completion(false)
                }
                return
        }
        
        guard let destinationKeyPair = try? KeyPair(publicKey: PublicKey.init(accountId: publicKey), privateKey: nil) else {
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
                            }
                        case .failure(let error):
                            
                            let xdr = try! transaction.getTransactionHash(network: Stellar.network)
                            print(xdr)
                            
                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"Post Payment Error", horizonRequestError:error)
                            DispatchQueue.main.async {
                                completion(false)
                            }
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
    
    
    static func login(_ passphrase: String, completion: @escaping (Bool) -> Void) {
        generateKeyPair(mnemonic: passphrase, completion: { (keyPair) in
            KeychainHelper.publicKey = keyPair.accountId
            KeychainHelper.privateSeed = keyPair.secretSeed
            KeychainHelper.mnemonic = passphrase
            NotificationCenter.default.post(name: Notification.Name("login"), object: nil, userInfo: [:])
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
        
//        createRealAccount {
//            DispatchQueue.main.async {
//                completion()
//            }
//        }
        #endif
    }
    
    
}
