//
//  ReportListCustomTableViewCell.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.10.23.
//

import UIKit

class ReportListCustomTableViewCell: UITableViewCell {

    
    static let identifier = "ReportListCustomCell"
    
    private var descriptionLabel = UILabel()
    private var latitudeData = UILabel()
    private var longitudeData = UILabel()
    private var fireImage = UIImageView()
    private var dateLabel = UILabel()
    private var coordinatesDescriptionLabel = UILabel()
    private var latitude = UILabel()
    private var longitude = UILabel()
    var imageString = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setFireImageUI()
        setupDescriptionLabelUI()
        setupDateLabelUI()
        setupLongitudeUI()
        setupLatitudeUI()
        setupcoordinatesDescriptionDesign()
        setupLatitudeLabel()
        setupLongitudeLabel()
//        getImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
//    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
//        guard let imageData = Data(base64Encoded: imageBase64String) else { print("No image")
//            return UIImage(named: "androidKiller")! }
//        let image = UIImage(data: imageData)
//        return image!
////        let imageData = Data(base64Encoded: imageBase64String)
////        let image = UIImage(data: imageData!)
////        return image!
//    }
    
    func decodeBase64ToImage(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
 
   
    
    func setupCell(image:String, descriptionLabel: String,latitude:Double, longitude:Double, date:Date){
        var dateString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy h:mm a"
            return formatter.string(from: date)
        }
//        let mydecompressedImage = convertBase64StringToImage (imageBase64String:image)
        fireImage.image = decodeBase64ToImage(base64String: image)
//        fireImage.image = convertBase64StringToImage (imageBase64String:image)
//        getImage()
        self.descriptionLabel.text = descriptionLabel
        self.latitudeData.text = String(latitude)
        self.longitudeData.text = String(longitude)
        self.dateLabel.text = String(dateString)
        print("\(imageString) my image string")
//        self.coordinateLabel.text = coordinateLabel
    }
    
   
    
    
    func setFireImageUI(){
        fireImage = UIImageView()
        fireImage.translatesAutoresizingMaskIntoConstraints = false
        fireImage.image = UIImage(named: "androidKiller")
        self.contentView.addSubview(fireImage)
        NSLayoutConstraint.activate([
            fireImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fireImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            fireImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            fireImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -270)
        ])
    }
    
    func setupDescriptionLabelUI(){
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        descriptionLabel.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
        descriptionLabel.numberOfLines = 4
        self.contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -90),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 170),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupcoordinatesDescriptionDesign(){
        coordinatesDescriptionLabel = UILabel()
        coordinatesDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        coordinatesDescriptionLabel.text = "Fireplace location:"
        coordinatesDescriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.contentView.addSubview(coordinatesDescriptionLabel)
        NSLayoutConstraint.activate([
            coordinatesDescriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            coordinatesDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            coordinatesDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 170),
            coordinatesDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupLatitudeLabel(){
        latitude = UILabel()
        latitude.translatesAutoresizingMaskIntoConstraints = false
        latitude.text = "Lat:"
        latitude.font = latitudeData.font.withSize(14)
        self.contentView.addSubview(latitude)
        NSLayoutConstraint.activate([
            latitude.topAnchor.constraint(equalTo: contentView.topAnchor),
            latitude.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
            latitude.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 170),
            latitude.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupLongitudeLabel(){
        longitude = UILabel()
        longitude.translatesAutoresizingMaskIntoConstraints = false
        longitude.text = "Long:"
        longitude.font = longitude.font.withSize(14)
        self.contentView.addSubview(longitude)
        NSLayoutConstraint.activate([
            longitude.topAnchor.constraint(equalTo: contentView.topAnchor),
            longitude.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 40),
            longitude.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 170),
            longitude.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupLatitudeUI(){
        latitudeData = UILabel()
        latitudeData.translatesAutoresizingMaskIntoConstraints = false
        latitudeData.text = "latitude: 51.507222, longitude: -0.1275"
        latitudeData.font = latitudeData.font.withSize(14)
        self.contentView.addSubview(latitudeData)
        NSLayoutConstraint.activate([
            latitudeData.topAnchor.constraint(equalTo: contentView.topAnchor),
            latitudeData.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
            latitudeData.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 210),
            latitudeData.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupLongitudeUI(){
        longitudeData = UILabel()
        longitudeData.translatesAutoresizingMaskIntoConstraints = false
        longitudeData.text = "latitude: 51.507222, longitude: -0.1275"
        longitudeData.font = longitudeData.font.withSize(14)
        self.contentView.addSubview(longitudeData)
        NSLayoutConstraint.activate([
            longitudeData.topAnchor.constraint(equalTo: contentView.topAnchor),
            longitudeData.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 40),
            longitudeData.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 210),
            longitudeData.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupDateLabelUI(){
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = "2020–04–15 11:11 PM"
        dateLabel.font = dateLabel.font.withSize(12)
        self.contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 90),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 170),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
  
}
