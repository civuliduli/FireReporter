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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllReports()
    }
    
    func getAllReports(){
        firebaseService.getAllReportsLocations { [self] myFireReports, error in
            self.myLocations = myFireReports
            for data in self.myLocations{
                let annotation = CustomPointAnnotation()
                annotation.ID = data.id
                annotation.likes = data.votes
                annotation.imageString = data.photo
                annotation.title = data.description
                annotation.coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
                   mapView.addAnnotation(annotation)
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
            finalReportVC.collectionVotes = annotation.likes ?? 0
            print(annotation.likes)
            finalReportVC.ID = annotation.ID
            present(finalReportVC, animated: true)
            }
     }
     
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         let identifier = "Location"

             if let customAnnotation = annotation as? CustomPointAnnotation {
                 var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

                 if annotationView == nil {
                     // Create a custom annotation view
                     annotationView = MKMarkerAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)

                     // Customize the annotation view
                     if let likes = customAnnotation.likes {
                         if likes == 0{
                             (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .blue
                         } else if likes <= 10 {
                             (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .yellow
                         } else if likes >= 10 {
                             (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .red
                         }
                     }

                     annotationView?.canShowCallout = true
                 } else {
                     annotationView?.annotation = annotation
                 }

                 return annotationView
             }

             return nil     }
     
     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
     }

    
    func setupMapUI(){
        view.addSubview(mapView)
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}









//
//  UserReportedLocationsViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 20.10.23.
//

//import UIKit
//import MapKit
//import CoreLocation
//
//class CustomPointAnnotation: MKPointAnnotation {
//    var imageString: String!
//    var ID: String?
//    var likes: Int?
//    var votedFor:Bool?
//    var custom_image: Bool = true
//}
//
//class UserReportedLocationsViewController: UIViewController, MKMapViewDelegate {
//    
//    private let firebaseService = FirebaseService()
//    lazy var mapView: MKMapView = {
//        let map = MKMapView()
//        map.translatesAutoresizingMaskIntoConstraints = false
//        return map
//    }()
//    
//    var iVoted: Bool?
//    
//    let annotation = MKPointAnnotation()
//    var coordinates: CLLocationCoordinate2D?
//    var myLocations = [FireReport]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupMapUI()
//        getAllReports()
//        self.mapView.delegate = self
//        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//    }
//    
//    func getAllReports(){
//        firebaseService.getAllReportsLocations { [self] myFireReports, error in
//            self.myLocations = myFireReports
//            for data in self.myLocations{
//                let annotation = CustomPointAnnotation()
//                print(data.id)
//                print(data.likes)
//                annotation.ID = data.id
//                annotation.likes = data.likes
//                annotation.imageString = data.photo
//                annotation.title = data.description
//                annotation.coordinate = CLLocationCoordinate2D(latitude: data.lat, longitude: data.long)
//                
//                for users in data.users {
//                               // Check if the users array is not nil
//                    print(users.votedFor)
//                           }
//                
//                   mapView.addAnnotation(annotation)
//            }
//        }
//    }
//    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let annotation = view.annotation as? CustomPointAnnotation {
//            let finalReportVC = FinalReportViewController()
//            finalReportVC.descriptionText = (annotation.title ?? "")
//            finalReportVC.coordinates = annotation.coordinate
//            finalReportVC.imageURL = annotation.imageString ?? ""
//            finalReportVC.isConfirmButtonHidden = true
//            finalReportVC.isTextFieldEditable = false
//            finalReportVC.issubmitVoteHidden = false
//            finalReportVC.isvotingDescriptionHidden = false
//            finalReportVC.isVoteForHidden = false
//            finalReportVC.isVoteAgainstHidden = false
//            finalReportVC.voteInfo.text = "\(String(describing: annotation.likes!))"
//            finalReportVC.votes = annotation.likes
//            print(annotation.likes)
//            finalReportVC.ID = annotation.ID
//            finalReportVC.votedFor = annotation.votedFor
//            print(annotation.votedFor ?? true)
//            present(finalReportVC, animated: true)
//            }
//     }
//     
//     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//         let identifier = "Location"
//         
//         
//         var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//         if annotationView == nil {
//             annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//             annotationView?.canShowCallout = true
//         } else {
//             annotationView?.annotation = annotation
//         }
//         return annotationView
//     }
//     
//     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
// //        guard let capital = view.annotation as? Capital else { return }
// //        let placeName = capital.title
// //        let annotation = CustomPointAnnotation()
// //
// //        let placeInfo = annotation.title ?? ""
// //        let tag = annotation.tag ?? ""
// //
// //        present(Alert(text: placeInfo, message: tag, confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
//     }
//
//    
//    func setupMapUI(){
//        view.addSubview(mapView)
//        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//    }
//}
