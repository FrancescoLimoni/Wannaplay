//
//  SettingTableViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class SettingTableViewController: UITableViewController {
    
    
    @IBOutlet var tableSettingView: UITableView!
    @IBOutlet weak var profileSettingCell: UITableViewCell!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTF: UILabel!
    @IBOutlet weak var subNameTF: UILabel!
    @IBOutlet weak var logoutBT: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil) {
            fetchData()
            imageView.image = #imageLiteral(resourceName: "profile picture")
            logoutBT.isHidden = false
            subNameTF.isHidden = false
            subNameTF.text = "View Profile"
        } else {
            imageView.image = #imageLiteral(resourceName: "user profile")
            logoutBT.isHidden = true
            nameTF.text = "Log in"
            subNameTF.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "profileCell" {
            if Auth.auth().currentUser != nil {
                performSegue(withIdentifier: "profileSegue", sender: self)
            } else {
                print(5678)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "loginView") as UIViewController
                self.present(newVC, animated: true, completion: nil)
            }
        }
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "notificationCell" {
            performSegue(withIdentifier: "notificationSegue", sender: nil)
        }
    }
    
    func fetchData() {
        let ref = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            let name = data?["name"] as? String ?? "unknown"
            let lastname = data?["lastname"] as? String ?? "unknown"
            self.nameTF.text = name + " " + lastname
        }) { (error) in
            print("Error retrieving data: \(error.localizedDescription)")
        }
    }
    
    @IBAction func notificationBarBTTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "notificationSegue", sender: nil)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        if (Auth.auth().currentUser != nil) {
            do {
                try Auth.auth().signOut()
                nameTF.text = "Log in"
                subNameTF.isHidden = true
                logoutBT.isHidden = true
                print("Successfully logged out")
            } catch let error as NSError {
                print("Error logging out: \(error)")
            }
        }
    }
    
    
    
}
