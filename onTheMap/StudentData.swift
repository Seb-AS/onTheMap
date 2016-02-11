//
//  StudentData.swift
//  onTheMap
//
//  Created by Sebas on 2/9/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import Foundation

class StudentData: NSObject {
    
    var userData = [StudentInformation]()
    
    //Shared Instance
    
    static func sharedInstance() -> StudentData {
        
        struct Singleton {
            static var sharedInstance = StudentData()
        }
        
        return Singleton.sharedInstance
    }
}
