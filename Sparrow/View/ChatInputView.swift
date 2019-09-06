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
    func handleSend()
}

class ChatInputView: UIView, UITextViewDelegate {
    
    var chatDelegate: ChatMenuDelegate?
    
    static let defaultHeight: CGFloat = 44
    
    weak var chatLogController: ChatController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(chatLogController?.handleSend), for: .touchUpInside)
        }
    }
    
    @objc func handleSendTap() {
        chatDelegate?.handleSend()
    }
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(Theme.black, for: .normal)
        button.titleLabel?.font = Theme.bold(18)
        button.addTarget(self, action: #selector(handleSendTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Theme.gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60)
        autoresizingMask = UIViewAutoresizing.flexibleHeight
        inputTextField.isScrollEnabled = false
        inputTextField.textView.delegate = self
        setupView()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
        inputTextField.inputView?.becomeFirstResponder()
    }
    
    lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var inputTextField: NextGrowingTextView = {
        let view = NextGrowingTextView()
        view.maxNumberOfLines = 6
        view.textView.textContainer.lineBreakMode = .byWordWrapping
        view.textView.placeholder = "Aa"
        view.textView.placeholderColor = Theme.gray
        view.textView.textContainerInset = UIEdgeInsetsMake(10, 14, 10, 14)
        view.textView.textColor = Theme.black
        view.textView.font = Theme.semibold(18)
        view.backgroundColor = Theme.lightBackground
        view.layer.cornerRadius = 20
        view.layer.borderColor = Theme.lightGray.cgColor
        view.layer.borderWidth = 1
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    func setupView() {
        addSubview(container)
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(separator)
        
        container.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        container.topAnchor.constraint(equalTo: separator.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 40).isActive = true
        
        separator.bottomAnchor.constraint(equalTo: inputTextField.topAnchor, constant: -8).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        
        sendButton.bottomAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: -4).isActive = true
        sendButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 38).isActive = true
        bringSubview(toFront: sendButton)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

