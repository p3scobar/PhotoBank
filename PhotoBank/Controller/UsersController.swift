//
//  UsersController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import UIKit
import Firebase

class UsersController: UITableViewController {
    
    let userCell = "userCellSmall"
    let statusCell = "statusCell"
    let standardCell = "standardCell"
    var navController: UINavigationController?
    var searchController: UISearchController!
    
    var users: [User]? {
        didSet {
            reloadTable()
        }
    }
    
    var query: String = "a" {
        didSet {
            fetchData(query: query)
        }
    }
    
    
    func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.lightBackground
        tableView.register(UserCellSmall.self, forCellReuseIdentifier: userCell)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 72, 0, 0)
    }
    
    
    @objc func fetchData(query: String) {
        guard query != "" else { return }
        UserService.fetchUsers(query: query) { (users) in
            self.users?.removeAll()
            self.users = users
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        query = text.lowercased()
        
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! UserCellSmall
        let user = users?[indexPath.row]
        cell.user = user
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = self.users?[indexPath.row] else { return }
        let vc = UserController(user)
        vc.user = user
        self.navController?.pushViewController(vc, animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension UsersController: UISearchResultsUpdating {
    
}


extension UsersController: UISearchControllerDelegate {
    
}
