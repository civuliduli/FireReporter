//
//  FinalReportViewModel.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 14.10.23.
//

import Foundation
import CoreLocation

class FinalReportViewModel{
    
    var locationManager = CLLocationManager()
    
    func configureLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
