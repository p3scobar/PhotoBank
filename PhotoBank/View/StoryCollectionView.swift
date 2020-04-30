//
//  StoryCollectionView.swift
//  PhotoBank
//
//  Created by Hackr on 9/14/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit

protocol StoryDelegate {
    func didSelectStory(_ story: Story)
}

class StoryHeaderView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var stories: [Story] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        view.backgroundColor = .white
        return view
    }()
    
    var storyCell = "storyCell"
    
    var storyDelegate: StoryDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        backgroundColor = Theme.black
        collectionView.register(StoryCell.self, forCellWithReuseIdentifier: storyCell)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: storyCell, for: indexPath) as! StoryCell
        cell.story = stories[indexPath.row]
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let story = stories[indexPath.row]
        storyDelegate?.didSelectStory(story)
    }
    
    
    lazy var line: UIView = {
        let frame = CGRect(x: 0, y: self.frame.height-0.5, width: self.frame.width, height: 0.6)
        let view = UIView(frame: frame)
        view.layer.borderWidth = 0.6
        view.layer.borderColor = Theme.border.cgColor
        return view
    }()
    

    func setupView() {
        addSubview(collectionView)
        addSubview(line)
    }
    
}

