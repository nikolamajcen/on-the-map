//
//  UserDetailsViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 24/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    @IBAction func logout(sender: UIButton) {
        UdacityClient.sharedInstance.logout { (success) -> Void in
            if success == true {
                performUIUpdatesOnMain({ () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                print("Logout failure.")
            }
        }
    }
}
