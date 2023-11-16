//
//  Authentication.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 10.11.23.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import CryptoKit
import AuthenticationServices



class Authentication {
    
    func facebookAuth(onSuccess: @escaping () -> Void, onError: @escaping () -> Void, onAuthError: @escaping () -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return
        }
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile"], from: rootViewController) { [weak self] (result, error) in
            if let error = error {
                print("Facebook login error: \(error.localizedDescription)")
                onError()
                return
            }
            
            guard let result = result, !result.isCancelled else {
                print("Facebook login cancelled")
                // Handle cancellation (e.g., show an appropriate message)
                return
            }

            guard let accessToken = AccessToken.current?.tokenString else {
                print("Failed to get access token for Facebook")
                onError()
                return
            }
            
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken)
            Auth.auth().signIn(with: credentials) { (authData, authError) in
                if let authError = authError {
                    print("Firebase authentication error: \(authError.localizedDescription)")
                    onAuthError()
                } else {
                    onSuccess()
                }
            }
        }
    }

    
    func googleAuth(onError:@escaping () -> Void, onSuccess:@escaping () -> Void, onAuthError: @escaping () -> Void){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootViewController = window.rootViewController else {
                    print("there is no root view controller")
                    return
                }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {authentication, error in
            if error != nil {
                onError()
                return
            }
            guard let user = authentication?.user, let idToken = user.idToken?.tokenString else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil {
                    onAuthError()
                } else {
                    onSuccess()
                }
            }
        }
    }
}

