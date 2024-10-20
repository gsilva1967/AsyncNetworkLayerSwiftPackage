//
//  File.swift
//  
//
//  Created by Michael Kacos on 3/9/22.
//

import Foundation


public enum NetworkRequestError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError(_ errorMessage: String)
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case invalidToken
    
    //Added this from other code - MGK
    case requestFailed(description: String)
}

//extension NetworkRequestError: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .invalidRequest: return "Invalid Request"
//        case .badRequest: return "Bad Request"
//        case .unauthorized: return "Unauthorized"
//        case .forbidden: return "Forbidden"
//        case .notFound: return "Not Found"
//        case .error4xx: return "Error 4xx"
//        case .serverError: return "Server Error"
//        case .error5xx: return "Error 5xx"
//        case .decodingError: return "Decoding Error"
//        case .urlSessionFailed: return "URL Session Failed"
//        case .unknownError: return "Unknown Error"
//        case .invalidToken: return "Invalid Token"
//        
//        //Added this from other code - MGK
//        case .requestFailed: return "Request Failed"
//        }
//    }
//        
//    
//}


/// Parses a HTTP StatusCode and returns a proper error
/// - Parameter statusCode: HTTP status code
/// - Returns: Mapped Error
private func httpError(_ statusCode: Int) -> NetworkRequestError {
    switch statusCode {
    case 400: return .badRequest
    case 401: return .unauthorized
    case 403: return .forbidden
    case 404: return .notFound
    case 402, 405...499: return .error4xx(statusCode)
    case 500: return .serverError
    case 501...599: return .error5xx(statusCode)
    default: return .unknownError
    }
}

/// Parses URLSession Publisher errors and return proper ones
/// - Parameter error: URLSession publisher error
/// - Returns: Readable NetworkRequestError
private func handleError(_ error: Error) -> NetworkRequestError {
    switch error {
    case is Swift.DecodingError:
        let decodingError = error as! DecodingError
        var errorMessage = ""
        switch(decodingError){
        case DecodingError.dataCorrupted(let context):
            print(context)
            errorMessage = context.debugDescription
        case DecodingError.keyNotFound(let key, let context):
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            errorMessage =  "Key '\(key)' not found: \(context.debugDescription) | codingPath: \(context.codingPath)"
        case DecodingError.valueNotFound(let value, let context):
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            
            errorMessage =  "Value '\(value)' not found: \(context.debugDescription) | codingPath: \(context.codingPath)"
        case DecodingError.typeMismatch(let type, let context):
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            errorMessage =  "Type '\(type)' not found: \(context.debugDescription) | codingPath: \(context.codingPath)"
        default:
            print("could not determine error")
            errorMessage = "could not determine error"
        }
        return .decodingError(errorMessage)
        
    case let urlError as URLError:
        return .urlSessionFailed(urlError)
    case let error as NetworkRequestError:
        return error
    default:
        return .unknownError
    }
}

@available(iOS 15, *)
public protocol AsyncNetworkAPI {
    
    var session: URLSession { get set }
    
    func dispatch<T: Decodable>(
        type: T.Type,
        with request: URLRequest,
        decodingWith decoder: JSONDecoder) async throws -> T
    
    func dispatchText(request: URLRequest) async throws -> String
}

@available(iOS 15, *)
extension AsyncNetworkAPI {
    //Stubs
    /// DIspatch a netwrok request
    /// - Returns: Decoded Type T
    public func dispatch<T: Decodable>(
        type: T.Type,
        with request: URLRequest,
        decodingWith decoder: JSONDecoder = JSONDecoder()) async throws -> T {            
            do {
                let (data, response) = try await session.data(for: request)
                // try! debugPayloadData(data)
                let httpResponse = response as? HTTPURLResponse
                guard httpResponse!.statusCode == 200 else {
                    //throw APIError.responseUnsuccessful(description: "status code - \(httpResponse.statusCode)")
                    throw httpError(httpResponse!.statusCode)
                }
                
                return try decoder.decode(type, from: data)
            } catch {
                //throw APIError.jsonConversionFailure(description: error.localizedDescription)
                throw handleError(error)
            }
        }
    
    public func dispatchText(request: URLRequest) async throws -> String {
            do {
                let (data, response) = try await session.data(for: request)
                // try! debugPayloadData(data)
                let httpResponse = response as? HTTPURLResponse
                guard httpResponse!.statusCode == 200 else {
                    //throw APIError.responseUnsuccessful(description: "status code - \(httpResponse.statusCode)")
                    throw httpError(httpResponse!.statusCode)
                }
                
                return String(decoding: data, as: UTF8.self)
            } catch {
                //throw APIError.jsonConversionFailure(description: error.localizedDescription)
                throw handleError(error)
            }
        }
    
    public func AsyncURLSession(session: URLSession,
                           task: URLSessionTask,
                           didReceiveChallenge challenge: URLAuthenticationChallenge,
                           completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential,
                          URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

