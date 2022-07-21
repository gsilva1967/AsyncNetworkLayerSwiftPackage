//
//  File.swift
//  
//
//  Created by Michael Kacos on 3/9/22.
//

import Foundation
import CoreData

extension APIClient {
    
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
}

extension CodingUserInfoKey {
    public static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
