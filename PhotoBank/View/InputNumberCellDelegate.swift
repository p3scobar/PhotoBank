//
//  InputNumberCellDelegate.swift
//  Sparrow
//
//  Created by Hackr on 8/10/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit

protocol InputNumberCellDelegate: class {
    func textFieldDidChange(key: Int, value: Decimal)
}

class InputNumberCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: InputNumberCellDelegate?
    var key = 0
    var value: Decimal = 0.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        selectionStyle = .none

        valueInput.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    @objc func editingChanged() {
        guard let text = valueInput.text else { return }
        let decimal = Decimal(string: text) ?? 0.0
        delegate?.textFieldDidChange(key: key, value: decimal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    let valueInput: UITextField = {
        let label = UITextField()
        label.font = Theme.semibold(20)
        label.textColor = .white
        label.tintColor = Theme.link
        label.attributedPlaceholder = NSAttributedString(string: label.placeholder ?? "0", attributes: [NSAttributedString.Key.foregroundColor:Theme.gray])
        label.textAlignment = .right
        label.keyboardType = .decimalPad
        label.keyboardAppearance = .dark
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    func setupView() {
        backgroundColor = Theme.tint
        textLabel?.textColor = Theme.gray
        textLabel?.font = Theme.medium(18)
        addSubview(valueInput)
        
        valueInput.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        valueInput.topAnchor.constraint(equalTo: topAnchor).isActive = true
        valueInput.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        valueInput.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

