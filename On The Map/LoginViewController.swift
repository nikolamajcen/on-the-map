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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        loginError.text = ""
        loadingIndicator.hidden = true
    }
    
    @IBAction func userLogin(sender: UIButton) {
        if usernameField.text != "" && passwordField.text != "" {
            self.showLoadingIndicator()
            UdacityClient.sharedInstance.login(username: usernameField.text!, password: passwordField.text!) { (result) -> Void in
                if result == true {
                    self.hideLoadingIndicator()
                    performUIUpdatesOnMain({ () -> Void in
                        self.completeLogin()
                    })
                } else {
                    self.hideLoadingIndicator()
                    performUIUpdatesOnMain({ () -> Void in
                        self.loginError.text = "Something is wrong. Try again :)"
                    })
                }
            }
        } else {
            performUIUpdatesOnMain({ () -> Void in
                self.loginError.text = "Please enter your username and password."
            })
        }
    }
    
    func completeLogin() {
        self.getUserData { (success) -> Void in
            if success == true {
                performUIUpdatesOnMain { () -> Void in
                    self.loginError.text = ""
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "User error",
                    message: "Users data failed to fetch.",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func getUserData(completionHandlerForUserData: (success: Bool) -> Void ) {
        UdacityClient.sharedInstance.getUserPublicData { (result, error) -> Void in
            guard let user = result else {
                completionHandlerForUserData(success: false)
                return
            }
            
            ParseClient.sharedInstance.currentUser = user as! ParseStudent
            completionHandlerForUserData(success: true)
        }
    }
    
    func showLoadingIndicator() {
        performUIUpdatesOnMain { () -> Void in
            self.loginError.text = ""
            self.loadingIndicator.hidden = false
            self.loadingIndicator.startAnimating()
        }
    }
    
    func hideLoadingIndicator(){
        performUIUpdatesOnMain { () -> Void in
            self.loadingIndicator.hidden = true
            self.loadingIndicator.stopAnimating()
        }
    }
}
