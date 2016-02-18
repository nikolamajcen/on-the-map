//
//  UdacityClient.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    // Shared session
    var session = NSURLSession.sharedSession()

    // Authentification state
    var requestToken: String?
    var sessionID: String?
    var userID: Int?
    
    override init() {
        super.init()
    }
    
    func createSession(method: String, username: String, password: String,
        completionHandlerForSession: (result: AnyObject!, error: NSError!) -> Void) -> NSURLSessionDataTask {
            
            let body = "{\"udacity\": {\"username\":\"" + username + "\", \"password\": \"" + password + "\"}}"
            
            let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseUrl + "session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                func sendError(error: String) {
                    print(error)
                    completionHandlerForSession(result: nil, error: NSError(domain: "createSession",
                        code: 1, userInfo: [NSLocalizedDescriptionKey: error]))
                }
                
                // GUARD: Is there an error?
                guard (error == nil) else {
                    sendError("Error: \(error)")
                    return
                }
                
                // GUARD: Response is 2xx?
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                    where statusCode >= 200 && statusCode <= 299 else {
                        sendError("Status code is not 2xx.")
                        return
                }
                
                // GUARD: Is data returned?
                guard let data = data else {
                    sendError("No data provided.")
                    return
                }
                
                // Return a result
                completionHandlerForSession(result: data, error: nil)
            }
            
            // Start the request
            task.resume()
            
            return task
    }
}