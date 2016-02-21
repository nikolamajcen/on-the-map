//
//  UserListViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {
    
    @IBOutlet weak var userList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func refreshUserList(sender: UIBarButtonItem) {
        ParseClient.sharedInstance.removeUsers()
        ParseClient.sharedInstance.getUsers { (success) -> Void in
            self.userList.reloadData()
            if success == false {
                let alertController = UIAlertController(title: "Fetch error",
                    message: "Users data failed to fetch.",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as UITableViewCell
        let student = ParseClient.sharedInstance.users[indexPath.row]
        
        cell.textLabel?.text = student.firstName! + " " + student.lastName!
        if student.mediaUrl != nil {
            cell.detailTextLabel?.text = student.mediaUrl!
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stringUrl = ParseClient.sharedInstance.users[indexPath.row].mediaUrl
        if stringUrl != nil {
            if UIApplication.sharedApplication().openURL(NSURL(string: stringUrl!)!) == false {
                let alert = UIAlertController(title: "Bad URL", message: "User doesn't provided good URL.",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "No URL", message: "User doesn't provided an URL.",
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}