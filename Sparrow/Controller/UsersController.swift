//
//  UsersController.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import UIKit

class UsersController: UITableViewController {
    
//    UISearchResultsUpdating, UISearchControllerDelegate
    
    
    var query: String? {
        didSet {
            fetchData(query!)
        }
    }
    
    let userCell = "userCell"
    
    var navController: UINavigationController?
//    var searchController: UISearchController!
    
    var users: [User]? {
        didSet {
            reloadTable()
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
        self.navigationItem.title = "Users"
        tableView.register(UserCell.self, forCellReuseIdentifier: userCell)
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 80, 0, 0)
        
    }
    
    
    @objc func fetchData(_ query: String) {
//        guard let query = searchController.searchBar.text, query.count > 2 else { return }
        UserService.fetchUsers(query: query.lowercased()) { (users) in
            self.users = users
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(fetchData), with: nil, afterDelay: 1.0)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as! UserCell
        let user = users?[indexPath.row]
        cell.user = user
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = self.users?[indexPath.row] else { return }
        let vc = UserController(user)
        self.navController?.pushViewController(vc, animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
