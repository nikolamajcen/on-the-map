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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        initializeUserLocation()
    }
    
    @IBAction func addLocation(sender: UIButton) {
        
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
