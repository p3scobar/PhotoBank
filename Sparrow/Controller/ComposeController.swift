//
//  ComposeController.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import UITextView_Placeholder
import Photos
import SPStorkController

class ComposeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.navigationItem.title = "Add Caption"
    }
    
    convenience init(image: UIImage?) {
        self.init()
        self.image = image
        imageView.image = image
        setupView()
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            scrollView.contentSize.height += 240
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let frame = UIScreen.main.bounds
        let view = UIScrollView(frame: frame)
        view.alwaysBounceVertical = true
        view.backgroundColor = .white
        view.contentSize = CGSize(width: frame.width, height: frame.height*1.2)
        return view
    }()
    
    lazy var inputTextView: UITextView = {
        let view = UITextView(frame: CGRect(x: 0, y: 240, width: self.view.frame.width, height: 320))
        view.placeholder = "What's happening?"
        view.placeholderColor = .lightGray
        view.font = Theme.semibold(18)
        view.keyboardType = .twitter
        view.textContainerInset = UIEdgeInsetsMake(20, 10, 0, 10)
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    

    
    override func viewDidAppear(_ animated: Bool) {
        inputTextView.becomeFirstResponder()
    }
    
    lazy var toolBar: ComposeToolbar = {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        let bar = ComposeToolbar(frame: frame)
        bar.inputDelegate = self
        return bar
    }()
    
    
    override var inputAccessoryView: UIView! {
        get {
            return toolBar
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func handleCancel() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    func setupView() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 64), animated: false)
        view.addSubview(scrollView)
        scrollView.addSubview(inputTextView)
        scrollView.addSubview(imageView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // fucked: fix this
        let height = estimateFrameForText(text: textView.text, fontSize: 20).height
        let newHeight: CGFloat = UIScreen.main.bounds.height + height
        scrollView.contentSize.height = newHeight
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
                print("status is \(status)")
                if status == PHAuthorizationStatus.authorized {
                    authorized = true
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
    
    
//    func handleImageTap() {
//        if photoPermission() {
//            let vc = UIImagePickerController()
//            vc.allowsEditing = true
//            vc.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
//            vc.modalPresentationStyle = .popover
//            self.present(vc, animated: true, completion: nil)
//        }
//    }
    
    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//
//    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        var selectedImageFromPicker: UIImage?
//        if let originalImage = info["UIImagePickerControllerOriginalImage"] {
//            selectedImageFromPicker = originalImage as? UIImage
//        }
//        if let selectedImage = selectedImageFromPicker {
//            self.image = selectedImage
//        }
//        self.dismiss(animated: true, completion: nil)
//    }
    
    
//    func handleSend() {
//        let publicKey = ""
//        let vc = PayController(publicKey: publicKey)
//        vc.publicKey = publicKey
//        let nav = UINavigationController(rootViewController: vc)
//
//        let transitionDelegate = SPStorkTransitioningDelegate()
//        nav.transitioningDelegate = transitionDelegate
//        nav.modalPresentationCapturesStatusBarAppearance = true
//        nav.modalPresentationStyle = .custom
//        nav.modalTransitionStyle = .crossDissolve
//        presentAsStork(nav, height: UIScreen.main.bounds.height*0.8)
//    }

}


extension ComposeController: ComposeDelegate {
    
    func handleSubmit() {
        guard let text = inputTextView.text else { return }
        NewsService.postPhoto(text: text, image: image!)
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
}
