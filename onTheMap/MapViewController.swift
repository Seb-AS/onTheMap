//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add pin button
        let pinButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "addPinAction")
        
        // add refresh button
        let refreshButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadAction")
        
        // add the buttons
        navigationItem.rightBarButtonItems = [refreshButton, pinButton]                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logout")
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadUsersData()
    }
    
    func addPinAction() {
        let postController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("postView") 
        presentViewController(postController, animated: true, completion: nil)
    }
    
    func reloadAction() {
        reloadUsersData()
    }
    
    //reload users data
    func reloadUsersData() {
        UdacityClient.sharedInstance().getStudentLocations { users, error in
            if let usersData =  users {
                dispatch_async(dispatch_get_main_queue(), {
                    StudentData.sharedInstance().userData = usersData
                    UdacityClient.sharedInstance().createAnnotations(usersData, mapView: self.map)
                })
            }
            else {
                if error != nil {
                    self.logout()
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                }
            }
        }
    }

    // setup pin properties
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinView.pinTintColor = UIColor.redColor()
            pinView.canShowCallout = true
            
            // pin button
            let pinButton = UIButton(type: UIButtonType.InfoLight)
            pinButton.frame.size.width = 44
            pinButton.frame.size.height = 44
            
            pinView.rightCalloutAccessoryView = pinButton
            
            return pinView
        }
        return nil
    }
    
    // click to pin
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // open url
        UdacityClient.sharedInstance().openURL(view.annotation!.subtitle!!)
    }
    
    // logout
    func logout() {
            UdacityClient.sharedInstance().logout(self)
    }
}
