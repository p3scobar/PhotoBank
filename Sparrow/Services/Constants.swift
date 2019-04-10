//
//  Constants.swift
//  Sparrow
//
//  Created by Hackr on 8/5/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import stellarsdk
import Foundation

let baseUrl = "https://expa.bubbleapps.io/version-test/api/1.1/wf"

public struct Stellar {
    static let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    static let network = Network.testnet
}

public struct HorizonServer {
    static let production = "https://horizon.stellar.org"
    static let test = "https://horizon-testnet.stellar.org"
    /// #if dev...
    static let url = HorizonServer.test
}


enum Assets: Int {
    
    case PBK
    
    var issuerAccountID: String {
        switch self {
        case .PBK:
            return "GBS6U6XQHH6FVVSEVVJGFT4IKUGO7I5CST3CIOI265R4CM22MPWML5JK"
        }
    }
}

