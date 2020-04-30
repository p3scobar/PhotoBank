//
//  NewsCell.swift
//  Sparrow
//
//  Created by Hackr on 7/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import ActiveLabel

protocol StatusCellDelegate: class {
    func handleComment(status: Status)
    func handleLike(post: Status)
    func handlePayTap()
    func handleUserTap(_ id: String)
    func handleUsernameTap(_ username: String)
    func handleHashtagTap(_ tag: String)
    func handleDoubleTap(publicKey: String, username: String)
}

class StatusCell: UITableViewCell {
    
    var indexPath: IndexPath!
    var delegate: StatusCellDelegate?
    
    var likeCount: Int = 0 {
        didSet {
            if likeCount > 0 {
                likeButton.titleLabel.text = "\(likeCount)"
            } else {
                likeButton.titleLabel.text = "Like"
            }
        }
    }
    
    var like: Bool = false {
        didSet {
            if like {
                likeButton.isSelected = true
                likeButton.icon.tintColor = Theme.red
            } else {
                likeButton.icon.tintColor = Theme.tint
            }
        }
    }
    
    
    
    var status: Status? {
        didSet {
            statusLabel.text = status?.text
            if let commentCount = status?.commentCount {
                commentButton.titleLabel.text = "\(commentCount)"
            }
            if let imageUrl = status?.image,
                let url = URL(string: imageUrl) {
                mainImageView.sd_setImage(with: url, completed: nil)
                
            }
            if let userImageUrl = status?.userImage,
                let url = URL(string: userImageUrl) {
                profileImageView.sd_setImage(with: url, completed: nil)
            }
            if let likes = status?.likes {
                likeCount = Int(likes)
            }
            if let name = status?.username {
                nameLabel.text = name
            }
            guard let id = status?.id else { return }
            like = Like.checkIfLiked(statusID: id)
        }
    }
    
    lazy var statusLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = Theme.medium(18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.hashtagColor = Theme.link
        label.mentionColor = Theme.link
        label.textColor = .white
        label.handleHashtagTap { (hashtag) in
           self.delegate?.handleHashtagTap(hashtag)
        }
        label.handleMentionTap { username in
            self.delegate?.handleUsernameTap(username)
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var adLabel: UILabel = {
        let width = UIScreen.main.bounds.width-24
        let frame = CGRect(x: 12, y: 12, width: width, height: 48)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(14)
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .right
        label.isHidden = true
        label.text = "Sponsored"
        return label
    }()
    

    lazy var profileImageView: UIImageView = {
        let frame = CGRect(x: 12, y: 12, width: 48, height: 48)
        let view = UIImageView(frame: frame)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        view.backgroundColor = Theme.tint
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let mainImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = Theme.tint
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var likeButton: PhotoButton = {
        let button = PhotoButton(imageName: "heartCircle", title: "0")
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var commentButton: PhotoButton = {
        let button = PhotoButton(imageName: "chat", title: "0")
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        button.layer.borderColor = Theme.border.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var payButton: PhotoButton = {
        let button = PhotoButton(imageName: "coin", title: "$0.00")
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handlePayTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func handlePayTap() {
        delegate?.handlePayTap()
    }
    
    @objc func handleComment() {
        guard let status = status else { return }
        delegate?.handleComment(status: status)
        commentButton.isHighlighted = false
        SoundKit.playSound(type: .button)
    }
    
    @objc func handleLike() {
        like = !like
        if like {
            likeCount += 1
        } else {
            likeCount -= 1
        }
        
        guard let key = status?.publicKey,
        let username = status?.username else { return }
        delegate?.handleDoubleTap(publicKey: key, username: username)
        SoundKit.playSound(type: .select)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        let userTap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        profileImageView.addGestureRecognizer(userTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleLike))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        customization()
    }
    
    func customization() {
//        imageViewHeight.constant = status?.imageHeight(self.frame.width) ?? 400
//        let bgView = UIView()
//        bgView.backgroundColor = Theme.tint
//        selectedBackgroundView = bgView
    }
    
    @objc func handleUserTap() {
        guard let id = status?.userId else { return }
        delegate?.handleUserTap(id)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageViewHeight: NSLayoutConstraint!
    
    func setupView() {
        addSubview(profileImageView)
        addSubview(adLabel)
        addSubview(nameLabel)
        addSubview(statusLabel)

//        addSubview(likeButton)
//        addSubview(commentButton)
        
        addSubview(mainImageView)
        
        backgroundColor = Theme.black
        
        
        mainImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12).isActive = true
        
        let height = status?.imageHeight(self.frame.width) ?? 420
        
        mainImageView.heightAnchor.constraint(equalToConstant: height).isActive = true

        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 14).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -2).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -60).isActive = true
        
        
//        likeButton.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
//        likeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        likeButton.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 14).isActive = true
//        likeButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
//        
//        commentButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        commentButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        commentButton.topAnchor.constraint(equalTo: likeButton.topAnchor).isActive = true
//        commentButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
//        payButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        payButton.widthAnchor.constraint(equalToConstant: width).isActive = true
//        payButton.topAnchor.constraint(equalTo: likeButton.topAnchor).isActive = true
//        payButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        statusLabel.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 20).isActive = true
        statusLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        statusLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
    }
    
}
