//
//  NewMessageTableViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 05/05/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var role: UILabel!
}

class NewMessageTableViewController: UITableViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    private let cellID = "reusableCell"
    private var friendsID = [String]()
    private var friendsData = [User]()
    
    override func viewWillAppear(_ animated: Bool) {
        if friendsData.isEmpty {
            fetchFriendID()
        } else {
            friendsData.removeAll()
            fetchFriendID()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupEmptyView()
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        
        navigationItem.title = "New Message"
        navigationItem.searchController = searchController
        
    }
    
    func setupEmptyView() {
        let emptyView = UIView()
        let titleLabel = UILabel()
        let subTitle = UILabel()
        
        emptyView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Empty friends list"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        subTitle.text = "Your contacts will be in here "
        subTitle.textColor =  .lightGray
        subTitle.textAlignment = .center
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(subTitle)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            subTitle.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor),
            subTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
            ])
    }
    
    private func fetchFriendID() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        ref.child("users").child(currentUserID).child("friendsList").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let snap = child
                let friendID = snap.value!
                self.friendsID.append(friendID as! String)
            }
            
            for friendID in self.friendsID {
                self.fetchFriendData(userID: friendID)
            }

        }, withCancel: nil)
        
    }
    
    private func fetchFriendData(userID: String) {
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).observe(.value) { (snapshot) in
            if let data = snapshot.value as? [String:AnyObject] {
                let user = User()
                let friendName = data["name"]
                let friendLastname = data["lastname"]
                let friendEmail = data["email"]
                let friendPhone = data["phone"]
                let friendAge = data["age"]
                let friendNationality = data["nationality"]
                let friendRole = data["role"]
                let FriendPicture = data["pictureURL"]
                
                user.id = userID
                user.name = (friendName as! String)
                user.lastname = (friendLastname as! String)
                user.email = (friendEmail as! String)
                user.picture = (FriendPicture as! String)
                user.age = (friendAge as! Int)
                user.phoneNumber = (friendPhone as! String)
                user.role = (friendRole as! String)
                user.nationality = (friendNationality as! String)
                self.friendsData.append(user)
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! NewMessageTableViewCell
        let friend = friendsData[indexPath.row]
        
        cell.imageProfile.image = UIImage(named: "profile picture")
        cell.imageProfile.layer.cornerRadius = cell.imageProfile.frame.height / 2
        cell.imageProfile.clipsToBounds = true
        cell.name.text = friend.name + " " + friend.lastname
        cell.role.text = friend.role
        tableView.tableFooterView = UIView()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            let chatsViewRef = ChatsTableViewController()
            let user = self.friendsData[indexPath.row]
            chatsViewRef.initiateChatWithUser(user: user)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
