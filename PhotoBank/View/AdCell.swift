//
//  AdCell.swift
//  Sparrow
//
//  Created by Hackr on 8/25/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit

class AdCell: StatusCell {
    
    var ad: Ad? {
        didSet {
            guard ad != nil else { return }
            nameLabel.text = "Sponsored"
            statusLabel.text = ad?.text
            
            if let imageUrl = ad?.image,
                let url = URL(string: imageUrl) {
                mainImageView.sd_setImage(with: url, completed: nil)

                adLabel.isHidden = false
            }
            
        }
    }
    
    
}
