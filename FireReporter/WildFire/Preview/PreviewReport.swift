//
//  PreviewReport.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 1.11.23.
//

import UIKit
import MapKit


class PreviewReport: UIViewController {
    
    var container = UIView()
    let scrollView = UIScrollView()
    var reportLabel = UILabel()
    var fireImage: UIImage?
    var fireImageView = UIImageView()
    var descriptionTextField = UITextView()
    let toolbar = UIToolbar()
    var previewImage = UIImageView()
    var descriptionText = ""
    var coordinates = CLLocationCoordinate2D()
    var imageURL = ""
    var isTextFieldEditable = true

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let availableImage = fireImage {
            fireImageView.image = availableImage
        } else {
            getImage()
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePreview(_:)))
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showPreview(_:)))
        previewImage.isUserInteractionEnabled = true
        previewImage.addGestureRecognizer(tapGestureRecognizer)
        fireImageView.isUserInteractionEnabled = true
        fireImageView.addGestureRecognizer(tapGestureRecognizer1)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePreview(_:)))
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showPreview(_:)))
        previewImage.isUserInteractionEnabled = true
        previewImage.addGestureRecognizer(tapGestureRecognizer)
        fireImageView.isUserInteractionEnabled = true
        fireImageView.addGestureRecognizer(tapGestureRecognizer1)
        fireLocation()
    }
    
    func decodeBase64ToImage(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func getImage(){
        let myDecompressedImage = decodeBase64ToImage(base64String: imageURL)
        fireImage = myDecompressedImage
    }
    
    func fireLocation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Fire was located here"
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    func setupUI(){
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        let hConst = container.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            container.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 850),

            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            container.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 2)
        ])
        reportLabelDesign()
        mapViewDesign()
        fireImageDesign()
        descriptionTextFieldDesign()
        previewImageDesign()
    }
    
    func reportLabelDesign(){
        reportLabel = UILabel()
        reportLabel.translatesAutoresizingMaskIntoConstraints = false
        reportLabel.text = "Fire Report Summary"
        reportLabel.font = reportLabel.font.withSize(28)
        reportLabel.textColor = UIColor.black
        self.view.addSubview(reportLabel)
        reportLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant:30).isActive = true
        reportLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16).isActive = true
    }
    
    func mapViewDesign(){
        self.view.addSubview(mapView)
        mapView.layer.cornerRadius = 10
        mapView.heightAnchor.constraint(equalToConstant:200).isActive = true
        mapView.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant:40).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20).isActive = true
    }
    
    func previewImageDesign(){
        previewImage = UIImageView()
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        previewImage.image = fireImage
        previewImage.isHidden = true
        previewImage.isUserInteractionEnabled = true
        previewImage.contentMode = .scaleAspectFill
        previewImage.frame = self.view.bounds
        self.view.addSubview(previewImage)
        previewImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        previewImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        previewImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        previewImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }

    func fireImageDesign(){
        fireImageView = UIImageView()
        fireImageView.contentMode = .scaleAspectFill
        fireImageView.clipsToBounds = true
        fireImageView.translatesAutoresizingMaskIntoConstraints = false
        fireImageView.image = fireImage
        fireImageView.layer.cornerRadius = 10
        self.view.addSubview(fireImageView)
        NSLayoutConstraint.activate([
            fireImageView.heightAnchor.constraint(equalToConstant:200),
            fireImageView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant:40),
            fireImageView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            fireImageView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -200)
        ])
    }

    func descriptionTextFieldDesign(){
        descriptionTextField = UITextView()
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.layer.cornerRadius = 10
        descriptionTextField.font = UIFont.systemFont(ofSize: 14)
        descriptionTextField.textColor = UIColor.black
        descriptionTextField.text = descriptionText
        descriptionTextField.isEditable = false
        descriptionTextField.backgroundColor = UIColor.descriptionBackgroundColor
        descriptionTextField.inputAccessoryView = toolbar
        self.view.addSubview(descriptionTextField)
        NSLayoutConstraint.activate([
            descriptionTextField.heightAnchor.constraint(equalToConstant:200),
            descriptionTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 40),
            descriptionTextField.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 240),
            descriptionTextField.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func showPreview(_ sender:AnyObject){
        previewImage.isHidden = false
    }

    @objc func hidePreview(_ sender:AnyObject){
        previewImage.isHidden = true
    }
}
