//
//  UdacityClient.swift
//  On The Map
//
//  Created by Nikola Majcen on 18/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    // Singleton
    static let sharedInstance = UdacityClient()
    
    // Shared session
    var session = NSURLSession.sharedSession()

    // Authentification data
    var sessionID: String?
    var userID: String?
    
    override init() {
        super.init()
    }
    
    func createSession(jsonBody: String,
        completionHandlerForSession: (result: AnyObject!, error: NSError!) -> Void) -> NSURLSessionDataTask {
            let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseUrl + "session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
            
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
                
                // Covert data (first 5 characters are for security) and return result
                self.convertJSONData(data.subdataWithRange(NSMakeRange(5, data.length - 5)),
                    completionHandlerForConvertedData: { (result, error) -> Void in
                        if error == nil {
                            self.getSessionID(result)
                            self.getUserID(result)
                        }
                        completionHandlerForSession(result: result, error: error)
                })
            }
            
            // Start the request
            task.resume()
            return task
    }
    
    func deleteSession(completionHandlerForLogout: (logout: Bool) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseUrl + "session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                completionHandlerForLogout(logout: false)
            }
            
            if error != nil {
                sendError("Error: \(error)")
                return
            }
            
            // let data = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            self.sessionID = nil
            self.userID = nil
            completionHandlerForLogout(logout: true)
        }
        task.resume()
        return task
    }
    
    func getUserPublicData(completionHandlerForUserData: (result: AnyObject!, error: NSError!) -> Void ) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/" + self.userID!)!)
        let session = NSURLSession.sharedSession()
        
        func sendError(error: String) {
            print(error)
            completionHandlerForUserData(result: nil, error: NSError(domain: "createSession",
                code: 1, userInfo: [NSLocalizedDescriptionKey: error]))
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            
            guard let data = data else {
                sendError("No data provided.")
                return
            }
            
            self.convertJSONData(data.subdataWithRange(NSMakeRange(5, data.length - 5)),
                completionHandlerForConvertedData: { (var result, error) -> Void in
                    if error == nil {
                        result = self.getUserDetails(result)
                    }
                    completionHandlerForUserData(result: result, error: error)
            })
        }
        
        task.resume()
        return task
    }
    
    private func convertJSONData(data: NSData, completionHandlerForConvertedData: (result: AnyObject!, error: NSError!) -> Void) {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            completionHandlerForConvertedData(result: nil, error: NSError(domain: "convertJSONData", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not parse JSON data."]))
        }
        
        completionHandlerForConvertedData(result: parsedResult, error: nil)
    }
    
    private func getSessionID(jsonData: AnyObject) {
        self.sessionID = jsonData["session"]!!["id"] as? String
    }
    
    private func getUserID(jsonData: AnyObject) {
        self.userID = jsonData["account"]!!["key"] as? String
    }
    
    func getUserDetails(jsonData: AnyObject) -> ParseStudent {
        let user = ParseStudent()
        
        user.objectId = self.userID
        user.uniqueKey = jsonData["user"]!!["key"] as? String
        user.firstName = jsonData["user"]!!["first_name"] as? String
        user.lastName = jsonData["user"]!!["last_name"] as? String
        user.imageUrl = NSURL(string: ("https:" + (jsonData["user"]!!["_image_url"] as? String)!))
        
        return user
    }
}