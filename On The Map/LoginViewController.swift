//
//  LoginViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        loginError.text = ""
    }
    
    @IBAction func userLogin(sender: UIButton) {
        let client = UdacityClient()
        client.createSession("POST", username: usernameField.text!, password: passwordField.text!) { (result, error) -> Void in
            if error == nil {
                performUIUpdatesOnMain({ () -> Void in
                    self.loginError.text = "Success :)"
                })
            } else {
                performUIUpdatesOnMain({ () -> Void in
                    self.loginError.text = "Failure :("

                })
            }
        }
    }
}
