//
//  DiscoverController.swift
//  Sparrow
//
//  Created by Hackr on 8/1/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import SDWebImage

class DiscoverController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate {
    
    private var searchController: UISearchController!
    private let photoCell = "photoCell"
    
    private let refresh = UIRefreshControl()
    
    var user: User?
    
    var timeline = [Status]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.refresh.endRefreshing()
            }
        }
    }
    
    var tabBarIndex: Int = 1
    
    var scrollEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.prefetchDataSource = self
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = Theme.black
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: photoCell)
        
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
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Discover"
        fetchData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView?.refreshControl = refresh
        refresh.tintColor = .white
        refresh.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        scrollEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scrollEnabled = false
        self.refresh.endRefreshing()
    }
    
    @objc func fetchData() {
        allPostsLoaded = false
        NewsService.discover(cursor: 0, query: nil) { [weak self] posts in
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
        //cell.mainImageView.image = nil
        if timeline.count > indexPath.row {
        cell.status = timeline[indexPath.row]   
        }
        print("INDEX PATH: \(indexPath.row)")
        checkIfScrolledToBottom(indexPath)
        return cell
    }
    
    func checkIfScrolledToBottom(_ indexPath: IndexPath) {
        if indexPath.row == timeline.count-9 {
            print("BOTTOM OF TABLE VIEW")
            loadMorePosts()
        }
    }
    
    var allPostsLoaded: Bool = false
    
    func loadMorePosts() {
//        guard allPostsLoaded == false else { return }
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private let prefetcher = SDWebImagePrefetcher.shared()
    
}


extension DiscoverController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = timeline.compactMap { URL(string: $0.thumbnail ?? "") }
        prefetcher.maxConcurrentDownloads = 30
        prefetcher.prefetchURLs(urls)
    }
}

