//
//  ProfileInfoSubViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 01/05/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit

class ProfileInfoSubViewController: UIViewController {
    
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followButtonWidth: NSLayoutConstraint!
    var isFriend = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInfoFollowButton()
    }
    
    func setInfoFollowButton() {
        followButton?.clipsToBounds = true
        followButton?.tintColor = .white
        followButton?.layer.cornerRadius = (followButton?.frame.height)! / 2
    }

    @IBAction func fallowButtonTapped(_ sender: Any) {
        print(1234)
//        switch isFriend {
//        case true:
//            followButton.isSelected = true
//            followButton.setTitle("Following", for: .selected)
//            followButton.setTitleColor(.black, for: .selected)
//            followButton.layer.borderColor = UIColor.black.cgColor
//            followButton.layer.borderWidth = 1.1
//            followButton.backgroundColor = .clear
////            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {}, completion: nil)
//            isFriend =  !isFriend
//
//        case false:
//            followButton.isSelected = false
//            followButton.setTitle("Follow", for: .normal)
//            followButton.setTitleColor(.white, for: .normal)
//            followButton.layer.borderColor = UIColor.clear.cgColor
//            followButton.layer.borderWidth = 0.0
//            followButton.backgroundColor = .black
//
////            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {}, completion: nil)
//
//            isFriend =  !isFriend
//        default:
//            print("default option")
//        }
    }
}
