//
//  QRController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//



import Foundation
import UIKit
import QRCode

class QRController: UIViewController {
    
    var string = "" {
        didSet {
            setQRCode()
        }
    }
    
    init(code: String) {
        self.string = code
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.black
        self.navigationController?.navigationBar.prefersLargeTitles = false
        setupView()
        setQRCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setQRCode() {
        let qrCode = QRCode(string)
        publicKeyLabel.text = string
        qrView.image = qrCode?.image
    }
    
    lazy var card: UIView = {
        let maxHeight = (self.view.frame.height < 540) ? self.view.frame.height*0.8 : 540
        let maxWidth = (self.view.frame.width > 380) ? 320 : self.view.frame.width-40
        let view = UIView(frame: CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight))
//        let height = self.view.frame.height/2
//        let frame = CGRect(x: 0, y: self.view.frame.height-height-20, width: self.view.frame.width-40, height: height)
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowRadius = 20
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowOpacity = 0.4
        view.layer.borderColor = Theme.border.cgColor
        view.layer.borderWidth = 0.5
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var qrView: UIImageView = {
        let frame = CGRect(x: card.center.x-80, y: 40, width: 160, height: 160)
        let view = UIImageView(frame: frame)
        return view
    }()
    
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = Theme.bold(18)
        button.setTitleColor(Theme.black, for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let line0: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    lazy var titleLabel: UITextView = {
        let frame = CGRect(x: 24, y: qrView.frame.maxY+10, width: card.frame.width-48, height: 80)
        let view = UITextView(frame: frame)
        view.textColor = Theme.black
        view.backgroundColor = .white
        view.textAlignment = .center
        view.isEditable = false
        view.text = "Send Stellar Lumens XLM to the following address:"
        view.font = Theme.semibold(16)
        return view
    }()
    
    lazy var publicKeyLabel: UITextView = {
        let frame = CGRect(x: 24, y: titleLabel.frame.maxY, width: card.frame.width-48, height: 80)
        let view = UITextView(frame: frame)
        view.textColor = Theme.black
        view.backgroundColor = .white
        view.textAlignment = .center
        view.isEditable = false
        view.font = Theme.semibold(16)
        return view
    }()
    
    let copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy", for: .normal)
        button.titleLabel?.font = Theme.bold(18)
        button.setTitleColor(Theme.black, for: .normal)
        button.addTarget(self, action: #selector(handleCopy), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let line1: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func handleCancel() {
        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleCopy() {
        UIPasteboard.general.string = KeychainHelper.publicKey
        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupView() {
        view.addSubview(card)
        card.addSubview(qrView)
        card.addSubview(titleLabel)
        card.addSubview(publicKeyLabel)
        card.addSubview(doneButton)
        card.addSubview(copyButton)
        card.addSubview(line0)
        card.addSubview(line1)
        
        card.center = view.center
        
        publicKeyLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 36).isActive = true
        publicKeyLabel.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -36).isActive = true
        publicKeyLabel.topAnchor.constraint(equalTo: qrView.bottomAnchor, constant: 20).isActive = true
        publicKeyLabel.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        line0.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        line0.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        line0.bottomAnchor.constraint(equalTo: copyButton.topAnchor).isActive = true
        line0.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        copyButton.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        copyButton.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        copyButton.bottomAnchor.constraint(equalTo: line1.topAnchor).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        line1.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        line1.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        line1.bottomAnchor.constraint(equalTo: doneButton.topAnchor).isActive = true
        line1.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        doneButton.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: card.bottomAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
    }
    
}

