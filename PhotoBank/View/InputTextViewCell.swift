//
//  InputTextViewCell.swift
//  Sparrow
//
//  Created by Hackr on 8/4/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import UIKit

class InputTextViewCell: UITableViewCell, UITextViewDelegate {
    
    var indexPath: IndexPath!
    var delegate: InputTextCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        textView.delegate = self
        backgroundColor = Theme.tint
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textFieldDidChange(indexPath: indexPath, value: textView.text ?? "")
    }
    
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.font = Theme.medium(18)
//        view.placeholderColor = Theme.gray
        view.backgroundColor = Theme.tint
        view.textColor = .white
        view.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        view.keyboardAppearance = .dark
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    func setupView() {
        addSubview(textView)
        
        textView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
