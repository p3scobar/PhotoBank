//
//  FeedController.swift
//  Sparrow
//
//  Created by Hackr on 7/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import SafariServices
import CoreData
import SDWebImage
import Pulley


class TimelineController: UITableViewController, UISearchControllerDelegate, UINavigationBarDelegate, StatusCellDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSourcePrefetching {
    
    
    private let statusCell = "newsCell"
    private let refresh = UIRefreshControl()
    private var spinner: UIActivityIndicatorView!
    
    var timeline = [Status]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
    }
    
    
    var tabBarIndex: Int = 0
    var scrollEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        tableView.register(StatusCell.self, forCellReuseIdentifier: statusCell)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.allowsSelection = false
        navigationItem.title = "Today"
        navigationController?.navigationBar.prefersLargeTitles = true

        let plusIcon = UIImage(named: "photo")?.withRenderingMode(.alwaysTemplate)
        let plus = UIBarButtonItem(image: plusIcon, style: .done, target: self, action: #selector(presentImagePicker))
        plus.tintColor = Theme.charcoal
        self.navigationItem.rightBarButtonItem = plus
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
        tableView.tableFooterView = spinner
        
        checkAuthentication()
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthentication), name: Notification.Name(rawValue: "login"), object: nil)
    }
    
    @objc func handleActivity() {
        let vc = ActivityController(style: .grouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.refreshControl = refresh
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        scrollEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollEnabled = false
        refresh.endRefreshing()
    }
    
    func scrollToTop() {
        if tabBarIndex == 0 && scrollEnabled && timeline.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    
    var picker: UIImagePickerController?
    
    @objc func presentImagePicker() {
        picker = UIImagePickerController()
        picker?.delegate = self
        self.present(picker!, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedImage = originalImage as? UIImage
        }
        let vc = ComposeController(image: selectedImage)
        picker.pushViewController(vc, animated: true)
    }
    
    
    @objc func checkAuthentication() {
        guard Model.shared.uuid != "" else {
            presentHomeController()
            return
        }
        fetchData()
        NewsService.fetchLikes { (_) in }
        NotificationCenter.default.addObserver(self, selector: #selector(newPostUploaded(notification:)), name: Notification.Name("newPost"), object: nil)
    }
    
    @objc func newPostUploaded(notification: Notification) {
        scrollToTop()
        guard let photo = notification.userInfo?["photo"] as? Status else { return }
        self.timeline.insert(photo, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    func presentHomeController() {
        let vc = HomeController()
        let nav = UINavigationController(rootViewController: vc)
        self.tabBarController?.present(nav, animated: false, completion: nil)
    }

    @objc func fetchData() {
        allPostsLoaded = false
        NewsService.fetchTimeline(cursor: 0) { (feed) in
            self.timeline = feed
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeline.count
    }
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: statusCell, for: indexPath) as! StatusCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.status = timeline[indexPath.row]
        checkIfScrolledToBottom(indexPath)
        return cell
    }

    let fetcher = SDWebImagePrefetcher.shared()
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = timeline.compactMap { URL(string: $0.image ?? "") }
        fetcher.prefetchURLs(urls)
    }
    
    func checkIfScrolledToBottom(_ indexPath: IndexPath) {
        guard Model.shared.uuid != "",
            indexPath.row == timeline.count-2,
            indexPath.row > 2,
            timeline.count > 0 else { return }
        loadMorePosts()
    }
    
    var allPostsLoaded: Bool = false
    var loadingPosts: Bool = false
    
    func loadMorePosts() {
        guard allPostsLoaded == false, loadingPosts == false else { return }
        loadingPosts = true
        self.spinner.startAnimating()
        NewsService.fetchTimeline(cursor: timeline.count+1) { [weak self] feed in
            self?.spinner.stopAnimating()
            self?.loadingPosts = false
            guard feed.count > 0 else {
                self?.allPostsLoaded = true
                return
            }
            self?.timeline.append(contentsOf: feed)
        }
    }
    
    func stopBottomSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 540
        if let text = timeline[indexPath.row].text {
            let textHeight = estimateFrameForText(text: text, fontSize: 18).height
            height += textHeight+20
        }
        return height
    }
    
    func handleLike(post: Status) {
        NewsService.likePost(post: post)
    }
    
    func handlePayTap() {
        let vc = AmountController(publicKey: nil)
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func handleComment(status: Status) {
        let vc = CommentsController(status: status)
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func handleUserTap(userId: String) {
        let layout = UICollectionViewFlowLayout()
        let user = UserController(collectionViewLayout: layout)
        user.userId = userId
        self.navigationController?.pushViewController(user, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 540
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = StatusController(style: .plain)
//        vc.status = timeline[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
}

