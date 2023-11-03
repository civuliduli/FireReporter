//
//  FinalReportViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 8.10.23.
//

//import UIKit
//import MapKit
//import FirebaseFirestore
//import Firebase
//
//protocol MyDataSendingDelegateProtocol{
//    func sendDataToCameraViewController(photoState:Bool)
//}
//
//class FinalReportViewController: UIViewController {
//    
//    private let finalReportViewModel = FinalReportViewModel()
//    var delegate: MyDataSendingDelegateProtocol?
//    private let firebaseService = FirebaseService()
//    
//    let userArray: [User] = []
//
//    
//    var currentLocation: CLLocation!
//    var fireImage: UIImage?
//    var fireImageView = UIImageView()
//    var descriptionTextField = UITextView()
//    var confirmReportButton: UIButton!
//    var descriptionLabel = UILabel()
//    var reportLabel = UILabel()
//    let toolbar = UIToolbar()
//    var isConfirmButtonHidden = false
//    var isTextFieldEditable = true
//    var descriptionText = ""
//    var coordinates = CLLocationCoordinate2D()
//    let scrollView = UIScrollView()
//    var container = UIView()
//    var previewImage = UIImageView()
//    var voteFor = UIButton()
//    var voteAgainst = UIButton()
//    var votingDescription = UILabel()
//    var imageURL = ""
//    var addressName: String?
//    var issubmitVoteHidden = true
//    var isvotingDescriptionHidden = true
//    var isVoteForHidden = true
//    var isVoteAgainstHidden = true
//    var infoImage = UIImageView()
//    var voteInfo = UILabel()
//    var voteLabel = UILabel()
//    var ID:String!
//    var votedFor:Bool?
//    var votes: Int?
//    var mainStack = UIStackView()
//    var mapStack = UIStackView()
//    var mapView = MKMapView()
//
//    
////    
////    lazy var mapView: MKMapView = {
////        let map = MKMapView()
////        return map
////    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        if let availableImage = fireImage {
//            fireImageView.image = availableImage
//        } else {
//            getImage()
//        }
//        setupUI()
//        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(dismissKeyboard)
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePreview(_:)))
//        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showPreview(_:)))
//        previewImage.isUserInteractionEnabled = true
//        previewImage.addGestureRecognizer(tapGestureRecognizer)
//        fireImageView.isUserInteractionEnabled = true
//        fireImageView.addGestureRecognizer(tapGestureRecognizer1)
//        self.enableDisableVoting()
//    }
//    
//    @objc func dismissKeyboard(){
//        view.endEditing(true)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        finalReportViewModel.configureLocationManager()
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
//        convertLatLongToAddress(latitude:coordinates.latitude,longitude:coordinates.longitude)
//    }
//
//    func convertImageToBase64String (img: UIImage) -> String {
//        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
//    }
//    
//    func decodeBase64ToImage(base64String: String) -> UIImage? {
//        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
//            return UIImage(data: data)
//        }
//        return nil
//    }
//    
//    func getImage(){
//        let myDecompressedImage = decodeBase64ToImage(base64String: imageURL)
//        fireImage = myDecompressedImage
//    }
//    
//    func convertLatLongToAddress(latitude:Double,longitude:Double){
//        
//        let geoCoder = CLGeocoder()
//        let location = CLLocation(latitude: latitude, longitude: longitude)
//        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//            var placeMark: CLPlacemark!
//            placeMark = placemarks?[0]
//            if let city = placeMark.locality {
//                self.addressName = city
//            }
//        })
//    }
//    
//    func getUserVotes(){
//        let db = Firestore.firestore()
//        let voteCollection = db.collection("reports")
//        let query = voteCollection.whereField("id", isEqualTo: ID!)
//        query.getDocuments { QuerySnapshot, error in
//            if let error = error{
//                print("error fetching votes")
//            } else if let document = QuerySnapshot?.documents.first{
//                let data = document.data()
//                if let vote = data["likes"] as? Int {
//                    self.votes = vote
//                    self.voteInfo.text = String(vote)
//                    print("\(vote) my vote")
//                } else {
//                    print("Misssing field")
//                }
//            }
//        }
//    }
//  
//    
//    @objc func sendReport(){
//        var likes = 0
//        if let user = Auth.auth().currentUser {
//            if user.isAnonymous {
//                likes += 1
//            } else {
//                likes += 10
//            }
//        }
//        let userArray: [User] = []
//        let myCompressedImage = convertImageToBase64String(img: (fireImage ?? UIImage(named: "androidKiller"))!)
//        let db = Firestore.firestore()
//        let uuid = UUID().uuidString
//        let userID = Auth.auth().currentUser
//        let user = User(userID: userID!.uid, votedFor: false)
//        let users = [user]
//        let fireReport = FireReport(description: descriptionTextField.text, id:uuid, lat: coordinates.latitude, long: coordinates.longitude, photo: myCompressedImage, timestamp: Date(), uniqueIdentifier: UIDevice.current.identifierForVendor!.uuidString, address: addressName, likes:likes, users:users)
//        print(fireReport)
//        db.collection("reports").addDocument(data: fireReport.dictionary) { err in
//                if let err = err {
//                    self.present(Alert(text: "Error", message: err.localizedDescription, confirmAction:[UIAlertAction(title: "Try again", style: .default)], disableAction: []))
//                    print("Error writing document: \(err.localizedDescription)")
//                    return
//                } else {
//                    print("Document successfully written!")
//                    self.navigationController?.popToRootViewController(animated: false)
//                    if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
//                        scene.photoState = .completed
//                    }
//                }
//            }
//    }
//    
//    @objc func putVote(){
//        var likes = 0
//        let db = Firestore.firestore()
//        let userID = Auth.auth().currentUser
//        var user = ["userID":userID?.uid,"votedFor":true] as [String : Any]
//        db.collection("reports").whereField("id", isEqualTo:ID!).getDocuments { result, error in
//            let documnetData = result?.documents.first?.data()
//            if error == nil {
//                var users = documnetData?["users"] as? [[String: Any]] ?? []
//                print(users)
//                if let index = users.firstIndex(where: { $0["userID"] as? String == userID?.uid }){
//                    if let useri = Auth.auth().currentUser {
//                        if useri.isAnonymous {
//                            users[index] = user
//                            self.votes! += 1
//                            //                            likes += 1
//                        } else {
//                            users[index] = user
//                            //                            likes += 10
//                            self.votes! += 10
//                        }
//                    }
//                } else {
//                    if let useri = Auth.auth().currentUser {
//                        if useri.isAnonymous {
//                            users.append(user)
//                            self.votes! += 1
//                        } else {
//                            users.append(user)
//                            self.votes! += 10
//                        }
//                    }
//                }
//                for document in result!.documents{
//                    db.collection("reports").document(document.documentID).updateData(["likes": self.votes!,"users":users])
//                }
////                self.voteFor.isEnabled = self.votedFor ?? true
////                self.voteAgainst.isEnabled = !(self.votedFor ?? false)
////                self.voteFor.setImage(UIImage(systemName: "arrow.up.square"), for: .normal)
////                self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
//                self.voteFor.isEnabled = false
//                self.voteAgainst.isEnabled = true
//                self.votedFor = true
////                self.enableDisableVoting()
//                self.getUserVotes()
//            }
//        }
//    }
//    
//    @objc func removeVote(){
//        var likes = 0
//        let db = Firestore.firestore()
//        let userID = Auth.auth().currentUser
//        var user = ["userID":userID?.uid,"votedFor":false] as [String : Any]
//        db.collection("reports").whereField("id", isEqualTo:ID!).getDocuments { result, error in
//            let documnetData = result?.documents.first?.data()
//            if error == nil {
//                var users = documnetData?["users"] as? [[String: Any]] ?? []
//                print(users)
//                if let index = users.firstIndex(where: { $0["userID"] as? String == userID?.uid }){
//                    if let useri = Auth.auth().currentUser {
//                        if useri.isAnonymous {
//                            users[index] = user
//                            self.votes! -= 1
//                            //                            likes -= 1
//                        } else {
//                            users[index] = user
//                            self.votes! -= 10
//                            //                            likes -= 10
//                        }
//                    }
//                } else {
//                    if let useri = Auth.auth().currentUser {
//                        if useri.isAnonymous {
//                            users.append(user)
//                            self.votes! -= 1
//                            //                            likes -= 1
//                        } else {
//                            users.append(user)
//                            self.votes! -= 10
//                            //                            likes -= 10
//                        }
//                    }
//                }
//                for document in result!.documents{
//                    db.collection("reports").document(document.documentID).updateData(["likes": self.votes!,"users":users])
//                }
////                self.voteFor.isEnabled = self.votedFor ?? true
////                self.voteAgainst.isEnabled = !(self.votedFor ?? false)
////                self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
////                self.voteFor.setImage(UIImage(systemName: "arrow.up.square"), for: .normal)
//                self.voteFor.isEnabled = true
//                self.voteAgainst.isEnabled = false
//                self.votedFor = false
////                self.enableDisableVoting()
//                self.getUserVotes()
//            }
//        }
//    }
//    
//    func enableDisableVoting(){
//        self.voteInfo.text = String("\(votes ?? 0)")
//        if votedFor ?? true  {
//            self.voteFor.isEnabled = false
//            self.voteFor.setImage(UIImage(systemName: "arrow.up.square.fill"), for: .normal)
//            self.voteAgainst.isEnabled = true
//            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
//        } else if votedFor == false  {
//            self.voteFor.isEnabled = true
//            self.voteFor.setImage(UIImage(systemName: "arrow.up.square"), for: .normal)
//            self.voteAgainst.isEnabled = false
//            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
//        } else {
//            self.voteFor.isEnabled = true
//            self.voteFor.setImage(UIImage(systemName: "arrow.up.square"), for: .normal)
//            self.voteAgainst.isEnabled = true
//            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
//        }
//
////        self.voteFor.isEnabled = self.votedFor ?? true
////        self.voteAgainst.isEnabled = !(self.votedFor ?? false)
////        self.voteFor.setImage(UIImage(systemName: "arrow.up.square"), for: .normal)
////        self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
////        
////        self.voteFor.isEnabled = self.votedFor ?? true
////        self.voteAgainst.isEnabled = !(self.votedFor ?? false)
////        self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
////        self.voteFor.setImage(UIImage(systemName: "arrow.up.square"), for: .normal)
//    }
//
//    func setupUI(){
//        self.view.addSubview(scrollView)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        self.scrollView.addSubview(container)
//        container.translatesAutoresizingMaskIntoConstraints = false
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
//            container.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 2)
//        ])
//        setupMainStack()
//        reportLabelDesign()
//        mapViewDesign()
//        mapViewStack()
//        fireImageDesign()
//        descriptionTextFieldDesign()
//        submitReportButtonDesign()
//        setupInfoDescriptionUI()
//        setupVotingUI()
//        previewImageDesign()
//        setupVotingInfo()
//    }
//    
//    func previewImageDesign(){
//        previewImage = UIImageView()
//        previewImage.translatesAutoresizingMaskIntoConstraints = false
//        previewImage.image = fireImage
//        previewImage.isHidden = true
//        previewImage.isUserInteractionEnabled = true
//        previewImage.contentMode = .scaleAspectFill
//        previewImage.frame = self.view.bounds
//        self.view.addSubview(previewImage)
//        previewImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
//        previewImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
//        previewImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
//        previewImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
//    }
//    
//    func setupMainStack(){
//        mainStack.alignment = .top
//        mainStack.axis = .vertical
//        self.container.addSubview(mainStack)
//        mainStack.translatesAutoresizingMaskIntoConstraints = false
//        mainStack.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16).isActive = true
//        mainStack.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -16).isActive = true
//        mainStack.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 40).isActive = true
//        mainStack.addArrangedSubview(reportLabel)
//        mainStack.addArrangedSubview(mapStack)
//    }
//    
//    func mapViewStack(){
//        mapStack.axis = .vertical
//        mapStack.alignment = .fill
//        mapStack.translatesAutoresizingMaskIntoConstraints = false
//        mapStack.addArrangedSubview(mapView)
//    }
//    
//    func reportLabelDesign(){
//        reportLabel.translatesAutoresizingMaskIntoConstraints = false
//        reportLabel.text = "Fire Report Summary"
//        reportLabel.font = reportLabel.font.withSize(28)
//        reportLabel.textColor = UIColor.black
//    }
//    
//    func mapViewDesign(){
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//        mapView.layer.cornerRadius = 10
//        mapView.heightAnchor.constraint(equalToConstant:200).isActive = true
//        mapView.layer.borderWidth = 1
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
//            fireImageView.topAnchor.constraint(equalTo: mapStack.bottomAnchor, constant:40),
//            fireImageView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
//            fireImageView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -200)
//        ])
//    }
//  
//    func descriptionTextFieldDesign(){
//        descriptionTextField = UITextView()
//        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
//        descriptionTextField.layer.cornerRadius = 10
//        descriptionTextField.font = UIFont.systemFont(ofSize: 14)
//        descriptionTextField.textColor = UIColor.black
//        descriptionTextField.backgroundColor = UIColor.descriptionBackgroundColor
//        descriptionTextField.inputAccessoryView = toolbar
//        descriptionTextField.isEditable = isTextFieldEditable
//        descriptionTextField.text = descriptionText
//        self.view.addSubview(descriptionTextField)
//        NSLayoutConstraint.activate([
//            descriptionTextField.heightAnchor.constraint(equalToConstant:200),
//            descriptionTextField.topAnchor.constraint(equalTo: mapStack.bottomAnchor, constant: 40),
//            descriptionTextField.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 240),
//            descriptionTextField.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -20),
//        ])
//    }
//    
//    func setupVotingInfo(){
//        voteInfo.translatesAutoresizingMaskIntoConstraints = false
//        voteInfo.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        voteInfo.textColor = UIColor.primaryColor
//        voteInfo.isHidden = isVoteForHidden
//        self.view.addSubview(voteInfo)
//        NSLayoutConstraint.activate([
//            voteInfo.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
//            voteInfo.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
//        ])
//
//        
//        voteLabel.translatesAutoresizingMaskIntoConstraints = false
//        voteLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        voteLabel.textColor = UIColor.primaryColor
//        voteLabel.text = "people have voted for this location as the most dangerous"
//        voteLabel.isHidden = isVoteForHidden
//        self.view.addSubview(voteLabel)
//        NSLayoutConstraint.activate([
//            voteLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
//            voteLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 40),
//        ])
//    }
//    
//    func setupInfoDescriptionUI(){
//        votingDescription = UILabel()
//        votingDescription.translatesAutoresizingMaskIntoConstraints = false
//        votingDescription.font = UIFont.systemFont(ofSize: 14)
//        votingDescription.text = "There was a fire reported at this location"
//        votingDescription.isHidden = isvotingDescriptionHidden
//        self.view.addSubview(votingDescription)
//        NSLayoutConstraint.activate([
//            votingDescription.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant: 12),
//            votingDescription.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 95)
//        ])
//        let infoIcon = UIImage(systemName: "info.circle")
//        infoImage = UIImageView()
//        infoImage.translatesAutoresizingMaskIntoConstraints = false
//        infoImage.image = infoIcon
//        infoImage.isHidden = isvotingDescriptionHidden
//        self.view.addSubview(infoImage)
//        NSLayoutConstraint.activate([
//            infoImage.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant: 10),
//            infoImage.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 65)
//        ])
//    }
//    
//    func setupVotingUI(){
//        voteFor = UIButton()
//        voteFor.translatesAutoresizingMaskIntoConstraints = false
//        voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
//        voteFor.contentVerticalAlignment = .fill
//        voteFor.contentHorizontalAlignment = .fill
//        voteFor.contentMode = .scaleAspectFill
//        self.view.addSubview(voteFor)
//        voteFor.isHidden = isVoteForHidden
//        voteFor.addTarget(self, action: #selector(putVote), for: .touchUpInside)
//        NSLayoutConstraint.activate([
//            voteFor.heightAnchor.constraint(equalToConstant: 70),
//            voteFor.widthAnchor.constraint(equalToConstant: 70),
//            voteFor.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 125),
//            voteFor.bottomAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 150)
//        ])
//        let arrowDown = UIImage(systemName: "arrow.down.square.fill")
//        voteAgainst = UIButton()
//        voteAgainst.translatesAutoresizingMaskIntoConstraints = false
//        voteAgainst.setImage(UIImage(systemName:"arrow.down.square"), for: .normal)
//        voteAgainst.addTarget(self, action: #selector(removeVote), for: .touchUpInside)
//        voteAgainst.contentVerticalAlignment = .fill
//        voteAgainst.contentHorizontalAlignment = .fill
//        self.view.addSubview(voteAgainst)
//        voteAgainst.isHidden = isVoteAgainstHidden
//        NSLayoutConstraint.activate([
//            voteAgainst.heightAnchor.constraint(equalToConstant: 70),
//            voteAgainst.widthAnchor.constraint(equalToConstant: 70),
//            voteAgainst.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant:-125),
//            voteAgainst.bottomAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 150)
//        ])
//    }
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
//        confirmReportButton.addTarget(self, action: #selector(sendReport), for: .touchUpInside)
//        self.view.addSubview(confirmReportButton)
//        confirmReportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        confirmReportButton.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant:-35).isActive = true
//        confirmReportButton.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 35).isActive = true
//        confirmReportButton.topAnchor.constraint(equalTo: fireImageView.bottomAnchor, constant: 100).isActive = true
//    }
//    
//    
//    @objc func showPreview(_ sender:AnyObject){
//        previewImage.isHidden = false
//    }
//    
//    @objc func hidePreview(_ sender:AnyObject){
//        previewImage.isHidden = true
//        votingDescription.isHidden = false
//    }
//}












//
//  FinalReportViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 8.10.23.
//
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
    private let firebaseService = FirebaseService()

    let userArray: [User] = []


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
    var voteFor = UIButton()
    var voteAgainst = UIButton()
    var votingDescription = UILabel()
    var imageURL = ""
    var addressName: String?
    var issubmitVoteHidden = true
    var isvotingDescriptionHidden = true
    var isVoteForHidden = true
    var isVoteAgainstHidden = true
    var infoImage = UIImageView()
    var voteInfo = UILabel()
    var voteLabel = UILabel()
    var ID:String!
    var votes: Int?
    var mainStack = UIStackView()
    var userVotes:Int = 0
    var updatedUserVote = 0
    var isUserVerified: Bool!
    var upVoteSelected: Bool!
    var downVoteSelected: Bool!
    var thisUser: Vote?
    var collectionVotes: Int!
    var totalVote: Int!
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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePreview(_:)))
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showPreview(_:)))
        previewImage.isUserInteractionEnabled = true
        previewImage.addGestureRecognizer(tapGestureRecognizer)
        fireImageView.isUserInteractionEnabled = true
        fireImageView.addGestureRecognizer(tapGestureRecognizer1)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName:"x.circle"), target: self, action: #selector(dismissScreen))
//        getUserVotes()
        getQuantity { [weak self] quantity in
              if let self = self, let quantity = quantity {
                  self.userVotes = quantity
                  print("Quantity in viewDidLoad: \(quantity)")
              }
          }
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        finalReportViewModel.configureLocationManager()
        fireLocation()
        getQuantity { [weak self] quantity in
              if let self = self, let quantity = quantity {
                  self.userVotes = quantity
                  print("Quantity in viewDidLoad: \(quantity)")
              }
          }
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getQuantity { [weak self] quantity in
            if let self = self, let quantity = quantity {
                self.userVotes = quantity
                print("Quantity in viewDidLoad: \(quantity)")
            }
        }
//        getUserVotes()
        self.isUserVerified = Auth.auth().currentUser?.isEmailVerified
        print("\(isUserVerified!)is user verified")
        print("\(collectionVotes ?? 0) report votes")
        self.voteInfo.text = String(collectionVotes ?? 0)
        updatedUserVote = userVotes
    }
    
    @objc func dismissScreen(){
        dismiss(animated: true, completion: nil)
    }

    func fireLocation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = "Fire was located here"
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        convertLatLongToAddress(latitude:coordinates.latitude,longitude:coordinates.longitude)
    }

    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.5)?.base64EncodedString() ?? ""
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

    func convertLatLongToAddress(latitude:Double,longitude:Double){

        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if let city = placeMark.locality {
                self.addressName = city
            }
        })
    }
    
    func getQuantity(completion: @escaping (Int?) -> Void){
           let db = Firestore.firestore()
           db.collection("reports").document(self.ID).collection("Votes").whereField("userID", isEqualTo: Auth.auth().currentUser?.uid ?? "").getDocuments { votesQuantity, error in
               guard let documents = votesQuantity?.documents else {
                   print("No Documents")
                   completion(nil)
                   return
               }
               
               if let quantity = documents.first?.data()["quantity"] as? Int {
                   self.userVotes = quantity
                   if self.userVotes == nil || self.userVotes == 0 {
                       self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
                       self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
                   } else if self.userVotes > 0 {
                       self.upVoteSelected = true
                       self.voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
                       self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
                   } else if self.userVotes < 0{
                       self.upVoteSelected = false
                       self.voteFor.setImage(UIImage(systemName:"arrow.down.square.fill"), for: .normal)
                       self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
                   }
                   completion(quantity)
               } else {
                   completion(nil)
               }
           }
    }

    @objc func sendReport(){
        let userID = Auth.auth().currentUser
        var votes = 0
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                votes += 1
            } else {
                votes += 10
            }
        }
        let myCompressedImage = convertImageToBase64String(img: (fireImage ?? UIImage(named: "androidKiller"))!)
        let db = Firestore.firestore()
        let fireReport = FireReport(description: descriptionTextField.text, id:self.ID, lat: coordinates.latitude, long: coordinates.longitude, photo: myCompressedImage, timestamp: Date(), uniqueIdentifier: UIDevice.current.identifierForVendor!.uuidString, address: addressName, votes:votes)
        print(fireReport)
        db.collection("reports").document(self.ID).setData(fireReport.dictionary) { err in
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

    @objc func putVote(){
        let voteWeight = isUserVerified ? 10 : 1
        if updatedUserVote == voteWeight {
            updatedUserVote = 0
            self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
        } else if updatedUserVote < 0 {
            updatedUserVote = voteWeight
            self.voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
        } else {
            updatedUserVote += voteWeight
            self.voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
        }
        totalVote = self.collectionVotes + self.updatedUserVote - self.userVotes
        self.voteInfo.text = String(totalVote)
        print("\(self.collectionVotes + self.updatedUserVote - self.userVotes) ghhghg")
        print("\(updatedUserVote) updated user vote")
        print(collectionVotes!)
    }

    @objc func removeVote(){
        let voteWeight = isUserVerified ? -10 : -1
        if updatedUserVote == voteWeight {
            updatedUserVote = 0
            self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
        } else if updatedUserVote > 0 {
            updatedUserVote = voteWeight
            self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
        } else {
            updatedUserVote += voteWeight
            self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
            self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
        }
        totalVote = self.collectionVotes + self.updatedUserVote - self.userVotes
        self.voteInfo.text = String(totalVote)
        print("\(self.collectionVotes + self.updatedUserVote - self.userVotes) ghhghg")
        print("\(updatedUserVote) updated user vote")
        print(collectionVotes!)
    }
    
    func sentVote(){
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser
        thisUser?.quantity = userVotes
        let vote = Vote(createdAt: Date(), documentID: self.ID, quantity: updatedUserVote, userID: userID?.uid ?? "")
        db.collection("reports").document(self.ID).collection("Votes").document(userID?.uid ?? "").getDocument { [self] querrySnapshot, error in
            if querrySnapshot?.exists == true {
                db.collection("reports").document(self.ID).collection("Votes").document(userID?.uid ?? " ").updateData(vote.dictionary)
//                db.collection("reports").document(self.ID).updateData(["votes": self.totalVote!])
                db.collection("reports").document(self.ID).updateData(["votes": FieldValue.increment(Double(totalVote))])

            } else {
                db.collection("reports").document(self.ID).collection("Votes").document(userID?.uid ?? " ").setData(vote.dictionary, merge: true)
//                db.collection("reports").document(self.ID).updateData(["votes" : FieldValue.increment(totalVote!)])
                db.collection("reports").document(self.ID).updateData(["votes": FieldValue.increment(Double(totalVote))])
            }
            print("my votes flag")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            sentVote()
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
        setupInfoDescriptionUI()
        setupVotingUI()
        previewImageDesign()
        setupVotingInfo()
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

    func setupMainStack(){

    }

    func mapViewDesign(){
        self.view.addSubview(mapView)
        mapView.layer.cornerRadius = 10
        mapView.heightAnchor.constraint(equalToConstant:200).isActive = true
        mapView.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant:40).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16).isActive = true
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

    func setupVotingInfo(){
        voteInfo.translatesAutoresizingMaskIntoConstraints = false
        voteInfo.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        voteInfo.textColor = UIColor.primaryColor
        voteInfo.isHidden = isVoteForHidden
        self.view.addSubview(voteInfo)
        NSLayoutConstraint.activate([
            voteInfo.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            voteInfo.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
        ])


        voteLabel.translatesAutoresizingMaskIntoConstraints = false
        voteLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        voteLabel.textColor = UIColor.primaryColor
        voteLabel.text = "votes for this location as the most dangerous"
        voteLabel.isHidden = isVoteForHidden
        self.view.addSubview(voteLabel)
        NSLayoutConstraint.activate([
            voteLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            voteLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 40),
        ])
    }

    func setupInfoDescriptionUI(){
        votingDescription = UILabel()
        votingDescription.translatesAutoresizingMaskIntoConstraints = false
        votingDescription.font = UIFont.systemFont(ofSize: 14)
        votingDescription.text = "There was a fire reported at this location"
        votingDescription.isHidden = isvotingDescriptionHidden
        self.view.addSubview(votingDescription)
        NSLayoutConstraint.activate([
            votingDescription.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant: 12),
            votingDescription.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 95)
        ])
        let infoIcon = UIImage(systemName: "info.circle")
        infoImage = UIImageView()
        infoImage.translatesAutoresizingMaskIntoConstraints = false
        infoImage.image = infoIcon
        infoImage.isHidden = isvotingDescriptionHidden
        self.view.addSubview(infoImage)
        NSLayoutConstraint.activate([
            infoImage.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant: 10),
            infoImage.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 65)
        ])
    }

    func setupVotingUI(){
        voteFor = UIButton()
        voteFor.translatesAutoresizingMaskIntoConstraints = false
        voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
        voteFor.contentVerticalAlignment = .fill
        voteFor.contentHorizontalAlignment = .fill
        voteFor.contentMode = .scaleAspectFill
        self.view.addSubview(voteFor)
        voteFor.isHidden = isVoteForHidden
        voteFor.addTarget(self, action: #selector(putVote), for: .touchUpInside)
        NSLayoutConstraint.activate([
            voteFor.heightAnchor.constraint(equalToConstant: 70),
            voteFor.widthAnchor.constraint(equalToConstant: 70),
            voteFor.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 125),
            voteFor.bottomAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 150)
        ])
        voteAgainst = UIButton()
        voteAgainst.translatesAutoresizingMaskIntoConstraints = false
        voteAgainst.setImage(UIImage(systemName:"arrow.down.square"), for: .normal)
        voteAgainst.addTarget(self, action: #selector(removeVote), for: .touchUpInside)
        voteAgainst.contentVerticalAlignment = .fill
        voteAgainst.contentHorizontalAlignment = .fill
        self.view.addSubview(voteAgainst)
        voteAgainst.isHidden = isVoteAgainstHidden
        NSLayoutConstraint.activate([
            voteAgainst.heightAnchor.constraint(equalToConstant: 70),
            voteAgainst.widthAnchor.constraint(equalToConstant: 70),
            voteAgainst.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant:-125),
            voteAgainst.bottomAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 150)
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
        voteLabel.isHidden = true
        voteInfo.isHidden = true
    }

    @objc func hidePreview(_ sender:AnyObject){
        previewImage.isHidden = true
        votingDescription.isHidden = false
        isVoteForHidden = false
        voteLabel.isHidden = false
        voteInfo.isHidden = false
    }
    }
