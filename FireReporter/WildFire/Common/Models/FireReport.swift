//
//  FireReport.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 17.10.23.
//

import Foundation
import Firebase

struct FireReport : Codable {
    var id: String
    var uniqueIdentifier: String
    var photo: String?
    var lat: Double
    var long: Double
    var description:String?
    var date: Date
    var address: String?
    var votes: Int
    var createdByVerifiedUser: Bool
    var country: String?
 
    
    var dictionary: [String: Any] {
        return ["id":id,
                "timestamp":Timestamp(date: date),
                "lat": lat,
                "long": long,
                "photo": photo ?? "",
                "uniqueIdentifier": uniqueIdentifier,
                "description": description ?? "",
                "address": address ?? "",
                "votes":votes,
                "createdByVerifiedUser": createdByVerifiedUser,
                "country": country ?? ""
        ]
       }
    
    init(description: String? = nil, id: String, lat: Double = 0.00, long: Double = 0.00, photo: String, timestamp: Date, uniqueIdentifier:String, address:String?, votes:Int,createdByVerifiedUser:Bool, country:String) {
        self.description = description
        self.id = id
        self.lat = lat
        self.long = long
        self.photo = photo
        self.date = timestamp
        self.uniqueIdentifier = uniqueIdentifier
        self.address = address
        self.votes = votes
        self.createdByVerifiedUser = createdByVerifiedUser
        self.country = country
    }
    
    enum CodingKeys: CodingKey {
        case description
        case id
        case lat
        case long
        case photo
        case date
        case uniqueIdentifier
        case address
        case votes
        case createdByVerifiedUser
        case country
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.id = try container.decode(String.self, forKey: .id)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.long = try container.decode(Double.self, forKey: .long)
        self.photo = try container.decodeIfPresent(String.self, forKey: .photo)
        self.date = try container.decode(Date.self, forKey: .date)
        self.uniqueIdentifier = try container.decode(String.self, forKey: .uniqueIdentifier)
        self.address = try container.decode(String.self, forKey: .address)
        self.votes = try container.decode(Int.self, forKey: .votes)
        self.createdByVerifiedUser = try container.decode(Bool.self, forKey: .createdByVerifiedUser)
        self.country = try container.decode(String.self, forKey: .country)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.lat, forKey: .lat)
        try container.encode(self.long, forKey: .long)
        try container.encodeIfPresent(self.photo, forKey: .photo)
        try container.encode(self.date.timeIntervalSince1970, forKey: .date)
        try container.encode(self.uniqueIdentifier, forKey: .uniqueIdentifier)
        try container.encode(self.address, forKey: .address)
        try container.encode(self.votes, forKey: .address)
        try container.encode(self.createdByVerifiedUser, forKey: .createdByVerifiedUser)
        try container.encode(self.country, forKey: .country)
    }
}
