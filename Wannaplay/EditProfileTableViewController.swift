//
//  EditProfileTableViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import Firebase

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var backBT: UIBarButtonItem!
    @IBOutlet weak var saveBT: UIBarButtonItem!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var roleTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            fetchData()
            nameTF.isEnabled = true
            lastnameTF.isEnabled = true
            ageTF.isEnabled = true
            roleTF.isEnabled = true
            emailTF.isEnabled = true
            phoneTF.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchData() {
        let ref = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            self.nameTF.text = data?["name"] as? String ?? "unknown"
            self.lastnameTF.text = data?["lastname"] as? String ?? "unknown"
            self.ageTF.text = data?["age"] as? String ?? "unknown"
            self.roleTF.text = data?["role"] as? String ?? "unknwon"
            self.emailTF.text = data?["email"] as? String ?? "unknown"
            self.phoneTF.text = data?["phone"] as? String ?? "unknown"
            
        }) { (error) in
            print("Error retrieving data: \(error.localizedDescription)")
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
    }
}
