//
//  ProfileTestViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 01/05/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit

class ProfileTestViewController: UIViewController {

    enum subViewStates {
        case expanded
        case collapsed
    }
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    
    var infoSubView: ProfileInfoSubViewController!
    var visualEffectView: UIVisualEffectView!
    var subViewHeight: CGFloat!
    var subViewHandlerHeight: CGFloat!
    var isFriend = false
    var isExpanded = false
    var nextState: subViewStates {
        return isExpanded ? .collapsed : .expanded
    }
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSubView()
        view.bringSubviewToFront(chatButton)
        view.bringSubviewToFront(closeButton)
    }
    
    func setSubView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSubViewTap(gesture:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSubViewPan(gesture:)))
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        infoSubView = ProfileInfoSubViewController(nibName: "infoSubView", bundle: nil)
        self.addChild(infoSubView)
        self.view.addSubview(infoSubView.view)
        
        subViewHeight = view.frame.height / 2
        subViewHandlerHeight = infoSubView.tapView.frame.height + infoSubView.name.frame.height + infoSubView.location.frame.height + 70
        
        infoSubView.view.clipsToBounds = true
        infoSubView.view.layer.cornerRadius = view.frame.width * 0.068
        infoSubView.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoSubView.view.frame = CGRect(x: 0, y: self.view.frame.height - subViewHandlerHeight, width: self.view.bounds.width, height: subViewHeight)
        
        infoSubView.tapView.addGestureRecognizer(tapGesture)
        infoSubView.view.addGestureRecognizer(panGesture)
    }
    
    func startInteractionTransiction(state: subViewStates, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransactionIfNeeded(state: state, duration: duration)
        }
        
        for animation in runningAnimations {
            animation.pauseAnimation()
            animationProgressWhenInterrupted = animation.fractionComplete
        }
    }
    
    func updateInteractionTransiction(fractionCompleted: CGFloat) {
        for animation in runningAnimations {
            animation.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractionTransiction() {
        for animation in runningAnimations {
            animation.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func animateTransactionIfNeeded(state: subViewStates, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimation = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                    case .expanded:
                        self.infoSubView.view.frame.origin.y = self.view.frame.height - self.subViewHeight
                        //self.view.bringSubviewToFront(self.visualEffectView)
                        //self.view.bringSubviewToFront(self.visualEffectView)
                    case .collapsed:
                        self.infoSubView.view.frame.origin.y = self.view.frame.height - self.subViewHandlerHeight
                default:
                    print("Default case")
                }
            }
            frameAnimation.addCompletion { (_) in
                self.isExpanded = !self.isExpanded
                self.runningAnimations.removeAll()
            }
            
            let blurAnimation = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                    case .expanded:
                        self.view.insertSubview(self.chatButton, belowSubview: self.visualEffectView)
                        self.view.insertSubview(self.closeButton, belowSubview: self.visualEffectView)
                        self.visualEffectView.effect = UIBlurEffect(style: .dark)
                        self.visualEffectView.alpha = 0.30
                    case .collapsed:
                        self.visualEffectView.effect = nil
                        self.view.insertSubview(self.chatButton, aboveSubview: self.visualEffectView)
                        self.view.insertSubview(self.closeButton, aboveSubview: self.visualEffectView)
                    default:
                        print("Default case")
                }
            }
            
            frameAnimation.startAnimation()
            blurAnimation.startAnimation()
            runningAnimations.append(frameAnimation)
            runningAnimations.append(blurAnimation)
        }
    }
    
    @objc func handleSubViewTap(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            animateTransactionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc func handleSubViewPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            startInteractionTransiction(state: nextState, duration: 0.8)
        case .changed:
            let position = gesture.translation(in: self.infoSubView.tapView)
            var fractionComplete = position.y / subViewHeight
            fractionComplete = isExpanded ? fractionComplete : -fractionComplete
            updateInteractionTransiction(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractionTransiction()
        default:
            print("undefined states!")
        }
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        print(1234)
        dismiss(animated: true, completion: nil)
    }
}
