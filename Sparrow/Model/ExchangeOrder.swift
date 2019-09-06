//
//  ExchangeOrder.swift
//  Sparrow
//
//  Created by Hackr on 8/10/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import stellarsdk

public struct ExchangeOrder {
    
    var size: Decimal
    var price: Decimal
    var total: Decimal
    var side: TransactionType
    var id: Int?
    var buy: Token?
    var sell: Token?
    
    init(size: Decimal, price: Decimal, side: TransactionType) {
        self.size = size
        self.price = price
        self.side = side
        self.total = price*size
    }
    
    init(exchangeOrder: OrderbookOfferResponse, side: TransactionType) {
        let price = Decimal(string: exchangeOrder.price) ?? 0
        let size = orderBookFormattedSize(exchangeOrder, side: side)
        self.init(size: size, price: price, side: side)
    }
    
}


internal func orderBookFormattedSize(_ order: OrderbookOfferResponse, side: TransactionType) -> Decimal {
    if side == .buy {
        let total = Decimal(string: order.amount) ?? 0
        let price = Decimal(string: order.price) ?? 0
        return total/price
    } else {
        let amount = Decimal(string: order.amount) ?? 0
        return amount
    }
}


extension ExchangeOrder {
    
    init(offer: OfferResponse) {
        let side: TransactionType = offer.selling.assetType == "native" ? .buy : .sell
        let buyingAssetAmount = offer.priceR.numerator
        let sellingAssetAmount = offer.priceR.denominator
        
        var price: Decimal = 0
        var size: Decimal = 0
        var total: Decimal = 0
        
        if side == .buy {
            price = Decimal(sellingAssetAmount)/100
            total = Decimal(string: offer.amount) ?? 0
            size = total/price
        } else {
            price = Decimal(buyingAssetAmount)/100
            size = Decimal(string: offer.amount) ?? 0
            total = price*size
        }
        
        self.init(size: size, price: price, side: side)
        self.id = offer.id
        
        buy = Token(offer.buying)
        sell = Token(offer.selling)
    }
    
    
}


