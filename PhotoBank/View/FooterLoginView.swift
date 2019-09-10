//
//  FooterLoginView.swift
//  Sparrow
//
//  Created by Hackr on 9/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit

class FooterLoginView: ButtonTableFooterView {
    
    var passphrase = ""
    
    override func setupView() {
        addSubview(indicator)
        addSubview(button)
        addSubview(inputField)
        button.center.y += 64
    }
    
    lazy var inputField: UITextField = {
        let frame = CGRect(x: 16, y: 0, width: self.frame.width-32, height: 64)
        let view = UITextField(frame: frame)
        view.font = Theme.semibold(18)
        view.textColor = .black
        view.placeholder = "12 word passphrase"
        view.attributedPlaceholder = NSAttributedString(string: view.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        view.textAlignment = .center
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.keyboardAppearance = .default
        view.backgroundColor = .white
        view.tintColor = Theme.link
        view.layer.cornerRadius = 14
        view.addTarget(self, action: #selector(updatePassphrase), for: .editingChanged)
        return view
    }()
    
    @objc func updatePassphrase() {
        passphrase = inputField.text ?? ""
    }
    
}
