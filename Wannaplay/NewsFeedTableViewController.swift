//
//  NewsFeedTableViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 26/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit
import MapKit

final class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subTitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subTitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle

        super.init()
    }

    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        return MKCoordinateRegion(center: coordinate, span: span)
    }

}

class NewsFeedCellTableViewController: UITableViewCell {
    
    @IBOutlet var imageProfile: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var starBT: UIButton!
    @IBOutlet weak var commentBT: UIButton!
    @IBOutlet weak var shareBT: UIButton!
    private var isLiked: Bool = false
    
    @IBAction func starBTTapped(_ sender: UIButton) {
        starBT.setImage(#imageLiteral(resourceName: "star solid yellow"), for: .selected)
        starBT.setImage(#imageLiteral(resourceName: "star solid black"), for: .normal)
        
        if isLiked == false {
            starBT.isSelected = true
            isLiked = true
        } else {
            starBT.isSelected = false
            isLiked = false
        }
    }
    
    @IBAction func commentBTTapped(_ sender: UIButton) {
    }
    
}

class NewsFeedTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func handleImageViewTapped() {
       performSegue(withIdentifier: "userSegue", sender: nil)
    }
    
    @objc func handleShareTapped() {
        let shareString = "String to share"
        let shareActicity = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        shareActicity.popoverPresentationController?.sourceView = self.view
        self.present(shareActicity, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellReusable"
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleImageViewTapped))
        let myCoordinate = CLLocationCoordinate2D(latitude: 44.489412, longitude: 11.388119)
        let myAnnotation = Annotation(coordinate: myCoordinate, title: "Hello", subTitle: "world")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NewsFeedCellTableViewController
        
        tableView.rowHeight = 180
        cell.mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        cell.mapView.addAnnotation(myAnnotation)
        cell.mapView.setRegion(myAnnotation.region, animated: true)
        
        cell.imageProfile.isUserInteractionEnabled = true
        cell.imageProfile.addGestureRecognizer(gesture)
        cell.shareBT.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension NewsFeedTableViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            annotation.animatesWhenAdded = true
            annotation.titleVisibility = .visible

            return annotation
        }

        return nil
    }
}
