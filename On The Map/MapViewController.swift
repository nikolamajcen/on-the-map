//
//  MapViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ParseClient.sharedInstance.getStudentLocations { (result, error) -> Void in
            if (error == nil) {
                // Convert JSON to student array
                let count = result["results"]!!.count
                for counter in 0...count - 1 {
                    let student = ParseStudent().JsonToStudent(result["results"]!![counter])
                    ParseClient.sharedInstance.userList.append(student)
                    print("Student: \(student.firstName!) \(student.lastName!)")
                }
            } else {
                print("Error occured.")
            }
        }
    }
}

