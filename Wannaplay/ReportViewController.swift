//
//  ReportViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 21/05/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import MapKit

class ReportViewController: UIViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var submitBarButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeView: UIView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeView: UIView!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoStackView: UIStackView!
    @IBOutlet weak var buttonPhoto1: UIButton!
    @IBOutlet weak var buttonPhoto2: UIButton!
    @IBOutlet weak var buttonPhoto3: UIButton!
    @IBOutlet weak var buttonPhoto4: UIButton!
    @IBOutlet weak var buttonPhoto5: UIButton!
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 500
    private let geoCoder = CLGeocoder()
    private var previousLocation: CLLocation?
    private var pickedImage = [UIImage]()
    let radiusRate: CGFloat = 0.15
    var isSearchControllerPresented: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupShadow()
        mapView.delegate = self
        checkLocationServices()
        self.previousLocation = self.locationManager.location
        submitBarButton.isEnabled = false
        
        setupCornerRadius(view: nameView, radius: radiusRate)
        setupCornerRadius(view: latitudeView, radius: radiusRate)
        setupCornerRadius(view: longitudeView, radius: radiusRate)
        setupCornerRadius(view: addressView, radius: radiusRate)
        setupCornerRadius(view: photoView, radius: radiusRate)
        setupCornerRadius(view: locationButton, radius: 0.3)
        setupCornerRadius(view: searchButton, radius: 0.3)
        
        customizePhotoButton(button: buttonPhoto1)
        customizePhotoButton(button: buttonPhoto2)
        customizePhotoButton(button: buttonPhoto3)
        customizePhotoButton(button: buttonPhoto4)
        customizePhotoButton(button: buttonPhoto5)
    }
    
    func setupShadow() {
        latitudeView.layer.shadowColor = UIColor.darkGray.cgColor
        latitudeView.layer.shadowRadius = 5.0
        latitudeView.layer.shadowOpacity = 0.6
        latitudeView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        longitudeView.layer.shadowColor = UIColor.darkGray.cgColor
        longitudeView.layer.shadowRadius = 5.0
        longitudeView.layer.shadowOpacity = 0.6
        longitudeView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addressView.layer.shadowColor = UIColor.darkGray.cgColor
        addressView.layer.shadowRadius = 5.0
        addressView.layer.shadowOpacity = 0.6
        addressView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        nameView.layer.shadowColor = UIColor.darkGray.cgColor
        nameView.layer.shadowRadius = 5.0
        nameView.layer.shadowOpacity = 0.6
        nameView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setupCornerRadius(view: UIView, radius: CGFloat) {
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.height * radius
    }
    
    func customizePhotoButton(button: UIButton) {
        let photoSpace = photoStackView.spacing = 10.0
        var newWidth = photoStackView.frame.width - 20
        let newHeight = photoStackView.frame.height - 20
        
        print("\n\nstackPhoto size: \(buttonPhoto1.frame.size)\n\n")
        
        button.clipsToBounds = true
        button.frame.size = CGSize(width: newWidth, height: newHeight)
        button.layer.cornerRadius = newHeight / 2
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([  button.widthAnchor.constraint(equalToConstant: newHeight),
                                       button.heightAnchor.constraint(equalToConstant: newWidth)
                                   ])
    }
    
    func customizeSubmitSubview(viewToModify: UIView) -> UIView {
        let title = UILabel()
        let subTitle = UILabel()
        let imageView = UIImageView()
        let dismissButton = UIButton(type: .system)
        let newWidth = view.frame.width * 0.8
        let newHeight = view.frame.height * 0.3
    
        viewToModify.frame.size = CGSize(width: newWidth, height: newHeight)
        viewToModify.backgroundColor = .white
        viewToModify.alpha = 0.5
        setupCornerRadius(view: viewToModify, radius: 0.08)
        
        
        imageView.frame.size = CGSize(width: 50, height: 50)
        imageView.image = UIImage(named: "checked filled")
        title.text = "Report Submitted"
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        subTitle.text = "We appreciate your help. We will check your report shortly and hopefully we will inplement it in our database"
        subTitle.textAlignment = .center
        subTitle.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subTitle.numberOfLines = 0
        subTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        subTitle.sizeToFit()
        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dismissButton.tintColor = .black
        
        viewToModify.addSubview(imageView)
        viewToModify.addSubview(title)
        viewToModify.addSubview(subTitle)
        viewToModify.addSubview(dismissButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ viewToModify.widthAnchor.constraint(equalToConstant: viewToModify.frame.width),
                                      viewToModify.heightAnchor.constraint(equalToConstant: viewToModify.frame.height),
                                      imageView.centerXAnchor.constraint(equalTo: viewToModify.centerXAnchor),
                                      imageView.topAnchor.constraint(equalTo: viewToModify.topAnchor, constant: 15),
                                      imageView.widthAnchor.constraint(equalToConstant: 50),
                                      imageView.heightAnchor.constraint(equalToConstant: 50),
                                      title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
                                      title.leftAnchor.constraint(equalTo: viewToModify.leftAnchor, constant: 12),
                                      title.rightAnchor.constraint(equalTo: viewToModify.rightAnchor, constant: -12),
                                      title.centerXAnchor.constraint(equalTo: viewToModify.centerXAnchor),
                                      subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
                                      subTitle.leftAnchor.constraint(equalTo: viewToModify.leftAnchor, constant: 12),
                                      subTitle.rightAnchor.constraint(equalTo: viewToModify.rightAnchor, constant: -12),
                                      subTitle.centerXAnchor.constraint(equalTo: viewToModify.centerXAnchor),
                                      dismissButton.centerXAnchor.constraint(equalTo: viewToModify.centerXAnchor),
                                      dismissButton.rightAnchor.constraint(equalTo: viewToModify.rightAnchor),
                                      dismissButton.leftAnchor.constraint(equalTo: viewToModify.leftAnchor),
                                      dismissButton.bottomAnchor.constraint(equalTo: viewToModify.bottomAnchor),
                                      dismissButton.heightAnchor.constraint(equalToConstant: 50)
                                   ])
        
        return viewToModify
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //UIAlertController cannot be presented in the view withouth been triggered by button
            //let alert = UIAlertController(title: "Location Services", message: "Your location services is off. Please go to Setting > Privacy > Location Serices and turn it on", preferredStyle: .alert)
            //alert.addAction(UIAlertAction(title: "Open Setting", style: .default, handler: { (result) in
            //    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            //}))
            
            //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            //self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
            //self.window?.rootViewController?.present(alert, animated: true, completion:nil)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            locationManager.requestWhenInUseAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        centerMapOnUserLocation()
    }
    
    private func centerMapOnUserLocation() {
        if let location =  locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            let lastLocation = locationManager.location
            
            previousLocation = lastLocation
            mapView.setRegion(region, animated: true)
        }
        
        reverseGeoLocation(location: locationManager.location!)
    }
    
    private func getMapViewCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func reverseGeoLocation(location: CLLocation) {
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard self != nil else { return }
            if error != nil {
                print("Error: \(String(error?.localizedDescription ?? "guard triggered"))")
            }
            
            guard let placemark = placemarks?.first else { return }

            DispatchQueue.main.async {
                if (placemark.ocean == nil) {
                    guard let latitude = placemark.location?.coordinate.latitude else { return }
                    guard let longitude = placemark.location?.coordinate.longitude else { return }
                    guard let city = placemark.locality else { return }
                    guard let address = placemark.thoroughfare else { return }
                    guard let postalAddress = placemark.subThoroughfare else { return }
                    
                    self?.addressLabel.text = address + " " + postalAddress + ", " + city
                    self?.latitudeLabel.text = String(format: "%.8f", latitude)
                    self?.longitudeLabel.text = String(format: "%.8f", longitude)
                    self?.submitBarButton.isEnabled = true
                }
            }
        }
    }
    
    func alertLoadPicture(isImagePresent: Bool) {
        let imagePicker = UIImagePickerController()
        var alertTitle: String!
        var alertMessage: String!
        var alert = UIAlertController()
        var camera = UIAlertAction()
        var library = UIAlertAction()
        var remove = UIAlertAction()
        var cancel = UIAlertAction()
        
        alertTitle = "Load Photo"
        alertMessage = "We know how important it is have a well-structured database that's why we allow users to report additional playground. In order to decrease the approval time we suggest you to load at least one picture"
        alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        camera = UIAlertAction(title: "Camera", style: .default) { (result) in
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        library = UIAlertAction(title: "Photo Library", style: .default, handler: { (result) in
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        })
        cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        camera.setValue(UIImage(named: "camera"), forKey: "image")
        library.setValue(UIImage(named: "photo gallery"), forKey: "image")
        
        alert.view.tintColor = .black
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        
        if isImagePresent == true {
            remove = UIAlertAction(title: "Remove", style: .destructive, handler: nil)
            remove.setValue(UIImage(named: "trash bin"), forKey: "image")
            alert.addAction(remove)
        }
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.setImage(UIImage(named: "close"), for: .selected)
        
        if isSearchControllerPresented == false {
            print("isSearchControllerPresented = false")
            searchButton.isSelected = true
            isSearchControllerPresented = true
        } else {
            print("isSearchControllerPresented = true")
            searchButton.isSelected = false
            isSearchControllerPresented = false
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        centerMapOnUserLocation()
    }
    
    @IBAction func cencelBarButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBarButtonTapped(_ sender: Any) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        var subView = UIView()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        subView = customizeSubmitSubview(viewToModify: subView)
        view.addSubview(blurView)
        blurView.contentView.addSubview(subView)
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ subView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                      subView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                                   ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //blurView.isHidden = true
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        let dispatchGroup = DispatchGroup()
        sender.setTitle("+", for: .normal)
        sender.setTitle("", for: .selected)
        sender.setTitleColor(.black, for: .normal)
        sender.setTitleColor(.black, for: .selected)
        sender.backgroundColor = .clear
        
        if sender.currentTitle != nil {
            sender.isSelected = true
            print("isSelected = false")
        } else {
            sender.isSelected = false
        }
        
//        dispatchGroup.enter()
//        if self.buttonPhoto1.imageView?.image == nil {
//            self.alertLoadPicture(isImagePresent: false)
//            dispatchGroup.leave()
//        } else {
//            self.alertLoadPicture(isImagePresent: true)
//            dispatchGroup.leave()
//        }
//
//
//
//
//        if self.pickedImage.isEmpty {
//            print("hohohoho")
//        } else {
//            print("isNotEmpty")
//        }
    }
}

extension ReportViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("\n\nuser location changed\n\n")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if Int(status.rawValue) == 3 || Int(status.rawValue) == 4{
            //authorizedAlways or authorizedWhenInUse
            mapView.showsUserLocation = true
            checkLocationServices()
        }
        
        checkLocationServices()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\n\nUnable to access user location \(error.localizedDescription)\n\n")
    }
}

extension ReportViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getMapViewCenterLocation(for: mapView)
        guard let lastLocation = previousLocation else { return }
        
        if center.distance(from: lastLocation) > (10)  {
            let newCenter = getMapViewCenterLocation(for: mapView)
            previousLocation = newCenter
            reverseGeoLocation(location: newCenter)
        }
    }
    
}

extension ReportViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("Error: No image found")
            return
        }
        
        if pickedImage.count < 5 {
            pickedImage.append(selectedImage)
        } else {
            pickedImage[0] = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
