//
//  StudentInformation.swift
//  onTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation {
    
    var firstName = ""
    var lastName = ""
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees =  CLLocationDegrees()
    var mediaURL = ""
    var studentId = ""
    
    /* Initial a student information from dictionary */
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary[UdacityClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[UdacityClient.JSONResponseKeys.LastName] as! String
        latitude = dictionary[UdacityClient.JSONResponseKeys.Latitude] as! CLLocationDegrees
        longitude = dictionary[UdacityClient.JSONResponseKeys.Longitude] as! CLLocationDegrees
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.MediaUrl] as! String
    }
    
    
    /* Convert an array of dictionaries to an array of student information struct objects */
    static func convertFromDictionaries(array: [[String : AnyObject]]) -> [StudentInformation] {
        var resultArray = [StudentInformation]()
        
        for dictionary in array {
            resultArray.append(StudentInformation(dictionary: dictionary))
        }
        return resultArray
    }
}
