//
//  AccountController.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import UIKit
import MessageUI
import Photos
import Firebase

class AccountController: UITableViewController, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    let standardCell = "userCell"
    
    let header: AccountHeader = {
        let view = AccountHeader(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Account"
        
        header.delegate = self
        header.tap.delegate = self
        
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = header
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCell)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Theme.lightBackground
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushProfile))
        header.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        header.setupNameAndProfileImage()
    }
    
    func photoPermission() -> Bool {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        var authorized: Bool = false
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            authorized = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized {
                    authorized = true
                    self.presentImagePickerController()
                }
            })
        case .restricted:
            print("User do not have access to photo album.")
            authorized = false
        case .denied:
            print("User has denied the permission.")
            authorized =  false
        }
        return authorized
    }
    
    
    @objc func pushProfile() {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let vc = UserController(id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: standardCell, for: indexPath)
        cell.textLabel?.font = Theme.medium(18)
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.textLabel?.text = "Settings"
        case (0, 1):
            cell.textLabel?.text = "Invite Friends"
        case (1, 0):
            cell.textLabel?.text = "Passphrase"
        case (1, 1):
            cell.textLabel?.text = "Security"
        case (2, 0):
            cell.textLabel?.text = "Sign out"
        default:
            break
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func handleEditButtonTap() {
        let vc = EditProfileController(style: .grouped)
        vc.accountController = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case(0,0):
            pushNotificationController()
        case (0, 1):
            presentInviteController()
        case (1, 0):
            presentPassphrase()
        case (1,1):
            pushSecurityController()
        case (2,0):
            confirmLogout()
        default:
            return
        }
    }
    
    func presentAccountTypeController() {
        
    }
    
    func presentPassphrase() {
        let vc = PassphraseController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushSecurityController() {
        let vc = SecurityController(style: .grouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func presentInviteController() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = .black
        let message = UIAlertAction(title: "iMessage", style: .default) { (mail) in
            self.presentMessageController()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(message)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func presentMessageController() {
        if !MFMessageComposeViewController.canSendText() {
            presentAlert(title: "iMessage Unavailable", message: "Unable to send text messages")
        } else {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.body = "Hey, you should download Sugar. Here's the link: sugar.am/ios"
        self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    
    func pushNotificationController() {
//        let vc = NotificationsController(style: .grouped)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmLogout() {
        let alert = UIAlertController(title: "Have you secured your recovery phrase?", message: "Without this you will not be able to recoer your account or sign back in.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let signOut = UIAlertAction(title: "Sign Out", style: .destructive) { (tap) in
            self.handleLogout()
        }
        alert.addAction(cancel)
        alert.addAction(signOut)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout() {
        UserService.signout { (loggedOut) in
            let vc = HomeController()
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
            self.tabBarController?.selectedIndex = 0
            let id = CurrentUser.uid
            
        }
    }
    
    
//    func pushProfileController() {
//        guard let id = Auth.auth().currentUser?.uid else { return }
//        let vc = UserController(id)
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let doneButton = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(doneButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func handleEditProfilePic() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let picker = UIAlertAction(title: "Camera Roll", style: .default) { (alert) in
            self.presentImagePickerController()
        }
        let done = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alert.addAction(picker)
        alert.addAction(done)
        present(alert, animated: true, completion: nil)
    }
    
    
    func presentImagePickerController() {
        if photoPermission() {
            let vc = UIImagePickerController()
            vc.allowsEditing = true
            vc.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as? UIImage
        }
        if let image = selectedImageFromPicker {
            UserService.updateProfilePic(image: image) { (imageUrl) in
                CurrentUser.image = imageUrl
                self.header.profileImage.image = image
                self.tableView.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

