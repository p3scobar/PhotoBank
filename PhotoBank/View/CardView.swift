//
//  CardView.swift
//  PhotoBank
//
//  Created by Hackr on 5/12/20.
//  Copyright © 2020 Sugar. All rights reserved.
//

import Foundation
import UIKit

class CardView: UIView {
    
     var token: Token? {
            didSet {
                if let name = token?.name {
                    titleLabel.text = name
                }
                
                let balance = Decimal(string: token?.balance ?? "") ?? 0.0
                
                let assetCode = token?.assetCode ?? ""
                titleLabel.text = assetCode
                bottomLeftLabel.text = balance.rounded(3)
                
            }
        }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

lazy var cardImageView: UIImageView = {
        let frame = card.frame
        let view = UIImageView(frame: frame)
//        view.image = UIImage(named: "silverBg")
        view.backgroundColor = Theme.tint
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.borderColor = Theme.border.cgColor
        view.layer.borderWidth = 0.6
        return view
    }()
    
    lazy var card: UIView = {
        let width = UIScreen.main.bounds.width-40
        let frame = CGRect(x: 20, y: 20, width: width, height: width*0.618)
        let view = UIView(frame: frame)
        view.frame = frame
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.borderColor = Theme.border.cgColor
        view.layer.borderWidth = 0.6
        return view
    }()
    
    lazy var shadow: UIView = {
        let view = UIView(frame: card.frame)
        view.layer.cornerRadius = card.layer.cornerRadius
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.shadowColor = Theme.black.cgColor
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        return view
    }()
    
    
    lazy var titleLabel: UILabel = {
        let frame = CGRect(x: 48, y: 40, width: card.frame.width-96, height: 40)
        let label = UILabel(frame: frame)
        label.font = Theme.bold(24)
        label.numberOfLines = 1
        label.textColor = .white
//        label.text = "PBK"
        return label
    }()
    
    lazy var topRightLabel: UILabel = {
        let frame = CGRect(x: 40, y: 40, width: card.frame.width-96, height: 40)
        let label = UILabel(frame: frame)
        label.font = Theme.bold(24)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.textColor = .white
        label.text = ""
        return label
    }()
    
    lazy var bottomLeftLabel: UILabel = {
        let frame = CGRect(x: 48, y: card.frame.height-32, width: card.frame.width-96, height: 40)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(20)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .white
        label.text = "Setup Wallet"
        return label
    }()
    
    
    func setupView() {
        addSubview(shadow)
        addSubview(cardImageView)
        addSubview(card)
        addSubview(titleLabel)
        addSubview(topRightLabel)
        addSubview(bottomLeftLabel)
    }

}

