//
//  UserReportedLocationsViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 20.10.23.
//

import UIKit
import MapKit
import CoreLocation

class CustomPointAnnotation: MKPointAnnotation {
    var imageString: String!
    var ID: String?
    var likes: Int?
    var votedFor:Bool?
    var custom_image: Bool = true
}

class UserReportedLocationsViewController: UIViewController, MKMapViewDelegate {
    
    
    private let firebaseService = FirebaseService()
    private let keychainService = KeychainService()

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    var iVoted: Bool?
    let annotation = MKPointAnnotation()
    var coordinates: CLLocationCoordinate2D?
    var myLocations = [FireReport]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapUI()
        getAllReports()
        self.mapView.delegate = self
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllReports()
    }
    
    func getAllReports(){
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        firebaseService.getAllReportsLocations { [self] myFireReports, error in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.myLocations = myFireReports
            for data in self.myLocations{
                let annotation = CustomPointAnnotation()
                annotation.ID = data.id
                annotation.likes = data.votes
                annotation.imageString = data.photo
                annotation.title = data.description
                annotation.coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
                   mapView.addAnnotation(annotation)
                if let annotationView = mapView.view(for: annotation) as? MKMarkerAnnotationView {
                    if let likes = annotation.likes {
                        if likes == 0 {
                            annotationView.markerTintColor = .blue
                        } else if likes <= 10 {
                            annotationView.markerTintColor = .yellow
                        } else {
                            annotationView.markerTintColor = .red
                        }
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? CustomPointAnnotation {
            let finalReportVC = FinalReportViewController()
            finalReportVC.descriptionText = (annotation.title ?? "") 
            finalReportVC.coordinates = annotation.coordinate
            finalReportVC.imageURL = annotation.imageString ?? ""
            finalReportVC.isConfirmButtonHidden = true
            finalReportVC.isTextFieldEditable = false
            finalReportVC.issubmitVoteHidden = false
            finalReportVC.isvotingDescriptionHidden = false
            finalReportVC.isVoteForHidden = false
            finalReportVC.isVoteAgainstHidden = false
            finalReportVC.voteInfo.text = "\(String(describing: annotation.likes!))"
            finalReportVC.votes = annotation.likes
            finalReportVC.ID = annotation.ID
            mapView.deselectAnnotation(view.annotation, animated: false)
            present(finalReportVC, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           let identifier = "Location"
           if let customAnnotation = annotation as? CustomPointAnnotation {
               var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
               if annotationView == nil {
                   annotationView = MKMarkerAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
                   annotationView?.canShowCallout = true
               } else {
                   annotationView?.annotation = annotation
               }

               if let likes = customAnnotation.likes {
                   if likes == 0 {
                       (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .blue
                   } else if likes <= 10 {
                       (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .yellow
                   } else {
                       (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .red
                   }
               }

               return annotationView
           }

           return nil
       }
    
    func setupMapUI(){
        view.addSubview(mapView)
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
