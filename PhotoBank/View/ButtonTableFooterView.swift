//
//  ButtonTableFooterView.swift
//  Sparrow
//
//  Created by Hackr on 9/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit

protocol ButtonTableFooterDelegate {
    func didTapButton(_ button: UIButton?)
}

class ButtonTableFooterView: UIView {
    
    var buttonTitle: String
    
    init(frame: CGRect, title: String) {
        self.buttonTitle = title
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        addSubview(indicator)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: ButtonTableFooterDelegate?
    
    var isLoading: Bool = false {
        didSet {
            if isLoading == true {
                indicator.startAnimating()
                button.isHidden = true
                indicator.isHidden = false
            } else {
                indicator.stopAnimating()
                button.isHidden = false
                indicator.isHidden = true
            }
        }
    }
    
    lazy var indicator: UIActivityIndicatorView = {
        let frame = CGRect(x: center.x-24, y: center.y-24, width: 48, height: 48)
        let view = UIActivityIndicatorView(frame: frame)
        view.style = .white
        return view
    }()
    
    
    lazy var button: Button = {
        let frame = CGRect(x: 20, y: 20, width: self.frame.width-40, height: 64)
        let button = Button(frame: frame, title: buttonTitle)
        button.setTitle(buttonTitle, for: .normal)
        button.layer.cornerRadius = 12
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(handleCancel), for: .touchDown)
        return button
    }()
    
    @objc func handleCancel() {
        delegate?.didTapButton(button)
    }
    
    
    
}




