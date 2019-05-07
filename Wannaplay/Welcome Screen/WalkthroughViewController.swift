//
//  WalkthroughViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController, WalkthroughPageViewControllerDelegate {
    
    
    @IBOutlet weak var skipBT: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBT: UIButton!
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let newVC = storyboard.instantiateViewController(withIdentifier: "joinView") as! JoinViewController
                self.present(newVC, animated: true, completion: nil)
                //dismiss(animated: true, completion: nil)
            default: break
            }
        }
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination  = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
    func updateView() {
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextBT.setTitle("Next", for: .normal)
                nextBT.backgroundColor = UIColor.clear
                nextBT.setTitleColor(.black, for: .normal)
                skipBT.isHidden = false
                pageControl.isHidden = false
            case 2:
                skipBT.isHidden = true
                pageControl.isHidden = true
                nextBT.setTitle("LOGIN", for: .normal)
                nextBT.backgroundColor = UIColor.black
                nextBT.clipsToBounds = true
                nextBT.layer.cornerRadius = 12
                nextBT.setTitleColor(.white, for: .normal)
            default: break
            }
            
            pageControl.currentPage = index
        }
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateView()
    }
    
}
