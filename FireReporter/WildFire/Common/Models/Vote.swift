//
//  Vote.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 30.10.23.
//

import Foundation
import FirebaseFirestore


struct Vote: Codable{
    var createdAt: Date
    var documentID:String
    var quantity: Int
    var userID: String
    var createdByVerifiedUser: Bool
    
    
    
    var dictionary: [String: Any] {
        return [
            "createdAt":createdAt,
            "documentID":documentID,
            "quantity":quantity,
            "userID":userID,
            "createdByVerifiedUser": createdByVerifiedUser
        ]
       }
}


