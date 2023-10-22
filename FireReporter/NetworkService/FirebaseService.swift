//
//  FirebaseService.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 21.10.23.
//

import Foundation
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit


class FirebaseService {
    
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
