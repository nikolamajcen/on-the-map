//
//  MapViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private var locationManager = CLLocationManager()
    var userLocationAlreadyAdded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationAuthorizationStatus()
        self.mapView.showsUserLocation = true
        self.mapView.zoomEnabled = true
        self.mapView.delegate = self
        
        initializeUsers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        removeAnnotationsFromMap()
        addAnnotationsToMap()
        
    }
    
    @IBAction func addUserLocation(sender: UIBarButtonItem) {
        ParseClient.sharedInstance.isStudentLocationAlreadyPosted { (alreadyPosted, objectId) -> Void in
            if alreadyPosted == false {
                self.userLocationAlreadyAdded = false
                self.performSegueWithIdentifier("FindLocationSegue", sender: self)
            } else {
                self.userLocationAlreadyAdded = true
                ParseClient.sharedInstance.currentUser.objectId = objectId as? String
                let alertController = UIAlertController(title: "Location alert",
                    message: "You already posted location.",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Overwrite",
                    style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    self.performSegueWithIdentifier("FindLocationSegue", sender: self)
                }))
                alertController.addAction(UIAlertAction(title: "Cancel",
                    style: UIAlertActionStyle.Default, handler: nil))
                performUIUpdatesOnMain({ () -> Void in
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func refreshUserLocations(sender: UIBarButtonItem) {
        ParseClient.sharedInstance.removeUsers()
        removeAnnotationsFromMap()
        ParseClient.sharedInstance.getUsers { (success) -> Void in
            if success == true {
                self.addAnnotationsToMap()
            } else {
                let alertController = UIAlertController(title: "Fetch error",
                    message: "Users locations failed to fetch.",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK",
                    style: UIAlertActionStyle.Default, handler: nil))
                performUIUpdatesOnMain({ () -> Void in
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let controller = navigationController.topViewController as! FindLocationViewController
        controller.updateUserLocation = self.userLocationAlreadyAdded
    }
    
    private func initializeUsers() {
        ParseClient.sharedInstance.getUsers { (success) -> Void in
            if success == true {
                self.addAnnotationsToMap()
            }
        }
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func removeAnnotationsFromMap() {
        if self.mapView.annotations.count > 0 {
            performUIUpdatesOnMain({ () -> Void in
                self.mapView.removeAnnotations(self.mapView.annotations)
            })
        }
    }
    
    private func addAnnotationsToMap() {
        performUIUpdatesOnMain({ () -> Void in
            self.mapView.addAnnotations(ParseClient.sharedInstance.users)
        })
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isMemberOfClass(MKUserLocation) {
            return nil
        } else {
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            if control == view.rightCalloutAccessoryView {
                if let stringUrl = view.annotation?.subtitle! {
                    UIApplication.sharedApplication().openURL(NSURL(string: stringUrl)!)
                }
            }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        self.mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate,
            span: MKCoordinateSpanMake(0.25, 0.25)), animated: true)
    }
}

