//
//  UserProfileViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 27/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leftBT: UIButton!
    @IBOutlet weak var rightBT: UIButton!
    private let isFriend: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        leftButtonStatus()
        
        if isFriend == false {
            rightBT.isHidden = true
            leftBT.isSelected = false
            leftBT.backgroundColor = .black
            leftBT.tintColor = .white
            leftBT.addTarget(self, action: #selector(handleFriendRequest), for: .touchUpInside)
        } else {
            rightBT.isHidden = false
            leftBT.isSelected = true
            leftBT.backgroundColor = .white
            leftBT.addTarget(self, action: #selector(handleMessage), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton(button: leftBT)
        setupButton(button: rightBT)
        imageProfile.layer.cornerRadius = imageProfile.bounds.width * 0.5
    }
    
    private func leftButtonStatus() {
        leftBT.setTitle("Follow", for: .normal)
        leftBT.setTitleColor(.white, for: .normal)
        leftBT.setTitle("Message", for: .selected)
        leftBT.setTitleColor(.black, for: .selected)
    }
    
    func setupButton(button: UIButton) {
        button.layer.borderWidth = 0.6
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = button.frame.height * 0.2
        
    }
    
    func getTodayString() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: now)
        
        let day = String(components.day!)
        let month = String(components.month!)
        let year = String(components.year!)
        let hour = String(components.hour!)
        let minute = String(components.minute!)
        let second = String(components.second!)
        
        let dateString = day + "/" + month + "/" + year + " - " + hour + ":" + minute + ":" + second
        return dateString
    }
    
    func makeFriendRequest() {
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserID = currentUser.uid
        let receiverUserID = "TODO: get receiver user id"
        let date =  getTodayString()
        var requestsID: String?
        
        // current user db side
        ref.child("users").child(currentUserID).child("friendsRequest").child("submit").childByAutoId().setValue(["from": currentUserID, "to": receiverUserID, "date": date])
        DispatchQueue.main.async {
            ref.child("users").child(currentUserID).child("friendsRequest").child("submit").observe(.childAdded) { (snapshot) in
                let id = snapshot.key
                requestsID = id
                print("id \(id)")
                print("requestID (inside): \(requestsID)")
            }
        }
        
        print("requestID (outside): \(requestsID)")
        // other user db side
    }

    
    @objc private func handleFriendRequest() {
        makeFriendRequest()
        
//        leftBT.isSelected = true
//        leftBT.backgroundColor = .white
//        rightBT.isHidden = false
    }
    
    @objc func handleMessage() {
        print(5678)
    }
    
    @IBAction func unfollowBTTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Unfollow", message: "Are you sure you want to unfollow <name & lastname>?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.leftBT.isSelected = false
            self.leftBT.backgroundColor = .black
            self.rightBT.isHidden = true
        }
        
        alert.addAction(yes)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
}

class Request {
    let requestID: String = ""
    let from: String = ""
    let to: String = ""
    let date: String = ""
}
