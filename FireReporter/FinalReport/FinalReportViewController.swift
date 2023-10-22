
//
//  FinalReportViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 8.10.23.
//

import UIKit
import MapKit
import FirebaseFirestore
import Firebase

protocol MyDataSendingDelegateProtocol{
    func sendDataToCameraViewController(photoState:Bool)
}

class FinalReportViewController: UIViewController {
    
    private let finalReportViewModel = FinalReportViewModel()
    var delegate: MyDataSendingDelegateProtocol?
    
    var currentLocation: CLLocation!
    var fireImage: UIImage?
    var fireImageView = UIImageView()
    var descriptionTextField = UITextView()
    var confirmReportButton: UIButton!
    var descriptionLabel = UILabel()
    var reportLabel = UILabel()
    let toolbar = UIToolbar()
    var isConfirmButtonHidden = false
    var isTextFieldEditable = true
    var descriptionText = ""
    var coordinates = CLLocationCoordinate2D()
    let scrollView = UIScrollView()
    var container = UIView()
    var previewImage = UIImageView()
    var documentsUrl: URL{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    var imageURL = ""
    
    
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
        setupUI()
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboard)
        print("\(imageURL) my image url")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePreview(_:)))
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showPreview(_:)))
        previewImage.isUserInteractionEnabled = true
        previewImage.addGestureRecognizer(tapGestureRecognizer)
        fireImageView.isUserInteractionEnabled = true
        fireImageView.addGestureRecognizer(tapGestureRecognizer1)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        finalReportViewModel.configureLocationManager()
        fireLocation()
    }
    
  
    
    func fireLocation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Fire was located here"
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        print(mapView.addAnnotation(annotation))
        print("\(coordinates.latitude) coordinates")
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
    }
    
//    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
//        guard let imageData = Data(base64Encoded: imageBase64String) else { print("No image")
//            return UIImage(named: "androidKiller")! }
//        let image = UIImage(data: imageData)
//        return image!
//    }
    
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
  
    
    @objc func sendReport(){
        let myCompressedImage = convertImageToBase64String(img: (fireImage ?? UIImage(named: "androidKiller"))!)
        let db = Firestore.firestore()
        let fireReport = FireReportModel(description: descriptionTextField.text, id:0, lat: coordinates.latitude, long: coordinates.longitude, photo: myCompressedImage, timestamp: Date(), uniqueIdentifier: UIDevice.current.identifierForVendor!.uuidString)
            db.collection("reports").addDocument(data: fireReport.dictionary) { err in
                if let err = err {
                    self.present(Alert(text: "Error", message: err.localizedDescription, confirmAction:[UIAlertAction(title: "Try again", style: .default)], disableAction: []))
                    print("Error writing document: \(err.localizedDescription)")
                    return
                } else {
                    print("Document successfully written!")
                    self.navigationController?.popToRootViewController(animated: false)
                    if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
                        scene.photoState = .completed
                    }
                }
            }
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
        submitReportButtonDesign()
        previewImageDesign()
    }
    
    func previewImageDesign(){
        previewImage = UIImageView()
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        previewImage.image = fireImage
        previewImage.isHidden = true
        previewImage.isUserInteractionEnabled = true
        previewImage.frame = UIScreen.main.bounds
        previewImage.contentMode = .scaleAspectFill
        self.view.addSubview(previewImage)
    }
    
    func reportLabelDesign(){
        reportLabel = UILabel()
        reportLabel.translatesAutoresizingMaskIntoConstraints = false
        reportLabel.text = "Fire Report Summary"
        reportLabel.font = reportLabel.font.withSize(28)
        reportLabel.textColor = UIColor.black
        self.view.addSubview(reportLabel)
        reportLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant:30).isActive = true
        reportLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 30).isActive = true
    }
    
    
    func mapViewDesign(){
        self.view.addSubview(mapView)
        mapView.layer.cornerRadius = 10
        mapView.heightAnchor.constraint(equalToConstant:200).isActive = true
        mapView.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant:40).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 20).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20).isActive = true
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
            fireImageView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 20),
            fireImageView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -200)
        ])
    }
    
  
    func descriptionTextFieldDesign(){
        descriptionTextField = UITextView()
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.layer.cornerRadius = 10
        descriptionTextField.font = UIFont.systemFont(ofSize: 14)
        descriptionTextField.textColor = UIColor.black
        descriptionTextField.backgroundColor = UIColor.descriptionBackgroundColor
        descriptionTextField.inputAccessoryView = toolbar
        descriptionTextField.isEditable = isTextFieldEditable
        descriptionTextField.text = descriptionText
        self.view.addSubview(descriptionTextField)
        NSLayoutConstraint.activate([
            descriptionTextField.heightAnchor.constraint(equalToConstant:200),
            descriptionTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 40),
            descriptionTextField.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 240),
            descriptionTextField.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20),
        ])
    }
    
    func descriptionLabelDesign(){
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Put your description here"
        descriptionLabel.font = descriptionLabel.font.withSize(10)
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
        descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
        ])
    }
    
    
    func submitReportButtonDesign(){
        confirmReportButton = UIButton()
        confirmReportButton.translatesAutoresizingMaskIntoConstraints = false
        confirmReportButton.setTitle("Submit Report!", for: .normal)
        confirmReportButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        confirmReportButton.backgroundColor = .gray
        confirmReportButton.tintColor = .white
        confirmReportButton.layer.cornerRadius = 10
        confirmReportButton.isHidden = isConfirmButtonHidden
        confirmReportButton.addTarget(self, action: #selector(sendReport), for: .touchUpInside)
        self.view.addSubview(confirmReportButton)
        confirmReportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        confirmReportButton.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant:-35).isActive = true
        confirmReportButton.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 35).isActive = true
        confirmReportButton.topAnchor.constraint(equalTo: fireImageView.bottomAnchor, constant: 100).isActive = true
    }
    
    
    @objc func showPreview(_ sender:AnyObject){
        previewImage.isHidden = false
    }
    
    @objc func hidePreview(_ sender:AnyObject){
        previewImage.isHidden = true
    }
//    func toolBar(){
//        toolbar.sizeToFit()
//        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//
//        toolbar.setItems([flexible, doneButton], animated: false)
//    }
    
//    @objc func doneButtonTapped() {
//        descriptionTextField.resignFirstResponder()
//    }
//    
//   @objc func dismissKeyboard(){
//        descriptionTextField.resignFirstResponder()
//    }
}



















//
//  FinalReportViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 8.10.23.
//

//import CoreLocation
//import UIKit
//import MapKit
//
//class FinalReportViewController: UIViewController {
//        
//    var locManager = CLLocationManager()
//    var currentLocation: CLLocation!
//    var fireImage = UIImage(named: "ap23228583464745-cbe17fd99bdb2c6161082c3d8a16887c5e171c82-s1100-c50")
//    var fireImageView = UIImageView()
//    var descriptionTextField = UITextView()
//    var confirmReportButton: UIButton!
//    var descriptionLabel = UILabel()
//    var reportLabel = UILabel()
//    let toolbar = UIToolbar()
//    var isConfirmButtonHidden = false
//    var descriptionText = ""
//    var coordinates = CLLocationCoordinate2D()
//    let scrollView: UIScrollView = {
//        let sv = UIScrollView()
//        sv.backgroundColor = .white
//        return sv
//    }()
//    var container: UIView = {
//        let c = UIView()
//        c.backgroundColor = .white
//        return c
//    }()
//    
//    lazy var mapView: MKMapView = {
//        let map = MKMapView()
//        map.translatesAutoresizingMaskIntoConstraints = false
//        return map
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        if let availableImage = fireImage{
//        fireImageView.image = availableImage
//        }
//        view.backgroundColor = .white
//        setupUI()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        locManager.desiredAccuracy = kCLLocationAccuracyBest
//        locManager.requestWhenInUseAuthorization()
//        locManager.startUpdatingLocation()
//        fireLocation()
//    }
//    
//    func fireLocation(){
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinates
//        annotation.title = "Fire was located here"
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
//        mapView.setRegion(region, animated: true)
//        mapView.addAnnotation(annotation)
//    }
//
//    @objc func sendReport(){
//        tabBarController?.selectedIndex = 1
//        let reportListVC = ReportListViewController()
////        reportListVC.modalPresentationStyle = .fullScreen
////        present(reportListVC, animated: false)
//        navigationController?.pushViewController(reportListVC, animated: false)
//    }
//    
//    func setupUI(){
//        self.view.addSubview(scrollView)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        self.scrollView.addSubview(container)
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        let hConst = container.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
//        hConst.isActive = true
//        hConst.priority = UILayoutPriority(50)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            
//            container.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
//            container.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
//            container.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
//            container.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 850),
//            
//            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            container.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 2),
//        ])
//        reportLabelDesign()
//        mapViewDesign()
//        fireImageDesign()
//        descriptionTextFieldDesign()
//        submitReportButtonDesign()
//        toolBar()
//    }
//    
//    func reportLabelDesign(){
//        reportLabel = UILabel()
//        reportLabel.translatesAutoresizingMaskIntoConstraints = false
//        reportLabel.text = "Fire Report Summary"
//        reportLabel.font = reportLabel.font.withSize(28)
//        reportLabel.textColor = UIColor.black
//        self.view.addSubview(reportLabel)
//        reportLabel.topAnchor.constraint(equalTo: self.container.topAnchor, constant:30).isActive = true
//        reportLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 30).isActive = true
//    }
//    
//    
//    func mapViewDesign(){
//        self.view.addSubview(mapView)
//        mapView.layer.cornerRadius = 10
//        mapView.heightAnchor.constraint(equalToConstant:200).isActive = true
//        mapView.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant:40).isActive = true
//        mapView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 20).isActive = true
//        mapView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20).isActive = true
//    }
//
//    func fireImageDesign(){
//        fireImageView = UIImageView()
//        fireImageView.contentMode = .scaleAspectFill
//        fireImageView.clipsToBounds = true
//        fireImageView.translatesAutoresizingMaskIntoConstraints = false
//        fireImageView.image = fireImage
//        fireImageView.layer.cornerRadius = 10
//        self.view.addSubview(fireImageView)
//        NSLayoutConstraint.activate([
//            fireImageView.heightAnchor.constraint(equalToConstant:200),
//            fireImageView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant:40),
//            fireImageView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 20),
//            fireImageView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -200)
//        ])
//    }
//    
//  
//    func descriptionTextFieldDesign(){
//        descriptionTextField = UITextView()
//        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
//        descriptionTextField.layer.cornerRadius = 10
//        descriptionTextField.font = UIFont.systemFont(ofSize: 14)
//        descriptionTextField.textColor = UIColor.black
//        descriptionTextField.backgroundColor = UIColor.descriptionBackgroundColor
//        descriptionTextField.inputAccessoryView = toolbar
//        descriptionTextField.text = descriptionText
//        self.view.addSubview(descriptionTextField)
//        NSLayoutConstraint.activate([
//            descriptionTextField.heightAnchor.constraint(equalToConstant:200),
//            descriptionTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 40),
//            descriptionTextField.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 240),
//            descriptionTextField.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20),
//        ])
//    }
//    
//    func descriptionLabelDesign(){
//        descriptionLabel = UILabel()
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        descriptionLabel.text = "Put your description here"
//        descriptionLabel.font = descriptionLabel.font.withSize(10)
//        view.addSubview(descriptionLabel)
//        NSLayoutConstraint.activate([
//        descriptionLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
//        ])
//    }
//    
//    
//    func submitReportButtonDesign(){
//        confirmReportButton = UIButton()
//        confirmReportButton.translatesAutoresizingMaskIntoConstraints = false
//        confirmReportButton.setTitle("Submit Report!", for: .normal)
//        confirmReportButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
//        confirmReportButton.backgroundColor = .gray
//        confirmReportButton.tintColor = .white
//        confirmReportButton.layer.cornerRadius = 10
//        confirmReportButton.isHidden = isConfirmButtonHidden
//        confirmReportButton.addTarget(self, action: #selector(sendReport), for: .allEvents)
//        self.view.addSubview(confirmReportButton)
//        confirmReportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        confirmReportButton.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant:-35).isActive = true
//        confirmReportButton.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 35).isActive = true
//        confirmReportButton.topAnchor.constraint(equalTo: fireImageView.bottomAnchor, constant: 100).isActive = true
//    }
//    
//    func toolBar(){
//        toolbar.sizeToFit()
//        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//
//        toolbar.setItems([flexible, doneButton], animated: false)
//    }
//    
//    @objc func doneButtonTapped() {
//        descriptionTextField.resignFirstResponder()
//    }
//}


