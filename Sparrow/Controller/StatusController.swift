//
//  StatusController.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import CoreData

class StatusController: UITableViewController, UISearchControllerDelegate, UINavigationBarDelegate, StatusHeaderDelegate, StatusCellDelegate, UIGestureRecognizerDelegate {

    private let statusCell = "newsCell"
    
    var statusId: String? {
        didSet {
            fetchStatusFromId()
        }
    }
    
    var status: Status? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.allowsSelection = false
        tableView.backgroundColor = Theme.lightBackground
        tableView.register(StatusCell.self, forCellReuseIdentifier: statusCell)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        navigationItem.title = "Photo"
        let more = UIImage(named: "more")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: more, style: .done, target: self, action: #selector(handleMore))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func fetchStatusFromId() {
        guard let id = statusId else { return }
        NewsService.fetchPost(postId: id) { (status) in
            self.status = status
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statusCell, for: indexPath) as! StatusCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.status = status
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 540
        if let text = status?.text {
            let textHeight = estimateFrameForText(text: text, fontSize: 18).height
            height += textHeight+20
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func presentUserController() {
        let vc = UserController()
        vc.userId = status?.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleComment(status: Status) {
        let vc = CommentsController(status: status)
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func handleLike(post: Status) {
        NewsService.likePost(post: post)
    }
    
    @objc func handleMore() {
        if status?.userId == Model.shared.uuid {
            presentDeleteMenu()
        } else {
            presentPublicMenu()
        }
    }
    
    func presentDeleteMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            guard let id = self.status?.id else { return }
            NewsService.deletePost(postId: id)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func presentPublicMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let report = UIAlertAction(title: "Report", style: .destructive) { (report) in
            guard let id = self.status?.id else { return }

        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(report)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func handleUserTap(userId: String) {
        let layout = UICollectionViewFlowLayout()
        let vc = UserController(collectionViewLayout: layout)
        vc.userId = status?.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handlePayTap() {
        let vc = AmountController(publicKey: nil)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
}
