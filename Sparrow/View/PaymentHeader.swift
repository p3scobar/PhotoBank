//
//  PaymentHeader.swift
//  Sparrow
//
//  Created by Hackr on 9/8/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit

class PaymentHeader: UIView {
    
    var payment: Payment?
    
    var user: User? {
        didSet {
            if let username = user?.username {
                self.usernameLabel.text = "$\(username)"
            }
            if let userImage = user?.image {
                let url = URL(string: userImage)
                profileImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var profileImageView: UIImageView = {
        let frame = CGRect(x: self.center.x-50, y: 32, width: 100, height: 100)
        let view = UIImageView(frame: frame)
        view.layer.cornerRadius = frame.width/2
        view.contentMode = .scaleAspectFill
        view.backgroundColor = Theme.lightGray
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    lazy var usernameLabel: UILabel = {
        let frame = CGRect(x: 20, y: 160, width: self.frame.width-40, height: 40)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.textColor = Theme.black
        label.text = "$"
        label.font = Theme.semibold(24)
        return label
    }()
    
    lazy var line: UIView = {
        let frame = CGRect(x: 0, y: self.frame.height-1, width: self.frame.width, height: 0.6)
        let view = UIView(frame: frame)
        view.backgroundColor = Theme.border
        return view
    }()
    
    func setupView() {
        addSubview(profileImageView)
        addSubview(usernameLabel)
    }
    
}


