//
//  UserInformation.swift
//  onTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import Foundation

struct UserInformation {
    var firstName = ""
    var lastName = ""
    
    /* Construct a PublicUserInformation from a dictionary */
    init(dictionary: NSDictionary) {
        firstName = dictionary["first_name"] as! String
        lastName = dictionary["last_name"] as! String
    }
}