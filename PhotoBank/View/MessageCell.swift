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
    func handleLongPress(_ message: Message)
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
            incoming = message?.incoming ?? true
        }
    }
    
    var incoming: Bool = true {
        didSet {
            if incoming == true {
                bubbleView.setX(12)
            } else {
                let offset = bubbleView.frame.width+12
                let x = frame.width-offset
                bubbleView.setX(x)
            }
        }
    }
    
    var isGroupMessage: Bool = false
    
    var bubbleView: UIView = {
        let frame = CGRect(x: 0, y: 12, width: 40, height: 40)
        let view = UIView(frame: frame)
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var messageLabel: UILabel = {
        let frame = CGRect(x:18, y: 8, width: 40, height: 40)
        let view = UILabel(frame: frame)
        view.font = Theme.medium(18)
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textAlignment = .left
        
        view.textColor = .white
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var usernameLabel: UILabel = {
        let view = UILabel()
        view.font = Theme.semibold(14)
        view.numberOfLines = 1
        view.textAlignment = .left
        view.textColor = Theme.gray
        view.isHidden = true
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var contentRight: NSLayoutConstraint?
    var contentLeft: NSLayoutConstraint?
    var contentWidth: NSLayoutConstraint?
    var contentHeight: NSLayoutConstraint?
    
    
    var leftMargin: CGFloat = 20
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
        backgroundColor = .clear
        addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        let press = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        bubbleView.addGestureRecognizer(press)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer?) {
        if sender?.state == UIGestureRecognizer.State.began {
            guard let message = message else { return }
            delegate?.handleLongPress(message)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupCell() {
        guard let msg = message else { return }
        if msg.incoming {
//            contentRight?.isActive = false
//            contentLeft?.isActive = true
            messageLabel.textAlignment = .left
            if isGroupMessage {
                usernameLabel.isHidden = false
            } else {
                usernameLabel.isHidden = true
            }
        } else {
//            contentRight?.isActive = true
//            contentLeft?.isActive = false
            messageLabel.textAlignment = .left
            usernameLabel.isHidden = true
        }
//        contentWidth?.isActive = true
        calculateFrame()
        setupColors(msg)
    }
    
    func setupColors(_ msg: Message) {
        switch msg.type {
            case .Text:
                if msg.incoming {
                    messageLabel.textColor = .black
                    bubbleView.backgroundColor = Theme.incoming
                } else {
                    messageLabel.textColor = .white
                    bubbleView.backgroundColor = Theme.outgoing
            }
            case .Money:
                bubbleView.backgroundColor = Theme.black
                
            break
        }
    }
    
    
    func calculateFrame() {
        guard let text = message?.text else {
            return
        }
        let frame = estimateChatBubbleSize(text: text, fontSize: 19)
        let bubbleHeight = frame.height + 20
        let bubbleWidth = frame.width + 34
        bubbleView.setWidth(bubbleWidth)
        bubbleView.setHeight(bubbleHeight)
        
        let messageHeight = frame.height + 4
        let messageWidth = frame.width + 4
        
        messageLabel.setWidth(messageWidth)
        messageLabel.setHeight(messageHeight)

    }
    
    
    
    @objc func handleLinkTap() {
        //        if let delegate = cellDelegate {
        //            guard let url = message?.url else { return }
        //            delegate.cellDidTapLink(url)
        //        }
    }
    
}

