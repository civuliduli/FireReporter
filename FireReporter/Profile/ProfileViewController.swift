//
//  ReportListViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.10.23.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit



class ProfileViewController: UIViewController, LoginButtonDelegate {
    
    private let firebaseService = FirebaseService()
    
    var profileLabel = UILabel()
    var verifyAccountLabel = UILabel()
    var verifyFacebook = FBLoginButton()
    var verifyGoogle = UIButton()
    var verifyApple = UIButton()
    var verifyPhoneNumber = UIButton()
    var myReports = UILabel()
    
    var reportsArray = [FireReportModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.allowsSelection = true
        tableView.register(ReportListCustomTableViewCell.self, forCellReuseIdentifier: ReportListCustomTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.secondaryColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        UITabBar.appearance().backgroundColor = UIColor.white
        print("Hello World")
        self.navigationController?.isNavigationBarHidden = true
        getFireReports()
        reportListTitleLabel()
        verifyAccountLabelUI()
        verifyWithFacebookButtonDesign()
        verifyWithGoogleButtonDesign()
        verifyWithAppleButtonDesign()
        verifyWithPhoneNumberButtonDesign()
        myReportsLabelDesign()
        setupTableUI()
        
    }
    
    func getFireReports(){
        let db = Firestore.firestore()
        db.collection("reports").getDocuments { querrySnapshot, error in
            guard let documents = querrySnapshot?.documents else {print("No Documents")
                return}
            self.reportsArray = documents.map({ querryDocumentSnapshot in
                let data = querryDocumentSnapshot.data()
                let uniqueIdentifier = data["uniqueIdentifier"] as? String? ?? ""
                let description = data["description"] as? String? ?? ""
                let lat = data["lat"] as? Double? ?? 0.00
                let long = data["long"] as? Double? ?? 0.00
                let timestamp = data["timestamp"] as? Timestamp
                let photo = data["photo"] as? String? ?? "androidKiller"
                return FireReportModel(description: description,id:0,lat: lat ?? 0.00, long: long ?? 0.00, photo:photo ?? "androidKiller", timestamp: timestamp?.dateValue() ?? Date(), uniqueIdentifier: uniqueIdentifier ?? "")
            })
            self.tableView.reloadData()
        }
    }
    
    enum AuthenticationError:Error {
        case authTokenError
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        print("Hello World")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            self.present(Alert(text: "Auth Failed", message: error?.localizedDescription ?? "Auth error", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
        return
        }
        if (AccessToken.current != nil) {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.present(Alert(text: "Auth Error", message: error.localizedDescription, confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                    return
                }
                self.present(Alert(text: "Success", message: "User verified succesfully", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
            }
        } else {
            print("there is no token for the user")
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
       print("Logged out")
    }
    
    @objc func setupGoogleVerification() {
        firebaseService.googleAuth {
            self.present(Alert(text: "Authentication Cancelled", message: "", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
        } onSuccess: {
            self.present(Alert(text: "Success", message: "You now are a WildFireReporter verified User", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
        } onAuthError: {
            self.present(Alert(text: "Auth Error", message: "Please try again later", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
        }
    }
  
    
    func setupTableUI(){
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.secondaryColor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: verifyPhoneNumber.bottomAnchor, constant: 100),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    func reportListTitleLabel(){
        profileLabel = UILabel()
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.text = "Profile"
        profileLabel.font = profileLabel.font.withSize(30)
        profileLabel.textColor = UIColor.primaryColor
        self.view.addSubview(profileLabel)
        profileLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:40).isActive = true
        profileLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30).isActive = true
    }
    
    func verifyAccountLabelUI(){
        verifyAccountLabel = UILabel()
        verifyAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        verifyAccountLabel.text = "Verify Account"
        verifyAccountLabel.font = verifyAccountLabel.font.withSize(24)
        verifyAccountLabel.textColor = UIColor.primaryColor
        self.view.addSubview(verifyAccountLabel)
        verifyAccountLabel.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant:40).isActive = true
        verifyAccountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
    }
    
    func verifyWithFacebookButtonDesign(){
        verifyFacebook = FBLoginButton()
        verifyFacebook.translatesAutoresizingMaskIntoConstraints = false
        verifyFacebook.setTitle("Verify with Facebook", for: .normal)
        verifyFacebook.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        verifyFacebook.backgroundColor = .systemBlue
        verifyFacebook.layer.cornerRadius = 10
        verifyFacebook.center = self.view.center
        verifyFacebook.delegate = self
        verifyFacebook.permissions = ["public_profile","email"]
//        verifyFacebook.addTarget(self, action:Selector(("setupFacebookVerification:")), for: UIControl.Event.touchUpInside)
//        verifyFacebook.addTarget(self, action: #selector(setupFacebookVerification), for: .touchUpInside)
        view.addSubview(verifyFacebook)
        verifyFacebook.heightAnchor.constraint(equalToConstant: 55).isActive = true
        verifyFacebook.topAnchor.constraint(equalTo: verifyAccountLabel.bottomAnchor, constant: 40).isActive = true
        verifyFacebook.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-35).isActive = true
        verifyFacebook.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35).isActive = true
    }
    
    func verifyWithGoogleButtonDesign(){
        let googleImage = UIImage(named:"Google_Logo.svg")
        verifyGoogle = UIButton()
        verifyGoogle.translatesAutoresizingMaskIntoConstraints = false
        verifyGoogle.clipsToBounds = true
        verifyGoogle.setImage(googleImage, for: .normal)
        verifyGoogle.imageView?.contentMode = .scaleAspectFit
        verifyGoogle.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        verifyGoogle.layer.cornerRadius = 10
        verifyGoogle.backgroundColor = UIColor.buttonBackgroundColor
        verifyGoogle.addTarget(self, action: #selector(setupGoogleVerification), for: .touchUpInside)
        view.addSubview(verifyGoogle)
        NSLayoutConstraint.activate([
            verifyGoogle.heightAnchor.constraint(equalToConstant: 55),
            verifyGoogle.topAnchor.constraint(equalTo: verifyFacebook.bottomAnchor, constant: 20),
            verifyGoogle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-220),
            verifyGoogle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
        ])
    }
    
    func verifyWithAppleButtonDesign(){
        let appleImage = UIImage(named: "Apple_logo_white.svg")
        verifyApple = UIButton()
        verifyApple.translatesAutoresizingMaskIntoConstraints = false
        verifyApple.setTitle("Apple", for: .normal)
        verifyApple.clipsToBounds = true
        verifyApple.setImage(appleImage, for: .normal)
        verifyApple.imageView?.contentMode = .scaleAspectFit
        verifyApple.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        verifyApple.layer.cornerRadius = 10
        verifyApple.backgroundColor = UIColor.buttonBackgroundColor
        //        verifyApple.addTarget(self, action: #selector(proceedToMapView), for: .touchUpInside)
        view.addSubview(verifyApple)
        NSLayoutConstraint.activate([
            verifyApple.heightAnchor.constraint(equalToConstant: 55),
            verifyApple.topAnchor.constraint(equalTo: verifyFacebook.bottomAnchor, constant: 20),
            verifyApple.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-35),
            verifyApple.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 220),
        ])
    }
    
    func verifyWithPhoneNumberButtonDesign(){
        verifyPhoneNumber = UIButton()
        verifyPhoneNumber.translatesAutoresizingMaskIntoConstraints = false
        verifyPhoneNumber.setTitle("Verify with Phone Number", for: .normal)
        verifyPhoneNumber.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        verifyPhoneNumber.backgroundColor = .systemGreen
        verifyPhoneNumber.layer.cornerRadius = 10
        verifyPhoneNumber.center = self.view.center
        //         verifyFacebookLabel.addTarget(self, action: #selector(verifyFacebookLabel), for: .touchUpInside)
        view.addSubview(verifyPhoneNumber)
        verifyPhoneNumber.heightAnchor.constraint(equalToConstant: 55).isActive = true
        verifyPhoneNumber.topAnchor.constraint(equalTo: verifyApple.bottomAnchor, constant: 20).isActive = true
        verifyPhoneNumber.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-35).isActive = true
        verifyPhoneNumber.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35).isActive = true
    }
    
    func myReportsLabelDesign(){
        myReports = UILabel()
        myReports.translatesAutoresizingMaskIntoConstraints = false
        myReports.text = "My Reports"
        myReports.font = myReports.font.withSize(30)
        myReports.textColor = UIColor.primaryColor
        self.view.addSubview(myReports)
        myReports.topAnchor.constraint(equalTo: verifyPhoneNumber.bottomAnchor, constant:40).isActive = true
        myReports.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30).isActive = true
    }
    
}





extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reportsArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.secondaryColor
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportListCustomTableViewCell.identifier, for: indexPath) as? ReportListCustomTableViewCell else {
            fatalError("The TableView could not dequeue a Custom Cell")
        }
        var description:String
        var latitude:Double
        var longitude: Double
        var date: Date
        var image:String
        //        if indexPath.row < reportsArray.count{
        //            for data in self.reportsArray{
        let report = reportsArray[indexPath.row]
        //        print(report)
        description = report.description ?? "No data to show"
        latitude = report.lat
        longitude = report.long
        date = report.date
        image = report.photo ?? "androidKiller"
        cell.selectionStyle = .none
        //        print(report.photo!)
        //            }
        //        } else {
        //            fatalError("Index path is out of bounds for reportsArray")
        //        }
        cell.setupCell(image:image,descriptionLabel: description, latitude: latitude, longitude: longitude, date:date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var description:String
        var latitude:Double
        var longitude: Double
        let finalReportVC = FinalReportViewController()
        var image:String
        
        
        //        if indexPath.row < reportsArray.count{
        let report = reportsArray[indexPath.row]
        description = report.description ?? "No data to show"
        latitude = report.lat
        longitude = report.long
        image = report.photo!
        finalReportVC.descriptionText = description
        finalReportVC.coordinates = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
        finalReportVC.isConfirmButtonHidden = true
        finalReportVC.isTextFieldEditable = false
        finalReportVC.imageURL = image
        //        } else {
        //            fatalError("Index path is out of bounds for reportsArray")
        //        }
        navigationController?.pushViewController(finalReportVC, animated: false)
    }
}
















//
//  ReportListViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.10.23.
//

//import UIKit
//import CoreLocation
//import FirebaseFirestore
//
//
//class ReportListViewController: UIViewController {
//
//    var reportListTitle = UILabel()
//
//    var reportsArray = [FireReportModel]()
//
//
//    private let images: [UIImage] = [
//        UIImage(named: "ap23228583464745-cbe17fd99bdb2c6161082c3d8a16887c5e171c82-s1100-c50")!,
//        UIImage(named: "fillet-steak-thumb")!,
//        UIImage(named: "ap23228583464745-cbe17fd99bdb2c6161082c3d8a16887c5e171c82-s1100-c50")!,
//        UIImage(named: "ap23228583464745-cbe17fd99bdb2c6161082c3d8a16887c5e171c82-s1100-c50")!
//    ]
//    private let descriptions = ["Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."]
//    private let coordinates = ["latitude: 51.507222, longitude: -0.1275","latitude: 59.95, longitude: 10.75","latitude: 48.8567, longitude: 2.3508","latitude: 41.9, longitude: 12.5"]
//    private let date = ["2020–04–15 11:11 PM","2020–04–15 11:11 PM","2020–04–15 11:11 PM","2020–04–15 11:11 PM"]
//
//
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.backgroundColor = .white
//        tableView.allowsSelection = true
//        tableView.register(ReportListCustomTableViewCell.self, forCellReuseIdentifier: ReportListCustomTableViewCell.identifier)
//        return tableView
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        getFireReports()
//        view.backgroundColor = UIColor.secondaryColor
//        setupUI()
//        reportListTitleLabel()
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//        UITabBar.appearance().backgroundColor = UIColor.white
//        print("Hello World")
//        self.navigationController?.isNavigationBarHidden = true
//    }
//
//
//    func getFireReports(){
//        let db = Firestore.firestore()
//
//        db.collection("reports").addSnapshotListener { querrySnapshot, error in
//            guard let documents = querrySnapshot?.documents else {print("No Documents")
//                return}
//
//            self.reportsArray = documents.map({ querryDocumentSnapshot in
//                let data = querryDocumentSnapshot.data()
//                let description = data["description"] as? String? ?? ""
//                let lat = data["lat"] as? Double? ?? 0.00
//                let long = data["long"] as? Double? ?? 0.00
//                self.tableView.reloadData()
//                return FireReportModel(description: description,id:0,lat: lat ?? 0.00, long: long ?? 0.00, photo: "", timestamp: Date.now)
//            })
//            self.tableView.reloadData()
//        }
//    }
////    for document in QuerySnapshot!.documents{
////        let fireData = document.data()
////        print(fireData)
////            self.wildFireReports = fireData
////            print(self.wildFireReports)
////        print(type(of:self.wildFireReports))
////    }
//
//
//
//    override func viewWillAppear(_ animated: Bool) {
//           super.viewWillAppear(animated)
//           navigationController?.setNavigationBarHidden(true, animated: animated)
//        print("Hello World")
//       }
//
//       override func viewWillDisappear(_ animated: Bool) {
//           super.viewWillDisappear(animated)
//           navigationController?.setNavigationBarHidden(false, animated: animated)
//       }
//
//    private func setupUI(){
//        self.view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.backgroundColor = UIColor.secondaryColor
//
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
//            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//        ])
//    }
//
//    func reportListTitleLabel(){
//        reportListTitle = UILabel()
//        reportListTitle.translatesAutoresizingMaskIntoConstraints = false
//        reportListTitle.text = "Fire Report List"
//        reportListTitle.font = reportListTitle.font.withSize(28)
//        reportListTitle.textColor = UIColor.primaryColor
//        view.addSubview(reportListTitle)
//        reportListTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:15).isActive = true
//        reportListTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30).isActive = true
//    }
//}
//
//
//
//extension ReportListViewController: UITableViewDelegate, UITableViewDataSource{
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.reportsArray.count
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.backgroundColor = UIColor.secondaryColor
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReportListCustomTableViewCell.identifier, for: indexPath) as? ReportListCustomTableViewCell else {
//            fatalError("The TableView could not dequeue a Custom Cell")
//        }
//        var description:String
//        var latitude:Double
//        var longitude: Double
//        var date: Date
//        if indexPath.row < reportsArray.count{
////            for data in self.reportsArray{
//                let report = reportsArray[indexPath.row]
//                description = report.description ?? "No data to show"
//                latitude = report.lat
//                longitude = report.long
//                date = report.timestamp
//                cell.selectionStyle = .none
////            }
//        } else {
//            fatalError("Index path is out of bounds for reportsArray")
//
//        }
//        cell.setupCell(descriptionLabel: description, latitude: latitude, longitude: longitude, date: date)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 130
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        var description:String
//        var latitude:Double
//        var longitude: Double
//        var date: Date
//        let finalReportVC = FinalReportViewController()
//
//        if indexPath.row < reportsArray.count{
////            for data in self.reportsArray{
//                let report = reportsArray[indexPath.row]
//                description = report.description ?? "No data to show"
//                latitude = report.lat
//                longitude = report.long
//                date = report.timestamp
//            finalReportVC.descriptionText = description
//            finalReportVC.coordinates = CLLocationCoordinate2D(latitude:latitude , longitude:longitude)
//            finalReportVC.isConfirmButtonHidden = true
//            finalReportVC.isTextFieldEditable = false
//        } else {
//            fatalError("Index path is out of bounds for reportsArray")
//
//        }
////        let image = self.images[indexPath.row]
////        let description = self.descriptions[indexPath.row]
////        let coordinates = self.coordinates[indexPath.row]
////        let dates = self.date[indexPath.row]
////
////        print(image,description,coordinates,dates)
////        let finalReportVC = FinalReportViewController()
////        finalReportVC.fireImage = image
////        finalReportVC.descriptionText = description
////        // fix with real data
////        finalReportVC.coordinates = CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508)
////
////
//        navigationController?.pushViewController(finalReportVC, animated: false)
//    }
//}

