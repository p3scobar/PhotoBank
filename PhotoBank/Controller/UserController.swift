//
//  ViewController.swift
//  Sparrow
//
//  Created by Hackr on 7/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import Firebase

class UserController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let photoCell = "photoCell"
    private let header = "header"
    
    var status: String? {
        didSet {
            print(status)
        }
    }
    
    var following: Bool = false {
        didSet {
            self.headerView.following = following
        }
    }
    
    var blocked: Bool = false {
        didSet {

        }
    }
    
    private let refresh = UIRefreshControl()
    
    var headerView: UserHeader = UserHeader()
    
    var user: User? {
        didSet {
            headerView.user = user
            collectionView?.reloadData()
        }
    }
    
    
    func fetchUser(_ id: String?) {
        guard let id = id, id != "" else {
            print(" NO USER ID")
            return
        }
        UserService.getUser(id) { (user) in
            self.user = user
        }
        UserService.following(userId: id) { (following, status) in
            self.following = following
            self.status = status
        }
    }
    
    var timeline = [Status]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.refresh.endRefreshing()
            }
        }
    }
    
    
    convenience init(_ user: User) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        self.user = user
        
        guard let id = user.id else { return }
        getData(id)

    }
    
    convenience init(_ id: String) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        fetchUser(id)
        getData(id)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView.setupButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = Theme.lightBackground
        collectionView?.register(UserHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: photoCell)
        navigationItem.title = "User"
        collectionView?.refreshControl = refresh
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)

    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 300
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 300
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl?) {
        guard let uid = user?.id else { return }
        getData(uid)
    }
    
    @objc func getData(_ uid: String) {
        print("UID: \(uid)")
        NewsService.fetchPosts(forUser: uid) { [weak self] (feed) in
            self?.timeline = feed
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeline.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCell, for: indexPath) as! PhotoCell
        cell.mainImageView.image = nil
        cell.status = timeline[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width/3
        return CGSize(width: width*0.99, height: width*0.99)
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = StatusController(style: .plain)
        vc.status = timeline[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
   
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.header, for: indexPath) as! UserHeader
        headerView.delegate = self
        headerView.user = user
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 240
        if let bio = user?.bio {
            let bioHeight = estimateFrameForTextWidth(width: self.view.frame.width-32, text: bio, fontSize: 19)+20
            height += bioHeight
        }
        return CGSize(width: self.view.frame.width, height: height)
    }
    

    func handleMore() {
        let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let done = UIAlertAction(title: "Done", style: .cancel) { (done) in }
        let block = UIAlertAction(title: "Block", style: .destructive) { (block) in
            guard let id = self.user?.id else { return }
            UserService.block(userId: id, block: self.blocked, completion: { (isBlocked) in
                self.blocked = isBlocked
            })
        }
        action.addAction(block)
        action.addAction(done)
        present(action, animated: true, completion: nil)
    }
    

    func presentRecoveryController() {
        let vc = RecoveryController()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    func presentPassphraseController() {
        let vc = PassphraseController()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    
}














extension UserController: UserHeaderDelegate {
    
    
    func handleFollow() {
        guard let id = user?.id else { return }
        UserService.follow(userId: id, follow: !following) { (following) in
            self.following = following
        }
    }

    
    func handleURLTap() {
        guard let urlString = user?.url,
            let url = URL(string: urlString) else { return }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true, completion: nil)
    }
    
    
    func handleMessage() {
        guard let fromId = Auth.auth().currentUser?.uid,
        let toId = user?.id else { return }
        let chatId = generateChatId(ids: [fromId,toId])
        let title = user?.name ?? ""
        let image = user?.image ?? ""
        let vc = ChatController(chatId: chatId, toId: toId, title: title, image: image)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
    func handlePay() {
        guard let pk = user?.publicKey else {
            presentPassphraseController()
            return
        }
        guard KeychainHelper.privateSeed != "" else {
            presentRecoveryController()
            return
        }
        let vc = AmountController(publicKey: pk)
        vc.username = user?.username
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    
}



extension UserController {
    
    @objc func handlePhotoTap() {
        guard let status = status, let url = URL(string: status) else { return }
        let vc = AVController(url)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalTransitionStyle = .crossDissolve
        self.tabBarController?.present(nav, animated: true, completion: nil)
    }
    
}
