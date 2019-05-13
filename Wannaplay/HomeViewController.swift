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


class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var qrCodeBT: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var centerLocationBT: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let locationManager = CLLocationManager()
    private let regionInMeters: Double = 5000
    private let cornerRadius: CGFloat = 0.28
    private let geoCoder = CLGeocoder()
    private var previousLocation: CLLocation?
    private var nation: String?
    private var state: String?
    private var region: String?
    private var city: String?
    private var selectedIndex: Int!
    private var fieldsAround = [Playground]()
    let dispatchGroup = DispatchGroup()
    
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
        
        emptyView.clipsToBounds = true
        emptyView.layer.cornerRadius = emptyView.frame.height * cornerRadius
        emptyView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
        locationManager.requestLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        centerMapOnUserLocation()
    }
    
    func centerMapOnUserLocation() {
        if let location =  locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            let lastLocation = locationManager.location
            
            previousLocation = lastLocation
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getMapViewCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude

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
                self?.nation = placemark.country?.lowercased()
                self?.state = placemark.administrativeArea?.lowercased()
                self?.region = placemark.subAdministrativeArea?.lowercased()
                self?.city = placemark.locality?.lowercased()
                
                self?.fetchPlaygroundName(nation: self?.nation! ?? "nil", state: self?.state! ?? "nil", region: self?.region! ?? "nil", city: self?.city! ?? "nil")
                
                //print("\n\nNation: \(self?.nation!), State: \(self?.state!), region: \(self?.region!), city: \(self?.city!)")
                //print("fieldsAround.count = \(self?.fieldsAround.count)")
            }
        }
        
    }
    
    func usStateEncoding(stateToTest: String) -> String {
        var newState: String?
        let statesDictionary = [ "AL":"Alabama","AK":"Alaska","AZ":"Arizona","AR":"Arkansas",
                                 "CA":"California","CO":"Colorado","CT":"Connecticut","DE":"Delaware","DC":"District of Columbia",
                                 "FL":"Florida","GA":"Georgia","HI":"Hawaii","ID":"Idaho","IL":"Illinois","IN":"Indiana","IA":"Iowa",
                                 "KS":"Kansas","KY":"Kentucky","LA":"Louisiana","ME":"Maine","MD":"Maryland","MA":"Massachusetts","MI":"Michigan",
                                 "MN":"Minnesota","MS":"Mississippi","MO":"Missouri","MT":"Montana",
                                 "NE":"Nebraska","NV":"Nevada","NH":"New Hampshire","NJ":"New Jersey","NM":"New Mexico","NY":"New York","NC":"North Carolina","ND":"North Dakota",
                                 "OH":"Ohio","OK":"Oklahoma","OR":"Oregon","PA":"Pennsylvania","RI":"Rhode Island","SC":"South Carolina","SD":"South Dakota",
                                 "TN":"Tennessee","TX":"Texas","UT":"Utha","VT":"Vermont","VA":"Virginia","WA":"Washington","WV":"West Virginia","WI":"Wisconsin","WY":"Wyoming"
                                ]
        
        for (key, value) in statesDictionary {
            if key == stateToTest.uppercased() {
                print("value: \(value)")
                newState = value.lowercased()
                break
            } else {
                newState = stateToTest
            }
        }
        
        return newState!
    }
    
    private func fetchPlaygroundName(nation: String, state: String, region: String, city: String)  {
        let dbRef = Database.database().reference().child("playgrounds")
        let newState = usStateEncoding(stateToTest: state)
        
        print("newState: \(newState)")
        
        dbRef.child(nation).child(newState).child(region).child(city).observe(.value, with: { (snapshot) in
            print("snapshot: ", snapshot)
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let name = child.key
                self.fetchPlaygroundData(nation: nation, state: newState, region: region, city: city, name: name)
            }
        }, withCancel: nil)
    }

    func fetchPlaygroundData(nation: String, state: String, region: String, city: String, name: String) {
        let dbRef = Database.database().reference().child("playgrounds")
        
        dbRef.child(nation).child(state).child(region).child(city).child(name).observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? [String:AnyObject] {
                let field = Playground()
                //let fieldID = "" //need to implement a fieldID
                let addressField = data["address"]
                let latitudeField = data["latitude"]
                let longitudeField = data["longitude"]
                let zipcodeField = data["zipcode"]
                
                field.nation = nation.capitalized
                field.state = state.capitalized
                field.region = region.capitalized
                field.city = city.capitalized
                field.address = (addressField as! String).capitalized
                field.name = name.capitalized
                field.latitude = (latitudeField as! Double)
                field.longitude = (longitudeField as! Double)
                field.zipcode = (zipcodeField as! Int)
                
                self.fieldsAround.append(field)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }, withCancel: nil)
        
        
    }
    
    func showEmptyView(isHidden: Bool){
        if isHidden {
            emptyView.isHidden = true
            self.collectionView.isHidden = false
        } else {
            emptyView.isHidden = false
            self.collectionView.isHidden = true
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playgroundSegue" {
            let vc = segue.destination as! PlaygroundViewController
            
            guard let address = fieldsAround[selectedIndex].address else { return }
            guard let name = fieldsAround[selectedIndex].name else { return }
            guard let zipcode = fieldsAround[selectedIndex].zipcode else { return }
            guard let city = fieldsAround[selectedIndex].city else { return }
            guard let nation = fieldsAround[selectedIndex].nation else { return }
            guard let latitude = fieldsAround[selectedIndex].latitude else { return }
            guard let longitude = fieldsAround[selectedIndex].longitude else { return }
            
            
            //if the data will be presented in the new view it need to be wrapped into dispatch
            DispatchQueue.main.async {
                //vc.setupAnnotationOnMap(latitude: latitude, longitude: longitude)
                vc.nameLabel?.text = name
                vc.addressLabel?.text = address + ", " + String(zipcode) + ", " + city + ", " + nation
            }
            
            //otherwise can be passed normally
            vc.latitude = latitude
            vc.longitude = longitude
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
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

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getMapViewCenterLocation(for: mapView)
        guard let lastLocation = previousLocation else { return }
        
        if center.distance(from: lastLocation) > (regionInMeters / 2)  {
            let newCenter = getMapViewCenterLocation(for: mapView)
            previousLocation = newCenter
            reverseGeoLocation(location: newCenter)
            print("\nRegion changed\n")
        } else {
            print("\nRegion did not change\n")
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fieldsAround.isEmpty {
            showEmptyView(isHidden: false)
            return 0
        } else {
            showEmptyView(isHidden: true)
            collectionView.backgroundView = nil
            return fieldsAround.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellReusable", for: indexPath) as! HomeCollectionViewCell
        setupCell(cell: cell)
        let field = fieldsAround[indexPath.row]
        
        //cell.image = field.image
        cell.nameLabel.text = field.name
        cell.locationLabel.text = field.address
        
        cell.image.layer.cornerRadius = (cell.image.frame.height / 3) * cornerRadius
        cell.image.clipsToBounds = true
        cell.starButton.layer.cornerRadius = cell.starButton.frame.height * cornerRadius
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
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

