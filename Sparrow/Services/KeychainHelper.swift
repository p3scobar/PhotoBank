//
//  KeychainHelper.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import KeychainSwift
import Foundation
import stellarsdk

class KeychainHelper: NSObject {
    
    static var mnemonic: String {
        get { return KeychainSwift().get("mnemonic") ?? newMnemonic() }
        set (key) { KeychainSwift().set(key, forKey: "mnemonic")
            print("Saving mnemonic: \(mnemonic)")
        }
    }
    
    static var publicKey: String {
        get { return KeychainSwift().get("publicKey") ?? "" }
        set (pk) { KeychainSwift().set(pk, forKey: "publicKey")
//            UserManager.updateUserInfo(values: ["publicKey":pk])
            print("Saving Public Key: \(publicKey)")
        }
    }
    
    static var privateSeed: String {
        get { return KeychainSwift().get("privateSeed") ?? "" }
        set (sk) { KeychainSwift().set(sk, forKey: "privateSeed")
            print("Saving Private Seed: \(privateSeed)")
        }
    }
    
    static func newMnemonic() -> String {
        let passphrase = Wallet.generate12WordMnemonic()
        mnemonic = passphrase
        return passphrase
    }
}

