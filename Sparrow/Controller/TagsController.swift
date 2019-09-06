//
//  TagsController.swift
//  Sparrow
//
//  Created by Hackr on 3/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class TagsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate {
    
    private let photoCell = "photoCell"
    var navController: UINavigationController?
    
    var query: String? {
        didSet {
            guard let query = query else { return }
            fetchData(query)
            self.navigationItem.title = "#\(query)"
        }
    }
    
    var timeline = [Status]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tabBarIndex: Int = 1
    
    var scrollEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView?.prefetchDataSource = self
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = .white
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: photoCell)
    }
    
    
    @objc func fetchData(_ query: String) {
        allPostsLoaded = false

        NewsService.discover(cursor: 0, query: query) { [weak self] posts in
            self?.timeline = posts
        }
    }
    
    func scrollToTop() {
        if tabBarIndex == 1 && scrollEnabled && timeline.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
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
        if timeline.count > indexPath.row {
            cell.status = timeline[indexPath.row]
        }
        print("INDEX PATH: \(indexPath.row)")
        checkIfScrolledToBottom(indexPath)
        return cell
    }
    
    func checkIfScrolledToBottom(_ indexPath: IndexPath) {
        guard Model.shared.uid != "" else { return }
        if indexPath.row == timeline.count-9 {
            print("BOTTOM OF TABLE VIEW")
            loadMorePosts()
        }
    }
    
    var allPostsLoaded: Bool = false
    
    func loadMorePosts() {
        guard allPostsLoaded == false else { return }
        NewsService.discover(cursor: timeline.count+1, query: nil) { [weak self] posts in
            guard posts.count > 0 else {
                print("NO MORE POSTS TO LOAD")
                self?.allPostsLoaded = true
                return
            }
            self?.timeline.append(contentsOf: posts)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width/3
        return CGSize(width: width*0.99, height: width*0.99)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = StatusController(style: .plain)
        vc.status = timeline[indexPath.row]
        navController?.pushViewController(vc, animated: true)
    }
    
    private let prefetcher = SDWebImagePrefetcher.shared()
    
}


extension TagsController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = timeline.compactMap { URL(string: $0.thumbnail ?? "") }
        prefetcher.maxConcurrentDownloads = 30
        prefetcher.prefetchURLs(urls)
    }
}


