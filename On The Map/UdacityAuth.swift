//
//  UdacityAuth.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func login(username: String, password: String, authHandler: (result: Bool) -> Void) -> Void {
        let body = "{\"udacity\": {\"username\":\"\(username)\", \"password\": \"\(password)\"}}"
        
        self.createSession(body) { (result, error) -> Void in
            if (error == nil) {
                authHandler(result: true)
            } else {
                authHandler(result: false)
            }
        }
    }
}