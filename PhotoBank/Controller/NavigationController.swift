//
//  NavigationBar.swift
//  Sparrow
//
//  Created by Hackr on 9/7/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
//    override init(rootViewController: UIViewController) {
//        super.init(rootViewController: rootViewController)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))


            //UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
        
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
                self.view.addGestureRecognizer(swipeRight)
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    @objc func handleSwipe(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                popViewController(animated: true)
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                break
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    
}
