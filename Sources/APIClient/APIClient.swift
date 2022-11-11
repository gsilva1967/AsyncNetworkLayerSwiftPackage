//
//  File.swift
//  
//
//  Created by Michael Kacos on 3/9/22.
//

import Foundation
import SwiftUI
import CoreData

public final class APIClient: NSObject, AsyncNetworkAPI, URLRequestBuilder, URLSessionDelegate {
    
    // Session Manager
    public var session: URLSession = URLSession()
    
    // Current Token
    var currentAccessToken: String?
    
    public init(configuration: URLSessionConfiguration, allowUntrusted: Bool = false) { //configuration: URLSessionConfiguration) {
        super.init()
        if allowUntrusted {
            self.session = URLSession(configuration: configuration,
                                      delegate: self,
                                      delegateQueue: OperationQueue.main)
        }
        else {
            self.session = URLSession(configuration: configuration)
        }
    }
    
    public convenience init(allowUntrusted: Bool = false) {
        //self.init(configuration: .default)
        self.init(configuration: .default, allowUntrusted: allowUntrusted)
    }
}

extension APIClient {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
    public func createDecoderWithDate() -> JSONDecoder {
        // Create the decoder
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
    public func createDecoder() -> JSONDecoder {
        // Create the decoder
        let decoder = JSONDecoder()
        return decoder
    }
    
    public func createDecoderWithDate(managedObjectContext: NSManagedObjectContext) -> JSONDecoder {
        // Create the decoder
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = managedObjectContext
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
    public func createDecoder(managedObjectContext: NSManagedObjectContext) -> JSONDecoder {
        // Create the decoder
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = managedObjectContext
        return decoder
    }
    
    public func setUpSecurityHeaders(for jsonWebToken: String, request: inout URLRequest) {
        // Added for OAuth
        if (!jsonWebToken.isEmpty) {
            request.addValue("Bearer \(jsonWebToken)" , forHTTPHeaderField: "Authorization")
        }
    }
    
    public func setUpHeader(for headerField: String, headerValue: String, request: inout URLRequest) {
            request.addValue(headerValue , forHTTPHeaderField: headerField)
    }
}

extension CodingUserInfoKey {
    public static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
