//
//  PaymentCell.swift
//  Sparrow
//
//  Created by Hackr on 8/6/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage

class PaymentCell: UITableViewCell {
    
    weak var payment: Payment? {
        didSet {
            self.subtitleLeftLabel.text = payment!.timestamp?.short()
            let amount = payment?.amount?.rounded(2) ?? "0.00"
            if payment?.isReceived ?? false {
                titleRightLabel.text = "+\(amount)"
            } else {
                titleRightLabel.text = "-\(amount)"
            }
        }
    }
    
    
    var user: User? {
        didSet {
//            guard let userImage = user?.image,
//                let url = URL(string: userImage) else { return }
//            profileImage.sd_setImage(with: url, completed: nil)
//            self.titleLeftLabel.text = user?.name ?? ""
        }
    }
    
    
//    let profileImage: UIImageView = {
//        let frame = CGRect(x: 16, y: 12, width: 48, height: 48)
//        let imageView = UIImageView(frame: frame)
//        imageView.layer.cornerRadius = frame.width/2
//        imageView.backgroundColor = Theme.lightBackground
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.masksToBounds = true
//        return imageView
//    }()

    lazy var titleLeftLabel: UILabel = {
        let frame = CGRect(x: 16, y: 12, width: self.frame.width-24, height: 32)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(18)
        label.textColor = Theme.black
        return label
    }()
    
    lazy var subtitleLeftLabel: UILabel = {
        let frame = CGRect(x: 16, y: 24, width: self.frame.width-24, height: 32)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(20)
        label.textColor = Theme.black
        return label
    }()
    
    
    lazy var titleRightLabel: UILabel = {
        let frame = CGRect(x: 16, y: 24, width: UIScreen.main.bounds.width-24, height: 32)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(20)
        label.textAlignment = .right
        label.textColor = Theme.black
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        
//        addSubview(profileImage)
        addSubview(titleLeftLabel)
        addSubview(subtitleLeftLabel)
        addSubview(titleRightLabel)
     
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
