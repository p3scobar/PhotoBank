//
//  WalletHeaderView.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit

protocol WalletHeaderDelegate {
    func handleQRTap()
    func handleCardTap()
    func handleBuy()
    func handleSell()
}

class WalletHeaderView: UIView {
    
    var delegate: WalletHeaderDelegate?
    
    var token: Token? {
        didSet {
            DispatchQueue.main.async {
                self.setupValues()
            }
        }
    }
    
    func setupValues() {
        guard KeychainHelper.privateSeed != "" else { return }
        balanceLabel.text = token?.balance.rounded(3)
        let value = Decimal(string: token?.balance ?? "") ?? 0.0
//        let value = decimal*nav
        let currency = "$\(value.rounded(2))"
        currencyLabel.text = currency
        titleLabel.text = token?.assetCode ?? ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
//        let press = UILongPressGestureRecognizer(target: self, action: #selector(animateCard(_:)))
//        press.minimumPressDuration = 0.05
//        card.addGestureRecognizer(press)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        card.addGestureRecognizer(tap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var card: UIImageView = {
        let frame = CGRect(x: 12, y: 20, width: UIScreen.main.bounds.width-24, height: 220)
        let view = UIImageView(frame: frame)
        view.image = UIImage(named: "cliff")?.withRenderingMode(.alwaysOriginal)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.borderColor = Theme.black.withAlphaComponent(0.3).cgColor
        view.layer.borderWidth = 3
        return view
    }()
    
    
    lazy var blurView: UIVisualEffectView = {
        let frame = CGRect(x: 0, y: 0, width: card.frame.width, height: card.frame.height)
        let view = UIVisualEffectView(frame: frame)
        view.effect = UIBlurEffect(style: .regular)
        return view 
    }()
    
    lazy var shadow: UIView = {
        let view = UIView(frame: card.frame)
        view.layer.cornerRadius = card.layer.cornerRadius
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        return view
    }()
    
    
    lazy var titleLabel: UILabel = {
        let frame = CGRect(x: 20, y: 12, width: card.frame.width-40, height: 40)
        let label = UILabel(frame: frame)
        label.font = Theme.bold(24)
        label.numberOfLines = 1
        label.textColor = Theme.darkGray
        label.layer.shadowColor = Theme.lightGray.withAlphaComponent(1.0).cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 0
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()
    
    lazy var balanceLabel: UILabel = {
        let frame = CGRect(x: 20, y: 12, width: card.frame.width-40, height: 40)
        let label = UILabel(frame: frame)
        label.font = Theme.bold(24)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.textColor = Theme.darkGray
        label.layer.shadowColor = Theme.lightGray.withAlphaComponent(1.0).cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 0
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()
    
    lazy var currencyLabel: UILabel = {
        let frame = CGRect(x: 20, y: self.card.frame.height-44, width: card.frame.width-40, height: 30)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(20)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.layer.shadowColor = Theme.lightGray.withAlphaComponent(1.0).cgColor
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 0
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.textColor = Theme.darkGray
        return label
    }()
    
    lazy var qrView: UIButton = {
        let frame = CGRect(x: self.card.frame.width-60, y: self.card.frame.height-60, width: 60, height: 60)
        let button = UIButton(frame: frame)
        let qrImage = UIImage(named: "qrcode")?.withRenderingMode(.alwaysTemplate)
        button.setImage(qrImage, for: .normal)
        button.tintColor = Theme.darkGray
        button.layer.shadowColor = Theme.lightGray.withAlphaComponent(1.0).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.addTarget(self, action: #selector(handleQRTap), for: .touchUpInside)
        return button
    }()
    
//    lazy var subMenu: NAVMenu = {
//        let frame = CGRect(x: 12, y: self.card.frame.height+40, width: card.frame.width, height: 100)
//        let view = NAVMenu(frame: frame)
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        view.layer.masksToBounds = true
//        return view
//    }()
    
//        lazy var buyButton: UIButton = {
//            let frame = CGRect(x: 12, y: self.card.frame.height+48, width: self.card.frame.width, height: 68)
//            let view = UIButton(frame: frame)
//            view.setTitleColor(.white, for: .normal)
//            view.setTitle("Buy", for: .normal)
//            view.titleLabel?.font = Theme.bold(22)
//            view.backgroundColor = Theme.black
//            view.layer.cornerRadius = 14
//            view.clipsToBounds = true
//            view.addTarget(self, action: #selector(handleBuy), for: .touchUpInside)
//            return view
//        }()
//
//    @objc func handleBuy() {
//        delegate?.handleBuy()
//    }
    
    @objc func handleCardTap(_ tap: UITapGestureRecognizer) {
         self.delegate?.handleCardTap()
    }
    
    @objc func handleQRTap(_ tap: UITapGestureRecognizer) {
        delegate?.handleQRTap()
    }
    
    @objc func animateCard(_ tap: UILongPressGestureRecognizer) {
        if tap.state == .began {
            UIView.animate(withDuration: 0.05) {
                self.shadow.center.y += 8
                self.card.center.y += 8
            }
        } else if tap.state == .ended {
            UIView.animate(withDuration: 0.05) {
                self.shadow.center.y -= 8
                self.card.center.y -= 8
            }
        }
    }
    
    
    func setupView() {
        backgroundColor = Theme.black
        addSubview(shadow)
        addSubview(card)
//        addSubview(buyButton)
        card.addSubview(blurView)
        card.addSubview(titleLabel)
        card.addSubview(balanceLabel)
        card.addSubview(currencyLabel)
        card.addSubview(qrView)
    }
    
    
}
