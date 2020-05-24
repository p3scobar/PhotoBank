//
//  TokenCell.swift
//  PhotoBank
//
//  Created by Hackr on 4/30/20.
//  Copyright © 2020 Sugar. All rights reserved.
//

import UIKit
import stellarsdk

class TokenCell: UITableViewCell {
    
    
    var token: Token? {
        didSet {
            guard let token = token else { return }
            if let name = token.name {
                titleLabel.text = name
                if let first = name.first {
                    iconView.text = String(first)
                }
            }

            if let balance = Decimal(string: token.balance) {
                rightTitleLabel.text = balance.rounded(4)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        backgroundColor = Theme.tint
        let bg = UIView()
        bg.backgroundColor = Theme.gray
        selectedBackgroundView = bg
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var iconView: UILabel = {
        let label = UILabel()
        label.font = Theme.medium(16)
        label.numberOfLines = 1
        label.backgroundColor = Theme.gray
        label.textAlignment = .center
        label.layer.cornerRadius = 24
        label.clipsToBounds = true
        label.textColor = .white
        label.text = ""
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.medium(18)
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "XLM"
        return label
    }()
    
    lazy var rightTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.textColor = Theme.highlight
        return label
    }()
    
    func setupView() {
        addSubview(titleLabel)
        addSubview(rightTitleLabel)
        addSubview(iconView)
        
        iconView.frame = CGRect(x: 16, y: 16, width: 48, height: 48)
        titleLabel.frame = CGRect(x: 80, y: 16, width: UIScreen.main.bounds.width-80, height: 48)
        rightTitleLabel.frame =  CGRect(x: UIScreen.main.bounds.width/2, y: 16, width: UIScreen.main.bounds.width/2-16, height: 48)
        
    }
    

}
