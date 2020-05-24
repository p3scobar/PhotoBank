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
import SPStorkController
import FirebaseAuth

class TimelineController: UITableViewController, UISearchControllerDelegate, UINavigationBarDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var searchController: UISearchController!
    
    private let statusCell = "newsCell"
    private let adCell = "adCell"
    private let refresh = UIRefreshControl()
    private var spinner: UIActivityIndicatorView!
    
    var feed = [Any]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            }
        }
    }
    
    
    lazy var header: StoryHeaderView = {
        let view = StoryHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 84))
        view.storyDelegate = self
        return view
    }()
    
    
    override func loadView() {
        super.loadView()
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    
    var tabBarIndex: Int = 0
    var scrollEnabled: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

//        tableView.tableHeaderView = header
        tableView.backgroundColor = Theme.black

        tableView.prefetchDataSource = self
        tableView.register(StatusCell.self, forCellReuseIdentifier: statusCell)
        tableView.register(AdCell.self, forCellReuseIdentifier: adCell)
        tableView.tableFooterView = UIView()

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        navigationItem.title = "Today"
        navigationController?.navigationBar.prefersLargeTitles = true
        
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

        let plusIcon = UIImage(named: "photo")?.withRenderingMode(.alwaysTemplate)
        let plus = UIBarButtonItem(image: plusIcon, style: .done, target: self, action: #selector(presentImagePicker))
        plus.tintColor = .white
        self.navigationItem.rightBarButtonItem = plus
        
        let userIcon = UIImage(named: "user")?.withRenderingMode(.alwaysTemplate)
//
//        pushAccountController
        let user = UIBarButtonItem(image: userIcon, style: .done, target: self, action: #selector(pushAccountController))
        user.tintColor = .white
        self.navigationItem.leftBarButtonItem = user
        
        spinner = UIActivityIndicatorView(style: .white)
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
        tableView.tableFooterView = spinner
        
        checkAuthentication()
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthentication), name: Notification.Name(rawValue: "login"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newPostUploaded(notification:)), name: Notification.Name("newPost"), object: nil)
        
        tableView.refreshControl = refresh
        refresh.tintColor = Theme.lightGray
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        scrollEnabled = true
        
        fetchData()
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gesture:)))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)
        
    }
    

    
    @objc func handleSwipe(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    
    @objc func pushAccountController() {
        let vc = AccountController(style: .grouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func paymentConfirmationView(_ payment: Payment) {
        definesPresentationContext = true
        let vc = ReceiptController(payment: payment)
        vc.payment = payment
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }
    
    @objc func handleActivity() {
        let vc = ActivityController(style: .grouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollEnabled = false
        refresh.endRefreshing()
    }
    
    func scrollToTop() {
        if tabBarIndex == 0 && scrollEnabled && feed.count > 0 {
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
    
    /// Add loading table foot er view
    
    @objc func checkAuthentication() {
        guard Auth.auth().currentUser != nil else { 
            presentHomeController()
            return
        }
        fetchData()
        NewsService.fetchLikes { (_) in }
    }
    
    @objc func newPostUploaded(notification: Notification) {
        scrollToTop()
        guard let post = notification.userInfo?["photo"] as? Status else { return }
        let id = post.id ?? ""
        self.feed.insert(post, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    func presentHomeController() {
        let vc = HomeController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.tabBarController?.present(nav, animated: false, completion: nil)
    }

    @objc func fetchData() {
        allPostsLoaded = false
        NewsService.getTimeline(cursor: 0) { posts, ads, stories  in
            self.feed = posts
            self.feed.append(contentsOf: ads)
            self.header.stories = stories
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let _ = feed[indexPath.row] as? Ad {
            let cell = tableView.dequeueReusableCell(withIdentifier: adCell, for: indexPath) as! AdCell
            cell.delegate = self
            cell.indexPath = indexPath
            cell.ad = feed[indexPath.row] as? Ad
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: statusCell, for: indexPath) as! StatusCell
            cell.delegate = self
            cell.indexPath = indexPath
            cell.status = feed[indexPath.row] as? Status
            return cell
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        checkIfAd(indexPath)
        checkIfScrolledToBottom(indexPath)
    }
    
    func checkIfAd(_ indexPath: IndexPath) {
        // replace modulo with bool on Status object that indicates if ad.
        if indexPath.row % 8 == 0 {
            let ad = feed[indexPath.row] as? Ad
            guard let id = ad?.id else {
                print("NO AD ID")
                return
            }
            
        }
    }

    let fetcher = SDWebImagePrefetcher.shared()
    
   
    
    func checkIfScrolledToBottom(_ indexPath: IndexPath) {
        print(indexPath.row)
        guard indexPath.row == feed.count-2,
            indexPath.row > 2,
            feed.count > 0 else { return }

//        if indexPath.row % 8 == 0 {
            loadMorePosts()
//        }
    }
    
    var allPostsLoaded: Bool = false
    var loadingPosts: Bool = false
    
    func loadMorePosts() {
        guard allPostsLoaded == false, loadingPosts == false else { return }
        loadingPosts = true
        self.spinner.startAnimating()
        NewsService.getTimeline(cursor: feed.count+1) { [weak self] posts, ads, stories in
            self?.spinner.stopAnimating()
            self?.loadingPosts = false
            if posts.count <= 0 {
//                self?.allPostsLoaded = true
                return
            }
            self?.feed.append(contentsOf: posts)
            self?.feed.append(contentsOf: ads)
        }
    }
    
    func stopBottomSpinner() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight(indexPath)
    }
    
    func cellHeight(_ indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if let status = feed[indexPath.row] as? Status {
            height = status.cellHeight(view.frame.width)
        } else if let ad = feed[indexPath.row] as? Ad {
            height = ad.cellHeight(view.frame.width)
        }
        return height
    }
    
    func handleLike(post: Status) {
        NewsService.likePost(post: post)
    }
    
    @objc func handlePayTap() {
        let vc = ActivityController(style: .grouped)
            //WalletController(style: .grouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleComment(status: Status) {
        let vc = CommentsController(status: status)
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight(indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let ad = feed[indexPath.row] as? Ad {
//            pushSafariVC(ad)
        } else if let status = feed[indexPath.row] as? Status {
//            pushStatus(status)
        }
    }
    
    
    func pushStatus(_ status: Status) {
        let vc = StatusController(style: .plain)
        vc.status = status
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func pushSafariVC(_ ad: Ad) {
        guard var urlString = ad.url, let url = URL(string: urlString) else { return }
        if !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true, completion: nil)
    }
    
    
}


extension TimelineController: StatusCellDelegate {
    
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
        //presentPaymentController(publicKey, username: username)
        handleSuperLike(pk: publicKey, username: username)
    }
    
    private func handleSuperLike(pk: String, username: String) {
        WalletService.sendPayment(token: counterAsset, toAccountID: pk, amount: superlikeAmount) { (_) in
        }
    }
    
    func presentPaymentController() {
        let vc = PayController()
//        vc.publicKey = publicKey
//        vc.username = username
        let nav = UINavigationController(rootViewController: vc)
        
        let transitionDelegate = SPStorkTransitioningDelegate()
        nav.transitioningDelegate = transitionDelegate
        nav.modalPresentationCapturesStatusBarAppearance = true
        nav.modalPresentationStyle = .custom
        nav.modalTransitionStyle = .crossDissolve
        presentAsStork(nav, height: UIScreen.main.bounds.height*0.8)
//        self.present(nav, animated: true, completion: nil)
        
    }
    
    func presentReceiptController() {
        definesPresentationContext = true
        let vc = ReceiptController(payment: nil)
//        vc.payment = payment
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.present(vc, animated: true, completion: nil)
    }
    
    
}

extension UIViewController {
    
    func presentPaymentController(publicKey: String) {
        let vc = PayController()
        vc.publicKey = publicKey
        let nav = UINavigationController(rootViewController: vc)
        
        let transitionDelegate = SPStorkTransitioningDelegate()
        nav.transitioningDelegate = transitionDelegate
        nav.modalPresentationCapturesStatusBarAppearance = true
        nav.modalPresentationStyle = .custom
        nav.modalTransitionStyle = .crossDissolve
        presentAsStork(nav, height: UIScreen.main.bounds.height*0.8)
        
    }
    
    
    
    
}


extension TimelineController: UITableViewDataSourcePrefetching {
  
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        var links: [URL] = []
        feed.forEach { (item) in
            if let status = item as? Status {
                let urlString = status.image ?? ""
                guard let url = URL(string: urlString) else { return }
                links.append(url)
            } else if let ad = item as? Ad {
                let urlString = ad.image ?? ""
                guard let url = URL(string: urlString) else { return }
                links.append(url)
            }
        }
        
        //        let images = links.compactMap { URL(string: $0.image ?? "") }
        fetcher.prefetchURLs(links)
    }
    
    func presentStory(_ story: Story) {
        let vc = AVController(story)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .crossDissolve
        self.tabBarController?.present(nav, animated: true, completion: nil)
    }
    
}




extension TimelineController: StoryDelegate {
    
    func didSelectStory(_ story: Story) {
//        presentStory(story)
    }
    
    
}
