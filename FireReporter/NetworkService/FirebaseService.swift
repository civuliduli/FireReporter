//
//  FirebaseService.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 21.10.23.
//

import Foundation
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
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
                let uniqueIdentifier = data["uniqueIdentifier"] as? String? ?? ""
                let description = data["description"] as? String? ?? ""
                let lat = data["lat"] as? Double? ?? 0.00
                let long = data["long"] as? Double? ?? 0.00
                let timestamp = data["timestamp"] as? Timestamp
                let photo = data["photo"] as? String? ?? "androidKiller"
                let address = data["address"] as? String
                let votes = data["votes"] ?? 0
                return FireReport(description: description,id:"",lat: lat ?? 0.00, long: long ?? 0.00, photo:photo ?? "androidKiller", timestamp: timestamp?.dateValue() ?? Date(), uniqueIdentifier: uniqueIdentifier ?? "", address:address, votes: votes as! Int)
            })
            completion(self.reportsArray, error)
        }
    }
    
    func getAllReportsLocations(completion: @escaping(_ myFireReports: [FireReport], Error?) -> Void){
        let db = Firestore.firestore()
        var mapLocationsArray = [FireReport]()
        db.collection("reports").getDocuments { querrySnapshot, error in
            guard let documents = querrySnapshot?.documents else {print("No Documents")
                return}
            mapLocationsArray = documents.map({ querryDocumentSnapshot in
                let data = querryDocumentSnapshot.data()
                let uniqueIdentifier = data["uniqueIdentifier"] as? String? ?? ""
                let description = data["description"] as? String? ?? ""
                let lat = data["lat"] as? Double? ?? 0.00
                let long = data["long"] as? Double? ?? 0.00
                let timestamp = data["timestamp"] as? Timestamp
                let photo = data["photo"] as? String? ?? "androidKiller"
                let votes = data["votes"] as? Int ?? 0
                let id = data["id"] as? String ?? ""
                return FireReport(description: description,id:id,lat: lat ?? 0.00, long: long ?? 0.00, photo:photo ?? "androidKiller", timestamp: timestamp?.dateValue() ?? Date(), uniqueIdentifier: uniqueIdentifier ?? "", address: "", votes: votes)
            })
            completion(mapLocationsArray, error)
        }
    }
    
    
    func googleAuth(onError:@escaping () -> Void, onSuccess:@escaping () -> Void, onAuthError: @escaping () -> Void){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    print("there is no root view controller")
                    return
                }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {authentication, error in
            if error != nil {
                onError()
                return
            }
            guard let user = authentication?.user, let idToken = user.idToken?.tokenString else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil {
                    onAuthError()
                } else {
                    onSuccess()
                }
            }
        }
    }
    
    func facebookAuth(onError:@escaping () -> Void, onSuccess:@escaping() -> Void){
//        if error != nil {
//            onError()
//        return
//        }
        if (AccessToken.current != nil) {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    onError()
                    return
                }
                onSuccess()
            }
        } else {
            onError()
            print("there is no token for the user")
        }
    }
}
