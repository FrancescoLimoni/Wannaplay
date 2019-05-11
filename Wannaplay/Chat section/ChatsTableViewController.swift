//
//  ChatsTableViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 27/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import Firebase

class ChatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}

class ChatsTableViewController: UITableViewController {

    @IBOutlet weak var composeBarButton: UIBarButtonItem!
    
    private let cellID = "cellReusable"
    private var chatsList = [String]()
    private var selectedUserIndex: Int!
    private var messages = [Message]()
    
    override func viewWillAppear(_ animated: Bool) {
        //retreiveMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
    }

    func setupNavigationController() {
        let bottomImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.shadowImage = bottomImage
        navigationController?.navigationBar.setBackgroundImage(bottomImage, for: UIBarMetrics.default)
    }
    
    func setupEmptyTableView() {
        let emptyView = UIView()
        let title = UILabel()
        let subTitle = UILabel()
        
        title.translatesAutoresizingMaskIntoConstraints = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.frame = view.frame
        title.text =  "Empty Chat List"
        title.textColor = .black
        title.textAlignment = .center
        subTitle.text = "your chats will be listed here"
        subTitle.textColor = .lightGray
        subTitle.textAlignment = .center
        
        emptyView.addSubview(title)
        emptyView.addSubview(subTitle)
        
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -12.5),
            title.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            subTitle.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: 12.5),
            subTitle.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
            ])
        
        self.tableView.backgroundView = emptyView
        self.tableView.separatorStyle = .none
    }
    
    func menuAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "More") { (action, view, complition) in
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let mute = UIAlertAction(title: "Mute", style: .default, handler: nil)
            let muteIcon = UIImage(named: "mute")
            let show = UIAlertAction(title: "Show Profile", style: .default, handler: nil)
            let showIcon = UIImage(named: "user profile")
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            mute.setValue(muteIcon, forKey: "image")
            show.setValue(showIcon, forKey: "image")
            
            alert.addAction(mute)
            alert.addAction(show)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            complition(true)
        }
        
        action.image = #imageLiteral(resourceName: "menu")
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            //TODO: delete the chat from the firebase
            //self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        action.image = #imageLiteral(resourceName: "trash bin")
        return action
    }
    
    private func retreiveMessages() {
        let ref = Database.database().reference().child("messages")

        ref.observe(.childAdded, with: { (snapshot) in
            if let data = snapshot.value as? [String:AnyObject] {
                let message = Message()
                let recipientID = data["recipientID"]
                let senderID = data["senderID"]
                let date = data["date"]
                let text = data["text"]

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
    
    @IBAction func newMessageTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "newMessageSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let menu = menuAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [menu, delete])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.isEmpty {
            setupEmptyTableView()
            return 0
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
        return chatsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatsTableViewCell
        
        tableView.rowHeight = 120
        tableView.tableFooterView = UIView()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedUserIndex = indexPath.row
        performSegue(withIdentifier: "openChatSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChatSegue" {
            let vc = segue.destination as! ChatTableViewController
            vc.recipientID = "receiver id"
            vc.recipientName = ""
            vc.recipientLastname = ""
            
        } else if segue.identifier == "newMessageSegue" {
            segue.destination as! NewMessageTableViewController
        }
        
        //self.hidesBottomBarWhenPushed = true
    }
}
