//
//  SwipeController.swift
//  Sparrow
//
//  Created by Hackr on 12/4/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SwipeMenuViewController

@objc protocol SwipeDelegate {
    @objc optional func didSelectUser(_ user: User)
    @objc optional func didSelectTag(_ tag: String)
}

class SwipeController: SwipeMenuViewController {
    
    var navController: UINavigationController?
    
    let usersController = UsersController(style: .plain)
    var tagsController = TagsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersController.navController = self.navController
        tagsController.navController = self.navController
        
        var options = SwipeMenuViewOptions()
        options.tabView.style                           = .segmented
        options.tabView.margin                          = 8.0
        options.tabView.additionView.backgroundColor    = UIColor.gray
        options.tabView.backgroundColor                 = UIColor.white
        options.tabView.itemView.textColor              = Theme.gray
        options.tabView.itemView.selectedTextColor      = Theme.black
        options.contentScrollView.backgroundColor       = Theme.lightBackground
        swipeMenuView.reloadData(options: options)
    }
    
    
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return 2
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        switch index {
        case 0:
            return usersController
        case 1:
            return tagsController
        default:
            return usersController
        }
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        switch index {
        case 0:
            return "People"
        case 1:
            return "Tags"
        default:
            return ""
        }
    }
    
}


extension SwipeController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        usersController.query = text
        tagsController.query = text
    }
    
}
