//
//  NSURLExtensions.swift
//  onTheMap
//
//  Created by Sebas on 2/5/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import Foundation

extension String {
    func isValidUrl() -> Bool {
        if (self.isEmpty) {
            return false
        }
        
        let output = NSURL(string: self)
        if output == nil {
            return false
        }
        let host = output!.host
        if ((host == nil) || (host!.isEmpty)) {
            return false
        }
        let scheme = output!.scheme
        if (scheme.isEmpty) {
            return false
        }
        return true
    }
    
    func openUrl()->Bool {
        if self.isValidUrl() {
            return true
        }
        return false
    }
}

extension NSError {
    func isNetworkError()->Bool {
        return self.domain == NSURLErrorDomain
    }
}