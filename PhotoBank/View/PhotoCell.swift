//
//  PhotoCell.swift
//  Sparrow
//
//  Created by Hackr on 8/1/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCell: UICollectionViewCell {
    
    var status: Status? {
        didSet {
            if let imageUrl = status?.thumbnail {
                let url = URL(string: imageUrl)
                mainImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        backgroundColor = Theme.lightBackground
    }
    
    lazy var mainImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(mainImageView)
        
        mainImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
}
