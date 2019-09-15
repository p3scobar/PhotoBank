//
//  UserHeader.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import SDWebImage

protocol UserHeaderDelegate: class {
    func handleFollow()
    func handlePay()
    func handleMessage()
    func handleMore()
    func handleURLTap()
    func handlePhotoTap()
}

class UserHeader: UICollectionReusableView {
    
    var delegate: UserHeaderDelegate?
    
    var following: Bool = false {
        didSet {
            if following {
                followButton.titleLabel.text = "Following"
                followButton.icon.image = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
            } else {
                followButton.titleLabel.text = "Follow"
                followButton.icon.image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        backgroundColor = .white
        
        let urlTap = UITapGestureRecognizer(target: self, action: #selector(handleURLTap))
        urlLabel.addGestureRecognizer(urlTap)
        
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap))
        profileImageView.addGestureRecognizer(imgTap)
    }
    
    @objc func handlePhotoTap() {
        delegate?.handlePhotoTap()
    }
    
    @objc func handleURLTap() {
        delegate?.handleURLTap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var user: User? {
        didSet {
            nameLabel.text = user?.name ?? ""
            if let username = user?.username {
                usernameLabel.text = "@\(username)"
            }
            if let userImage = user?.image {
                let url = URL(string: userImage)
                profileImageView.sd_setImage(with: url, completed: nil)
            }
            if let bio = user?.bio {
                bioLabel.text = bio
            }
            
            if let followersCount = user?.followersCount {
                followersLabel.text = "\(followersCount) Followers"
            }
            
            if let url = user?.url {
                urlLabel.text = url
            }
        }
    }
    
    var buttonsEnabled: Bool = true {
        didSet {
            guard let id = user?.id, CurrentUser.uid != id else { return }
            followButton.isEnabled = buttonsEnabled
            payButton.isEnabled = buttonsEnabled
            messageButton.isEnabled = buttonsEnabled
        }
    }
    
    func setupButtons() {
        /// CURRENT USER
        guard let id = user?.id, CurrentUser.uid != id else {
            buttonsEnabled = false
            return
        }
        
        /// NO Wallet (Current User)
        guard KeychainHelper.privateSeed != "" else {
            payButton.isEnabled = false
            return
        }
        
        /// NO WALLET (Other User)
        guard user?.publicKey != "" else {
            payButton.isEnabled = false
            return
        }
        
    }
    
    lazy var profileImageView: UIImageView = {
        let frame = CGRect(x: 20, y: 30, width: 108, height: 108)
        let view = UIImageView(frame: frame)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = frame.width/2
        view.backgroundColor = Theme.lightGray
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.bold(28)
        label.numberOfLines = 0
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = Theme.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var followButton: ProfileButton = {
        let button = ProfileButton(imageName: "plus", title: "Follow")
        button.layer.cornerRadius = 10
        button.isEnabled = true
        button.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var payButton: ProfileButton = {
        let button = ProfileButton(imageName: "token", title: "Pay")
        button.layer.cornerRadius = 10
        button.isEnabled = true
        button.addTarget(self, action: #selector(handlePay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var messageButton: ProfileButton = {
        let button = ProfileButton(imageName: "chat", title: "Message")
        button.layer.cornerRadius = 10
        button.isEnabled = true
        button.addTarget(self, action: #selector(message), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func handleFollow() {
        following = !following
        delegate?.handleFollow()
    }
    
    @objc func handlePay() {
        delegate?.handlePay()
    }
    
    @objc func handleMore() {
        delegate?.handleMore()
    }
    
    @objc func message() {
        delegate?.handleMessage()
    }
    

    func setupView() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(followersLabel)
        addSubview(followButton)
        addSubview(bioLabel)
        addSubview(urlLabel)
        addSubview(bottomLine)
        addSubview(payButton)
        addSubview(messageButton)
        
//        profileImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
//        profileImage.widthAnchor.constraint(equalToConstant: 108).isActive = true
//        profileImage.heightAnchor.constraint(equalToConstant: 108).isActive = true
//        profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        
        followersLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        followersLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 0).isActive = true
        followersLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followersLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        
        bioLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24).isActive = true
        bioLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 0).isActive = true
        bioLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 0).isActive = true
        bioLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        urlLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 10).isActive = true
        urlLabel.leftAnchor.constraint(equalTo: profileImageView.leftAnchor, constant: 0).isActive = true
        urlLabel.rightAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 0).isActive = true
        urlLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let width = frame.width/3
        
        followButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        followButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        followButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 72).isActive = true

        payButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        payButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        payButton.bottomAnchor.constraint(equalTo: followButton.bottomAnchor).isActive = true
        payButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        messageButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        messageButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        messageButton.bottomAnchor.constraint(equalTo: followButton.bottomAnchor).isActive = true
        messageButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        bottomLine.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bottomLine.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    
}

