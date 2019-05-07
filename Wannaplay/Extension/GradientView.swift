//
//  GradientView.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 03/05/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setGradientColorOnView(colorOne: UIColor, colorTwo: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 0.55]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
