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

class FinalReportViewController: UIViewController, UITextViewDelegate {

    private let finalReportViewModel = FinalReportViewModel()
    private let firebaseService = FirebaseService()
    private let keychainService = KeychainService()
    var delegate: MyDataSendingDelegateProtocol?

    let userArray: [User] = []

    var onChange: (() -> Void)?
    var currentLocation: CLLocation!
    var fireImage: UIImage!
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
    var horizontalStack = UIStackView()
    var userVotes:Int = 0
    var updatedUserVote = 0
    var isUserVerified: Bool!
    var upVoteSelected: Bool!
    var downVoteSelected: Bool!
    var thisUser: Vote?
    var collectionVotes: Int!
    var totalVote: Int!
    var IDfromKeychain:String?
    var hasSentVote: Bool?
    var hasChanges = false
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let availableImage = fireImage {
            fireImageView.image = availableImage
        } else {
            getImage()
        }
        setupUI()
        if let savedUUID = keychainService.retrieveUUIDFromKeychain() {
            self.IDfromKeychain = savedUUID
            print("UUID from Keychain: \(savedUUID)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willResignActiveNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isUserVerified = Auth.auth().currentUser?.isEmailVerified
        finalReportViewModel.configureLocationManager()
        fireLocation()
        getAllVotes { [weak self] (documents, error) in
            guard let self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let documents = documents {
                for document in documents {
                    let data = document.data()
                    if let votes = data?["votes"] as? Int {
                        self.collectionVotes = votes
                        print(self.collectionVotes ?? 0)
                        self.voteInfo.text = String(votes)
                    }
                }
            }
        }
        getQuantity { [weak self] quantity in
            if let self = self, let quantity = quantity {
                self.userVotes = quantity
                updatedUserVote = userVotes
                print("1111 Quantity in viewDidLoad: \(quantity)")
            }
        }
        print("\(String(describing: isUserVerified))is user verified")
        print("\(collectionVotes ?? 0) report votes")
            self.voteInfo.text = String(self.collectionVotes ?? 0)
        print(collectionVotes)
        print("Hello World")
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

    func getImage(){
        let myDecompressedImage = finalReportViewModel.decodeBase64ToImage(base64String: imageURL)
        fireImage = myDecompressedImage
    }
    
    // TODO: MVVM
    func getQuantity(completion: @escaping (Int?) -> Void){
        let userID = Auth.auth().currentUser
        let uid:String?
        if isUserVerified == nil || isUserVerified == false{
            uid = IDfromKeychain
        } else {
            uid = userID?.uid
        }
           let db = Firestore.firestore()
        db.collection("reports").document(self.ID).collection("Votes").whereField("userID", isEqualTo: uid ?? "").getDocuments { [weak self] votesQuantity, error in
            guard let self else { return }
               guard let documents = votesQuantity?.documents else {
                   print("No Documents")
                   completion(nil)
                   return
               }
               if let quantity = documents.first?.data()["quantity"] as? Int {
                   self.userVotes = quantity
                   if self.userVotes == 0 {
                       self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
                       self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
                   } else if self.userVotes > 0 {
                       self.upVoteSelected = true
                       self.voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
                       self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
                   } else if self.userVotes == 0 || self.userVotes <= -1{
                       self.upVoteSelected = false
                       self.voteAgainst.setImage(UIImage(systemName:"arrow.down.square.fill"), for: .normal)
                       self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
                   }
                   completion(quantity)
               } else {
                   completion(nil)
               }
           }
    }

    @objc func sendReport(){
        finalReportViewModel.sendReport(fireReport: FireReport(description: descriptionTextField.text, id: self.ID, lat: coordinates.latitude, long: coordinates.longitude, photo: "", timestamp: Date(), uniqueIdentifier: UIDevice.current.identifierForVendor!.uuidString, address: "", votes: 0, createdByVerifiedUser: false), fireImage: fireImage) {
            if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
                scene.photoState = .completed
            }
            self.navigationController?.popToRootViewController(animated: false)
            let successView = SuccessMessageViewController()
            self.present(successView, animated: true)
        } error: {
            self.present(Alert(text: "Error!", message: "Error sending report", confirmAction: [UIAlertAction(title: "Try again", style: .default)], disableAction: []))
        }
    }

    @objc func putVote(){
        var voteWeight: Int!
        isUserVerified = Auth.auth().currentUser?.isEmailVerified
        var votes = 0
        if isUserVerified == nil || isUserVerified == false{
            voteWeight = 1
        } else {
            voteWeight = 10
        }
          if updatedUserVote == voteWeight {
              updatedUserVote = 0
//              hasChanges = false
              self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
              self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
          } else if updatedUserVote < 0 {
              updatedUserVote = voteWeight
//              hasChanges = true
              self.voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
              self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
          } else {
              updatedUserVote += voteWeight
//              hasChanges = true
              self.voteFor.setImage(UIImage(systemName:"arrow.up.square.fill"), for: .normal)
              self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
          }
          totalVote = self.collectionVotes + self.updatedUserVote - self.userVotes
          self.voteInfo.text = String(totalVote)
          print("\(self.collectionVotes + self.updatedUserVote - self.userVotes) ghhghg")
          print("\(updatedUserVote) updated user vote")
          print(collectionVotes!)
//        hasChanges.toggle()
        hasChanges = userVotes != updatedUserVote
        print(hasChanges)
        
      }
    
    @objc func removeVote(){
        var voteWeight: Int!
        isUserVerified = Auth.auth().currentUser?.isEmailVerified
        var votes = 0
        if isUserVerified == nil || isUserVerified == false{
            voteWeight = -1
        } else {
            voteWeight = -10
        }
           if updatedUserVote == voteWeight {
               updatedUserVote = 0
//               hasChanges = false
               self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
               self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
           } else if updatedUserVote > 0 {
               updatedUserVote = voteWeight
//               hasChanges = true
               self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
               self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
           } else {
               updatedUserVote += voteWeight
//               hasChanges = true
               self.voteFor.setImage(UIImage(systemName:"arrow.up.square"), for: .normal)
               self.voteAgainst.setImage(UIImage(systemName: "arrow.down.square.fill"), for: .normal)
           }
           totalVote = self.collectionVotes + self.updatedUserVote - self.userVotes
           self.voteInfo.text = String(totalVote)
           print("\(self.collectionVotes + self.updatedUserVote - self.userVotes) ghhghg")
           print("\(updatedUserVote) updated user vote")
           print(collectionVotes!)
//        hasChanges = true
        hasChanges = userVotes != updatedUserVote
        print(hasChanges)

       }
    
    //TODO: MVVM
    func sentVote() {
        let userID = Auth.auth().currentUser
        let uid:String?
        var isCreatedVerifiedUser: Bool!
        if isUserVerified == nil || isUserVerified == false{
            uid = IDfromKeychain
            isCreatedVerifiedUser = false
        } else {
            uid = userID?.uid
            isCreatedVerifiedUser = true
        }
        let myVote = updatedUserVote - self.userVotes
        if updatedUserVote == userVotes {
            print("5555 send vote and dismiss")
            dismiss(animated: true, completion: nil)
        } else {
            let db = Firestore.firestore()
            thisUser?.quantity = userVotes
            let vote = Vote(createdAt: Date(), documentID: self.ID, quantity: updatedUserVote, userID: uid ?? "", createdByVerifiedUser: isCreatedVerifiedUser)
            print("5555 send vote before update")
            db.collection("reports").document(self.ID).collection("Votes").document(uid ?? "").getDocument { [weak self] querrySnapshot, error in
                guard let self else { return }
                hasChanges = false
                if querrySnapshot?.exists == true {
                    db.collection("reports").document(self.ID).collection("Votes").document(uid ?? "").updateData(vote.dictionary)
                    db.collection("reports").document(self.ID).updateData(["votes": FieldValue.increment(Double(myVote))])
                } else {
                    db.collection("reports").document(self.ID).collection("Votes").document(uid ?? "").setData(vote.dictionary, merge: true)
                    db.collection("reports").document(self.ID).updateData(["votes": FieldValue.increment(Double(myVote))])
                }
                print("5555 my votes flag")
                getQuantity { [weak self] quantity in
                    if let self = self, let quantity = quantity {
                        self.userVotes = quantity
                        updatedUserVote = userVotes
                        print("Quantity in viewDidLoad: \(quantity)")
                    }
                }
                getAllVotes { [weak self](documents, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else if let documents = documents {
                        for document in documents {
                            guard let self else { return }
                            let data = document.data()
                            if let votes = data?["votes"] as? Int {
                                self.collectionVotes = votes
                                print("\(self.collectionVotes ?? 0) my votesssssssss")
                                self.voteInfo.text = String(votes)
                                print("All votes are here")
                            }
                        }
                    }
                }
            }
        }
     }
    
    func getAllVotes(completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("reports").whereField("id", isEqualTo: self.ID ?? "").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(querySnapshot?.documents, nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        onChange?()
        if updatedUserVote == userVotes {
            print("You havent voted yet")
        }else {
            sentVote()
        }
        print("Is dismissed")
    }
    
    @objc func appWillTerminate(){
        if hasChanges {
            sentVote()
        } else {
            print("You haven't voted yet")
        }
        print("pspspsppspspspspssp")
    }
    
    @objc func appDidBecomeActive(){
            print("The app is active")
    }
    
    func setupUI(){
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        let hConst = container.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        hConst.isActive = true
        hConst.priority = UILayoutPriority(50)
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboard)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.backgroundColor = .white
        view.backgroundColor = .white
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
        setupVotingInfo()
//        setupHorizontalStack()
        previewImageDesign()
        
    }

    func previewImageDesign(){
        previewImage = UIImageView()
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        previewImage.image = fireImage
        previewImage.isHidden = true
        previewImage.isUserInteractionEnabled = true
        previewImage.contentMode = .scaleAspectFill
        previewImage.frame = self.view.bounds
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hidePreview(_:)))
        previewImage.isUserInteractionEnabled = true
        previewImage.addGestureRecognizer(tapGestureRecognizer)
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
        reportLabel.textColor = UIColor.textColor
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

    //TODO: Fix autolayout

    func fireImageDesign(){
        fireImageView = UIImageView()
        fireImageView.contentMode = .scaleAspectFill
        fireImageView.clipsToBounds = true
        fireImageView.translatesAutoresizingMaskIntoConstraints = false
        fireImageView.image = fireImage
        fireImageView.layer.cornerRadius = 10
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showPreview(_:)))
        fireImageView.isUserInteractionEnabled = true
        fireImageView.addGestureRecognizer(tapGestureRecognizer1)
        self.view.addSubview(fireImageView)
        NSLayoutConstraint.activate([
            fireImageView.heightAnchor.constraint(equalToConstant:200),
            fireImageView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant:40),
            fireImageView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
            fireImageView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -200)
        ])
    }

    //TODO: Fix autolayout

    func descriptionTextFieldDesign(){
        descriptionTextField = UITextView()
        descriptionTextField.delegate = self
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new text length if the change is allowed
        let currentText = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        // Check if the updated text length exceeds 20 characters
        if updatedText.count > 35 {
            return false
        }
        
        return true
    }

    
    //TODO: Fix autolayout
    func setupVotingInfo(){
        voteInfo.translatesAutoresizingMaskIntoConstraints = false
        voteInfo.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        voteInfo.textColor = UIColor.primaryColor
        voteInfo.isHidden = isVoteForHidden
        voteInfo.textColor = UIColor.textColor
        self.view.addSubview(voteInfo)
        NSLayoutConstraint.activate([
            voteInfo.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            voteInfo.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16),
        ])
        voteLabel.translatesAutoresizingMaskIntoConstraints = false
        voteLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        voteLabel.textColor = UIColor.textColor
        voteLabel.text = "votes for this location as the most dangerous"
        voteLabel.isHidden = isVoteForHidden
        self.view.addSubview(voteLabel)
        NSLayoutConstraint.activate([
            voteLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            voteLabel.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 40),
        ])
    }

    //TODO: Fix autolayout
    func setupInfoDescriptionUI(){
        votingDescription = UILabel()
        votingDescription.translatesAutoresizingMaskIntoConstraints = false
        votingDescription.font = UIFont.systemFont(ofSize: 14)
        votingDescription.textColor = UIColor.textColor
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
    
//    func setupHorizontalStack(){
//        horizontalStack = UIStackView()
//        horizontalStack.distribution = .fillEqually
//        horizontalStack.alignment = .fill
//        horizontalStack.spacing = 16
//        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//        horizontalStack.addArrangedSubview(voteFor)
//        horizontalStack.addArrangedSubview(voteAgainst)
//        horizontalStack.topAnchor.constraint(equalTo: self.descriptionTextField.bottomAnchor, constant: 50).isActive = true
//        horizontalStack.widthAnchor.constraint(equalToConstant: 300).isActive = true
//        horizontalStack.heightAnchor.constraint(equalToConstant: 120).isActive = true
//        self.view.addSubview(horizontalStack)
//    }

    //TODO: Fix autolayout
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
        confirmReportButton = UIButton(type:.system)
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
        isVoteForHidden = false
    }
}
