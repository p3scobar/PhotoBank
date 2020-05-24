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
    func presentOrderController(side: TransactionType)
}

class WalletHeaderView: UIView {
    
    var delegate: WalletHeaderDelegate?
    
    var token: Token? {
        didSet {
            
            self.card.token = token
        }
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
    
    lazy var card: CardView = {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width-40, height: self.frame.width*0.62)
        let view = CardView(frame: frame)
//        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    
    @objc func handleCardTap(_ tap: UITapGestureRecognizer) {
         self.delegate?.handleCardTap()
    }
    
    @objc func handleQRTap(_ tap: UITapGestureRecognizer) {
        delegate?.handleQRTap()
    }
    
    @objc func animateCard(_ tap: UILongPressGestureRecognizer) {
        if tap.state == .began {
            UIView.animate(withDuration: 0.05) {
//                self.card.center.y += 8
            }
        } else if tap.state == .ended {
            UIView.animate(withDuration: 0.05) {
//                self.card.center.y -= 8
            }
        }
    }
    
    lazy var buyButton: Button = {
          let frame = CGRect(x: 16, y: self.frame.height-80, width: self.frame.width/2-24, height: 54)
          let button = Button(frame: frame, title: "Buy")
          button.titleLabel?.font = Theme.semibold(20)
          button.setTitleColor(.white, for: .normal)
          button.backgroundColor = Theme.darkGray
          button.layer.cornerRadius = 8
          button.clipsToBounds = true
          button.addTarget(self, action: #selector(handleBuyTap), for: .touchUpInside)
          return button
      }()

      lazy var sellButton: Button = {
          let frame = CGRect(x: self.frame.width/2+8, y: self.frame.height-80, width: self.frame.width/2-24, height: 54)
          let button = Button(frame: frame, title: "Sell")
          button.titleLabel?.font = Theme.semibold(20)
          button.setTitleColor(.white, for: .normal)
          button.backgroundColor = Theme.darkGray
          button.layer.cornerRadius = 8
          button.clipsToBounds = true
          button.addTarget(self, action: #selector(handleSellTap), for: .touchUpInside)
          return button
      }()
    
    @objc func handleBuyTap() {
        delegate?.presentOrderController(side: .buy)
    }
    
    
    @objc func handleSellTap() {
        delegate?.presentOrderController(side: .sell)
    }
    
    func setupView() {
        backgroundColor = Theme.black

        addSubview(card)
        addSubview(buyButton)
        addSubview(sellButton)
        
    }
    
    
}
