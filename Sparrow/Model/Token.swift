//
//  Token.swift
//  Sparrow
//
//  Created by Hackr on 8/10/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import stellarsdk

public final class Token {
    
    public var balance: String
    public let assetType: String
    public var assetCode: String?
    public let assetIssuer: String?
    public var lastPrice: Decimal = 0
    
    public init(assetType: String, assetCode: String?, assetIssuer: String?, balance: String) {
        self.assetType = assetType
        self.assetCode = assetCode
        self.assetIssuer = assetIssuer
        self.balance = balance
    }
    
    public init(assetCode: String, issuer: String) {
        self.assetCode = assetCode
        self.assetIssuer = issuer
        self.balance = "0.0"
        self.assetType = AssetTypeAsString.CREDIT_ALPHANUM4
    }
    
    
    init(response: AccountBalanceResponse) {
        self.assetType = response.assetType
        self.assetCode = response.assetCode
        self.assetIssuer = response.assetIssuer
        self.balance = response.balance
    }
    
    init(_ response: OfferAssetResponse) {
        self.assetType = response.assetType
        self.assetCode = response.assetCode
        self.assetIssuer = response.assetIssuer
        self.balance = "0.0"
    }
    
    internal func toRawAsset() -> Asset {
        var type: Int32
        if let code = self.assetCode, code.count >= 5, code.count <= 12 {
            type = AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
        } else if let code = self.assetCode, code.count >= 1, code.count <= 4 {
            type = AssetType.ASSET_TYPE_CREDIT_ALPHANUM4
        } else {
            type = AssetType.ASSET_TYPE_NATIVE
        }
        
        if let issuer = self.assetIssuer {
            let issuerKeyPair = try? KeyPair(accountId: issuer)
            return Asset(type: type, code: self.assetCode, issuer: issuerKeyPair)!
        }
        
        return Asset(type: type, code: self.assetCode, issuer: nil) ?? Asset(type: AssetType.ASSET_TYPE_NATIVE, code: "XLM", issuer: nil)!
    }
    
    
    public var name: String? {
        let code = assetCode ?? ""
        switch code {
        case "USD":
            return "US Dollar"
        case "DMT":
            return "Delémont"
        case "XSG":
            return "Supergold"
        case "XLM":
            return "Stellar Lumens"
        default:
            return assetCode ?? ""
        }
        
    }
    
    
    public var url: String {
        let code = assetCode ?? ""
        switch code {
        case "USD":
            return ""
        case "DMT":
            return "https://delemont.io"
        case "XSG":
            return "https://supergold.io"
        case "XLM":
            return "https://stellar.org"
        default:
            return ""
        }
        
    }
    
    
    
    public var isNative: Bool {
        if assetType == AssetTypeAsString.NATIVE {
            return true
        }
        
        return false
    }
    
    public var hasZeroBalance: Bool {
        if let balance = Decimal(string: balance) {
            return balance.isZero
        }
        
        return true
    }
}

extension Token: Equatable {
    public static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.assetType == rhs.assetType && lhs.assetCode == rhs.assetCode && lhs.assetIssuer == rhs.assetIssuer
    }
}


extension Token {
    
    public static var native: Token {
        return Token(assetType: AssetTypeAsString.NATIVE, assetCode: "XLM", assetIssuer: nil, balance: "")
    }
    
    public static var USD: Token {
        return Token(assetCode: "USD", issuer: "GAUM73DX3ZHRPFDUCYN5AQIEJ4YYWDBH2RYEW276TWJLSCJSFLB23UWN")
    }
    
    
    
    public static var DMT: Token {
        return Token(assetCode: "DMT", issuer: "GAUM73DX3ZHRPFDUCYN5AQIEJ4YYWDBH2RYEW276TWJLSCJSFLB23UWN")
    }
    
    
    public static var XSG: Token {
        return Token(assetCode: "XSG", issuer: "GAUM73DX3ZHRPFDUCYN5AQIEJ4YYWDBH2RYEW276TWJLSCJSFLB23UWN")
    }
    
    
}
