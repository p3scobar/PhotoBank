//
//  ActivityController.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import CoreData

class ActivityController: UITableViewController, UISearchControllerDelegate, UINavigationBarDelegate {
    
    private let activityCell = "activityCell"
    private let refresh = UIRefreshControl()
    
    var notifications = [Activity]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                self.setupEmptyView()
            }
        }
    }
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height/2, width: self.view.frame.width, height: 80))
        label.text = "Nothing to see here."
        label.textColor = Theme.lightGray
        label.font = Theme.semibold(18)
        label.textAlignment = .center
        return label
    }()
    
    func setupEmptyView() {
        if notifications.count == 0 {
            self.tableView.backgroundView = emptyLabel
        } else {
            self.tableView.backgroundView = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.register(ActivityCell.self, forCellReuseIdentifier: activityCell)
        tableView.backgroundColor = .white
        navigationItem.title = "Activity"
        navigationController?.navigationBar.prefersLargeTitles = true
        extendedLayoutIncludesOpaqueBars = true
        fetchData()
    }
    
    @objc func fetchData() {
        ActivityService.fetchActivity { (notifications) in
            self.notifications = notifications
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.refreshControl = refresh
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: activityCell, for: indexPath) as! ActivityCell
//        cell.activity = notifications[indexPath.row]
//        cell.delegate = self
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 60
        if let text = notifications[indexPath.row].text {
            let textHeight = estimateFrameForText(text: text, fontSize: 18).height
            height += textHeight
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notification = notifications[indexPath.row]
        let type = notification.type ?? "like"
        switch type {
        case "comment":
            guard let statusID = notification.statusId else { return }
            pushCommentsController(statusID)
        case "like":
            guard let statusID = notification.statusId else { return }
            pushStatusController(statusID)
        default:
            return
        }
    }
    
    func pushStatusController(_ statusID: String) {
        let vc = StatusController()
        vc.statusId = statusID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushCommentsController(_ statusID: String) {
        let vc = CommentsController(statusID: statusID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func handleUserTap(userId: String) {
        let vc = UserController(userId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handlePhotoTap(_ statusId: String) {
        let vc = StatusController()
        vc.statusId = statusId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


