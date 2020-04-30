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
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
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





class UserCellSmall: UserCell {
    
    override func setupView() {
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        profileImage.frame.size = CGSize(width: 40, height: 40)
        profileImage.layer.cornerRadius = 20
        nameLabel.frame = CGRect(x: 72, y: 10, width: self.frame.width-100, height: 24)
        usernameLabel.frame = CGRect(x: 72, y: 30, width: self.frame.width-100, height: 24)
    }
    
}
