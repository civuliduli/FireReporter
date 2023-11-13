//
//  FireReporter + UIAlertControllerExtension.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 7.10.23.
//

import Foundation
import UIKit

extension UIViewController{
    func present(_ alertData: Alert) {
        let alert = UIAlertController(title: alertData.text, message: alertData.message, preferredStyle: .alert)
        alertData.confirmAction.forEach{alert.addAction($0)}
        alertData.disableAction.forEach{alert.addAction($0)}
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
