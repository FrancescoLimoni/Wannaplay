//
//  HomeViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

struct Playground {
    var name:String
    var address: String
    var latitude: Double
    var longitude: Double
    var zipcode: Int
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var qrCodeBT: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var centerLocationBT: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 5000
    private let cornerRadius: CGFloat = 0.28
    private let geoCoder = CLGeocoder()
    private var previousLocation: CLLocation?
    private var nation: String!
    private var state: String!
    private var region: String!
    private var city: String!
    private var playgroundNames: [String] = []
    private var playgroundsNear: [Playground] = []
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.Delegates()
            self.setupShadow()
            self.setupCornerRadius()
            //self.setupSearchController()
            self.checkLocationServices()
            self.previousLocation = self.locationManager.location
            
            print()
            print("address: \(self.nation ?? "unknown"), \(self.state ?? "unknown"), \(self.region ?? "unknown"), \(self.city ?? "unknown")")
            print()
        }
        
        fetchPlaygroundName(nation: "italy", state: "emilia romagna", region: "bologna", city: "bologna") { (result) in
                self.playgroundNames = result

            //print("playgroundNames inside: \(self.playgroundNames)")
        }
        
        for name in playgroundNames {
            fetchPlaygroundData(nation: "italy", state: "emilia romagna", region: "bologna", city: "bologna", name: name) { (result) in
                self.playgroundsNear = result
                print("playgroundsNear inside: \(self.playgroundsNear)")
            }
            
            print("playgroundsNear outside: \(self.playgroundsNear)")
        }
    }
    
    private func Delegates() {
        searchTextField.delegate = self
        mapView.delegate = self
        collectionView.delegate = self
    }
    
    func setupShadow() {
        searchBarView.layer.shadowColor = UIColor.darkGray.cgColor
        searchBarView.layer.shadowRadius = 5.0
        searchBarView.layer.shadowOpacity = 0.6
        searchBarView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        collectionView.layer.shadowColor = UIColor.darkGray.cgColor
        collectionView.layer.shadowRadius = 5.0
        collectionView.layer.shadowOpacity = 0.6
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setupCornerRadius() {
        qrCodeBT.clipsToBounds = true
        qrCodeBT.layer.cornerRadius = qrCodeBT.frame.height * cornerRadius
        qrCodeBT.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    
        searchBarView.clipsToBounds = true
        searchBarView.layer.cornerRadius = searchBarView.frame.height * cornerRadius
        
        centerLocationBT.clipsToBounds = true
        centerLocationBT.layer.cornerRadius = centerLocationBT.frame.height * cornerRadius
        centerLocationBT.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self as UISearchBarDelegate
        present(searchController, animated: true, completion: nil)
    }
    
    func beginSearch() {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        let searchRequest = MKLocalSearch.Request()
        let searchProcess = MKLocalSearch(request: searchRequest)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
//        searchBar.resignFirstResponder()
//        dismiss(animated: true, completion: nil)
        
        searchRequest.naturalLanguageQuery = searchTextField.text
        searchProcess.start { (result, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                //cannot press on button
                let alert = UIAlertController(title: "NO RESULT", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
           
            if CLError.locationUnknown.rawValue == 4 {
                return
            }
            
            //TODO: remoove annotation
            
            //TODO:getting result
            let coordinates = CLLocationCoordinate2D(latitude: result?.boundingRegion.center.latitude ?? 0.0, longitude: result?.boundingRegion.center.longitude ?? 0.0)
            let myAnnotation = MKPointAnnotation()
            myAnnotation.title = self.searchTextField.text
            myAnnotation.coordinate = coordinates
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.mapView.addAnnotation(myAnnotation)
        }
        
    }
    
    func checkLocationServices() {
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
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerMapOnUserLocation()
        //locationManager.startUpdatingLocation()
        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func centerMapOnUserLocation() {
        if let location =  locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        reverseGeoLocation(location: CLLocation(latitude: latitude, longitude: longitude))
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    func reverseGeoLocation(location: CLLocation) {
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard self != nil else { return }
            if error != nil {
                print("Error: \(String(error?.localizedDescription ?? "guard triggered"))")
            }
            guard let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                self?.nation = placemark.country
                self?.state = placemark.administrativeArea
                self?.region = placemark.subAdministrativeArea
                self?.city = placemark.locality
                
//                print()
//                print("address: \(self?.nation ?? "unknown"), \(self?.state ?? "unknown"), \(self?.region ?? "unknown"), \(self?.city ?? "unknown")")
//                print()
                
            }
        }
        
    }
    
    private func fetchPlaygroundName(nation: String, state: String, region: String, city: String, completion: @escaping ([String]) -> ())  {
        let dbRef = Database.database().reference()
        var array = [String]()
        
        dbRef.child("playgrounds").child(nation).child(state).child(region).child(city).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let snap = child
                let nameField = snap.key
                
                array.append(nameField)
                completion(array)
            }
        }
    }

    func fetchPlaygroundData(nation: String, state: String, region: String, city: String, name: String, completion: @escaping ([Playground]) -> ()) {
        let dbRef = Database.database().reference()
        var array: [Playground] = []
        
        dbRef.child("playgrounds").child(nation).child(state).child(region).child(city).child(name).observeSingleEvent(of: .value) { (snapshot) in
            let data = snapshot.value as? NSDictionary
            let addressField = data?["address"] as? String ?? "unknown"
            let latitudeField = data?["latitude"] as? Double ?? 0
            let longitudeField = data?["longitude"] as? Double ?? 0
            let zipcodeField = data?["zipcode"] as? Int ?? 0
            let field = Playground(name: name, address: addressField, latitude: latitudeField, longitude: longitudeField, zipcode: zipcodeField)
            
            array.append(field)
            completion(array)
        }
        
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() {
            centerMapOnUserLocation()
        } else {
            let alert = UIAlertController(title: "Location Services", message: "Your location services is off. Please go to Setting > Privacy > Location Serices and turn it on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open Setting", style: .cancel, handler: { (result) in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        print("button pressed: \(centerLocationBT.isTouchInside)")
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            self.reverseGeoLocation(location: CLLocation(latitude: lat, longitude: lon))
        }
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
        if error != nil {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
}

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: previousLocation) > (regionInMeters / 2) else { return }
        self.previousLocation = center
        
        reverseGeoLocation(location: center)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellReusable", for: indexPath) as! HomeCollectionViewCell
        setupCell(cell: cell)
        
        cell.image.layer.cornerRadius = (cell.image.frame.height / 3) * cornerRadius
        cell.image.clipsToBounds = true
        cell.starButton.layer.cornerRadius = cell.starButton.frame.height * cornerRadius
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "playgroundSegue", sender: self)
    }
    
    func setupCell(cell: UICollectionViewCell) {
        let screenSize = UIScreen.main.bounds.size
        let cellScaleX: CGFloat = 0.9
        let cellScaleY: CGFloat = 0.3
        let cellWidth = floor(screenSize.width * cellScaleX)
        let cellHeight = floor(screenSize.height * cellScaleY)
        let insetX = (view.bounds.width - cellWidth) / 2
        let insetY = (view.bounds.width - cellHeight) / 2
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    
    }
}

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.text?.isEmpty == false {
            beginSearch()
            textField.text = nil
            textField.placeholder = "Search Playground"
        }
        
        return true
    }
    
    func setupTextField() {
        searchTextField.delegate = self
    }
    
    private func TextFieldTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldTap))
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func handleTextFieldTap() {
        view.endEditing(true)
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    
}

