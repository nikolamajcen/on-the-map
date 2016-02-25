//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 24/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userUrl: UITextField!
    
    var annotation: MKAnnotation!
    var updateUserLocation: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        initializeUserLocation()
    }
    
    @IBAction func addLocation(sender: UIButton) {
        if updateUserLocation == false {
            ParseClient.sharedInstance.addUserLocation(location: annotation.title!!,
                latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude,
                mediaUrl: userUrl.text!, completionHandlerForAddingLocation: { (success) -> Void in
                    if success ==  true {
                        ParseClient.sharedInstance.removeUsers()
                        ParseClient.sharedInstance.getUsers({ (success) -> Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    } else {
                        let alertController = UIAlertController(title: "Location error",
                            message: "Unable to add user location.",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK",
                            style: UIAlertActionStyle.Default, handler: nil))
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
            })
        } else {
            ParseClient.sharedInstance.updateUserLocation(location: annotation.title!!,
                latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude,
                mediaUrl: userUrl.text!, completionHandlerForUpdatingLocation: { (success) -> Void in
                    if success == true {
                        ParseClient.sharedInstance.removeUsers()
                        ParseClient.sharedInstance.getUsers({ (success) -> Void in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    } else {
                        let alertController = UIAlertController(title: "Location error",
                            message: "Unable to update user location.",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK",
                            style: UIAlertActionStyle.Default, handler: nil))
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
            })
        }
    }
    
    private func initializeUserLocation() {
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
        mapView.zoomEnabled = true
    }
}

extension AddLocationViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reusePinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusePinId)
            as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusePinId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor.orangeColor()
            pinView!.tintColor = UIColor.grayColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .InfoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
