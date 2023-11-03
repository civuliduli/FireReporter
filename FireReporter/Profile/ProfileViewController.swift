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
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit


class ProfileViewController: UIViewController {
    
    private let firebaseService = FirebaseService()
    
    private var currentNonce:String?
    var profileLabel = UILabel()
    var verifyAccountLabel = UILabel()
    var verifyFacebook = UIButton()
    var verifyGoogle = UIButton()
    var verifyApple = UIButton()
    var myReports = UILabel()
    var usernameLabel = UILabel()
    var verificationBadge = UIImageView()
    var verificationInfo = UILabel()
    var infoBadge = UIImageView()
    var signOutButton = UIButton()
    var horizontalStack = UIStackView()
    let scrollView = UIScrollView()
    var container = UIView()
    let verticalStack = UIStackView()
    let badgeStack = UIStackView()
    let usernameProfileStack = UIStackView()
    var isUserProfileHidden:Bool?
    var reportsArray = [FireReport]()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkAuthenticatedUser()
    }
    
    enum AuthenticationError:Error {
        case authTokenError
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFireReports()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    
    func getFireReports(){
        firebaseService.getFireReportsData { myFireReports, error in
            self.reportsArray = myFireReports
            self.tableView.reloadData()
        }
    }
    
    @objc func setupFacebookVerification(){
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
            guard let accessToken = AccessToken.current?.tokenString else {
                print("Failed to get access token for Facebook")
                return
            }
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken)
            Auth.auth().signIn(with: credentials, completion: { (data, error) in
                guard let result = data, error == nil else {
                    print("FB Login Error: \(String(describing: error?.localizedDescription))")
                    return
                }
                self?.checkAuthenticatedUser()
            })
        }
    }
    
    @objc func setupAppleVerification(){
        currentNonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(currentNonce!)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    @objc func setupGoogleVerification() {
                firebaseService.googleAuth {
                    self.present(Alert(text: "Authentication Cancelled", message: "", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                } onSuccess: {
                    self.checkAuthenticatedUser()
                    self.present(Alert(text: "Success", message: "You now are a WildFireReporter verified User", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                } onAuthError: {
                    self.present(Alert(text: "Auth Error", message: "Please try again later", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                }
    }
    
    func checkAuthenticatedUser(){
        guard let userID = Auth.auth().currentUser else { return }
        usernameLabel.text = userID.displayName
        userID.getIDToken()
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate{
            if let user = Auth.auth().currentUser {
                if user.isAnonymous {
                    isUserProfileHidden = true
                    usernameLabel.isHidden = true
                    verificationBadge.isHidden = true
                    signOutButton.isHidden = true
                    verifyFacebook.isHidden = false
                    verificationInfo.isHidden = false
                    verifyGoogle.isHidden = false
                    verifyApple.isHidden = false
                    verifyAccountLabel.isHidden = false
                    infoBadge.isHidden = false
                    usernameProfileStack.isHidden = true
                } else {
                    isUserProfileHidden = false
                    usernameLabel.isHidden = false
                    verificationBadge.isHidden = false
                    signOutButton.isHidden = false
                    verifyFacebook.isHidden = true
                    verifyGoogle.isHidden = true
                    verifyApple.isHidden = true
                    verifyAccountLabel.isHidden = true
                    verificationInfo.isHidden = true
                    infoBadge.isHidden = true
                    usernameProfileStack.isHidden = false
                }
            }
        }
    }
    
    
    @objc func signOutFunction(){
        do{
          try Auth.auth().signOut()
            checkAuthenticatedUser()
            print("Hellooo")
            usernameLabel.isHidden = true
            verificationBadge.isHidden = true
            signOutButton.isHidden = true
            verifyFacebook.isHidden = false
            verificationInfo.isHidden = false
            verifyGoogle.isHidden = false
            verifyApple.isHidden = false
            verifyAccountLabel.isHidden = false
            infoBadge.isHidden = false
            present(Alert(text: "User is signed out", message: "", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
            Auth.auth().signInAnonymously()
        }
        catch {
            print("Error signing out")
        }
    }
    
    func setupUI(){
        self.view.addSubview(scrollView)
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = UIColor.secondaryColor
        UITabBar.appearance().backgroundColor = UIColor.white
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
        getFireReports()
        reportListTitleLabel()
        verifyAccountLabelUI()
        verifyWithFacebookButtonDesign()
        verifyWithGoogleButtonDesign()
        verifyWithAppleButtonDesign()
        reportListTitleLabel()
        setupUsernameUI()
        checkAuthenticatedUser()
        signOutButtonUI()
        setupHorizontalStack()
        verificationBadgeDesign()
        verifyInfoUI()
        infoBadgeUI()
        setupProfileStack()
        badgeStackUI()
        setupVerticalStack()
        myReportsLabelDesign()
        setupTableUI()
    }
    
    func setupVerticalStack(){
        verticalStack.distribution = .fill
        verticalStack.alignment = .top
        verticalStack.spacing = 16
        verticalStack.axis = .vertical
        self.container.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 16).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: -16).isActive = true
        verticalStack.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 40).isActive = true
        verticalStack.addArrangedSubview(profileLabel)
        verticalStack.addArrangedSubview(verifyAccountLabel)
        verticalStack.addArrangedSubview(horizontalStack)
        verticalStack.addArrangedSubview(usernameProfileStack)
        verticalStack.addArrangedSubview(badgeStack)
    }
    
    func updateArrangedSubviews(verifies: Bool) {
        verticalStack.arrangedSubviews.forEach { subview in
            verticalStack.removeArrangedSubview(subview)
        }
    }
  
    func setupTableUI(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.container.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.secondaryColor
        tableView.backgroundColor = .white
        tableView.allowsSelection = true
        tableView.register(ReportListCustomTableViewCell.self, forCellReuseIdentifier: ReportListCustomTableViewCell.identifier)
        checkAuthenticatedUser()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: myReports.bottomAnchor, constant: 20),
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
    }
    
    
    func setupUsernameUI(){
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = usernameLabel.font.withSize(30)
        checkAuthenticatedUser()
        usernameLabel.textColor = UIColor.primaryColor
        usernameLabel.isHidden = true
    }
    
    func setupProfileStack(){
        usernameProfileStack.distribution = .fill
        usernameProfileStack.alignment = .fill
        usernameProfileStack.spacing = 16
        usernameProfileStack.translatesAutoresizingMaskIntoConstraints = false
        usernameProfileStack.addArrangedSubview(usernameLabel)
        usernameProfileStack.addArrangedSubview(verificationBadge)
        usernameProfileStack.addArrangedSubview(signOutButton)
    }
    
    func verificationBadgeDesign(){
        verificationBadge = UIImageView()
        verificationBadge.translatesAutoresizingMaskIntoConstraints = false
        verificationBadge.isHidden = true
        checkAuthenticatedUser()
        verificationBadge.image = UIImage(named:"istockphoto-1313547780-612x612")
        self.view.addSubview(verificationBadge)
        verificationBadge.heightAnchor.constraint(equalToConstant: 40).isActive = true
        verificationBadge.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func verifyAccountLabelUI(){
        verifyAccountLabel = UILabel()
        verifyAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        verifyAccountLabel.text = "Verify Account"
        verifyAccountLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        verifyAccountLabel.textColor = UIColor.primaryColor
        verifyAccountLabel.isHidden = false
        checkAuthenticatedUser()
        self.view.addSubview(verifyAccountLabel)
    }
    
    func setupHorizontalStack(){
        horizontalStack = UIStackView()
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .fill
        horizontalStack.spacing = 16
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.addArrangedSubview(verifyFacebook)
        horizontalStack.addArrangedSubview(verifyGoogle)
        horizontalStack.addArrangedSubview(verifyApple)
    }
    
    func verifyWithFacebookButtonDesign(){
        var facebookImage = UIImage(named:"facebook")
//        verifyFacebook = FBLoginButton()
        verifyFacebook.translatesAutoresizingMaskIntoConstraints = false
        verifyFacebook.setImage(facebookImage, for: .normal)
        verifyFacebook.imageEdgeInsets = UIEdgeInsets(top: 50, left: 80, bottom: 50, right: 80)
        verifyFacebook.backgroundColor = UIColor.defaultWhiteColor
        verifyFacebook.layer.cornerRadius = 20
        verifyFacebook.layer.borderWidth = 1
        checkAuthenticatedUser()
        verifyFacebook.isHidden = false
        verifyFacebook.contentMode = .scaleAspectFit
        verifyFacebook.addTarget(self, action: #selector(setupFacebookVerification), for: .touchUpInside)
        verifyFacebook.heightAnchor.constraint(equalToConstant: 55).isActive = true
    }
    
    func verifyWithGoogleButtonDesign(){
        let googleImage = UIImage(named:"search")
        verifyGoogle = UIButton()
        verifyGoogle.translatesAutoresizingMaskIntoConstraints = false
        verifyGoogle.clipsToBounds = true
        verifyGoogle.setImage(googleImage, for: .normal)
        verifyGoogle.imageEdgeInsets = UIEdgeInsets(top: 45, left: 75, bottom: 45, right: 75)
        verifyGoogle.layer.cornerRadius = 20
        verifyGoogle.layer.borderWidth = 1
        checkAuthenticatedUser()
        verifyGoogle.isHidden = false
        verifyGoogle.contentMode = .scaleAspectFit
        verifyFacebook.backgroundColor = UIColor.defaultWhiteColor
        verifyGoogle.addTarget(self, action: #selector(setupGoogleVerification), for: .touchUpInside)
        verifyGoogle.heightAnchor.constraint(equalToConstant: 55).isActive = true
    }
    
    func verifyWithAppleButtonDesign(){
        let appleImage = UIImage(named: "apple-3")
        verifyApple = UIButton(frame: CGRect(x: 0, y: 0, width:55 , height: 55))
        verifyApple.translatesAutoresizingMaskIntoConstraints = false
        verifyApple.clipsToBounds = true
        verifyApple.setImage(appleImage, for: .normal)
        verifyApple.backgroundColor = UIColor.defaultWhiteColor
        verifyApple.layer.borderWidth = 1
        verifyApple.contentMode = .scaleAspectFit
        verifyApple.imageEdgeInsets = UIEdgeInsets(top: 70, left: 100, bottom: 70, right: 100)
        checkAuthenticatedUser()
        verifyApple.isHidden = false
        verifyApple.layer.cornerRadius = 20
        verifyApple.addTarget(self, action: #selector(setupAppleVerification), for: .touchUpInside)
        verifyApple.heightAnchor.constraint(equalToConstant: 55).isActive = true
    }
    
    func badgeStackUI(){
        badgeStack.distribution = .fill
        badgeStack.alignment = .fill
        badgeStack.spacing = 16
        badgeStack.translatesAutoresizingMaskIntoConstraints = false
        badgeStack.addArrangedSubview(infoBadge)
        badgeStack.addArrangedSubview(verificationInfo)
    }
    
    func verifyInfoUI(){
        verificationInfo = UILabel()
        verificationInfo.translatesAutoresizingMaskIntoConstraints = false
        verificationInfo.text = "Verified users are refelcted with their higher level of trustworthines"
        verificationInfo.font = verificationInfo.font.withSize(11)
        verificationInfo.textColor = UIColor.primaryColor
        verificationInfo.numberOfLines = 1
        verificationInfo.sizeToFit()
        verificationInfo.isHidden = false
        checkAuthenticatedUser()
    }
    
    func infoBadgeUI(){
        let infoImage = UIImage(systemName: "info.circle")
        infoBadge = UIImageView()
        infoBadge.translatesAutoresizingMaskIntoConstraints = false
        infoBadge.image = infoImage
        infoBadge.isHidden = false
        checkAuthenticatedUser()
    }
    
    func signOutButtonUI(){
        signOutButton = UIButton()
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.setTitle("Sign Out!", for: .normal)
        signOutButton.backgroundColor = .systemRed
        signOutButton.layer.cornerRadius = 10
        signOutButton.isHidden = true
        checkAuthenticatedUser()
        self.view.addSubview(signOutButton)
        signOutButton.addTarget(self, action: #selector(signOutFunction), for: .touchUpInside)
        signOutButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    func myReportsLabelDesign(){
        myReports = UILabel()
        myReports.translatesAutoresizingMaskIntoConstraints = false
        myReports.text = "My Reports"
        myReports.font = myReports.font.withSize(30)
        myReports.textColor = UIColor.primaryColor
        self.container.addSubview(myReports)
        myReports.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant:20).isActive = true
        myReports.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 20).isActive = true
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
        var address:String
        let report = reportsArray[indexPath.row]
        description = report.description ?? "No data to show"
        latitude = report.lat
        longitude = report.long
        date = report.date
        image = report.photo ?? "androidKiller"
        address = report.address ?? ""
        cell.selectionStyle = .none
        cell.setupCell(image:image,descriptionLabel: description, latitude: latitude, longitude: longitude, date:date, address: address)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var description:String
        var latitude:Double
        var longitude: Double
        let previewReport = PreviewReport()
        var image:String
        let report = reportsArray[indexPath.row]
        description = report.description ?? "No data to show"
        latitude = report.lat
        longitude = report.long
        image = report.photo!
        previewReport.descriptionText = description
        previewReport.coordinates = CLLocationCoordinate2D(latitude:latitude, longitude:longitude)
//        previewReport.isConfirmButtonHidden = true
        previewReport.isTextFieldEditable = false
        previewReport.imageURL = image
//        finalReportVC.isVoteForHidden = true
//        finalReportVC.isVoteAgainstHidden = true
        present(previewReport, animated: true, completion: nil)
    }
}

extension ProfileViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let nonce = currentNonce,
           let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let appleidToken = appleIDCredential.identityToken,
           let appleIDTokenString = String(data: appleidToken, encoding: .utf8){
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken:appleIDTokenString, rawNonce:nonce)
            Auth.auth().signIn(with: credential){(result, error) in
                if (error != nil) {
                    self.present(Alert(text: error?.localizedDescription ?? "Authentication Error", message: "", confirmAction: [UIAlertAction(title: "Try again", style: .default)], disableAction: []))
                    return
                } else {
                    self.checkAuthenticatedUser()
                    self.present(Alert(text: "Success", message: "You're now a Fire Reporter Verified User", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                }
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print(error.localizedDescription)
        }
    }
}
