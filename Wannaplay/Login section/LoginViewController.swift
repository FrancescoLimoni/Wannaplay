//
//  LoginViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var backBT: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var lostCredetialBT: UIButton!
    @IBOutlet weak var createAccountBT: UIButton!
    @IBOutlet weak var loginBT: UIButton!
    @IBOutlet var fbBT: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShadow()
        createBottomLine(textField: usernameTF)
        createBottomLine(textField: passwordTF)
        fbBT.contentMode = .scaleAspectFit
        
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
        loginView.layer.shadowColor = UIColor.lightGray.cgColor
        loginView.layer.shadowOpacity = 0.7
        loginView.layer.shadowOffset = CGSize(width: 0, height: 0)
        loginView.layer.shadowRadius = 15
        loginView.layer.masksToBounds = false
        
        loginBT.layer.shadowColor = UIColor.lightGray.cgColor
        loginBT.layer.shadowOpacity = 0.7
        loginBT.layer.shadowOffset = CGSize(width: 0, height: 12)
        loginBT.layer.shadowRadius = 15
        loginBT.layer.masksToBounds = false
        
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
    
    func createBottomLineError(textField: UITextField) {
        let bottomLine = CALayer()
        let width = textField.frame.size.width
        let height = textField.frame.size.height
        //let color = UIColor(red: 243, green: 242, blue: 248, alpha: 0.7)
        
        bottomLine.frame = CGRect(x: 0, y: height-1, width: width, height: 0.5)
        bottomLine.backgroundColor = UIColor.red.cgColor
        
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
        textField.layer.masksToBounds = true
    }
    
    func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
        
        // at least one uppercase, at least one digit, at least one lowercase, 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
    @IBAction func unwindSegue(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func login(_ sender: Any) {
        guard let email = usernameTF.text else { createBottomLineError(textField: usernameTF); return }
        guard let pw = passwordTF.text else { createBottomLineError(textField: passwordTF); return }
        
        Auth.auth().signIn(withEmail: email, password: pw) { (result, error) in
            if error != nil {
                print("Error logging in: \(error?.localizedDescription ?? "")")
                return
            }
            
            
            print("Successfully logged in: \(String(describing: result))")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        //fetching data
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            //check for errors
            if error != nil {
                print("Errror durin the login with facebook: \(error?.localizedDescription ?? "Error Login Facebook")")
                return
            }
            
            //featch data from FB (id, name, email)
            let parameters = ["fields": "id, name, email"]
            FBSDKGraphRequest(graphPath: "/me", parameters: parameters)?.start(completionHandler: { (connection, result, error) in
                if error != nil {
                    print("ERROR during the graph request: \(error?.localizedDescription ?? "Error graph request")")
                    return
                }
                
                print(result ?? "")
            })
            
            //create fb user into Firebase
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                if error != nil {
                    print("Error creating user from FB to FireBase: \(error?.localizedDescription ?? "")")
                }
                
                //Dismiss view get to home
                print("Successfully registrion: \(String(describing: result))")
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name ==  UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -(keyboardRect.height/2.5)
            print("keyboardRect.height: \(keyboardRect.height)")
            //view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //check errors while sign in
        if error != nil {
            print("ERROR: \(error.localizedDescription)")
            return
        }
        
        //make a request
        print("Successfully logged in")
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"])?.start(completionHandler: { (connection, result, error) in
            if error != nil {
                print("ERROR during the graph request: \(error?.localizedDescription ?? "")")
                return
            }
            
            print(result as Any)
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out from Facebook")
    }
}
