//
//  TableFooterView.swift
//  Sparrow
//
//  Created by Hackr on 8/11/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit

protocol TableFooterDelegate {
    func didTapButton()
}

class TableFooterView: UIView {
    
    var buttonTitle: String
    
    init(frame: CGRect, title: String) {
        self.buttonTitle = title
        super.init(frame: frame)
        addSubview(indicator)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate: TableFooterDelegate?
    
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
        let frame = CGRect(x: 16, y: 20, width: self.frame.width-32, height: 60)
        let button = Button(frame: frame, title: buttonTitle)
        button.setTitle(buttonTitle, for: .normal)
        button.layer.cornerRadius = 12
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(handleCancel), for: .touchDown)
        return button
    }()
    
    @objc func handleCancel() {
        delegate?.didTapButton()
    }
    
    
    
}



import UIKit

class Button: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = Theme.lightGray
            } else {
                backgroundColor = previousTintColor
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                backgroundColor = Theme.tint
            }
        }
    }
    
    
    private var previousTintColor: UIColor?
    
    
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setTitle(title, for: .normal)
        titleLabel?.font = Theme.semibold(20)
        layer.cornerRadius = 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        previousTintColor = self.backgroundColor
        isHighlighted = true
        sendActions(for: .touchDown)
    }
    
    override func touchesCancelled(_: Set<UITouch>, with _: UIEvent?) {
        isHighlighted = false
    }
    
    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        isHighlighted = false
        sendActions(for: .touchUpInside)
    }
    
}

