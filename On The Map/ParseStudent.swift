//
//  ParseStudent.swift
//  On The Map
//
//  Created by Nikola Majcen on 19/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation
import MapKit

class ParseStudent: NSObject, MKAnnotation {
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    var imageUrl: NSURL?
    
    var title: String? {
        return self.firstName! + " " + self.lastName!
    }
    
    var subtitle: String? {
        return mediaUrl!
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude!),
            longitude: CLLocationDegrees(longitude!))
    }
    
    func JsonToStudent(jsonData: AnyObject) -> ParseStudent {
        
        self.firstName = jsonData["firstName"] as? String
        self.lastName = jsonData["lastName"] as? String
        self.latitude = jsonData["latitude"] as? Double
        self.longitude = jsonData["longitude"] as? Double
        self.mapString = jsonData["mapString"] as? String
        
        let tempUrl = jsonData["mediaURL"] as? String
        if tempUrl!.lowercaseString.rangeOfString("http") == nil {
            self.mediaUrl = "http://" + tempUrl!.lowercaseString
        } else {
            self.mediaUrl = tempUrl!.lowercaseString
        }
        
        return self
    }
}