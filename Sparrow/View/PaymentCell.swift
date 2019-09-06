//
//  PaymentCell.swift
//  Sparrow
//
//  Created by Hackr on 8/6/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage

class PaymentCell: UITableViewCell {
    
    weak var payment: Payment? {
        didSet {
            self.nameLabel.text = payment!.timestamp?.short()
            
            let amount = payment?.amount?.rounded(2) ?? "0.00"
            if payment?.isReceived ?? false {
                amountLabel.text = "+\(amount)"
            } else {
                amountLabel.text = "-\(amount)"
            }
        }
    }

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.textAlignment = .right
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        
        addSubview(nameLabel)
        addSubview(amountLabel)
     
        nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        amountLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        amountLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        amountLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        amountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
