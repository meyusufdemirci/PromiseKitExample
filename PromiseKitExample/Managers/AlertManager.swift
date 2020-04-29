//
//  AlertManager.swift
//  PromiseKitExample
//
//  Created by Yusuf Demirci on 29.04.2020.
//  Copyright © 2020 Yusuf Demirci. All rights reserved.
//

import UIKit

class AlertManager {
    
    class func showError(message: String, controller: UIViewController) {
        let alertController: UIAlertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}
