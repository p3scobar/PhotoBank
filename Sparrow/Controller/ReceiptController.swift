//
//  ReceiptController.swift
//  Sparrow
//
//  Created by Hackr on 8/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit

class ReceiptController: UIViewController {
    
    
    var payment: Payment? {
            didSet {
                guard let amount = payment?.amount else { return }
                amountLabel.text = amount.rounded(2)
                let formattedDate = payment!.timestamp?.asString() ?? ""
                self.subtitleLabel.text = formattedDate
            }
    }
    
    func fetchUser() {
        let publicKey = otherUserID()
        UserService.getUserWithPublicKey(publicKey) { (user) in
            guard let user = user else { return }
            self.titleLabel.text = "@\(user.username ?? "")"
            let url = URL(string: user.image ?? "")
            self.profileImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    init(payment: Payment?) {
        self.payment = payment
        super.init(nibName: nil, bundle: nil)
        fetchUser()
    }
    
    func otherUserID() -> String {
        let pk = KeychainHelper.publicKey
        guard let from = payment?.from,
        let to = payment?.to else { return "" }
        return from != pk ? from : to
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(tap)
        
        let tapCard = UITapGestureRecognizer(target: self, action: nil)
        card.addGestureRecognizer(tapCard)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.maximumNumberOfTouches = 1
        card.addGestureRecognizer(pan)
    }
    
    @objc func handleDismiss() {
        animateCardOut()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateCardIn(0.2)
    }
    
    lazy var cardVerticalPosition = card.center.y
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.translation(in: self.view).y
        if touchPoint > -20 {
            self.card.center.y = cardVerticalPosition+touchPoint
        }
        if gesture.state == .ended {
            if touchPoint < 100 {
                resetCardPosition()
            } else {
                handleDismiss()
            }
        }
    }
    
    func resetCardPosition() {
        animateCardIn(0.0)
    }
    
    lazy var card: UIView = {
        let frame = self.view.frame
        let view = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: 420))
        view.layer.cornerRadius = 32
        view.backgroundColor = .white
        return view
    }()
    
    func animateCardIn(_ after: TimeInterval) {
        UIView.animate(withDuration: 0.1, delay: after, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.card.center.y = self.view.bounds.height-self.card.frame.height/2-4
        }, completion: nil)
    }
    
    func animateCardOut() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.card.center.y += self.card.frame.height+4
        }, completion: { (_) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func setupView() {
        view.addSubview(card)
        card.addSubview(tab)
        card.addSubview(profileImageView)
        card.addSubview(amountLabel)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: tab.bottomAnchor, constant: 32).isActive = true
        
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20).isActive = true
        
        amountLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        amountLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor).isActive = true
        amountLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -20).isActive = true
        amountLabel.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        subtitleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20).isActive = true
    }
    
    lazy var tab: UIView = {
        let view = UIView(frame: CGRect(x: self.view.center.x-24, y: 12, width: 48, height: 6))
        view.layer.cornerRadius = 3
        view.backgroundColor = Theme.lightBackground
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.bold(24)
        label.textColor = Theme.gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.semibold(18)
        label.textColor = Theme.lightGray
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = Theme.tint
        label.font = Theme.bold(24)
        label.textColor = .white
        label.layer.cornerRadius = 32
        label.textAlignment = .center
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 50
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Theme.border.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
}
