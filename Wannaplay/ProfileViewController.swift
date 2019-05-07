
//
//  ProfileViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoutBT: UIButton!
    @IBOutlet weak var shareBT: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        if (Auth.auth().currentUser == nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let newVC = storyboard.instantiateViewController(withIdentifier: "loginView") as UIViewController
            self.present(newVC, animated: true, completion: nil)
        }
        
        imageView.image = #imageLiteral(resourceName: "profile picture")
        fetchUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
        setupButton(button: logoutBT)
        setupButton(button: shareBT)
        
        //add gesture to the uiimage
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    func fetchUserInfo() {
        guard let user = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()
        
        ref.child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let nameText = value?["name"] as? String ?? "unavailable"
            let lastnameText = value?["lastname"] as? String ?? "unavailable"
            self.name.text = nameText + " " + lastnameText
            //self.age.text = value?["age"] as? String ?? "unavailable"
            //self.role.text = value?["role"] as? String ?? "unavailable"
        }) { (error) in
            print("Error retrieving data: \(error.localizedDescription)")
        }
    }
    
    func setupButton(button: UIButton) {
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 0.6
        
        if button.titleLabel?.text == "Log out" {
            button.layer.borderColor = UIColor.red.cgColor
        } else {
            button.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @objc func profileImageTapped(_ gesture: UITapGestureRecognizer) {
        requestPictureSource()
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        let shareString = "put here your string"
        let shareActivity = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        
        shareActivity.popoverPresentationController?.sourceView = self.view
        self.present(shareActivity, animated: true, completion: nil)
    }
    
    @IBAction func editBarBTTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editProfileSegue", sender: nil)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        if (Auth.auth().currentUser != nil) {
            let alert = UIAlertController(title: "Log out Process", message: "Are you sure you want to log out?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive) { (action) in
                do {
                    try Auth.auth().signOut()
                    print("Successfully logged out")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyboard.instantiateViewController(withIdentifier: "tabBarView") as! UITabBarController
                    self.present(newViewController, animated: true, completion: nil)
                } catch let error as NSError {
                    print("Error logging out: \(error)")
                }
            }
            
            let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(no)
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(1234)
//            self.imageView.image = originalImage
//            self.imageView.contentMode = .scaleToFill
//            self.imageView.clipsToBounds = true
        }else if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            print(5678)
//            self.imageView.image = editImage
//            self.imageView.contentMode = .scaleToFill
//            self.imageView.clipsToBounds = true
        } else {
            print(91011)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func requestPictureSource() {
       
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let library = UIAlertAction(title: "Library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        camera.setValue(UIImage(named: "camera"), forKey: "image")
        library.setValue(UIImage(named: "photo gallery"), forKey: "image")
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellID = collectionView.dequeueReusableCell(withReuseIdentifier: "reusableCell", for: indexPath) as! FriendsCollectionViewCell
        cellID.layer.cornerRadius = cellID.frame.width / 2
        
        return cellID
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print()
        print("selected item at index \(indexPath)")
        print()
    }
    
    
}
