//
//  ReportListCustomTableViewCell.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.10.23.
//

import UIKit
import CoreLocation

class ReportListCustomTableViewCell: UITableViewCell {

    static let identifier = "ReportListCustomCell"
    
    private var descriptionLabel = UILabel()
    private var latitudeData = UILabel()
    private var longitudeData = UILabel()
    private var fireImage = UIImageView()
    private var dateLabel = UILabel()
    private var locationDescriptionLabel = UILabel()
    private var locationName = UILabel()
    var imageString = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setFireImageUI()
        setupDateLabelUI()
        setupLocationNameDesign()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func decodeBase64ToImage(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func setupCell(image: String, descriptionLabel: String, latitude: Double, longitude: Double, date: Date, address: String) {
        var dateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
            return formatter.string(from: date)
        }
        fireImage.image = decodeBase64ToImage(base64String: image)
        self.descriptionLabel.text = descriptionLabel
        self.dateLabel.text = timeAgoString(from: date)
        locationName.text = address
    }

    func timeAgoString(from date: Date) -> String {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: currentDate)
        if let year = components.year, year > 0 {
            return "\(year) \(year == 1 ? "year" : "years") ago"
        } else if let month = components.month, month > 0 {
            return "\(month) \(month == 1 ? "month" : "months") ago"
        } else if let day = components.day, day > 0 {
            return "\(day) \(day == 1 ? "day" : "days") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) \(hour == 1 ? "hour" : "hours") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) \(minute == 1 ? "minute" : "minutes") ago"
        } else {
            return "Just now"
        }
    }
        
    func setFireImageUI(){
        fireImage = UIImageView()
        fireImage.translatesAutoresizingMaskIntoConstraints = false
        fireImage.image = UIImage(named: "pictureNotAvailable")
        self.contentView.addSubview(fireImage)
        fireImage.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            fireImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fireImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            fireImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fireImage.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func setupLocationNameDesign(){
        locationName = UILabel()
        locationName.translatesAutoresizingMaskIntoConstraints = false
        locationName.textColor = UIColor.textColor
        locationName.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        self.contentView.addSubview(locationName)
        NSLayoutConstraint.activate([
            locationName.topAnchor.constraint(equalTo: contentView.topAnchor),
            locationName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            locationName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 150),
            locationName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupDateLabelUI(){
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "2020–04–15 11:11 PM"
        dateLabel.font = dateLabel.font.withSize(17)
        dateLabel.textColor = UIColor.textColor
        self.contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 40),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 150),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
  
}
