//
//  CommentsController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit

class CommentsController: UITableViewController, CommentInputDelegate {
    
    let commentCell = "commentCell"
    
//    var photoId: String?
    var status: Status?
    
    var comments: [Comment] = [] {
        didSet {
            reloadTable()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Comments"
        tableView.register(CommentCell.self, forCellReuseIdentifier: commentCell)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0)
        view.backgroundColor = .white
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    convenience init(statusID: String) {
        self.init(style: .plain)
        NewsService.fetchPost(postId: statusID, completion: { (status) in
            self.status = status
            guard let statusID = status.id else { return }
            self.fetchData(id: statusID)
        })
    }
    
    
    convenience init(status: Status) {
        self.init(style: .plain)
        self.status = status
        guard let statusID = status.id else { return }
        fetchData(id: statusID)
    }
    
    func fetchData(id: String) {
        NewsService.getComments(statusID: id) { (comments) in
            self.comments = comments
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCell, for: indexPath) as! CommentCell
//        cell.delegate = self
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = view.frame.width-76
        let text = comments[indexPath.row].text ?? ""
        return estimateFrameForTextWidth(width: width, text: text, fontSize: 18)+44
    }
    
    lazy var menu: CommentInputView = {
        let view = CommentInputView()
        view.commentDelegate = self
        view.commentsController = self
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
    
    
    @objc func handleSend() {
        guard let post = status,
            let text = menu.inputTextField.textView.text,
            text.count > 0 else { return }
        scrollToComment()
        NewsService.postComment(status: post, text: text) { (comment) in
            guard let comment = comment else { return }
            self.comments.insert(comment, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        }
        menu.inputTextField.textView.text = ""
    }
    
    
    func scrollToComment() {
        if comments.count > 1 {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        if notification.name == Notification.Name.UIKeyboardDidHide {
            tableView.contentInset.bottom = 0
        } else {
            tableView.contentInset.bottom = 40
        }
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func scrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(010)) {
            let numberOfRows = self.tableView.numberOfRows(inSection: 0)
            let indexPath = IndexPath(row: numberOfRows-1, section: 0)
            if numberOfRows > 0 {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard CurrentUser.uid == comments[indexPath.row].userId else {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let commentId = comments[indexPath.row].id,
                let post = status else {
                    print("no comment ID")
                    return
            }
//            NewsService.deleteComment(id: commentId, post: post, completion: { (success) in
//                self.comments.remove(at: indexPath.row)
//            })
        }
    }
    
    func handleUserTap(userId: String) {
        let vc = UserController(userId)
    self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handlePhotoTap(_ statusId: String) {}
    
    
}
