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
        setupDescriptionLabelUI()
        setupDateLabelUI()
        setupcoordinatesDescriptionDesign()
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
 
    
    func setupCell(image:String, descriptionLabel: String,latitude:Double, longitude:Double, date:Date, address:String){
        var dateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
            return formatter.string(from: date)
        }
        fireImage.image = decodeBase64ToImage(base64String: image)
        self.descriptionLabel.text = descriptionLabel
        self.dateLabel.text = String(dateString)
        print("\(imageString) my image string")
        locationName.text = address
    }
    
   
    
    func setFireImageUI(){
        fireImage = UIImageView()
        fireImage.translatesAutoresizingMaskIntoConstraints = false
        fireImage.image = UIImage(named: "pictureNotAvailable")
        self.contentView.addSubview(fireImage)
        NSLayoutConstraint.activate([
            fireImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fireImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            fireImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fireImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -250)
        ])
    }
    
    func setupDescriptionLabelUI(){
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        descriptionLabel.textColor = UIColor.textColor
        descriptionLabel.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
        descriptionLabel.numberOfLines = 4
        self.contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -130),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 190),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupcoordinatesDescriptionDesign(){
        locationDescriptionLabel = UILabel()
        locationDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        locationDescriptionLabel.text = "Fireplace location:"
        locationDescriptionLabel.textColor = UIColor.textColor
        locationDescriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.contentView.addSubview(locationDescriptionLabel)
        NSLayoutConstraint.activate([
            locationDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            locationDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            locationDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 190),
            locationDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupLocationNameDesign(){
        locationName = UILabel()
        locationName.translatesAutoresizingMaskIntoConstraints = false
        locationName.textColor = UIColor.textColor
        locationName.font = latitudeData.font.withSize(14)
        self.contentView.addSubview(locationName)
        NSLayoutConstraint.activate([
            locationName.topAnchor.constraint(equalTo: contentView.topAnchor),
            locationName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
            locationName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 190),
            locationName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupDateLabelUI(){
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "2020–04–15 11:11 PM"
        dateLabel.font = dateLabel.font.withSize(12)
        dateLabel.textColor = UIColor.textColor
        self.contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 130),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 190),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
  
}
