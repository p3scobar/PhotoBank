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
                icon.tintColor = Theme.gray
                titleLabel.textColor = Theme.gray
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                icon.tintColor = Theme.gray
                titleLabel.textColor = Theme.gray
            }
        }
    }
    
    private var previousLabelTintColor: UIColor?
    private var previousImageTintColor: UIColor?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(16)
        label.textAlignment = .left
        label.textColor = Theme.charcoal
        label.text = "💬"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var icon: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.tintColor = Theme.charcoal
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
        
        previousImageTintColor = Theme.gray
        previousLabelTintColor = Theme.gray
        
        icon.tintColor = Theme.charcoal
        titleLabel.textColor = Theme.charcoal
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
        addSubview(titleLabel)
        
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
