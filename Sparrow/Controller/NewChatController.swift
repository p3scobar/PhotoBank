//
//  NewChatController.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import Firebase

protocol NewMessageDelegate {
    func handleNewChat(chatId: String, toId: String, title: String, image: String)
    func handleNewChannel(channelId: String)
}


class NewMessageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    
    var delegate: NewMessageDelegate?
    var messagesController: MessagesController?
    
    var query: String? {
        didSet {
            fetchUsers(query)
        }
    }
    
    var users = [User]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var channels = [Chat]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Chat"
        tableView.frame = view.frame
        view.addSubview(tableView)
        self.definesPresentationContext = true
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorInset = UIEdgeInsetsMake(0, 88, 0, 0)
//        tableView.separatorColor = Theme.borderColor
//        tableView.backgroundColor = Theme.darkBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.prefersLargeTitles = true
        fetchUsers("")
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func fetchChannels() {
        //        ChatService.fetchChannels { (channels) in
        //            self.channels = channels
        //        }
    }
    
    func fetchUsers(_ query: String?) {
//        UserManager.fetchFavorites { (favs) in
//            var favorites = favs ?? []
//            favorites.sort{ $0.username ?? "" < $1.username ?? "" }
//            self.users = favorites
//        }
        let query = query ?? ""
        UserService.fetchUsers(query: query) { (users) in
            self.users = users
        }
    }
    
    
    func reloadTable() {
        users.removeAll()
        if (tableView.numberOfSections > 0 && users.count > 0) {
            let indexSet = NSIndexSet(index: 0) as IndexSet
            tableView.reloadSections(indexSet, with: .none)
        } else {
            tableView.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            pushGroupChatController(id: "general")
        } else {
            createNewChat(indexPath)
        }
    }
    
    fileprivate func createNewChat(_ indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        let uid = Model.shared.uid
        guard let toId = user.id else { return }
        let ids = [uid, toId]
        let chatId = generateChatId(ids: ids)
        let image = user.image ?? ""
        self.dismiss(animated: true) {
            self.delegate?.handleNewChat(chatId: chatId, toId: toId, title: user.name!, image: image)
        }
    }
    
    fileprivate func pushGroupChatController(id: String) {
        self.dismiss(animated: true) {
            self.delegate?.handleNewChannel(channelId: id)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return users.count
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell.textLabel?.text = "General"
            cell.textLabel?.font = Theme.semibold(18)
            cell.textLabel?.textColor = .white
            let groupIcon = UIImage(named: "general")?.withRenderingMode(.alwaysTemplate)
            cell.profileImage.image = groupIcon
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell.user = self.users[indexPath.row]
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
}


