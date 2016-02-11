//
//  ShowAlert.swift
//  onTheMap
//
//  Created by Sebas on 1/14/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit

protocol ShowsAlert {}

extension ShowsAlert where Self: UIViewController {
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
