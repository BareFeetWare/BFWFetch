//
//  UIViewController+Alert.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 2/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(error: Error, handler: ((UIAlertAction) -> Void)? = nil) {
        showAlert(title: "Error", message: error.localizedDescription, handler: handler)
    }
    
}
