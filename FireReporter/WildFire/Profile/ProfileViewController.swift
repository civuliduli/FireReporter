//
//  ReportListViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.10.23.
//

import UIKit
import Firebase
import SwiftUI


class ProfileViewController: UIViewController {
    
    private let firebaseService = FirebaseService()
    private let keychainService = KeychainService()
    private let authentication = Authentication()
    
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
        if let storedUser = UserDefaults.standard.object(forKey: "appleUsername") as? String {
            print(storedUser)
        } else {
            print("Not found")
        }
    }

    func getFireReports(){
        firebaseService.getFireReportsData { myFireReports, error in
            self.reportsArray = myFireReports
            self.tableView.reloadData()
        }
    }
    
    @objc func setupFacebookVerification(){
        authentication.facebookAuth {
            self.present(Alert(text: "Success", message: "You're now a verified Fire Reporter user", confirmAction: [UIAlertAction(title: "Great", style: .default)], disableAction: []))
            self.checkAuthenticatedUser()
        } onError: {
            self.present(Alert(text: "Error", message: "Login Failed", confirmAction: [UIAlertAction(title: "Try again", style: .default)], disableAction: []))
        }
    }
    
    @objc func setupAppleVerification(){
        setupAppleAuth()
       }
    
    @objc func setupGoogleVerification() {
        authentication.googleAuth {
                    self.present(Alert(text: "Authentication Cancelled", message: "", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                } onSuccess: {
                    self.checkAuthenticatedUser()
                    self.present(Alert(text: "Success", message: "You now are a WildFireReporter verified User", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                } onAuthError: {
                    self.present(Alert(text: "Auth Error", message: "Please try again later", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                }
    }
    
// TODO: Clean code
    func checkAuthenticatedUser(){
        guard let userID = Auth.auth().currentUser else {
            return
        }
        if let displayName = userID.displayName {
            usernameLabel.text = displayName
        } else {
            if let usernameFromUserDefaults = UserDefaults.standard.string(forKey: "appleUsername") {
                usernameLabel.text = usernameFromUserDefaults
            } else {
                usernameLabel.text = "Default Username"
            }
        }
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
        }
        catch {
            print("Error signing out")
        }
    }
    
    func setupUI(){
        self.view.addSubview(scrollView)
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = UIColor.defaultWhiteColor
        UITabBar.appearance().backgroundColor = UIColor.defaultWhiteColor
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
        verticalStack.alignment = .fill
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
        tableView.backgroundColor = UIColor.defaultWhiteColor
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
        profileLabel.textColor = UIColor.textColor
    }
    
    
    func setupUsernameUI(){
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = usernameLabel.font.withSize(30)
        checkAuthenticatedUser()
        usernameLabel.textColor = UIColor.textColor
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
        verificationBadge.image = UIImage(named:"verificationIcon")
        self.view.addSubview(verificationBadge)
        verificationBadge.heightAnchor.constraint(equalToConstant: 40).isActive = true
        verificationBadge.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func verifyAccountLabelUI(){
        verifyAccountLabel = UILabel()
        verifyAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        verifyAccountLabel.text = "Verify Account"
        verifyAccountLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        verifyAccountLabel.textColor = UIColor.textColor
        verifyAccountLabel.isHidden = false
        checkAuthenticatedUser()
        self.view.addSubview(verifyAccountLabel)
    }
    
    func setupHorizontalStack(){
        horizontalStack = UIStackView()
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .fill
        horizontalStack.distribution = .fillEqually
        horizontalStack.spacing = 16
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.addArrangedSubview(verifyFacebook)
        horizontalStack.addArrangedSubview(verifyGoogle)
        horizontalStack.addArrangedSubview(verifyApple)
    }
    
    func verifyWithFacebookButtonDesign(){
        let facebookImage = UIImage(named:"icons8-facebook-48")
        verifyFacebook.translatesAutoresizingMaskIntoConstraints = false
        verifyFacebook.setImage(facebookImage?.withRenderingMode(.alwaysOriginal), for: .normal)
//        verifyFacebook.setImage(facebookImage, for: .normal)
        verifyFacebook.backgroundColor = UIColor.defaultWhiteColor
        verifyFacebook.layer.cornerRadius = 20
        verifyFacebook.layer.borderWidth = 1
        checkAuthenticatedUser()
        verifyFacebook.isHidden = false
        verifyFacebook.addTarget(self, action: #selector(setupFacebookVerification), for: .touchUpInside)
        verifyFacebook.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func verifyWithGoogleButtonDesign(){
        let googleImage = UIImage(named:"icons8-google-48-2")
        verifyGoogle = UIButton()
        verifyGoogle.translatesAutoresizingMaskIntoConstraints = false
        verifyGoogle.clipsToBounds = true
        verifyGoogle.setImage(googleImage, for: .normal)
        verifyGoogle.layer.cornerRadius = 20
        verifyGoogle.layer.borderWidth = 1
        checkAuthenticatedUser()
        verifyGoogle.isHidden = false
        verifyGoogle.contentMode = .scaleAspectFit
        verifyGoogle.addTarget(self, action: #selector(setupGoogleVerification), for: .touchUpInside)
        verifyGoogle.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func verifyWithAppleButtonDesign(){
        let appleImage = UIImage(named: "icons8-apple-48")
        verifyApple.translatesAutoresizingMaskIntoConstraints = false
        verifyApple.clipsToBounds = true
        verifyApple.setImage(appleImage, for: .normal)
        verifyApple.backgroundColor = UIColor.defaultWhiteColor
        verifyApple.layer.borderWidth = 1
        checkAuthenticatedUser()
        verifyApple.isHidden = false
        verifyApple.layer.cornerRadius = 20
        verifyApple.addTarget(self, action: #selector(setupAppleVerification), for: .touchUpInside)
        verifyApple.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        verificationInfo.textColor = UIColor.textColor
        verificationInfo.numberOfLines = 1
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
        myReports.textColor = UIColor.textColor
        self.container.addSubview(myReports)
        myReports.topAnchor.constraint(equalTo: verticalStack.bottomAnchor, constant:20).isActive = true
        myReports.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: 20).isActive = true
    }
}
//struct ViewController_Preview: PreviewProvider{
//    static var previews: some View {
//    ViewControllerPreview{
//            ProfileViewController()
//        }
//    }
//}
