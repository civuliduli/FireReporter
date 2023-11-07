//
//  SuccessMessageViewController.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 6.11.23.
//

import UIKit
import FirebaseRemoteConfig


class SuccessMessageViewController: UIViewController {

    var successImage: UIImage!
    var successImageView = UIImageView()
    var successText = UILabel()
    var backToCamera = UIButton()
    var callFireFighter = UIButton()
    var horizontalStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        successImageDesign()
        successLabelDesign()
        setupHorizontalStack()
    }

    func successImageDesign() {
        successImageView.contentMode = .scaleAspectFill
        successImageView.translatesAutoresizingMaskIntoConstraints = false
        successImageView.image = UIImage(named: "accept")
        self.view.addSubview(successImageView)
        NSLayoutConstraint.activate([
            successImageView.heightAnchor.constraint(equalToConstant: 200),
            successImageView.widthAnchor.constraint(equalToConstant: 200),
            successImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            successImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200)
        ])
    }

    func successLabelDesign() {
        successText.translatesAutoresizingMaskIntoConstraints = false
        successText.text = "Report sent successfully"
        successText.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        successText.textColor = .systemGreen
        self.view.addSubview(successText)
        NSLayoutConstraint.activate([
            successText.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            successText.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }

    func setupHorizontalStack() {
        horizontalStack = UIStackView()
        horizontalStack.axis = .vertical
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .fill
        horizontalStack.spacing = 16
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.addArrangedSubview(backToCameraButtonDesign())
        horizontalStack.addArrangedSubview(callFireFighterButtonDesign())

        // Add the horizontal stack to the view
        self.view.addSubview(horizontalStack)

        horizontalStack.topAnchor.constraint(equalTo: successText.bottomAnchor, constant: 150).isActive = true
        horizontalStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        horizontalStack.widthAnchor.constraint(equalToConstant: 300).isActive = true
        horizontalStack.heightAnchor.constraint(equalToConstant: 120).isActive = true
    }
    
    @objc func backToCameraTapped(){
        dismiss(animated: true)
    }
    
    @objc func callFireFighters(){
            let remoteConfig = RemoteConfig.remoteConfig()
            let remoteConfigSettings = RemoteConfigSettings()

            // Set minimum fetch interval to reduce the frequency of fetching
            remoteConfigSettings.minimumFetchInterval = 3600  // Fetch once every hour

            remoteConfig.configSettings = remoteConfigSettings

            remoteConfig.fetch { (status, error) in
                if status == .success {
                    remoteConfig.activate { (changed, error) in
                        // Configuration is activated
                        let phoneNumber = remoteConfig["emergencyPhoneNumber"].stringValue ?? "default_phone_number"
                        print("Phone number: \(phoneNumber)")
                        guard let url = URL(string: "telprompt://\(phoneNumber)"),
                               UIApplication.shared.canOpenURL(url) else {
                               return
                           }
                        DispatchQueue.main.async{
                                guard let url = URL(string: "telprompt://\(phoneNumber)") else { return }
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                } else {
                    // Handle fetch error
                    print("Error fetching remote config: \(error?.localizedDescription ?? "Unknown error")")
                }
            }

        }
       
    func backToCameraButtonDesign() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Back To Camera", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 10
        button.backgroundColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.addTarget(self, action: #selector(backToCameraTapped), for: .touchUpInside)
        return button
    }

    func callFireFighterButtonDesign() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Call Emergency Services", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.addTarget(self, action: #selector(callFireFighters), for: .touchUpInside)
        return button
    }
}
