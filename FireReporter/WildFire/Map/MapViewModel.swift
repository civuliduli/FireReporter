//
//  MapViewModel.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 14.10.23.
//

import Foundation
import CoreLocation
import MapKit

class MapViewModel: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager, onDenial: @escaping () -> Void){
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
