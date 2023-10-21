//
//  UserReportedLocationsViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 20.10.23.
//

import UIKit
import MapKit
import CoreLocation

class UserReportedLocationsViewController: UIViewController {
    
    let annotation = MKPointAnnotation()
    var coordinates: CLLocationCoordinate2D?
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapUI()
        view.backgroundColor = .systemBlue
    }
    
    
    func setupMapUI(){
        view.addSubview(mapView)
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
