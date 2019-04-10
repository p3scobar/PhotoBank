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

class UserController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserHeaderDelegate {
    
    private let photoCell = "photoCell"
    private let header = "header"
    
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
    
    var headerView: UserHeader!
    
    var user: User? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    // delete user ID.. Just using for testing
    var userId: String?
    
    var timeline = [Status]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.refresh.endRefreshing()
            }
        }
    }
    
    convenience init(_ username: String) {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        UserService.fetchUsers(username: username) { (users) in
            guard let user = users.first else { return }
            self.userId = user.id
            self.user = user
            self.fetchData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = Theme.lightBackground
        collectionView?.register(UserHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: header)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: photoCell)
        navigationItem.title = "User"
        collectionView?.refreshControl = refresh
        refresh.tintColor = .black
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)

        fetchData()
    }
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 300
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 300
    }
    
    
    @objc func fetchData() {
        guard let uuid = userId else { return }
        NewsService.fetchPosts(forUser: uuid) { (feed) in
            self.timeline = feed
        }
        UserService.fetchUser(uuid: uuid) { (user, following)  in
            self.user = user
            self.following = following
            self.headerView.user = user
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
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.header, for: indexPath) as? UserHeader
        headerView.delegate = self
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 280
        if let bio = user?.bio {
            let bioHeight = estimateFrameForTextWidth(width: self.view.frame.width-32, text: bio, fontSize: 18)
            height += bioHeight
        }
        return CGSize(width: self.view.frame.width, height: height)
    }
    
    
    func handleFollow() {
        guard let id = userId else { return }
        UserService.follow(userId: id, follow: !following) { (following) in
            self.following = following
        }
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
    

    
    func handlePay() {
        guard let pk = user?.publicKey else { return }
        guard KeychainHelper.privateSeed != "" else {
            presentRecoveryController()
            return
        }
        let vc = AmountController(publicKey: pk)
        vc.username = user?.username
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    func presentRecoveryController() {
        let vc = RecoveryController()
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    
    
    func handleURLTap() {
        guard let urlString = user?.url,
            let url = URL(string: urlString) else { return }
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true, completion: nil)
    }
    
}
