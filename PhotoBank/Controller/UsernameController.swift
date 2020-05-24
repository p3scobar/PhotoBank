//
//  UsernameController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class UsernameController: UIViewController, UITextFieldDelegate {
    
    var username = ""
    var available = false
    var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.text = CurrentUser.username
        view.backgroundColor = Theme.background
        setupView()
        self.title = "Username"
        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
        self.navigationItem.rightBarButtonItem = saveButton
        inputField.delegate = self
        self.inputField.text = CurrentUser.username
        inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    var isModal: Bool {
        return presentingViewController != nil ||
            navigationController?.presentingViewController?.presentedViewController === navigationController ||
            tabBarController?.presentingViewController is UITabBarController
    }
    
    @objc func handleSave() {
        guard available == true && username != "" else { return }
        CurrentUser.username = username
        
        let data = ["username":username]
        UserService.updateUserInfo(values: data) { (success) in
            if success == true {
                self.dismissController()
            } else {
                ErrorPresenter.showError(message: "Username unavailable", on: self)
            }
        }
    }
    
    
    
    func dismissController() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    

    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Select a Username"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inputField: UITextField = {
        let view = UITextField()
        view.layer.cornerRadius = 8
        view.backgroundColor = Theme.tint
        view.font = Theme.medium(18)
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.keyboardType = .twitter
        view.textAlignment = .center
        view.textColor = .white
        view.textRect(forBounds: CGRect(x: 20, y: 0, width: 20, height: 10))
        view.placeholder = "@username"
        if view.placeholder != nil {
            view.attributedPlaceholder = NSAttributedString(string: view.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: Theme.gray])
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var toolbar: UIToolbar = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let bar = UIToolbar(frame: frame)
        return bar
    }()
    
    let resultsLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        label.textColor = Theme.gray
        label.font = Theme.medium(16)
        label.textAlignment = .center
        return label
    }()
    
    override var inputAccessoryView: UIView? {
        return toolbar
    }
    
    
    func setupView() {
        view.addSubview(label)
        view.addSubview(inputField)
        
        toolbar.addSubview(resultsLabel)
        
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120).isActive = true
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inputField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        inputField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        inputField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20).isActive = true
        inputField.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    
    func usernameAvailable(_ username: String) {
        UserService.usernameAvailable(username) { (available) in
            if !available || username.count < 4 {
                self.available = false
                if self.username == CurrentUser.username {
                    self.resultsLabel.text = "Hello @\(self.username)!"
                }
            } else {
                self.resultsLabel.text = "👍"
                self.available = true
            }
        }
    }
    
    @objc func textFieldDidChange() {
        available = false
        guard let text = inputField.text else { return }
        username = text
        usernameAvailable(text)
       
    }
    
    
}

