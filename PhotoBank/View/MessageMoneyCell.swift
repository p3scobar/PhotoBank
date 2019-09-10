//
//  MessageMoneyCell.swift
//  Sparrow
//
//  Created by Hackr on 9/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit

class MessageMoneyCell: MessageCell {
    
    override var message: Message? {
        didSet {
            if let amount = message?.amount {
                self.amountLabel.text = amount.rounded(2)
            }
            if let assetCode = message?.assetCode {
                self.assetCodeLabel.text = assetCode
            }
            if let status = message?.status {
                self.statusLabel.text = status
            }
        }
    }
    
    var amount: Decimal = 0 {
        didSet {
            amountLabel.text = amount.rounded(2)
        }
    }
    
    

    lazy var assetCodeLabel: UILabel = {
        let frame = CGRect(x: 16, y: 6, width: self.bubbleView.frame.width-20, height: 20)
        let label = UILabel(frame: frame)
        label.textAlignment = .left
        label.textColor = .white
        label.font = Theme.semibold(16)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let frame = CGRect(x: 0, y: 0, width: 180, height: 180)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.textColor = .white
        label.font = Theme.bold(48)
        label.numberOfLines = 0
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var statusLabel: UILabel = {
        let frame = CGRect(x: 10, y: self.bubbleView.frame.height-80, width: self.bubbleView.frame.width-28, height: 30)
        let label = UILabel(frame: frame)
        label.textAlignment = .right
        label.textColor = Theme.gray
        label.font = Theme.semibold(14)
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView.addSubview(amountLabel)
        bubbleView.addSubview(assetCodeLabel)
        bubbleView.addSubview(statusLabel)
        
        contentHeight?.constant = 160
        amountLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        amountLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true

        bubbleView.backgroundColor = Theme.black
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

