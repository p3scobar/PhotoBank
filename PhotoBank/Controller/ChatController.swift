//
//  ChatController.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//


import UIKit
import Firebase
//import Kingfisher
import AVFoundation
import SafariServices

class ChatController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate, UIBarPositioningDelegate {
    
    private let textCell = "text"
    private let moneyCell = "money"
    
    var generator: UIImpactFeedbackGenerator?
    
//    convenience init(channelId: String, title: String, image: UIImage?) {
//        self.init()
////        self.navigationItem.title = title
////        ChatService.fetchChat(chatId: channelId) { (chat) in
////            if chat != nil {
////                self.chat = chat
//////
////                chat?.userIds.append(Model.shared.userId)
////            } else {
////                let groupChat = Chat(userIds: [Model.shared.userId])
////                groupChat.isGroup = true
////                self.chat = groupChat
////            }
////        }
//    }
    
    convenience init(chatId: String, toId: String, title: String?, image: String?) {
        self.init()
        self.userId = toId
        self.navigationItem.title = title ?? ""
        if image != nil {
            let url = URL(string: image!)
            avatar.sd_setImage(with: url, completed: nil)
        }
        ChatService.fetchChat(chatId: chatId) { (fetchedChat) in
            if fetchedChat != nil {
                self.chat = fetchedChat
            } else {
                guard let fromId = Auth.auth().currentUser?.uid else { return }
                let newChat = Chat(userIds: [fromId, toId])
                self.chat = newChat
            }
        }
    }
    
    convenience init(chat: Chat, title: String?, image: String?) {
        self.init()
        self.chat = chat
        guard let title = title, let image = image else { return }
        navigationItem.title = title
        let url = URL(string: image)
        avatar.sd_setImage(with: url, completed: nil)
        userId = chat.partnerId
    }
    
    
    var chat: Chat? {
        didSet {
            guard let chatId = chat?.id else { return }
            observeMessages(chatID: chatId)
        }
    }
    
    var userId: String?
    
    var messages = [Message]() {
        didSet {
            messages.sort(by: { $0.timestamp < $1.timestamp })
            chatView.reloadData()
        }
    }
    
    lazy var chatView: UITableView = {
        let frame = UIScreen.main.bounds
        let view = UITableView(frame: frame, style: .plain)
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        view.layoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bounces = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(chatView)
        chatView.delegate = self
        chatView.dataSource = self
        chatView.allowsSelection = false
        chatView.alwaysBounceVertical = true
        extendedLayoutIncludesOpaqueBars = true
        hidesBottomBarWhenPushed = false
        
        chatView.register(MessageCell.self, forCellReuseIdentifier: textCell)
        chatView.register(MessageMoneyCell.self, forCellReuseIdentifier: moneyCell)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatar)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap))
        avatar.addGestureRecognizer(tap)
        
        avatar.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        chatView.keyboardDismissMode = .interactive
        menu.inputMoney.inputView = cashKeyboard
        cashKeyboard.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        cashKeyboard.delegate = self
        menu.becomeFirstResponder()
    }
    
    let cashKeyboard: CashKeyboard = {
        let keyboard = CashKeyboard()
//        keyboard.translatesAutoresizingMasrkIntoConstraints = false
        return keyboard
    }()
    
    
    deinit {
        removeObserver()
    }
    
    
    let avatar: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = Theme.lightBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    @objc func handleAvatarTap() {
        guard let userId = userId, chat?.isGroup == false else { return }
        let vc = UserController(userId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func handleUserTap(userId: String) {
//        let vc = UserController(<#T##username: String##String#>)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //    func handlePlusTap() {
    //        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    //        let image = UIAlertAction(title: "Alert", style: .default, handler: nil)
    //        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    //        alert.addAction(image)
    //        alert.addAction(cancel)
    //        self.present(alert, animated: true, completion: nil)
    //    }
    
    
    func insertMessage(message: Message) {
        chatView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = message.cellForMessageType(tableView: tableView, indexPath: indexPath) as! MessageCell
        cell.delegate = self
        cell.message = message
        return cell
    }
    
    @objc func coinButtonTap() {
        menu.inputMoney.becomeFirstResponder()
    }
    
    var menuBottomAnchor: NSLayoutConstraint?
    
    lazy var menu: ChatInputView = {
        let view = ChatInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        view.chatDelegate = self
        return view
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToBottom(animated: true)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        inputAccessoryView.reloadInputViews()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom(animated: false)
        menu.inputTextField.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //        menu.inputTextField.textView.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func observeMessages(chatID: String) {
        ChatService.observeMessages(chatId: chatID) { (message) in
            DispatchQueue.main.async {
                guard let msg = message else { return }
                self.messages.append(msg)
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    
    func removeObserver() {
        guard let id = chat?.id else { return }
        ChatService.removeObserverForChat(chatId: id)
    }
    
    
    override var inputAccessoryView: UIView! {
        get {
            return menu
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    static var AllowUserInteraction: UIViewKeyframeAnimationOptions {
        get {
            return UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.allowUserInteraction.rawValue)
        }
    }
    
    
    @objc func handleSend(_ text: String) {
        guard let text = menu.inputTextField.textView.text, text.count > 0 else { return }
        guard let chat = chat else {
            print("NO CHAT TO FETCH")
            return }
        let data = ["text": text, "type": "text"]
        ChatService.sendMessage(chat: chat, properties: data) { _ in
            self.scrollToBottom(animated: true)
        }
        menu.inputTextField.textView.text = ""
//        SoundKit.playSound(type: .send)
        
    }
    
    
    func scrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(010)) {
            let numberOfSections = self.chatView.numberOfSections
            let numberOfRows = self.chatView.numberOfRows(inSection: numberOfSections-1)
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.chatView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            image = editedImage as? UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            image = originalImage as? UIImage
        }
        //        if let selectedImage = image {
        //            guard let toId = self.user?.id else { return }
        //            Model.uploadToFirebaseStorageUsingImage(chatId: chatId!, toId: toId, image: selectedImage)
        //        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if notification.name == Notification.Name.UIKeyboardDidHide {
            animateContentInset(inset: 20)
        } else {
            animateContentInset(inset: keyboardSize.height)
        }
        chatView.scrollIndicatorInsets = chatView.contentInset
    }
    
    
    
    func animateContentInset(inset: CGFloat) {
        let offset: CGPoint = chatView.contentOffset
        UIView.animate(withDuration: 1.0) {
            self.chatView.contentInset.bottom = inset
            self.chatView.contentOffset = offset
            self.scrollToBottom(animated: true)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        chatView.invalidateIntrinsicContentSize()
    }
    
    
    func popControllerOffStack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return messages[indexPath.row].height(chat?.isGroup ?? false)
    }
    
    
    func cellDidTapLink(_ url: String) {
        let url = URL(string: url)
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = true
        config.entersReaderIfAvailable = true
        let svc = SFSafariViewController(url: url!, configuration: config)
        svc.delegate = self
        present(svc, animated: true, completion: nil)
    }
    
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func inputTextPanelDidChangeHeight(_ height: CGFloat) {
        print("Height needs to be updated on Chat Log Controller")
    }
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let date = messages[indexPath.row].timestamp
        let timestamp = formatter.string(from: date)
        let action = UITableViewRowAction(style: .normal, title: timestamp) { (action, indexPath) in
        }
        action.backgroundColor = Theme.lightBackground
        
        return [action]
    }
    
    func handleLongPress(_ message: Message) {
        presentAlertController(message)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func presentAlertController(_ message: Message) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewProfile = UIAlertAction(title: "Copy", style: .default) { (tap) in
            UIPasteboard.general.string = message.text ?? ""
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(viewProfile)
        alert.addAction(cancel)
        if let rootVC =
            UIApplication.shared.windows.last?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
    
}


extension ChatController: ChatMenuDelegate {
    
}

extension ChatController: MessageCellDelegate {

    
}


extension ChatController: CashKeyboarDelegate {
    
    func keyWasTapped(character: String) {
        print(character)
    }
    
    func sendMoney(amount: Decimal) {
        let to = chat?.users.filter { $0.id != CurrentUser.uid }.first
        guard let publicKey = to?.publicKey else {
            print("NO PUBLIC KEY FOR OTHER USER")
            return
        }
        let assetCode = reserveAsset.assetCode ?? ""
        let status = "pending"
        guard let chat = chat else { return }
        
        let data: [String:Any] = ["amount": "\(amount)", "type": "money", "assetCode":assetCode, "status":status]
        
        
        ChatService.sendMessage(chat: chat, properties: data) { (msgID) in
            
            WalletService.sendPayment(token: reserveAsset, toAccountID: publicKey, amount: amount, completion: { (success) in

                let chatId = chat.id
//                ChatService.updateTransaction(chatID: chatId, messageID: msgID, txID: , values: <#T##[String : Any]#>)
            })
        }
    }
    
    
}




