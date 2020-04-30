//
//  ComposeToolbar.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


protocol ComposeDelegate: class {
    func handleSubmit()
}

import UIKit

class ComposeToolbar: UIToolbar {
    
    var inputDelegate: ComposeDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isTranslucent = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        setItems([flexibleSpace, sendButton], animated: true)
        tintColor = .black
    }
    
    
    lazy var sendButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleSend))
        button.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 10), for: .default)
        return button
    }()
    
    @objc func handleSend() {
        inputDelegate?.handleSubmit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
