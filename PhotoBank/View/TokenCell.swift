//
//  TokenCell.swift
//  PhotoBank
//
//  Created by Hackr on 4/30/20.
//  Copyright © 2020 Sugar. All rights reserved.
//

import Foundation
import UIKit

class TokenCell: TokenCell {
    
    var imageUrl: String? {
        didSet {
            
        }
    }
    
    var payment: Payment? {
        didSet {
            guard let payment = payment else { return }
            leftSubtitleLabel.text = (payment.isReceived) ? "Received" : "Sent"
            if let timestamp = payment.timestamp {
                titleLabel.text = timestamp.short()
            }
            
            if let amount = payment.amount,
                let decimal = Decimal(string: amount) {
                if payment.isReceived {
                    rightTitleLabel.text = decimal.rounded(2)
                } else {
                    rightTitleLabel.text = "-" + decimal.rounded(2)
                }
            }
            let assetCode = payment.assetCode ?? "XLM"
            guard assetCode != "" else { return }
            rightSubtitleLabel.text = assetCode
            profileImageView.isHidden = false
        }
    }
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(frame: iconView.frame)
        view.backgroundColor = Theme.tint
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    var lastPrice: Decimal = 0 {
        didSet {
            let balance = Decimal(string: token?.balance ?? "") ?? 0.0
            let value = lastPrice*balance
            rightSubtitleLabel.text = value.rounded(2) + " \(baseAsset.assetCode ?? "")"
        }
    }
    
    override var token: Token? {
        didSet {
            super.token = token
            titleLabel.text = token?.name ?? ""
            leftSubtitleLabel.text = token?.assetCode ?? ""
        }
    }
    
    lazy var leftSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.medium(14)
        label.textColor = Theme.gray
        label.numberOfLines = 1
        return label
    }()
    
    lazy var rightSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.medium(14)
        label.textColor = Theme.gray
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()
    
    override func setupView() {
        addSubview(leftSubtitleLabel)
        addSubview(rightSubtitleLabel)
        addSubview(titleLabel)
        addSubview(rightTitleLabel)
//        addSubview(iconView)
//        addSubview(profileImageView)
        
        rightTitleLabel.textColor = Theme.highlight
        
//        iconView.frame = CGRect(x: 16, y: 16, width: 48, height: 48)
        titleLabel.frame = CGRect(x: 20, y: 18, width: UIScreen.main.bounds.width-40, height: 20)
        leftSubtitleLabel.frame = CGRect(x: 20, y: 42, width: UIScreen.main.bounds.width-40, height: 20)
        rightSubtitleLabel.frame = CGRect(x: 20, y: 42, width: UIScreen.main.bounds.width-40, height: 20)
        rightTitleLabel.frame =  CGRect(x: 24, y: 16, width: UIScreen.main.bounds.width-40, height: 20)
        
    }
    
    
   
    
    
}

