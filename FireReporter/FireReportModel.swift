//
//  FireReportModel.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 17.10.23.
//

import Foundation
import Firebase

struct FireReportModel : Codable {
    var description:String?
    var id: Int
    var lat: Double
    var long: Double
    var photo: String?
    var date: Date
    var uniqueIdentifier: String
 
    
    var dictionary: [String: Any] {
        return ["id":id,
                "timestamp":Timestamp(date: date),
                "lat": lat,
                "long": long,
                "photo": photo ?? "",
//                "date": date,
                "uniqueIdentifier": uniqueIdentifier,
                "description": description ?? ""
        ]
       }
    
    init(description: String? = nil, id: Int, lat: Double = 0.00, long: Double = 0.00, photo: String, timestamp: Date, uniqueIdentifier:String) {
        self.description = description
        self.id = id
        self.lat = lat
        self.long = long
        self.photo = photo
        self.date = timestamp
        self.uniqueIdentifier = uniqueIdentifier
    }
    
    enum CodingKeys: CodingKey {
        case description
        case id
        case lat
        case long
        case photo
        case date
        case uniqueIdentifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.id = try container.decode(Int.self, forKey: .id)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.long = try container.decode(Double.self, forKey: .long)
        self.photo = try container.decodeIfPresent(String.self, forKey: .photo)
        self.date = try container.decode(Date.self, forKey: .date)
        self.uniqueIdentifier = try container.decode(String.self, forKey: .uniqueIdentifier)
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
    }
}