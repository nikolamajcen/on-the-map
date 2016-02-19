//
//  MapViewController.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        self.getStudents()
        self.checkLocationAuthorizationStatus()
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func getStudents() {
        ParseClient.sharedInstance.getStudentLocations { (result, error) -> Void in
            if (error == nil) {
                // Convert JSON to student array
                let count = result["results"]!!.count
                for counter in 0...count - 1 {
                    let student = ParseStudent().JsonToStudent(result["results"]!![counter])
                    ParseClient.sharedInstance.userList.append(student)
                    self.putPinOnMap(student)
                }
            } else {
                print("Error occured.")
            }
        }
        print("Students initialized.")
    }
    
    private func putPinOnMap(user: ParseStudent) {
        self.mapView.addAnnotation(user)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.orangeColor()
            pinView!.tintColor = UIColor.grayColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .InfoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print("Pin tapped.")
        }
    }
}

