//
//  CommentCell.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Firebase

protocol CommentCellDelegate: class {
    func handleUserTap(_ userId: String)
}

class CommentCell: UITableViewCell {
    
    var delegate: CommentCellDelegate?
    
    var comment: Comment? {
        didSet {
            let username = comment?.username ?? ""
            let text = comment?.text ?? ""
            titleLabel.text = username + " " + text
            titleLabel.sizeToFit()
            setupUser()
            selectionStyle = .none
        }
    }
    
    func setupUser() {
        if let image = comment?.userImage {
            let url = URL(string: image)
            profileImage.sd_setImage(with: url, completed: nil)
        }
    }
    
    
    let profileImage: UIImageView = {
        let frame = CGRect(x: 12, y: 8, width: 36, height: 36)
        let view = UIImageView(frame: frame)
        view.layer.cornerRadius = frame.width/2
        view.backgroundColor = Theme.tint
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    lazy var titleLabel: UILabel = {
        let frame = CGRect(x: profileImage.frame.maxX+12, y: profileImage.frame.minY, width: self.frame.width-80, height: 40)
        let view = UILabel(frame: frame)
        view.font = Theme.regular(16)
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.textAlignment = .left
        view.textColor = .white
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
        backgroundColor = Theme.background
        addSubview(profileImage)
        addSubview(titleLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        profileImage.addGestureRecognizer(tap)
    }
    
    
    @objc func handleTap() {
//        if sender?.state == UIGestureRecognizer.State.began {
            guard let userId = comment?.userId else { return }
            delegate?.handleUserTap(userId)
//        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

