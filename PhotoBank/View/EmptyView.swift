//
//  EmptyView.swift
//  PhotoBank
//
//  Created by Hackr on 5/16/20.
//  Copyright © 2020 Sugar. All rights reserved.
//

import Foundation
import UIKit

class EmptyView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var headline: UILabel = {
        let frame = CGRect(x: 0, y: 100, width: self.frame.width, height: 60)
        let view = UILabel(frame: frame)
        view.text = "Scan NFC Wallet"
        view.font = Theme.bold(32)
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
  
    
    
    func setupView() {
        backgroundColor = .red
        addSubview(headline)
    }
    
}
