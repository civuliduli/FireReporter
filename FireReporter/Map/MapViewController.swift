//  MapViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 6.10.23.
//
//
import CoreLocation
import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    private let mapViewModel = MapViewModel()

    let annotationView = MKMarkerAnnotationView()
    var confirmButton = UIButton(type:.system)
    let locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    let annotation = MKPointAnnotation()
    var firePlace = UIImage()

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapUI()
        confirmButtonDesign()
        configureLocationManager()
        locationManagerAuthorization()
    }

    func locationManagerAuthorization(){
        mapViewModel.locationManagerDidChangeAuthorization(locationManager) {
            self.present(Alert(text: "Location Denied!", message: "To allow FireManager report fire locations please give access to location in settings", confirmAction: [UIAlertAction(title: "Go to settings", style: .default, handler: { action in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })], disableAction: [UIAlertAction(title: "Cancel", style: .cancel)]))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            pinUserLocation(location)
            coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func pinUserLocation(_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }

    func configureLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        annotation.coordinate = touchMapCoordinate
        coordinates = touchMapCoordinate
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinates!, span: span)
        mapView.setRegion(region, animated: true)
    }

    @objc func removeAnnotations(_ gestureRecognizer: UIGestureRecognizer){
        mapView.annotations.forEach { annotation in
            coordinates = nil
            self.mapView.removeAnnotation(annotation)
        }
    }

    @objc func confirmReport(){
        if (coordinates == nil) {
            present(Alert(text: "Alert!", message: "Please mark a fire location", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
        } else {
            let finalReportVC = FinalReportViewController()
            finalReportVC.coordinates = coordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            finalReportVC.fireImage = firePlace
            navigationController?.pushViewController(finalReportVC, animated: false)
        }
    }

    @objc func userInfo(){
        present(Alert(text: "Info!", message:"In order to mark a location long press a desired location. To remove just press the location mark", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
    }

   private func setupMapUI(){
       view.addSubview(mapView)
       mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
       mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
       mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
       navigationItem.rightBarButtonItem = UIBarButtonItem(title: "info", image: UIImage(systemName:"info.circle"), target: self, action: #selector(userInfo))
       let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
       let removeAnnotation = UITapGestureRecognizer(target:self, action: #selector(removeAnnotations(_:)))
       longPressRecognizer.minimumPressDuration = 0.5
       mapView.addGestureRecognizer(removeAnnotation)
       mapView.addGestureRecognizer(longPressRecognizer)
    }

    private func confirmButtonDesign(){
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Confirm Report", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        confirmButton.backgroundColor = .white
        confirmButton.layer.cornerRadius = 10
        confirmButton.center = self.view.center
        confirmButton.addTarget(self, action: #selector(confirmReport), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-35).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true

     }
    }












//  MapViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 6.10.23.


//import CoreLocation
//import UIKit
//import MapKit
//
//class MapViewController: UIViewController, CLLocationManagerDelegate {
//    
//    private let mapViewModel = MapViewModel()
//
//    var confirmButton: UIButton!
//    let annotation = MKPointAnnotation()
//    let annotationView = MKMarkerAnnotationView()
//    var coordinates: CLLocationCoordinate2D?
//    var firePlace = UIImage()
//    let locationManager = CLLocationManager()
//
//    lazy var mapView: MKMapView = {
//        let map = MKMapView()
//        map.translatesAutoresizingMaskIntoConstraints = false
//        return map
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupMapUI()
//        confirmButtonDesign()
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        let removeAnnotation = UITapGestureRecognizer(target:self, action: #selector(removeAnnotations(_:)))
//        longPressRecognizer.minimumPressDuration = 0.5
//        mapView.addGestureRecognizer(removeAnnotation)
//        mapView.addGestureRecognizer(longPressRecognizer)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "info", image: UIImage(systemName:"info.circle"), target: self, action: #selector(userInfo))
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManagerDidChangeAuthorization(locationManager)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//    }
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus{
//        case .authorizedAlways:
//            break
//        case .notDetermined:
//            break
//        case .restricted:
//            break
//        case .authorizedWhenInUse:
//            break
//        case .denied:
//            present(Alert(text: "Location Denied!", message: "To allow FireManager report fire locations please give access to location in settings", confirmAction: [UIAlertAction(title: "Go to settings", style: .default, handler: { action in
//                if let url = URL(string: UIApplication.openSettingsURLString) {
//                    if UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//                }
//            })], disableAction: [UIAlertAction(title: "Cancel", style: .cancel)]))
//        @unknown default:
//            print("Give permission please")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            locationManager.stopUpdatingLocation()
//            pinUserLocation(location)
//            coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            print(coordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
//        }
//    }
//
//    func pinUserLocation(_ location: CLLocation){
//        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
//
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
//        mapView.setRegion(region, animated: true)
//
//        annotation.coordinate = coordinate
//        mapView.addAnnotation(annotation)
//    }
//
//
//    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer){
//        if gestureRecognizer.state != .began { return }
//
//        let touchPoint = gestureRecognizer.location(in: mapView)
//        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//        
//
//        annotation.coordinate = touchMapCoordinate
//        coordinates = touchMapCoordinate
//        print("\(annotation.coordinate) my coordinates")
//        mapView.addAnnotation(annotation)
//        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        let region = MKCoordinateRegion(center: coordinates!, span: span)
//        mapView.setRegion(region, animated: true)
//    }
//
//    @objc func removeAnnotations(_ gestureRecognizer: UIGestureRecognizer){
//        mapView.annotations.forEach { annotation in
//            coordinates = nil
//            self.mapView.removeAnnotation(annotation)
//        }
//    }
//
//
//    @objc func confirmReport(){
//        if (coordinates == nil) {
//            present(Alert(text: "Alert!", message: "Please mark a fire location", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
//        } else {
//            let finalReportVC = FinalReportViewController()
//            finalReportVC.coordinates = coordinates ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//            finalReportVC.fireImage = firePlace
//            navigationController?.pushViewController(finalReportVC, animated: false)
//            print(annotation.coordinate)
//            print("\(String(describing: coordinates)) after mapview")
//        }
//    }
//
//    @objc func userInfo(){
//        present(Alert(text: "Info!", message:"In order to mark a location long press a desired location. To remove just press the location mark", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
//    }
//
//   private func setupMapUI(){
//       view.addSubview(mapView)
//       mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//       mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//       mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//       mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//    }
//
//    private func confirmButtonDesign(){
//        confirmButton = UIButton(type:.system)
//        confirmButton.translatesAutoresizingMaskIntoConstraints = false
//        confirmButton.setTitle("Confirm Report", for: .normal)
//        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
//        confirmButton.backgroundColor = .white
//        confirmButton.layer.cornerRadius = 10
//        confirmButton.center = self.view.center
//        confirmButton.addTarget(self, action: #selector(confirmReport), for: .touchUpInside)
//        view.addSubview(confirmButton)
//        confirmButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-35).isActive = true
//        confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35).isActive = true
//        confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120).isActive = true
//
//     }
//    }
