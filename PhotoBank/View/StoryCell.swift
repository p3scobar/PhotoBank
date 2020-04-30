//
//  StoryCell.swift
//  PhotoBank
//
//  Created by Hackr on 9/14/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import SDWebImage

class StoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var story: Story? {
        didSet {
            guard let userImage = story?.userImage,
            let url = URL(string: userImage) else { return }
            mainImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    lazy var mainImageView: UIImageView = {
        let frame = CGRect(x: 10, y: 10, width: self.frame.width-20, height: self.frame.height-20)
        let imageView = UIImageView(frame: frame)
        imageView.layer.cornerRadius = frame.width/2
        imageView.backgroundColor = Theme.lightBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    func setupView() {
        addSubview(mainImageView)
    }
    
}


