//
//  PlaygroundTestViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 21/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import MapKit
import QuartzCore
import Charts

class PlaygroundViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backBT: UIButton!
    @IBOutlet weak var moreBT: UIButton!
    @IBOutlet weak var starBT: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var featuresView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var requestBT: UIButton!

    private let cornerRadius: CGFloat = 0.28
    private var isLiked: Bool = false
    var currentTouchPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegates()
        setupShadow()
        setupStarBTImage()
        setupRoundCorner()
        setupBlurBackground(button: backBT)
        setupBlurBackground(button: moreBT)
        setupBlurBackground(button: starBT)
        
        let coordinates = CLLocationCoordinate2D(latitude: 44.489415, longitude: 11.388137)
        let myAnnotation = MKPointAnnotation()
        myAnnotation.title = "Cà Rossa"
        //myAnnotation.subtitle = nil
        myAnnotation.coordinate = coordinates
        let span  = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        mapView.addAnnotation(myAnnotation)
        mapView.setRegion(region, animated: true)
    }
 
    func setupDelegates() {
        scrollView.delegate = self
    }
    
    func setupRoundCorner() {
        chartView.layer.cornerRadius = ((chartView.frame.height / 4) * cornerRadius)
        featuresView.layer.cornerRadius = ((featuresView.frame.height / 4) * cornerRadius)
        addressView.layer.cornerRadius = ((addressView.frame.height / 4) * cornerRadius)
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = ((mapView.frame.height / 4) * cornerRadius)
        mapView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
    
    func setupBlurBackground(button: UIButton) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibracyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibracyEffectView = UIVisualEffectView(effect: vibracyEffect)
     
        blurEffectView.frame = button.frame
        blurEffectView.layer.cornerRadius = 0.5 * button.bounds.size.width
        blurEffectView.clipsToBounds = true
        blurEffectView.isUserInteractionEnabled = false
        
        vibracyEffectView.frame = button.frame
        vibracyEffectView.layer.cornerRadius = 0.5 * button.bounds.size.width
        vibracyEffectView.clipsToBounds = true
        vibracyEffectView.isUserInteractionEnabled = false
        
        button.addSubview(blurEffectView)
        //blurEffectView.insertSubview(button, at: 0)
        //blurEffectView.bringSubviewToFront(button)
    }
    
    func setupShadow() {
        chartView.layer.shadowColor = UIColor.lightGray.cgColor
        chartView.layer.shadowRadius = 3.0
        chartView.layer.shadowOpacity = 0.8
        chartView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        featuresView.layer.shadowColor = UIColor.lightGray.cgColor
        featuresView.layer.shadowRadius = 3.0
        featuresView.layer.shadowOpacity = 0.8
        featuresView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addressView.layer.shadowColor = UIColor.lightGray.cgColor
        addressView.layer.shadowRadius = 3.0
        addressView.layer.shadowOpacity = 0.8
        addressView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setupStarBTImage() {
        starBT.setImage(#imageLiteral(resourceName: "star solid yellow"), for: .selected)
        starBT.setImage(#imageLiteral(resourceName: "star solid black"), for: .normal)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backBTTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreBTTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let share = UIAlertAction(title: "Share", style: .default) { (action) in
            let shareString = "Share useful information about this"
            let shareActivity = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
            shareActivity.popoverPresentationController?.sourceView = self.view
            self.present(shareActivity, animated: true, completion: nil)
        }
        let qrCode = UIAlertAction(title: "Qr Code", style: .default, handler: nil)
        let direction = UIAlertAction(title: "Get Direction", style: .default) { (action) in
            let coordinates = CLLocationCoordinate2D(latitude: 44.489415, longitude: 11.388137)
            let span  = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            let option = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center)]
            let address = ["CNPostalAddressStreetKey": "Via Felsina", "CNPostalAddressPostalCodeKey": "50", "CNPostalAddressCityKey":"Bologna", "CNPostalAddressCountryKey":"Italy"]
            let myPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: address)
            let mapItem = MKMapItem(placemark: myPlacemark)
            
            mapItem.openInMaps(launchOptions: option)
        }
        let report = UIAlertAction(title: "Report Problem", style: .destructive, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        share.setValue(UIImage(named: "share"), forKey: "image")
        qrCode.setValue(UIImage(named: "qr code"), forKey: "image")
        direction.setValue(UIImage(named: "direction"), forKey: "image")
        report.setValue(UIImage(named: "issue"), forKey: "image")
        alert.addAction(share)
        alert.addAction(qrCode)
        alert.addAction(direction)
        alert.addAction(report)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func starBTTapped(_ sender: Any) {
        
        if isLiked == false {
            starBT.isSelected = true
            isLiked = true
        } else {
            starBT.isSelected = false
            isLiked = false
        }
    }
    
    @IBAction func directionButtonTapped(_ sender: Any) {
        let coordinates = CLLocationCoordinate2D(latitude: 44.489415, longitude: 11.388137)
        let span  = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        let option = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center)]
        let address = ["CNPostalAddressStreetKey": "Via Felsina", "CNPostalAddressPostalCodeKey": "50", "CNPostalAddressCityKey":"Bologna", "CNPostalAddressCountryKey":"Italy"]
        let myPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: address)
        let mapItem = MKMapItem(placemark: myPlacemark)
        
        mapItem.openInMaps(launchOptions: option)
    }
}

extension PlaygroundViewController: UIScrollViewDelegate {
    //Expand the imageView when scrollView scrolls down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y
        
        if contentY < 0 {
            let width = self.view.bounds.width
            let height = 240 - contentY
            
            imageView.frame = CGRect(x: 0, y: contentY, width: width, height: height)
        }
    }
}
