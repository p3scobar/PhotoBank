//
//  MessagesController.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit
import Firebase
//import OneSignal

class MessagesController: UITableViewController {
    
    private let chatCell = "chatCell"
    var searchController: UISearchController!
    
    var chats: [Chat] = [] {
        didSet {
            reloadSections()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Messages"
        tableView.register(ChatCell.self, forCellReuseIdentifier: chatCell)
        let composeIcon = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
        let compose = UIBarButtonItem(image: composeIcon, style: .done, target: self, action: #selector(handleCompose))
        compose.tintColor = Theme.black
        tableView.separatorInset = UIEdgeInsetsMake(0, 90, 0, 0)
        self.navigationItem.rightBarButtonItem = compose
        view.backgroundColor = Theme.lightBackground
        tableView.backgroundColor = Theme.lightBackground
        tableView.tableFooterView = UIView()
        
        
        self.definesPresentationContext = true
        let vc = SwipeController()
        searchController = UISearchController(searchResultsController: vc)
        searchController.delegate = self
        searchController.searchResultsUpdater = vc
        vc.navController = self.navigationController
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.tintColor = Theme.gray
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        extendedLayoutIncludesOpaqueBars = true
        checkAuthentication()
    }
    
    func checkAuthentication() {
        Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {

            } else {
                self.fetchChats()
                self.promptForNotifications()
            }
        })
    }
    
    
    @objc func handleCompose() {
        let vc = NewMessageController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func fetchChats() {
        ChatService.fetchChats()
        ChatService.chats = { (chats) in
            self.chats = chats
        }
    }
    
    func handleNewChat(chatId: String, toId: String, title: String, image: String) {
        let vc = ChatController(chatId: chatId, toId: toId, title: title, image: image)
        vc.userId = toId
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleNewChannel(channelId: String) {
        let vc = ChatController(channelId: channelId, title: channelId.capitalized, image: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated:true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCell, for: indexPath) as! ChatCell
        cell.chat = chats[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        let vc = ChatController(chat: chat, title: chat.title, image: chat.image)
        vc.hidesBottomBarWhenPushed = true
        vc.chat = chat
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let id = chats[indexPath.row].id
            chats.remove(at: indexPath.row)
            ChatService.deleteChat(chatId: id)
        }
    }
    
    func reloadSections() {
        let indexSet = NSIndexSet(index: 0) as IndexSet
        tableView.reloadSections(indexSet, with: .fade)
    }
    
    func promptForNotifications() {
//        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
//        OneSignal.promptForPushNotifications { (accepted) in
//            guard let notificationKey = status.subscriptionStatus.userId else { return }
//            UserManager.saveNotificationKey(key: notificationKey)
//        }
    }
    
    
}


extension MessagesController: NewMessageDelegate {
    
}

