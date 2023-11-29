//
//  FirebaseService.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 21.10.23.
//

import Foundation
import FirebaseFirestore


class FirebaseService {
    var reportsArray = [FireReport]()
    
    func getFireReportsData(completion: @escaping(_ myFireReports: [FireReport], Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("reports").whereField("uniqueIdentifier", isEqualTo: UIDevice.current.identifierForVendor!.uuidString).getDocuments { querrySnapshot, error in
            guard let documents = querrySnapshot?.documents else {print("No Documents")
                return}
            self.reportsArray = documents.map({ querryDocumentSnapshot in
                let data = querryDocumentSnapshot.data()
                let timestamp = data["timestamp"] as? Timestamp
                return FireReport(description: data["description"] as? String,id:"",lat: data["lat"] as? Double ?? 0.0, long: data["long"] as? Double ?? 0.0, photo: data["photo"] as? String ?? "pictureNotAvailable", timestamp: timestamp?.dateValue() ?? Date(), uniqueIdentifier: data["uniqueIdentifier"] as? String ?? "", address: data["address"] as? String, votes: data["votes"] as? Int ?? 0, createdByVerifiedUser: (data["createdByVerifiedUser"] != nil), country: data["country"] as? String ?? "" )
            })
            completion(self.reportsArray, error)
        }
    }
    
    func getAllReportsLocations(completion: @escaping(_ myFireReports: [FireReport], Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("reports").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error ?? "Unknown error" as! Error)")
                completion([], error)
                return
            }

            let mapLocationsArray = documents.map { queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                let timestamp = data["timestamp"] as? Timestamp

                return FireReport(
                    description: data["description"] as? String,
                    id: data["id"] as? String ?? "",
                    lat: data["lat"] as? Double ?? 0.0,
                    long: data["long"] as? Double ?? 0.0,
                    photo: data["photo"] as? String ?? "pictureNotAvailable",
                    timestamp: timestamp?.dateValue() ?? Date(),
                    uniqueIdentifier: data["uniqueIdentifier"] as? String ?? "",
                    address: "",
                    votes: data["votes"] as? Int ?? 0,
                    createdByVerifiedUser: (data["createdByVerifiedUser"] != nil),
                    country: data["country"] as? String ?? ""
                )
            }

            completion(mapLocationsArray, nil)
        }
    }

    
//    func getAllReportsLocations(completion: @escaping(_ myFireReports: [FireReport], Error?) -> Void){
//        let db = Firestore.firestore()
//        var mapLocationsArray = [FireReport]()
//        db.collection("reports").getDocuments { querrySnapshot, error in
//            guard let documents = querrySnapshot?.documents else {print("No Documents")
//                return}
//            mapLocationsArray = documents.map({ querryDocumentSnapshot in
//                let data = querryDocumentSnapshot.data()
//                let timestamp = data["timestamp"] as? Timestamp
//                return FireReport(description: data["description"] as? String,id: data["id"] as? String ?? "",lat: data["lat"] as? Double ?? 0.0, long: data["long"] as? Double ?? 0.0, photo:data["photo"] as? String ?? "pictureNotAvailable", timestamp: timestamp?.dateValue() ?? Date(), uniqueIdentifier: data["uniqueIdentifier"] as? String ?? "", address: "", votes: data["votes"] as? Int ?? 0, createdByVerifiedUser: (data["createdByVerifiedUser"] != nil), country: data["country"] as? String ?? "")
//            })
//            completion(mapLocationsArray, error)
//        }
//    }
}
