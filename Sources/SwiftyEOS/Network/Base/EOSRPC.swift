//
//  EOSRPC.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/4.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

let errorDomain = "SwiftyEOSErrorDomain"

var se_iso8601dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    return dateFormatter
}()

var se_iso8601dateFormatterWithoutMilliseconds: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter
}()

var se_iso8601dateFormatterRequest: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
    return dateFormatter
}()

func customDateFormatter(_ decoder: Decoder) throws -> Date {
    let dateString = try decoder.singleValueContainer().decode(String.self)
    switch dateString.count {
    case 20..<Int.max:
        return se_iso8601dateFormatter.date(from: dateString)!
    case 19:
        return se_iso8601dateFormatterWithoutMilliseconds.date(from: dateString)!
    default:
        let dateKey = decoder.codingPath.last
        fatalError("Unexpected date coding key: \(String(describing: dateKey))")
    }
}

@objcMembers class EOSRPC: NSObject {
    static var endpoint: String?
    
    class var sharedInstance: EOSRPC {
        struct Singleton {
            static let instance : EOSRPC = EOSRPC()
        }
        return Singleton.instance
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(customDateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    internal func internalRequest<T: Codable>(router: BaseRouter, completion: @escaping (_ result: T?, _ error: Error?) -> ()) {
        guard let request = try? router.urlRequest() else {
            completion(nil, NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Error creating request"]))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil, NSError(domain: errorDomain, code: 1,
                                            userInfo: [NSLocalizedDescriptionKey: "Networking error \(String(describing: error)) \(String(describing: response))"]))
                    return
                }
                
                let decoder = self.decoder
                guard let responseObject = try? decoder.decode(T.self, from: data) else {
                    guard let errorResponse = try? decoder.decode(RPCErrorResponse.self, from: data) else {
                        completion(nil, NSError(domain: errorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Decoding error \(String(describing: error))"]))
                        return
                    }
                    completion(nil, NSError(domain: errorDomain, code: RPCErrorResponse.ErrorCode, userInfo: [RPCErrorResponse.ErrorKey: errorResponse]))
                    return
                }
                completion(responseObject, error)
            }
            
        }
        
        dataTask.resume()
    }
}
