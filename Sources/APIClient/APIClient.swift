//
//  File.swift
//  
//
//  Created by Michael Kacos on 3/9/22.
//

import Foundation
import SwiftUI

public final class APIClient: AsyncNetworkAPI, URLRequestBuilder {
    
    // Session Manager
    public let session: URLSession
    
    // Current Token
    var currentAccessToken: String?
    
    public init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    public convenience init() {
        self.init(configuration: .default)
    }
}
