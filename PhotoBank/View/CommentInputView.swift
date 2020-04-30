//
//  CommentInputView.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import NextGrowingTextView

protocol CommentInputDelegate: class {
    func handleSend()
}

class CommentInputView: UIView, UITextViewDelegate {
    
    var commentDelegate: CommentInputDelegate?
    
    static let defaultHeight: CGFloat = 44
    
    weak var commentsController: CommentsController? {
        didSet {
            sendButton.addTarget(commentsController, action: #selector(commentsController?.handleSend), for: .touchUpInside)
        }
    }
    
    
    @objc func handleSendTap() {
        commentDelegate?.handleSend()
    }
    
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(Theme.tint, for: .normal)
        button.titleLabel?.font = Theme.bold(18)
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
        backgroundColor = .white
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 62)
        autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        inputTextField.isScrollEnabled = false
        inputTextField.textView.delegate = self
        
        setupView()
        
        inputTextField.delegates.didChangeHeight = { height in
//            self.frame.size.height = height+16
//            self.frame.offsetBy(dx: 0, dy: -height)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        let height = textView.frame.height
//        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height+16)
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
//        view.textView.placeholder = "Aa"
//        view.textView.placeholderColor = Theme.gray
        view.textView.font = Theme.medium(18)
        view.textView.textColor = .black
        view.layer.borderColor = Theme.lightGray.cgColor
        view.layer.borderWidth = 1
        view.textView.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 12)
        view.layer.cornerRadius = 22
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
        
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        
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
