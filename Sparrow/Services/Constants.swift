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


public struct HorizonServer {
    static let production = ""
    static let test = "https://horizon-testnet.stellar.org/"
    static let url = HorizonServer.test
}

public struct Stellar {
    static let sdk = StellarSDK(withHorizonUrl: HorizonServer.url)
    static let network = Network.testnet
    
}


enum Assets: Int {
    
    case BNK
    
    var issuerAccountID: String {
        switch self {
        case .BNK:
            return "GDA62UZZ2E3LVPVXLN3JQXB4KO3SGIQUHLVUPM7CY4EUSYY4EOMSCGQY"
        }
    }
}

