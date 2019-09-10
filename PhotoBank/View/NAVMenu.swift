//
//  NAVMenu.swift
//  Sparrow
//
//  Created by Hackr on 9/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit

protocol NAVMenuDelegate {
    func handleBuy()
}

class NAVMenu: UIView {
    
    var delegate: NAVMenuDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    lazy var navLabel: UILabel = {
        let frame = CGRect(x: 20, y: 10, width: self.frame.width/2, height: 40)
        let label = UILabel(frame: frame)
        label.font = Theme.semibold(32)
        label.textAlignment = .center
        label.textColor = Theme.darkGray
        label.text = "$1.04"
        return label
    }()
    
    lazy var buyButton: UIButton = {
        let frame = CGRect(x: self.frame.width-100, y: -2, width: 104, height: self.frame.height+4)
        let button = UIButton(frame: frame)
        button.setTitle("Buy", for: .normal)
        button.titleLabel?.font = Theme.bold(22)
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = Theme.border.cgColor
        button.addTarget(self, action: #selector(handleBuy), for: .touchUpInside)
        return button
    }()
    
    @objc func handleBuy() {
        delegate?.handleBuy()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(navLabel)
        addSubview(buyButton)
    }
    
}
