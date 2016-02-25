//
//  FindLocationViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 23/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit
import MapKit

class FindLocationViewController: UIViewController {
    
    var annotation: MKPointAnnotation!
    var updateUserLocation: Bool?
    
    @IBOutlet weak var locationSearchField: UITextField!
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findLocationOnMap(sender: UIButton) {
        if let location = locationSearchField.text where location.isEmpty == false {
            findLocation(location) { (success, annotation) -> Void in
                if success == true {
                    self.annotation = annotation
                    self.performSegueWithIdentifier("AddLocationSegue", sender: self)
                } else {
                    let alertController = UIAlertController(title: "Location search",
                        message: "Location does not exist.",
                        preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        } else {
            let alertController = UIAlertController(title: "Location search",
                message: "Please enter location.",
                preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AddLocationViewController
        controller.annotation = self.annotation
        controller.updateUserLocation = self.updateUserLocation
        self.annotation = nil
    }
    
    private func findLocation(location: String, completionHandlerForLocation: (success: Bool,
        annotation: MKPointAnnotation!) -> Void) -> Void  {
            
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = location
            let search = MKLocalSearch(request: searchRequest)
            
            search.startWithCompletionHandler { (searchResponse, error) -> Void in
                
                guard (error == nil) else {
                    completionHandlerForLocation(success: false, annotation: nil)
                    return
                }
                
                let annotation = MKPointAnnotation()
                annotation.title = location
                annotation.coordinate = CLLocationCoordinate2D(latitude: searchResponse!.boundingRegion.center.latitude,
                    longitude: searchResponse!.boundingRegion.center.longitude)
                
                completionHandlerForLocation(success: true, annotation: annotation)
            }
    }
}