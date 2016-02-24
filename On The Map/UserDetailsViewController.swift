//
//  UserDetailsViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 24/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userFirstName: UILabel!
    @IBOutlet weak var userLastName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUserData()
    }
    
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
    
    private func initializeUserData() {
        userFirstName.text = ParseClient.sharedInstance.currentUser.firstName
        userLastName.text = ParseClient.sharedInstance.currentUser.lastName
        
        getDataFromUrl(ParseClient.sharedInstance.currentUser.imageUrl!) { (success, image) -> Void in
            if success == false {
                // TODO: Show blank avatar image
            } else {
                performUIUpdatesOnMain({ () -> Void in
                    self.userImage.image = UIImage(data: image)
                })
            }
        }
    }
    
    private func getDataFromUrl(url: NSURL, completionHandlerForUserImage: (success: Bool, image: NSData!) -> Void) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandlerForUserImage(success: false, image: nil)
                return
            }
            
            guard let data = data else {
                completionHandlerForUserImage(success: false, image: nil)
                return
            }
            
            completionHandlerForUserImage(success: true, image: data)
        }.resume()
    }
}
