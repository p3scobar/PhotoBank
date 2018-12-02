//
//  CommentCell.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import SDWebImage

protocol CommentCellDelegate {
    func handleUserTap(userId: String)
    func handlePhotoTap(_ statusId: String)
}

class CommentCell: UITableViewCell {
    
    var delegate: CommentCellDelegate?
    
    var comment: Comment? {
        didSet {
            nameLabel.text = comment?.name
            commentLabel.text = comment?.text
            if let profile = comment?.userImage {
                let url = URL(string: profile)
                profileImage.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleUserTap))
        profileImage.addGestureRecognizer(tap)
        
    }
    
    @objc func handleUserTap() {
        guard let userId = comment?.userId else { return }
        delegate?.handleUserTap(userId: userId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let profileImage: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 12, y: 12, width: 48, height: 48))
        view.layer.cornerRadius = 24
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Theme.lightGray.cgColor
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        return view
    }()
    
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(16)
        label.numberOfLines = 1
        label.textColor = Theme.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.medium(16)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var textAnchorRight: NSLayoutConstraint?
    
    func setupView() {
        selectionStyle = .none
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(commentLabel)
        
        nameLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 16).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        commentLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        textAnchorRight = commentLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        textAnchorRight?.isActive = true
        
        commentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        commentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 22).isActive = true
    }
    
}
