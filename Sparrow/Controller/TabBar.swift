//
//  TabBar.swift
//  Sparrow
//
//  Created by Hackr on 7/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import Pulley

class TabBar: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate {
    
    var timelineVC: TimelineController!
    var discoverVC: DiscoverController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        timelineVC = TimelineController()
        let timeline = UINavigationController(rootViewController: timelineVC)
        timeline.tabBarItem.image = UIImage(named: "home")
        timeline.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -6, right: 0)
        
        let layout = UICollectionViewFlowLayout()
        discoverVC = DiscoverController(collectionViewLayout: layout)
        let discover = UINavigationController(rootViewController: discoverVC)
        discover.tabBarItem.image = UIImage(named: "search")
        discover.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -6, right: 0)

        let walletVC = WalletController()
        let scan = ScanController()
        let pulley = PulleyViewController(contentViewController: scan, drawerViewController: walletVC)
//        pulley.initialDrawerPosition = .open
//        pulley.drawerTopInset = 20
//        pulley.tabBarItem.image = UIImage(named: "qrcode")
//        pulley.drawerCornerRadius = 0
        pulley.tabBarItem.image = UIImage(named: "qrcode")
        pulley.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -6, right: 0)
        
        let activityVC = ActivityController(style: .plain)
        let activity = UINavigationController(rootViewController: activityVC)
        activity.tabBarItem.image = UIImage(named: "bell")
        activity.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -6, right: 0)
        
        let accountVC = AccountController(style: .grouped)
        let account = UINavigationController(rootViewController: accountVC)
        account.tabBarItem.image = UIImage(named: "user")
        account.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -6, right: 0)
        
        viewControllers = [timeline, discover, pulley, activity, account]
        
        picker?.allowsEditing = true
        picker?.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker?.modalPresentationStyle = .popover
        
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleUnread(notification:)), name: Notification.Name("unread"), object: nil)
    }
    
    @objc func handleUnread(notification: Notification) {
        guard let count = notification.userInfo?["count"] as? Int else { return }
        if count < 1 {
            self.tabBar.items?[3].badgeValue = nil
        } else {
            self.tabBar.items?[3].badgeValue = "\(count)"
        }
    }

    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController == viewControllers?[2] {
//            presentImagePicker()
//            return false
//        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let items = tabBar.items else { return }
        if item != items[selectedIndex] {
            SoundKit.playSound(type: .tab)
        }
        if item == items[0] {
            timelineVC.scrollToTop()
        }
        if item == items[1] {
            discoverVC.scrollToTop()
        }
    }
    

    var picker: UIImagePickerController?
    
    @objc func presentImagePicker() {
        picker = UIImagePickerController()
        picker?.delegate = self
        self.present(picker!, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImage = originalImage as? UIImage
        }
        let vc = ComposeController(image: selectedImage)
        picker.pushViewController(vc, animated: true)
    }
    
    
}

