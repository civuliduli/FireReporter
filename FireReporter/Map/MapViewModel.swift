//
//  MapViewModel.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 14.10.23.
//

import Foundation
import CoreLocation

class MapViewModel{
    
    let locationManager = CLLocationManager()
    
    func configureLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerAuthorization(onDenial: @escaping () -> Void){
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
            switch manager.authorizationStatus{
            case .authorizedAlways:
                break
            case .notDetermined:
                break
            case .restricted:
                break
            case .authorizedWhenInUse:
                break
            case .denied:
                onDenial()
            @unknown default:
                print("Give permission please")
            }
        }
    }
    
    func updateLocation(onUpdate: @escaping(_ location:CLLocation) -> Void){
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
            if let location = locations.first {
                let locationManager = CLLocationManager()
                locationManager.stopUpdatingLocation()
                onUpdate(location)
            }
        }
    }
    
    
}
