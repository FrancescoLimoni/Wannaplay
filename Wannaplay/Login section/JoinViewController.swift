//
//  JoinViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import Firebase

class JoinViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var repeatPasswordTF: UITextField!
    @IBOutlet weak var joinBT: UIButton!
    @IBOutlet weak var fbBT: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShadow()
        createBottomLine(textField: nameTF)
        createBottomLine(textField: lastnameTF)
        createBottomLine(textField: emailTF)
        createBottomLine(textField: passwordTF)
        createBottomLine(textField: repeatPasswordTF)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupShadow() {
        joinView.layer.shadowColor = UIColor.lightGray.cgColor
        joinView.layer.shadowOpacity = 0.7
        joinView.layer.shadowOffset = CGSize(width: 0, height: 0)
        joinView.layer.shadowRadius = 15
        joinView.layer.masksToBounds = false
        
        joinBT.layer.shadowColor = UIColor.lightGray.cgColor
        joinBT.layer.shadowOpacity = 0.7
        joinBT.layer.shadowOffset = CGSize(width: 0, height: 12)
        joinBT.layer.shadowRadius = 15
        joinBT.layer.masksToBounds = false
        
        fbBT.layer.shadowColor = UIColor.lightGray.cgColor
        fbBT.layer.shadowOpacity = 0.35
        fbBT.layer.shadowOffset = CGSize(width: 0, height: 0)
        fbBT.layer.shadowRadius = 15
        fbBT.layer.masksToBounds = false
        
    }
    
    func createBottomLine(textField: UITextField) {
        let bottomLine = CALayer()
        let width = textField.frame.size.width
        let height = textField.frame.size.height
        //let color = UIColor(red: 243, green: 242, blue: 248, alpha: 0.7)
        
        bottomLine.frame = CGRect(x: 0, y: height-1, width: width, height: 0.5)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
        textField.layer.masksToBounds = true
    }
    
    func splitStringAfterSpace(string: String) -> (String, String){
        let stringSplittedArray = string.components(separatedBy: " ")
        let name = stringSplittedArray[0]
        let lastname = stringSplittedArray[1]
        
        return (name, lastname)
    }
    
    @IBAction func unwindSegue(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinWithEmail(_ sender: Any) {
        guard let name = nameTF.text else { return }
        guard let lastname = lastnameTF.text else { return }
        guard let email = emailTF.text else { return }
        guard let pw = passwordTF.text else { return }
        guard let repeatPW = repeatPasswordTF.text else { return }
        
        if pw == repeatPW {
            //create user authentication
            Auth.auth().createUser(withEmail: email, password: pw) { (result, error) in
                if error != nil {
                    print("Error: \(error?.localizedDescription ?? "")")
                    return
                }
                
                //create user reference on database. (to create a new brunch into the database must create a reference and add data to that)
                let ref = Database.database().reference(withPath: "users")
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let brunch = ref.child(userID)
                let user = ["name": name,
                            "lastname": lastname,
                            "email": email,
                            "age": "unknown",
                            "role": "unknown",
                            "nationality": "unknown",
                            "pictureURL": "unknwon",
                            "phone": "unknwon"]
                brunch.setValue(user)
                
                //Dismiss back to the first sugue
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func joinWithFB(_ sender: Any) {
        let manager = FBSDKLoginManager()
        let permisions = ["email", "public_profile"]
        
        manager.logIn(withReadPermissions: permisions, from: self) { (resultLogin, error) in
            if error != nil {
                print("Errror durin the login with facebook: \(error?.localizedDescription ?? "Error Login Facebook")")
                return
            }
            print()
            print("result login: ", resultLogin!)
            print()
            
            //Request fetching data from facebook
            let parameters = ["Fields": "id, name, email"]
            FBSDKGraphRequest(graphPath: "/me", parameters: parameters)?.start(completionHandler: { (connection, resultRequest, error) in
                
                print()
                print("result request: ", resultRequest!)
                print()
            })
            
            //Profile picture request I cannot grab the url
            let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
            pictureRequest?.start(completionHandler: { (connection, resultPicture, error) in
                if error == nil {
                    print("resultPicture: ", resultPicture ?? "unknown")
                } else {
                    print("Error resultPicture: \(error?.localizedDescription ?? "unknown")")
                }
            })
            
            let accessToken  = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else { return }
            let credetial = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signInAndRetrieveData(with: credetial, completion: { (resultCredential, error) in
                if error != nil {
                    print("Error creating user from FB to FireBase: \(error?.localizedDescription ?? "Error create user ot Firebase")")
                    return
                }
                
                //Saving user info into firebase db
                guard let userID = Auth.auth().currentUser?.uid else { return }
                let fullName = resultCredential?.user.displayName ?? "unknown"
                let (name, lastname) = self.splitStringAfterSpace(string: fullName)
                let email = resultCredential?.user.email ?? "unknown"
                guard let pictureURL = resultCredential?.user.photoURL else { return }
                var urlString: String = ""
                do {
                    urlString =  try String(contentsOf: pictureURL)
                } catch {
                    print("error")
                }
                
                let phone = resultCredential?.user.phoneNumber ?? "unknown"
                
                let ref = Database.database().reference()
                let newUserDB = ref.child("users").child(userID)
                let user = ["name": name,
                            "lastname": lastname,
                            "email": email,
                            "age": "unknown",
                            "role": "unknown",
                            "nationality": "unknown",
                            "pictureURL": urlString,
                            "phone": phone]
                newUserDB.setValue(user)
                
                //dismiss views
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                
            })
        }
        
    }
}

extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name ==  UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -(keyboardRect.height/2.6)
            print("keyboardRect.height: \(keyboardRect.height)")
        } else {
            view.frame.origin.y = 0
        }
    }
}
