//
//  FinalReportViewModel.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 14.10.23.
//

import Foundation
import CoreLocation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class FinalReportViewModel{
    
    var locationManager = CLLocationManager()
    var addressName: String?
    
    func configureLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func convertImageToBase64String (img:UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
    
    func convertBase64ToImage(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func convertLatLongToAddress(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                completion("Address is not available")
            } else if let placeMark = placemarks?.first, let city = placeMark.locality {
                completion(city)
            } else {
                completion("Address is not available")
            }
        }
    }
    
    // TODO: Set a spinner while waiting for data to be sent
    func sendReport(fireReport:FireReport, fireImage: UIImage, success:@escaping ()-> Void, error:@escaping ()-> Void){
        convertLatLongToAddress(latitude: fireReport.lat, longitude: fireReport.long) { [self] locationName in
            self.addressName = locationName
            var isCreatedVerifiedUser: Bool!
            var isUserVerified: Bool!
            isUserVerified = Auth.auth().currentUser?.isEmailVerified
            var votes = 0
            if isUserVerified == nil || isUserVerified == false{
                votes += 1
                isCreatedVerifiedUser = false
            } else {
                votes += 10
                isCreatedVerifiedUser = true
            }
            let myCompressedImage = convertImageToBase64String(img: fireImage)
            let db = Firestore.firestore()
            let fireReport = FireReport(description: fireReport.description, id:fireReport.id, lat: fireReport.lat, long: fireReport.long, photo: myCompressedImage, timestamp: fireReport.date, uniqueIdentifier: UIDevice.current.identifierForVendor!.uuidString, address: locationName, votes:votes, createdByVerifiedUser: isCreatedVerifiedUser)
            print(fireReport)
            db.collection("reports").document(fireReport.id).setData(fireReport.dictionary) { err in
                if err != nil {
                    error()
                    return
                } else {
                    success()
                    if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
                        scene.photoState = .completed
                    }
                }
            }
        }
    }
    
    func getQuantity(id: String?, completion: @escaping (Int?) -> Void){
           let db = Firestore.firestore()
        db.collection("reports").document(id ?? "").collection("Votes").whereField("userID", isEqualTo: Auth.auth().currentUser?.uid ?? "").getDocuments { votesQuantity, error in
               guard let documents = votesQuantity?.documents else {
                   print("No Documents")
                   completion(nil)
                   return
               }
               if let quantity = documents.first?.data()["quantity"] as? Int {
                   completion(quantity)
               } else {
                   completion(nil)
               }
           }
    }
    
}

