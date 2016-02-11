//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate, ShowsAlert{

    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        changeVisibility(true)
    }
    
    func createButton() {
        let button = UIButton();
        button.setTitle("Cancel", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.frame = CGRectMake(self.view.frame.size.width - 100, 65, 100, 30) // X, Y, width, height
        button.addTarget(self, action: "cancelButtonPressed:", forControlEvents: .TouchUpInside)
        view.addSubview(button)
    }
    
    
    @IBAction func findOnMapAction(sender: UIButton) {
        if (!locationField.text!.isEmpty) {
            getGeocodLocation(locationField.text!)
        }
        else {
            locationField.becomeFirstResponder()
            showAlert(message:"please, add a city")
        }
    }
    
    // find user location via geocoder
    func getGeocodLocation(address : String) {
        showActivityIndicator()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if error != nil {
                self.hideActivityIndicator()
                UdacityClient.sharedInstance().showAlert(error!, viewController: self)
            }
            else {
                self.map.hidden = false
                self.submitButton.hidden = false
                self.linkField.hidden = false
                
                if let placemark = placemarks?[0]{
                    self.latitude = placemark.location!.coordinate.latitude
                    self.longitude = placemark.location!.coordinate.longitude
                    self.placeMarkerOnMap(placemark)
                }
                self.hideActivityIndicator()
                self.changeVisibility(false)
            }
        })
    }
    
    // Set marker on map and zoom in
    func placeMarkerOnMap(placemark: CLPlacemark) {
        // set zoom
        let latDelta : CLLocationDegrees = 0.01
        let longDelta : CLLocationDegrees = 0.01
        
        // make span
        let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        // create location
        let location : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        // create region
        let region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        map.addAnnotation(MKPlacemark(placemark: placemark))
    }
    
    //Activity indicator
    func showActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func submitAction(sender: UIButton) {
        // get public data udacity
        if (!linkField.text!.isEmpty) {
            
            if (isValidURL(linkField.text!)) {
                // user data
                showActivityIndicator()
                sendUserLocation()
            }
            else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: ["NSLocalizedDescriptionKey" : "Invalid URL"])
                UdacityClient.sharedInstance().showAlert(error, viewController: self)
            }
        }
        else {
            linkField.becomeFirstResponder()
            showAlert(message:"please, add a link")
        }
    }
    
    func changeVisibility(firstStep: Bool) {
        findButton.hidden = !firstStep
        submitButton.hidden = firstStep
        locationField.hidden = !firstStep
        linkField.hidden = firstStep
        map.hidden = firstStep
        
        if (firstStep) {
            mainText.text = "Where are you studying today?"
        } else {
            mainText.text = "Enter associated link"
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        cancel()
    }
    
    // go back to map view
    func cancel() {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // validate url
    func isValidURL(urlString: String) -> Bool {
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        return NSURLConnection.canHandleRequest(request)
    }
    
    // get user data from udacity and post user location to parse
    func sendUserLocation() {
        
        var userData : [String: AnyObject] = [String: AnyObject]()        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UdacityClient.sharedInstance().getUserPublicData(appDelegate.studentKey, completionHandler: { userInformation, error in
            if userInformation != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    userData  = [
                        UdacityClient.JSONBodyKeys.UniqueKey: appDelegate.studentKey,
                        UdacityClient.JSONBodyKeys.FirstName: userInformation!.firstName,
                        UdacityClient.JSONBodyKeys.LastName: userInformation!.lastName,
                        UdacityClient.JSONBodyKeys.MapString: self.locationField.text!,
                        UdacityClient.JSONBodyKeys.MediaURL: self.linkField.text!,
                        UdacityClient.JSONBodyKeys.Latitude: self.latitude,
                        UdacityClient.JSONBodyKeys.Longitude: self.longitude
                    ]
                    
                    //send request to parse
                    UdacityClient.sharedInstance().sendUserLocation(userData, completionHandler: { (result, error) -> Void in
                        if error != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hideActivityIndicator()
                                UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                            })
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.hideActivityIndicator()
                                self.cancel()
                            })
                        }
                    })
                })
            } else {
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                    })
                }
            }
        })
    }
}
