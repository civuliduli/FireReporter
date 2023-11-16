//
//  AppleAuth.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.11.23.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

var currentNonce:String?

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
            print(appleIDCredential.fullName)
            Auth.auth().signIn(with: credential){(result, error) in
                if (error != nil) {
                    print("\(String(describing: result?.user)) user result")
                    self.present(Alert(text: error?.localizedDescription ?? "Authentication Error", message: "", confirmAction: [UIAlertAction(title: "Try again", style: .default)], disableAction: []))
                    return
                } else {
                    if let result = result {
                        let user = result.user
                        print(user.displayName ?? "No name")
                    }
                    print("\(credential) user credentials")
                    if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
                        let userIdentifier = appleIDCredential.user
                        let fullName = appleIDCredential.fullName?.givenName
                        let email = appleIDCredential.email
                        let defaults = UserDefaults.standard
                        defaults.set(fullName, forKey:"appleUsername" )
                        print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
                    self.checkAuthenticatedUser()
//                    self.present(Alert(text: "Success", message: "You're now a Fire Reporter Verified User", confirmAction: [UIAlertAction(title: "OK", style: .default)], disableAction: []))
                }
            }
        }
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print(error.localizedDescription)
        }
    }
    
         func randomNonceString(length: Int = 32) -> String {
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
//    
           @available(iOS 13, *)
            func sha256(_ input: String) -> String {
             let inputData = Data(input.utf8)
             let hashedData = SHA256.hash(data: inputData)
             let hashString = hashedData.compactMap {
               String(format: "%02x", $0)
             }.joined()
    
             return hashString
           }
    
    func setupAppleAuth(){
        currentNonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(currentNonce!)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
