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
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = Theme.lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.medium(16)
        label.textColor = Theme.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        profileImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 0).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
