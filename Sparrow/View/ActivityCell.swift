//
//  ActivityCell.swift
//  Sparrow
//
//  Created by Hackr on 8/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ActivityCell: CommentCell {
    
    var activity: Activity? {
        didSet {
            commentLabel.text = activity?.text
            if let profileUrl = activity?.userImage {
                let url = URL(string: profileUrl)
                profileImage.sd_setImage(with: url, completed: nil)
            }
            if let name = activity?.name {
                nameLabel.text = name
            }
            if let imageUrl = activity?.image {
                let url = URL(string: imageUrl)
                photoView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(photoView)
        constraints()
        textAnchorRight?.constant = -110
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap))
        photoView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc override func handleUserTap() {
        guard let userId = activity?.userId else { return }
        delegate?.handleUserTap(userId: userId)
    }
    
    @objc func handlePhotoTap() {
        guard let statusId = activity?.statusId else { return }
        delegate?.handlePhotoTap(statusId)
    }
    
    lazy var photoView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 12
        view.backgroundColor = Theme.lightBackground
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func constraints() {
        photoView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        photoView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        photoView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        photoView.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
}
