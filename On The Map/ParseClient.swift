//
//  ParseClient.swift
//  On The Map
//
//  Created by Nikola Majcen on 19/02/16.
//  Copyright © 2016 Nikola Majcen. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    static let sharedInstance = ParseClient()
    
    var currentUser = ParseStudent()
    var users = [ParseStudent]()
    
    override init() {
        super.init()
    }
    
    func getUsers(completionHanderForUsers: (success: Bool) -> Void) -> Void {
        self.fetchUsers { (result, error) -> Void in
            if (error == nil) {
                let count = result["results"]!!.count
                for counter in 0...count - 1 {
                    let user = ParseStudent().JsonToStudent(result["results"]!![counter])
                    self.users.append(user)
                }
                self.users.sortInPlace({ (userA, userB) -> Bool in
                    userA.firstName < userB.firstName
                })
                completionHanderForUsers(success: true)
            } else {
                completionHanderForUsers(success: false)
            }
        }
    }
    
    func removeUsers() {
        self.users.removeAll()
    }
    
    func isStudentLocationAlreadyPosted(handler: (alreadyPosted: Bool, objectId: AnyObject!) -> Void) -> Void {
        getUserLocation { (success, result) -> Void in
            handler(alreadyPosted: success, objectId: result)
        }
    }
    
    func addUserLocation(location location: String, latitude: Double, longitude: Double, mediaUrl: String,
        completionHandlerForAddingLocation: (success: Bool) -> Void) -> NSURLSessionDataTask {
            let user = ParseClient.sharedInstance.currentUser
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue(ParseConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = "{\"uniqueKey\": \"\(user.uniqueKey!)\", \"firstName\": \"\(user.firstName!)\", \"lastName\": \"\(user.lastName!)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
                .dataUsingEncoding(NSUTF8StringEncoding)
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    completionHandlerForAddingLocation(success: false)
                    return
                }
                completionHandlerForAddingLocation(success: true)
            }
            task.resume()
            return task
    }
    
    func updateUserLocation(location location: String, latitude: Double, longitude: Double, mediaUrl: String,
        completionHandlerForUpdatingLocation: (success: Bool) -> Void) -> NSURLSessionDataTask {
            let user = ParseClient.sharedInstance.currentUser
            let urlString = "https://api.parse.com/1/classes/StudentLocation/\(user.objectId!)"
            
            let url = NSURL(string: urlString)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "PUT"
            request.addValue(ParseConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = "{\"uniqueKey\": \"\(user.uniqueKey!)\", \"firstName\": \"\(user.firstName!)\", \"lastName\": \"\(user.lastName!)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(mediaUrl)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
                .dataUsingEncoding(NSUTF8StringEncoding)
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    completionHandlerForUpdatingLocation(success: false)
                    return
                }
                completionHandlerForUpdatingLocation(success: true)
            }
            task.resume()
            return task
    }
    
    private func fetchUsers(completionHandlerForStudents: (result: AnyObject!, error: NSError!) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(ParseConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        var session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            func sendError(error: String) {
                print(error)
                completionHandlerForStudents(result: nil,
                    error: NSError(domain: "fetchUserData", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: error]))
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
    
    private func getUserLocation(completionHandlerForGettingUserLocation: (success: Bool, result: AnyObject!) -> Void) -> NSURLSessionDataTask {
        let uniqueKey = ParseClient.sharedInstance.currentUser.uniqueKey
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + uniqueKey! + "%22%7D"
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(ParseConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseConstants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandlerForGettingUserLocation(success: false, result: nil)
                return
            }
            
            self.convertJSONData(data!, completionHandler: { (result, error) -> Void in
                if error == nil {
                    guard (result["results"] as! NSArray).count == 0 else {
                        completionHandlerForGettingUserLocation(success: true,
                            result: result["results"]!![0]["objectId"])
                        return
                    }
                    completionHandlerForGettingUserLocation(success: false, result: nil)
                } else  {
                    completionHandlerForGettingUserLocation(success: false, result: nil)
                }
            })
            
        }
        task.resume()
        return task
    }
    
    private func convertJSONData(data: NSData, completionHandler: (result: AnyObject!, error: NSError!) -> Void) {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments)
        } catch {
            completionHandler(result: nil, error: NSError(domain: "convertJSONData",
                code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot convert data to JSON."]))
        }
        completionHandler(result: parsedResult, error: nil)
    }
}