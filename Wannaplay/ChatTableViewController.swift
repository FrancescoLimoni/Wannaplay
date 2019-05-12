//
//  DiscussionTableViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 27/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewController: UITableViewController {
    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var infoBarButton: UIBarButtonItem!
    var isNewChat: Bool!
    var recipientID: String?
    var recipientName: String?
    var recipientLastname: String?
    private let currentUser = Auth.auth().currentUser?.uid
    private let messageTextField: UITextField = {
        let messageTextField = UITextField()
        messageTextField.placeholder = "Enter a message..."
        messageTextField.autocorrectionType = .yes
        messageTextField.borderStyle = .roundedRect
        messageTextField.layer.masksToBounds = true
        messageTextField.layer.cornerRadius = 20
        messageTextField.layer.borderWidth = 0.65
        messageTextField.adjustsFontSizeToFitWidth = true
        messageTextField.autocapitalizationType = .sentences
        messageTextField.enablesReturnKeyAutomatically = true
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.layer.borderColor = UIColor.black.cgColor//(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0).cgColor
        messageTextField.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.2)
        return messageTextField
    }()
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.isEnabled = false
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named:"send"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pushMessage), for: .touchUpInside)
        return button
    }()
    private var chatsID = [String]()
    private var messages = [Message]()
    private let cellID = "reusableCell"

    override func viewWillAppear(_ animated: Bool) {
        if isNewChat == true {
            self.navigationItem.setHidesBackButton(true, animated: true)
        } else {
            self.navigationItem.setHidesBackButton(true, animated: true)
            //self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationController()
        setupBottomMessageView()
        setupMessageTextField()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func setupNavigationController() {
        let nameLabel = UILabel()
        let userImage = UIImageView(image: UIImage(named: "profile picture"))
        let contentView = UIView()
        let titleView = UIView()
        let bottomImage = UIImage()
        
        
        nameLabel.text = (recipientName ?? "Name") + " " + (recipientLastname ?? "Lastname")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        userImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        userImage.contentMode = .scaleAspectFill
        userImage.layer.cornerRadius = 20
        userImage.clipsToBounds = true
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        contentView.addSubview(userImage)
        contentView.addSubview(nameLabel)
        
        userImage.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        userImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: userImage.rightAnchor, constant: 10).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: userImage.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: userImage.heightAnchor).isActive = true
    
        navigationItem.titleView = contentView
        self.navigationController?.navigationBar.shadowImage = bottomImage
        self.navigationController?.navigationBar.setBackgroundImage(bottomImage, for: UIBarMetrics.default)
    }
    
    private func setupBottomMessageView() {
        
        let scrollView = UIScrollView()
        let bottomView: UIView = {
            let innerView = UIView()
            innerView.backgroundColor = .lightText
    
            innerView.translatesAutoresizingMaskIntoConstraints = false
            return innerView
        }()
        
        bottomView.addSubview(sendButton)
        bottomView.addSubview(messageTextField)
        view.addSubview(scrollView)
        view.addSubview(bottomView)
        
        //constraint
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            
            bottomView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            bottomView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80),
            
            sendButton.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            messageTextField.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 20),
            messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
            messageTextField.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func keepTrackOfChatID(completion: @escaping (String) -> ()) {
        let ref = Database.database().reference()
        
        ref.child("messages").observeSingleEvent(of: .childAdded, with: { (snapshot) in
            completion(snapshot.key)
        }, withCancel: nil)
    }
    
    private func retrieveMessages(chatRef: String) {
        let ref = Database.database().reference().child("messages")
        
        ref.child(chatRef).observe( .childChanged, with: { (snapshot) in
            if let data = snapshot.value as? [String:AnyObject] {
                let message = Message()
                let messageID = snapshot.key
                let recipientID = data["recipientID"]
                let senderID = data["senderID"]
                let date = data["date"]
                let text = data["text"]
                
                print()
                print("messageID: \(messageID)")
                print()
                
                message.messageID = messageID
                message.recipientID = (recipientID as! String)
                message.senderID = (senderID as! String)
                message.date = (date as! String)
                message.text = (text as! String)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }
       }, withCancel: nil)
        
    }
    
    @objc private func pushMessage() {
        let ref = Database.database().reference()
        let date = Date()
        let dateFormatter = DateFormatter()
        let stringDate: String!
        let senderID: String = Auth.auth().currentUser!.uid
        let text: String = messageTextField.text ?? "unknonw"
        let dispatchGroup = DispatchGroup()
        
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss a"
        stringDate = dateFormatter.string(from: date)
        
        let dictionary = ["senderID":senderID, "recipientID":recipientID!, "date": stringDate!, "text": text] as [String : Any]
        
        if isNewChat {
            ref.child("messages").childByAutoId().childByAutoId().setValue(dictionary)
            dispatchGroup.enter()
            keepTrackOfChatID { (result) in
                self.chatsID.append(result)
                self.isNewChat = false
                self.retrieveMessages(chatRef: self.chatsID.first!)
                dispatchGroup.leave()
            }
        } else {
            ref.child("messages").child(self.chatsID.first!).childByAutoId().setValue(dictionary)
                retrieveMessages(chatRef: chatsID.first!)
        }
    
        clearTextField()
    }
    
    func clearTextField() {
        messageTextField.text = ""
        sendButton.tintColor = .darkGray
        sendButton.isEnabled = false
    }
    
    @objc private func handleChangeInText() {
    if messageTextField.text?.isEmpty == true || messageTextField.text == "" {
        sendButton.tintColor = .darkGray
        sendButton.isEnabled = false
    } else {
        sendButton.tintColor = .black
        sendButton.isEnabled = true
    }
}
    
    @IBAction func backBarButtonTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func infoBarButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let profile = UIAlertAction(title: "View Profile", style: .default, handler: nil)
        let report = UIAlertAction(title: "Report", style: .destructive, handler: nil)
        
        alert.addAction(profile)
        alert.addAction(report)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = .black
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        let message = messages[indexPath.row]
        
        cell?.textLabel!.text = message.text
        
        return cell!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isNewChat == true {
            self.navigationController?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension ChatTableViewController: UITextFieldDelegate {
    
    func setupMessageTextField() {
        messageTextField.delegate = self
        messageTextField.addTarget(self, action: #selector(handleChangeInText), for: .editingChanged)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapDismissKeyboard))
        self.view.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func handleKeyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name ==  UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -(keyboardRect.height)
        } else {
            view.frame.origin.y = 0
        }
    }
    
    @objc func handleTapDismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true || textField.text == "" {
            sendButton.tintColor = .darkGray
            sendButton.isEnabled = false
        }
    }
}
