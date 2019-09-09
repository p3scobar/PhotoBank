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
            setupValues()
        }
    }
    
    func setupValues() {
        balanceLabel.text = token?.balance.rounded(0)
        let value = Decimal(string: token?.balance ?? "") ?? 0.0
//        let value = decimal*nav
        currencyLabel.text = value.rounded(2)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        card.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var card: UIImageView = {
        let frame = CGRect(x: 12, y: 20, width: UIScreen.main.bounds.width-24, height: 220)
        let view = UIImageView(frame: frame)
        view.image = UIImage(named: "card")?.withRenderingMode(.alwaysOriginal)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.borderColor = Theme.darkGray.withAlphaComponent(0.3).cgColor
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
        view.layer.shadowColor = UIColor.gray.cgColor
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
        label.text = "ARIES"
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
    
    //    lazy var buyButton: UIButton = {
    //        let frame = CGRect(x: 12, y: 280, width: (self.frame.width-48)/2, height: 60)
    //        let view = UIButton(frame: frame)
    //        view.setTitle("Buy", for: .normal)
    //        view.titleLabel?.font = Theme.semibold(20)
    //        view.backgroundColor = Theme.card
    //        view.layer.cornerRadius = 10
    //        view.clipsToBounds = true
    //        view.tintColor = .white
    //        view.addTarget(self, action: #selector(handleBuy), for: .touchUpInside)
    //        return view
    //    }()
    //
    //    lazy var sellButton: UIButton = {
    //        let frame = CGRect(x: self.center.x+12, y: 280, width: (self.frame.width-48)/2, height: 60)
    //        let view = UIButton(frame: frame)
    //        view.setTitle("Sell", for: .normal)
    //        view.titleLabel?.font = Theme.semibold(20)
    //        view.backgroundColor = Theme.card
    //        view.layer.cornerRadius = 10
    //        view.clipsToBounds = true
    //        view.addTarget(self, action: #selector(handleSell), for: .touchUpInside)
    //        view.tintColor = .white
    //        return view
    //    }()
    //
    //    @objc func handleBuy() {
    //        delegate?.handleBuy()
    //    }
    //
    //    @objc func handleSell() {
    //        delegate?.handleSell()
    //    }
    
    @objc func handleQRTap(_ tap: UITapGestureRecognizer) {
        delegate?.handleQRTap()
    }
    
    @objc func handleCardTap(_ tap: UITapGestureRecognizer) {
        delegate?.handleCardTap()
    }
    
    
    func setupView() {
        backgroundColor = Theme.lightBackground
        addSubview(shadow)
        addSubview(card)
        card.addSubview(blurView)
        card.addSubview(titleLabel)
        card.addSubview(balanceLabel)
        card.addSubview(currencyLabel)
        card.addSubview(qrView)
    }
    
    
}
