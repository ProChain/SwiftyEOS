//
//  BaseRouter.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/4.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

typealias QueryParams = [String : AnyObject]?

protocol APIConfiguration {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: QueryParams { get }
    var baseUrl: String { get }
}

class BaseRouter : APIConfiguration {
    func urlRequest() throws -> URLRequest {
        let baseURL = NSURL(string: baseUrl)
        var components = URLComponents(string: (baseURL!.appendingPathComponent(path)?.absoluteString)!)
        if parameters?.count != 0 {
            components?.queryItems = parameters?.compactMap{
                return URLQueryItem(name: $0, value: "\($1)")
            }
        }
        var request = URLRequest(url: (components?.url)!)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request as URLRequest
    }
    
    
    init() {}
    
    var headers: Dictionary<String, String> {
        let dict = Dictionary<String, String>()
        return dict
    }
    
    var method: HTTPMethod {
        fatalError("[\(String(describing: type(of: self))) - \(#function))] Must be overridden in subclass")
    }
    
    var path: String {
        fatalError("[\(String(describing: type(of: self))) - \(#function))] Must be overridden in subclass")
    }
    
    var parameters: QueryParams {
        fatalError("[\(String(describing: type(of: self))) - \(#function))] Must be overridden in subclass")
    }
    
    var body: Data? {
        fatalError("[\(String(describing: type(of: self))) - \(#function))] Must be overridden in subclass")
    }
    
    var baseUrl: String {
        if EOSRPC.endpoint != nil {
            return EOSRPC.endpoint! + "/v1"
        }
        return "https://api.eosnewyork.io/v1"
    }
}
