//
//  ChatInputView.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import NextGrowingTextView

protocol ChatMenuDelegate: class {
    func handleSend(_ text: String)
}

class ChatInputView: UIView, UITextViewDelegate {
    
    var chatDelegate: ChatMenuDelegate?
    
    static let defaultHeight: CGFloat = 44
    
//    weak var chatLogController: ChatController? {
//        didSet {
//            sendButton.addTarget(chatLogController, action: #selector(chatLogController?.handleSend), for: .touchUpInside)
//        }
//    }
    
    @objc func handleSendTap() {
        guard let text = inputTextField.textView.text else { return }
        chatDelegate?.handleSend(text)
    }
    
    @objc func handlePlusTap() {
        inputMoney.becomeFirstResponder()
    }
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Theme.bold(18)
        button.addTarget(self, action: #selector(handleSendTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "token")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Theme.gray
        button.addTarget(self, action: #selector(handlePlusTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
        autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        inputTextField.isScrollEnabled = false
        inputTextField.textView.delegate = self
        setupView()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
        inputTextField.inputView?.becomeFirstResponder()
    }
    
    lazy var inputMoney: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.showsVerticalScrollIndicator = false
        textField.font = UIFont.systemFont(ofSize: 8)
        return textField
    }()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.border
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var inputTextField: NextGrowingTextView = {
        let view = NextGrowingTextView()
        view.maxNumberOfLines = 6
        view.textView.textContainer.lineBreakMode = .byWordWrapping
//        view.textView.placeholder = "Aa"
//        view.textView.placeholderColor = Theme.gray
        view.textView.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        view.textView.textColor = .white
        view.textView.font = Theme.semibold(18)
        view.backgroundColor = Theme.background
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.border.cgColor
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textView.keyboardAppearance = .dark
        return view
    }()
    
    
    func setupView() {
        backgroundColor = Theme.background
        addSubview(inputMoney)
        addSubview(sendButton)
        addSubview(inputTextField)
        
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        
        
        sendButton.bottomAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: -4).isActive = true
        sendButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        bringSubviewToFront(sendButton)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

