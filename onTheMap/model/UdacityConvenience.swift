//
//  UdacityConvenience.swift
//  onTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit
import Foundation
import MapKit

extension UdacityClient {
    
    func userLogin(email: String, password: String, completionHandler: (result: String?, error: NSError?) -> Void) {
        let parameters : [String:String] = [
            UdacityClient.JSONBodyKeys.Username: email,
            UdacityClient.JSONBodyKeys.Password: password
        ]
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity: parameters
        ]
        
        // make the request
        taskForPOSTMethod(UdacityClient.RequestToServer.udacity, method: Methods.CreateSession, parameters: parameters, jsonBody: jsonBody, subdata: 5) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let errorMsg = result.valueForKey(UdacityClient.JSONResponseKeys.Error)  as? String {
                    completionHandler(result: nil, error: NSError(domain: "udacity login issue", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                }
                else {
                    let session = result["account"] as! NSDictionary
                    let key = session["key"] as! String
                    completionHandler(result: key, error: nil)
                }
            }
        }
    }
    
    // download student locations
    func getStudentLocations(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        // make the request
        taskForGETMethod(UdacityClient.RequestToServer.parse, method: Methods.limit, parameters: ["limit": 100, "order": "-updatedAt"]) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let locations = result as? [NSObject: NSObject] {
                    if let usersResult = locations["results"] as? [[String : AnyObject]] {
                        let studentsData = StudentInformation.convertFromDictionaries(usersResult)
                        completionHandler(result: studentsData, error: nil)
                    }
                }
            }
        }
    }
    
    // get user data from udacity
    func getUserPublicData(userId: String, completionHandler: (result: UserInformation?, error: NSError?) -> Void) {
        // mak the request
        taskForGETMethod(RequestToServer.udacity, method: Methods.Users + userId, parameters: ["":""]) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let data = result["user"] as? NSDictionary {
                    let studentsInfo = UserInformation(dictionary: data)
                    completionHandler(result: studentsInfo, error: nil)
                }
            }
        }
    }
    
    // post user location to parse
    func sendUserLocation(userDetails: [String : AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) {        // make the request
        taskForPOSTMethod(RequestToServer.parse, method: "", parameters: ["":""], jsonBody: userDetails, subdata: 0, completionHandler: { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
                
            }
        })
    }
    
    // set annotations for map with users data
    func createAnnotations(users: [StudentInformation], mapView: MKMapView) {
        
        if mapView.annotations.count >= 1{
            mapView.removeAnnotations(mapView.annotations)
        }
        for user in users {
            // set pin location
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2DMake(user.latitude, user.longitude)
            annotation.title = "\(user.firstName) \(user.lastName)"
            annotation.subtitle = user.mediaURL
            
            mapView.addAnnotation(annotation)
        }
    }
    
    // logout request from udacity
    func logoutRequest(completionHandler: (result: AnyObject?, error: NSError?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityBaseURL + Methods.CreateSession)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
            var newData: NSData?
            newData = nil
            if (data != nil) {
                newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                if newData != nil {
                    completionHandler(result: newData, error: nil)
                }
                else {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                }
            }
            else {
                UdacityClient.sharedInstance().showAlert(error!, viewController: self)
            }
        }
        task.resume()
    }
    
    // logout user from udacity
    func logout(viewController: AnyObject) {
        UdacityClient.sharedInstance().logoutRequest { (result, error) -> Void in
            if error != nil {
                UdacityClient.sharedInstance().showAlert(error!, viewController: viewController)
            }
            else {
                if(FBSDKAccessToken.currentAccessToken() != nil) {
                    //if facebook logout
                    FBSDKLoginManager().logOut()
                }
                dispatch_async(dispatch_get_main_queue(), {
                    viewController.dismissViewControllerAnimated(true, completion: nil)
                })
            }
        }
    }
}