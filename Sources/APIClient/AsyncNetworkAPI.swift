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
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case invalidToken
    
    //Added this from other code - MGK
    case requestFailed(description: String)
}


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
            return .decodingError
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        case let error as NetworkRequestError:
            return error
        default:
            return .unknownError
    }
}

@available(iOS 15, *)
protocol AsyncNetworkAPI {
    
    var session: URLSession { get }
    
    func dispatch<T: Decodable>(
        type: T.Type,
        with request: URLRequest,
        decodingWith decoder: JSONDecoder) async throws -> T
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
}

