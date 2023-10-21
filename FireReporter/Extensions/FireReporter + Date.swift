//
//  FireReporter + Date.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 17.10.23.
//

import Foundation

//extension Date {
//
// static func getCurrentDate() -> String {
//
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateFormat = "MMMM dd, yyyy 'at' H:mm:ss a"
//
//        return dateFormatter.string(from: Date())
//
//    }
//}

extension Date {
    static func date(fromString dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }
}


//print(Date.getCurrentDate())

//October 16, 2023 at 2:37:00 AM UTC+2
