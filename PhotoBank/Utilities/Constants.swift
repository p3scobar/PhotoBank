//
//  Constants.swift
//  Sparrow
//
//  Created by Hackr on 8/5/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import stellarsdk
import Foundation
import Firebase

let baseUrl = "https://expa.bubbleapps.io/version-test/api/1.1/wf"

public struct Stellar {
    static let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    static let network = Network.testnet
}

public struct HorizonServer {
    static let production = "https://horizon.stellar.org"
    static let test = "https://horizon-testnet.stellar.org"
    static let url = HorizonServer.test
}

var superlikeAmount: Decimal = 0.1

let db = Firestore.firestore()
let dbRealtime = Database.database().reference()
let bubbleAPIKey = "afc1c4b4f396fd140e06326b81cbcd65"

let feeAddress = "GA4HWMRCEDPN3PDJSMCPYUMM3LPAALS43FESCUC2T5X7ZPMJEGOXE2JH"

let counterAsset = Token.PBK
let baseAsset = Token.native
