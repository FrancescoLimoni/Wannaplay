//
//  PlaygroundViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class PlaygroundViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeBT: UIButton!
    @IBOutlet weak var moreBT: UIButton!
    @IBOutlet weak var backBT: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var addressViewToTap: UIView!
    @IBOutlet weak var fieldFeatures: UIView!
    @IBOutlet weak var addressView: UIView!
    var like: Bool!
    var statusBar: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCornerRadius(view: fieldFeatures)
        viewCornerRadius(view: addressView)
        
        blurButtonBackground(button: backBT)
        blurButtonBackground(button: moreBT)
        blurButtonBackground(button: likeBT)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleAddressTapped(recognizer:)))
        addressViewToTap.addGestureRecognizer(gesture)
    }
    
    func viewCornerRadius(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
    }
    
    func blurButtonBackground(button: UIButton) {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        blur.frame = button.bounds
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 0.5 * button.bounds.size.width
        blur.clipsToBounds = true
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.insertSubview(blur, at: 0)
        button.bringSubviewToFront(button.imageView!)
    }
    
    @objc func handleAddressTapped(recognizer: UITapGestureRecognizer) {
        
        let distance = 5000
        let coordinates = CLLocationCoordinate2D(latitude: 1000, longitude: 1000)
        let mapSpam = MKCoordinateRegion(center: coordinates, latitudinalMeters: CLLocationDistance(distance), longitudinalMeters: CLLocationDistance(distance))
        let options = [  MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: mapSpam.center),
                         MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: mapSpam.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "Cà Rossa"
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func unwindSegue(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Hazard Menu", message: "Here you can reports inaccuracy and issues about this playground", preferredStyle: .actionSheet)
        let option1 = UIAlertAction(title: "Option1", style: .default, handler: nil)
        let option2 = UIAlertAction(title: "Option2", style: .default, handler: nil)
        let option3 = UIAlertAction(title: "Option3", style: .default, handler: nil)
        let option4 = UIAlertAction(title: "Option4", style: .default, handler: nil)
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alert.addAction(option1)
        alert.addAction(option2)
        alert.addAction(option3)
        alert.addAction(option4)
        alert.addAction(cancelOption)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func like(_ sender: Any) {
        if like == true {
            like = false
            //load empty hart
        } else {
            like = true
            //load full hart
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension PlaygroundViewController: UIScrollViewDelegate {
    
    //Expand the imageView when scrollView scrolls down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y
        
        if contentY < 0 {
            let width = self.view.bounds.width
            let height = 250 - contentY
            
            imageView.frame = CGRect(x: 0, y: contentY, width: width, height: height)
        }
    }
}
