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


class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var delegate: NewMessageDelegate?
//    var messagesController: MessagesController?
    
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
        self.definesPresentationContext = true
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Theme.background
        view.backgroundColor = Theme.background
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
 
    }
    
    func fetchUsers(_ query: String?) {
        let query = query ?? ""
        
        UserService.fetchUsers(query: query) { (users) in
            let filteredUsers = users.filter { $0.id != CurrentUser.uid }
            self.users = filteredUsers
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        createNewChat(indexPath)
    }
    
    fileprivate func createNewChat(_ indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        let uid = CurrentUser.uid
        let toId = user.id ?? ""
        let ids = [uid, toId]
        let chatId = generateChatId(ids: ids)
        let image = user.image ?? ""
        let name = user.name ?? ""
        delegate?.handleNewChat(chatId: chatId, toId: toId, title: name, image: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func pushGroupChatController(id: String) {
        self.dismiss(animated: true) {
            self.delegate?.handleNewChannel(channelId: id)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell.user = self.users[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
}


extension NewMessageController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        query = text
    }
}


extension NewMessageController: UISearchControllerDelegate {
    
}
