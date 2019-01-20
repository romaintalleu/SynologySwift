//
//  SynologySwiftCoreNetwork.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 20/12/2018.
//  Copyright © 2018 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwiftCoreNetwork {
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case HEAD
        case DELETE
        case PATCH
        case TRACE
        case OPTIONS
        case CONNECT
    }
    
    enum RequestResult<T> {
        case success(T)
        case failure(RequestError)
    }
    
    enum RequestError: Error {
        case parametersFormatError
        case networkError(Error)
        case invalidStatusCode(Int?)
        case dataNotFound
        case jsonParsingError(Error)
    }
    
    enum RequestQuickConnectCommonError: Int {
        case unknowError              = 100
        case invalidParameter         = 101
        case apiDoesNotExist          = 102
        case methodDoesNotExist       = 103
        case versionNotSupported      = 104
        case sessionInsuffisanceScope = 105
        case sessionExpired           = 106
        case sessionDuplicate         = 107
        
        var description: String {
            switch self {
            case .unknowError:              return "Unknown error"
            case .invalidParameter:         return "Invalid parameter"
            case .apiDoesNotExist:          return "The requested API does not exist"
            case .methodDoesNotExist:       return "The requested method does not exist"
            case .versionNotSupported:      return "The requested version does not support the functionality"
            case .sessionInsuffisanceScope: return "The logged in session does not have permission"
            case .sessionExpired:           return "Session timeout"
            case .sessionDuplicate:         return "Session interrupted by duplicate login"
            }
        }
    }
    
    static func performRequest<T: Decodable>(with url: String, for objectType: T.Type, method: HTTPMethod = .GET, params: [String: Any]? = nil, contentType: String? = "application/json", timeout: TimeInterval = 10, completion: @escaping (RequestResult<T>) -> Void) {
        let dataURL = URL(string: url)!
        let session = URLSession.shared
        var request = URLRequest(url: dataURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
        request.addValue(contentType ?? "application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        
        /* Body ? */
        if let params = params {
            if contentType == "application/x-www-form-urlencoded; charset=utf-8" {
                if let queryParams = SynologySwiftTools.queryStringForParams(params) {request.httpBody = queryParams.data(using: .utf8)}
            } else {
                guard let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else {
                    completion(.failure(.parametersFormatError))
                    return
                }
                request.httpBody = data
            }
        }
        
        SynologySwiftTools.logMessage("CoreNetwork : Start call (\(url))")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            SynologySwiftTools.logMessage("CoreNetwork : End call (\(url))")
            
            guard error == nil else {
                completion(.failure(.networkError(error!)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                200...300 ~= httpResponse.statusCode
                else {
                    completion(.failure(.invalidStatusCode((response as? HTTPURLResponse)?.statusCode)))
                    return
            }
            
            guard let data = data else {
                completion(.failure(.dataNotFound))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(objectType.self, from: data)
                completion(.success(decodedObject))
            } catch let error {
                completion(.failure(.jsonParsingError(error as! DecodingError)))
            }
        })
        
        task.resume()
    }

}
