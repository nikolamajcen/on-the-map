//
//  UdacityAuth.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func login(username username: String, password: String, authHandler: (result: Bool) -> Void) -> Void {
        let body = "{\"udacity\": {\"username\":\"\(username)\", \"password\": \"\(password)\"}}"
        
        createSession(body) { (result, error) -> Void in
            if (error == nil) {
                authHandler(result: true)
            } else {
                authHandler(result: false)
            }
        }
    }
    
    func logout(completionHandlerForLogout: (success: Bool) -> Void) -> Void {
        deleteSession { (logout) -> Void in
            if logout == true {
                completionHandlerForLogout(success: true)
            } else {
                completionHandlerForLogout(success: false)
            }
        }
    }
}