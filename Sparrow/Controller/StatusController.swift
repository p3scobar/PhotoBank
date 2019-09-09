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

class StatusController: UITableViewController, UISearchControllerDelegate, UINavigationBarDelegate, StatusHeaderDelegate, UIGestureRecognizerDelegate {

    private let statusCell = "newsCell"
    private let commentCell = "commentCell"
    
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
    
    var comments: [Comment] = [] {
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
        tableView.register(CommentCell.self, forCellReuseIdentifier: commentCell)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.contentInset.bottom = 60
        tableView.backgroundColor = Theme.lightBackground
        navigationItem.title = "Photo"
        let more = UIImage(named: "more")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: more, style: .done, target: self, action: #selector(handleMore))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getComments()
    }
    
    
    func fetchStatusFromId() {
        guard let id = statusId else { return }
        NewsService.fetchPost(postId: id) { (status) in
            self.status = status
        }
    }
    
    func getComments() {
        guard let id = status?.id else { return }
        NewsService.getComments(statusID: id) { (comments) in
            self.comments = comments
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return comments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: statusCell, for: indexPath) as! StatusCell
            cell.delegate = self
            cell.indexPath = indexPath
            cell.status = status
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: commentCell, for: indexPath) as! CommentCell
            let comment = comments[indexPath.row]
            cell.comment = comment
//            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return status?.cellHeight(view.frame.width) ?? 640
        } else {
            return comments[indexPath.row].height()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    lazy var menu: ChatInputView = {
        let view = ChatInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        view.chatDelegate = self
        
        return view
    }()
    
    override var inputAccessoryView: UIView! {
        get {
            return menu
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    static var AllowUserInteraction: UIViewKeyframeAnimationOptions {
        get {
            return UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.allowUserInteraction.rawValue)
        }
    }
    
    
    func presentUserController() {
        guard let id = status?.userId else { return }
        let vc = UserController(id)
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
        if status?.userId == CurrentUser.uid {
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

    
    func handlePayTap() {
        let vc = AmountController(publicKey: nil)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
}


extension StatusController: StatusCellDelegate {
    
    func handleUsernameTap(_ username: String) {
        let vc = UserController(username)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleUserTap(_ userId: String) {
        let vc = UserController(userId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func handleHashtagTap(_ tag: String) {
        let vc = TagsController()
        vc.query = tag
        vc.navController = self.navigationController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleDoubleTap(publicKey: String, username: String) {
        
    }
    
    
    
}



extension StatusController: ChatMenuDelegate {
    
    func handleSend(_ text: String) {
        guard let status = status else { return }
        menu.inputTextField.textView.text = ""
        view.resignFirstResponder()
        NewsService.postComment(status: status, text: text) { (comment) in
            guard let comment = comment else { return }
            self.comments.insert(comment, at: 0)
            if self.tableView.numberOfRows(inSection: 0) > 0 {
                let path = IndexPath(item: 0, section: 1)
                self.tableView.scrollToRow(at: path, at: .top, animated: true)
            }
        }
    }
    
}


extension StatusController: CommentCellDelegate {

}
