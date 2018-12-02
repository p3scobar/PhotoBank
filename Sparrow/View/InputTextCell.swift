//
//  InputTextCell.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


protocol InputTextCellDelegate: class {
    func textFieldDidChange(indexPath: IndexPath, value: String)
}

import UIKit

class InputTextCell: UITableViewCell {
    
    var indexPath: IndexPath!
    var delegate: InputTextCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        backgroundColor = .white
        valueInput.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc func valueChanged() {
        delegate?.textFieldDidChange(indexPath: indexPath, value: valueInput.text ?? "")
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var valueInput: UITextField = {
        let view = UITextField()
        view.font = Theme.medium(18)
        view.textAlignment = .right
        if view.placeholder != nil {
            view.attributedPlaceholder = NSAttributedString(string: view.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupView() {
        addSubview(titleLabel)
        addSubview(valueInput)
        
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        valueInput.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        valueInput.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        valueInput.topAnchor.constraint(equalTo: topAnchor).isActive = true
        valueInput.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



