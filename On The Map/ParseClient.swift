//
//  ParseClient.swift
//  On The Map
//
//  Created by Nikola Majcen on 19/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    // Singleton
    static let sharedInstance = ParseClient()
    
    // Shared session
    var session = NSURLSession.sharedSession()
    
    // User list
    var userList = [ParseStudent]()
    
    override init() {
        super.init()
    }
    
    func getStudentLocations(completionHandlerForStudents: (result: AnyObject!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(ParseConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            func sendError(error: String) {
                print(error)
                completionHandlerForStudents(result: nil, error: NSError(domain: "createSession",
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
            self.convertJSONData(data, completionHandler: completionHandlerForStudents)
        }
        task.resume()
        return task
    }
    
    private func convertJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError!) -> Void) {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch {
            completionHandler(result: nil, error: NSError(domain: "convertJSONData",
                code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot convert data to JSON."]))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
}