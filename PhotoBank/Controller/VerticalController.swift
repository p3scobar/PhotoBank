//
//  VerticalController.swift
//  PhotoBank
//
//  Created by Hackr on 9/14/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit

protocol VerticalScrollDelegate {
    func scroll(_ isEnabled: Bool)
}

class VerticalPageController: UIPageViewController {

//    var pageViewController: PageViewController!

//    var horizontalScrollEnabled: Bool = false {
//        didSet {
//            pageViewController.horizontalScrollEnabled = horizontalScrollEnabled
//        }
//    }

    lazy var controllers: [UIViewController] = {
        let scan = CameraController()
//        price.delegate = self
        let tab = TabBar()
        return [scan, tab]
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = Theme.black
        let second = controllers[1]
        self.setViewControllers([second], direction: .forward, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        horizontalScrollEnabled = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        horizontalScrollEnabled = true
    }



}


extension VerticalPageController: UIPageViewControllerDelegate {

}

extension VerticalPageController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let vcIndex = controllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard controllers.count > previousIndex else { return nil }

        return controllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let vcIndex = controllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1

        guard controllers.count != nextIndex else { return nil }
        guard controllers.count > nextIndex else { return nil }

        return controllers[nextIndex]

    }

}


extension VerticalPageController: VerticalScrollDelegate {

    func scroll(_ isEnabled: Bool) {
//        self.horizontalScrollEnabled = isEnabled
    }

}
