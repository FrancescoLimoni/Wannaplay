//
//  FollowButton.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 03/05/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit

class FollowButton: UIButton {
    var isOn = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        layer.cornerRadius =  frame.size.height / 2
        layer.borderWidth = 1.1
        layer.borderColor = UIColor.black.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        setTitle("Following", for: .normal)
        setTitleColor(.black, for: .normal)
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isOn)
    }
    
    func activateButton(bool: Bool) {
        isOn = bool
        
        let colorButton = bool ? UIColor.white : UIColor.black
        let title = bool ? "Following" : "Follow"
        let titleColor = bool ? UIColor.black : UIColor.white
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = colorButton
    }
}
