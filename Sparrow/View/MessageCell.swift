//
//  MessageCell.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import Firebase

protocol MessageCellDelegate: class {
    func handleLongPress(userId: String)
}

class MessageCell: UITableViewCell {
    
    var delegate: MessageCellDelegate?
    
    var message: Message? {
        didSet {
            setupCell()
            if let text = message?.text {
                messageLabel.text = text
            } else {
                messageLabel.text = ""
            }
            if let username = message?.username {
                usernameLabel.text = "@\(username)"
            } else {
                usernameLabel.text = ""
            }
        }
    }
    
    var isGroupMessage: Bool = false
    
    var bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = Theme.incoming
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var messageLabel: UILabel = {
        let view = UILabel()
        view.font = Theme.medium(18)
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textAlignment = .left
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var usernameLabel: UILabel = {
        let view = UILabel()
        view.font = Theme.semibold(14)
        view.numberOfLines = 1
        view.textAlignment = .left
        view.textColor = Theme.gray
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var contentRight: NSLayoutConstraint?
    var contentLeft: NSLayoutConstraint?
    var contentWidth: NSLayoutConstraint?
    var contentHeight: NSLayoutConstraint?
    
    
    var leftMargin: CGFloat = 20
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        addSubview(bubbleView)
        addSubview(messageLabel)
        addSubview(usernameLabel)
        
        contentRight = messageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -28)
        contentRight?.isActive = false
        
        
        contentLeft = messageLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 28)
        contentLeft?.isActive = false
        
        contentWidth = messageLabel.widthAnchor.constraint(equalToConstant: 240)
        contentWidth?.priority = UILayoutPriority.init(999.0)
        contentWidth?.isActive = false
        
        contentHeight = messageLabel.heightAnchor.constraint(equalToConstant: 40)
        contentHeight?.isActive = true
        
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        bubbleView.leftAnchor.constraint(equalTo: messageLabel.leftAnchor, constant: -12).isActive = true
        bubbleView.rightAnchor.constraint(equalTo: messageLabel.rightAnchor, constant: 12).isActive = true
        bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor).isActive = true
        
        usernameLabel.leftAnchor.constraint(equalTo: messageLabel.leftAnchor).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -4).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        bubbleView.addGestureRecognizer(press)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer?) {
        if sender?.state == UIGestureRecognizerState.began {
            guard let userId = message?.userId else { return }
            delegate?.handleLongPress(userId: userId)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupCell() {
        guard let msg = message else { return }
        if msg.incoming {
            contentRight?.isActive = false
            contentLeft?.isActive = true
            messageLabel.textAlignment = .left
            messageLabel.textColor = .white
            bubbleView.backgroundColor = Theme.incoming
            if isGroupMessage {
                usernameLabel.isHidden = false
            } else {
                usernameLabel.isHidden = true
            }
        } else {
            contentRight?.isActive = true
            contentLeft?.isActive = false
            messageLabel.textAlignment = .left
            messageLabel.textColor = .white
            bubbleView.backgroundColor = Theme.outgoing
            usernameLabel.isHidden = true
        }
        contentWidth?.isActive = true
        calculateFrame()
    }
    
    
    func calculateFrame() {
        guard let text = message?.text else { return }
        let frame = estimateChatBubbleSize(text: text, fontSize: 18)
        var width = frame.width+2
        width = width > 20 ? width : 20.0
        contentWidth?.constant = width
        contentHeight?.constant = frame.height+20
    }
    
    
    
    @objc func handleLinkTap() {
        //        if let delegate = cellDelegate {
        //            guard let url = message?.url else { return }
        //            delegate.cellDidTapLink(url)
        //        }
    }
    
}

