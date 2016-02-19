//
//  UserListViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance.userList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")! as UITableViewCell
        let student = ParseClient.sharedInstance.userList[indexPath.row]
        
        cell.textLabel?.text = student.firstName! + " " + student.lastName!
        if student.mediaUrl != nil {
            cell.detailTextLabel?.text = student.mediaUrl!
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stringUrl = ParseClient.sharedInstance.userList[indexPath.row].mediaUrl
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