//
//  NewPageController.swift
//  PhotoBank
//
//  Created by Hackr on 9/12/19.
//  Copyright © 2019 Sugar. All rights reserved.
//


import UIKit

class NewPageController: UIPageViewController {

//    var vertical: VerticalPageController!
    var horizontalScrollEnabled: Bool = true

    lazy var controllers: [UIViewController] = {

        let layout = UICollectionViewFlowLayout()
        let discover = DiscoverController(collectionViewLayout: layout)
        
        let account = AccountController(style: .grouped)
        
        return [discover, account]
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
//        view.backgroundColor = Theme.background
        let first = controllers[0]
        self.setViewControllers([first], direction: .forward, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        auth()
    }

    func auth() {
//        guard Keychain.publicKey != nil, Keychain.publicKey != "" else {
//            presentHomeController()
//            return
//        }
    }

    func presentHomeController() {
        let vc = HomeController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: false, completion: nil)
    }


}


extension NewPageController: UIPageViewControllerDelegate {

}

extension NewPageController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard horizontalScrollEnabled == true else { return nil }
        guard let vcIndex = controllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard controllers.count > previousIndex else { return nil }

        return controllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard horizontalScrollEnabled == true else { return nil }
        guard let vcIndex = controllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1

        guard controllers.count != nextIndex else { return nil }
        guard controllers.count > nextIndex else { return nil }

        return controllers[nextIndex]

    }
}

