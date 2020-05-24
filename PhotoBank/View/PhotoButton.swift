//
//  PhotoButton.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit

class PhotoButton: UIControl {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                icon.tintColor = .white
                titleLabel.textColor = .white
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                icon.tintColor = .white
                titleLabel.textColor = .white
            }
        }
    }
    
    private var previousLabelTintColor: UIColor?
    private var previousImageTintColor: UIColor?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(16)
        label.textAlignment = .left
        label.textColor = .white
        label.text = "💬"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var icon: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    convenience init(imageName: String, title: String) {
        self.init()
        icon.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = title
        setupView()
    }
    
    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        isHighlighted = true
        
        previousImageTintColor = .white
        previousLabelTintColor = .white
        
        icon.tintColor = Theme.gray
        titleLabel.textColor = Theme.gray
        sendActions(for: .touchDown)
    }
    
    override func touchesCancelled(_: Set<UITouch>, with _: UIEvent?) {
        isHighlighted = false
        
        icon.tintColor = previousImageTintColor
        titleLabel.textColor = previousLabelTintColor
    }
    
    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        isHighlighted = false
        
        icon.tintColor = previousImageTintColor
        titleLabel.textColor = previousLabelTintColor
        
        sendActions(for: .touchUpInside)
    }
    
    
    func setupView() {
        addSubview(icon)
        
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        
    }
}
