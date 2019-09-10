//
//  CashKeyboard.swift
//  Sparrow
//
//  Created by Hackr on 9/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//


import UIKit
//import SwiftySound

protocol CashKeyboarDelegate: class {
    func keyWasTapped(character: String)
    func sendMoney(amount: Decimal)
}

class CashKeyboard: UIView {
    weak var delegate: CashKeyboarDelegate?
    
    var amount: Decimal = 5 {
        didSet {
            moneyLabel.text = "$\(amount)"
        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.outgoing
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let moneyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "$5"
        label.font = UIFont.systemFont(ofSize: 64)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    let moneyLabel: UIPickerView = {
    //        let label = UIPickerView()
    //        label.rowSize(forComponent: 100)
    //        label.numberOfRows(inComponent: 1)
    ////        label.textColor = .white
    ////        label.text = "$10"
    ////        label.font = UIFont.systemFont(ofSize: 64)
    ////        label.textAlignment = .center
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //        return label
    //    }()
    
    
    var timer: Timer?
    
    @objc func plusButtonHold(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handlePlusHold), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func minusButtonHold(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handleMinusHold), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func handlePlusTap() {
        amount += 1
//        Sound.play(file: "clink.m4a")
    }
    
    @objc func handlePlusHold() {
        amount += 10
//        Sound.play(file: "clink.m4a")
    }
    
    @objc func handleMinusHold() {
        if amount > 10 {
            amount -= 10
//            Sound.play(file: "clink.m4a")
        }
    }
    
    
    @objc func handleMinusTap() {
        if amount > 1 {
            amount -= 1
//            Sound.play(file: "clink.m4a")
        }
        
    }
    
    @objc func handlePay() {
        guard let delegate = self.delegate else { return }
        delegate.sendMoney(amount: amount)
        amount = 5
    }
    
    let payButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(handlePay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handlePlusTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let lessButton: UIButton = {
        let button = UIButton()
        button.setTitle("–", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(handleMinusTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setupView() {
        addSubview(moneyLabel)
        addSubview(payButton)
        addSubview(moreButton)
        addSubview(lessButton)
        moneyLabel.text = "$\(amount)"
        
        let longPlusPress = UILongPressGestureRecognizer(target: self, action: #selector(plusButtonHold(gesture:)))
        moreButton.addGestureRecognizer(longPlusPress)
        
        let longMinusPress = UILongPressGestureRecognizer(target: self, action: #selector(minusButtonHold(gesture:)))
        lessButton.addGestureRecognizer(longMinusPress)
        
        moneyLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        moneyLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        moneyLabel.widthAnchor.constraint(equalToConstant: 180).isActive = true
        moneyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        moreButton.leftAnchor.constraint(equalTo: moneyLabel.rightAnchor, constant: 20).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: moneyLabel.centerYAnchor).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        lessButton.rightAnchor.constraint(equalTo: moneyLabel.leftAnchor, constant: -20).isActive = true
        lessButton.centerYAnchor.constraint(equalTo: moneyLabel.centerYAnchor).isActive = true
        lessButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        lessButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        payButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        payButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        payButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}

