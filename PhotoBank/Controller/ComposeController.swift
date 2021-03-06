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
        view.backgroundColor = Theme.background
        view.contentSize = CGSize(width: frame.width, height: frame.height*1.2)
        return view
    }()
    
    
    lazy var inputTextView: UITextView = {
        let view = UITextView(frame: CGRect(x: 0, y: 240, width: self.view.frame.width, height: 320))
        view.font = Theme.semibold(18)
        view.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
        view.backgroundColor = Theme.background
        view.textColor = .white
        view.keyboardAppearance = .dark
        view.keyboardType = .twitter
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
    
    
}
    

extension ComposeController: ComposeDelegate {
    
    func handleSubmit() {

        let vc = PayController()
        vc.publicKey = feeAddress
        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.customHeight = self.view.frame.height*0.5
        vc.transitioningDelegate = transitionDelegate
        vc.modalPresentationStyle = .custom
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true, completion: {
            print("submit payment")
        })
        
        
//        guard let text = inputTextView.text else { return }
//        NewsService.postPhoto(text: text, image: image!)
//        view.endEditing(true)
//        dismiss(animated: true, completion: nil)
    }
    
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
////        return PayController(presentedViewController: presented, presentingViewController: presentingViewController)
//    }
    
}

extension ComposeController: UIViewControllerTransitioningDelegate {
    
}
