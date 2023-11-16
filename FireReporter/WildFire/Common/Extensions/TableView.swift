//
//  TableView.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 11.11.23.
//

import Foundation
import UIKit
import CoreLocation

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reportsArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.defaultWhiteColor
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportListCustomTableViewCell.identifier, for: indexPath) as? ReportListCustomTableViewCell else {
            fatalError("The TableView could not dequeue a Custom Cell")
        }
        let report = reportsArray[indexPath.row]
        cell.selectionStyle = .none
        cell.setupCell(image:report.photo ?? "pictureNotAvailable",descriptionLabel: report.description ?? "No description available", latitude: report.lat, longitude: report.long, date:report.date, address: report.address ?? "Address is not available")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previewReport = PreviewReport()
        let report = reportsArray[indexPath.row]
        previewReport.descriptionText = report.description ?? "No description available"
        previewReport.coordinates = CLLocationCoordinate2D(latitude:report.lat, longitude:report.long)
        previewReport.imageURL = report.photo ?? "pictureNotAvailable"
        present(previewReport, animated: true, completion: nil)
    }
}
