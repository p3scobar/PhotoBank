//
//  UserCell.swift
//  Sparrow
//
//  Created by Hackr on 8/6/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage

class UserCell: UITableViewCell {
    
    weak var user: User? {
        didSet {
            if let name = user?.name {
                self.nameLabel.text = name
            }
            
            if let username = user?.username {
                usernameLabel.text = "@\(username)"
            }
            profileImage.image = nil
            if let image = user?.image {
                let url = URL(string: image)
                profileImage.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    
    let profileImage: UIImageView = {
        let frame = CGRect(x: 16, y: 12, width: 48, height: 48)
        let imageView = UIImageView(frame: frame)
        imageView.layer.cornerRadius = frame.width/2
        imageView.backgroundColor = Theme.lightBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    lazy var nameLabel: UILabel = {
        let frame = CGRect(x: 80, y: 12, width: self.frame.width, height: 30)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(18)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        let frame = CGRect(x: 80, y: 32, width: self.frame.width, height: 30)
        let label = UILabel(frame: frame)
        label.font = Theme.medium(16)
        label.textColor = Theme.gray
        return label
    }()
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        profileImage.frame.size = CGSize(width: 56, height: 56)
        profileImage.layer.cornerRadius = 28
        nameLabel.frame = CGRect(x: 88, y: 14, width: self.frame.width-100, height: 30)
        usernameLabel.frame = CGRect(x: 88, y: 38, width: self.frame.width-100, height: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



import UIKit
import Firebase

class ChatCell: UserCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    var chat: Chat? {
        didSet {
            if chat!.isGroup {
                setupChannel()
            } else {
                setupNameAndProfileImage()
            }
            if let time = self.chat?.lastMessageSent {
                let date = Date(timeIntervalSince1970: time)
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                self.dateLabel.text = formatter.string(from: date)
            }
        }
    }
    
    fileprivate func setupChannel() {
        nameLabel.text = chat!.title
        if let chatImage = chat!.image {
            let url = URL(string: chatImage)
//            profileImage.kf.setImage(with: url)
        }
        if let lastMessage = self.chat?.lastMessage {
            self.usernameLabel.text = lastMessage
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = Theme.semibold(14)
        label.textColor = Theme.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setupNameAndProfileImage() {
        if let partnerId = chat?.partnerId, partnerId != "" {
            
//            if let user = chat?.users.first {
//                if let name = user.name {
//                    self.nameLabel.text = name
//                }
//
//                if let imageUrl = user.image,
//                    let url = URL(string: imageUrl) {
//                    self.profileImage.sd_setImage(with: url, completed: nil)
//                }
//            }
            
            UserService.fetchUser(userId: partnerId) { (user) in
                self.user = user

                if let name = user.name {
                    self.nameLabel.text = name
                }

                if let imageUrl = user.image,
                    let url = URL(string: imageUrl) {
                    self.profileImage.sd_setImage(with: url, completed: nil)
                }
                if let lastMessage = self.chat?.lastMessage {
                    self.usernameLabel.text = lastMessage
                }

            }
        }
    }
    
    func setupView() {
        addSubview(dateLabel)
        
        dateLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        dateLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 6).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        
    }
    
}
