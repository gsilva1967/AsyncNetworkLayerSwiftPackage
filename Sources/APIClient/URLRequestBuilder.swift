//
//  File.swift
//  
//
//  Created by Michael Kacos on 3/9/22.
//

import Foundation

 public enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

 public protocol URLRequestBuilder: AnyObject {
     func createRequest(type: HttpMethod, endPoint: String, headers: [String:String], body: Data?) -> URLRequest
}

extension URLRequestBuilder {
    
    public func createRequest(type: HttpMethod, endPoint: String, headers: [String:String] = [:], body: Data? = nil) -> URLRequest {
        // Create URLRequest
        let url = URL(string: endPoint)
        var request = URLRequest(url: url!)
        
        // Set The type
        request.httpMethod = type.rawValue
        
        // Set up the body
        //if (!body.isEmpty) {
        if let body = body {
            //request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = body
        }
        
        if (!headers.isEmpty) {
            for header in headers {
                request.addValue(header.0, forHTTPHeaderField: header.1)
            }
        }
        else {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        // return the new request
        return request
    }
}

