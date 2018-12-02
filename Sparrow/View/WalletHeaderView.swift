//
//  WalletHeaderView.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import QRCode

protocol WalletHeaderDelegate: class {
    func handleQRTap()
}

class WalletHeaderView: UIView {
    
    var delegate: WalletHeaderDelegate?
    
    lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = NSLocale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    
    var balance: String = "0.000" {
        didSet {
            if let number = formatter.number(from: balance),
                let string = formatter.string(from: number) {
                balanceLabel.text = string
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setQRCode()
    }
    
    func setQRCode() {
        let publicKey = KeychainHelper.publicKey
        let qrCode = QRCode(publicKey)
        qrView.image = qrCode?.image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = Theme.bold(24)
        label.text = "0.000"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var currencyCodeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.text = "BNK"
        label.font = Theme.medium(18)
        label.textColor = Theme.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.black
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var shadow: UIView = {
        let view = UIView()
        view.layer.cornerRadius = container.layer.cornerRadius
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var qrView: UIImageView = {
        let frame = CGRect(x: 0, y: 0, width: 72, height: 72)
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var tab: UIView = {
        let frame = CGRect(x: self.frame.width/2-24, y: 7, width: 48, height: 6)
        let view = UIView(frame: frame)
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.backgroundColor = Theme.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func handleQRTap() {
        delegate?.handleQRTap()
    }
    
    func setupView() {
        addSubview(tab)
        addSubview(shadow)
        addSubview(container)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleQRTap))
        container.addGestureRecognizer(tap)
        container.addSubview(balanceLabel)
        container.addSubview(currencyCodeLabel)
        
        shadow.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        shadow.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        shadow.heightAnchor.constraint(equalToConstant: 220).isActive = true
        shadow.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        
        container.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        container.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        container.heightAnchor.constraint(equalToConstant: 220).isActive = true
        container.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
//        qrView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
//        qrView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 16).isActive = true
//        qrView.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        qrView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        balanceLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        balanceLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -16).isActive = true
        balanceLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -16).isActive = true
        balanceLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        currencyCodeLabel.leftAnchor.constraint(equalTo: balanceLabel.leftAnchor).isActive = true
        currencyCodeLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
        currencyCodeLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 20).isActive = true
        currencyCodeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
}
