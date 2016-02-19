//
//  ParseStudent.swift
//  On The Map
//
//  Created by Nikola Majcen on 19/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

class ParseStudent: NSObject {
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    
    func JsonToStudent(jsonData: AnyObject) -> ParseStudent {
        
        self.firstName = jsonData["firstName"] as? String
        self.lastName = jsonData["lastName"] as? String
        self.latitude = jsonData["latitude"] as? Double
        self.longitude = jsonData["longitude"] as? Double
        self.mapString = jsonData["mapString"] as? String
        self.mediaUrl = jsonData["mediaURL"] as? String
        
        return self
    }
}