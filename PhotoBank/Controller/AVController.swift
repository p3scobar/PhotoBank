//
//  AVController.swift
//  PhotoBank
//
//  Created by Hackr on 9/13/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class AVController: UIViewController {
    
    var stories: [Story] = []
    
    init(_ stories: [Story]) {
        self.stories = stories
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ story: Story) {
        self.stories = [story]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleCancel))
        self.navigationController?.navigationBar.tintColor = .white
        
        setupPlayer()
    }
    
    func setupPlayer() {
        
        
//        guard let urlString = story.url,
//            let url = URL(string: urlString) else { return }
//        let player = AVPlayer(url: url)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.view.bounds
//        playerLayer.videoGravity = .resizeAspectFill
//        self.view.layer.addSublayer(playerLayer)
//        player.play()
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
