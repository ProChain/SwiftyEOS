//
//  Currency.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/29.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

@objcMembers class Transfer: NSObject, Codable {
    var from: String = ""
    var to: String = ""
    var quantity: String = ""
    var memo: String = ""
}

@objcMembers class Currency {
    static func transferCurrency(transfer: Transfer, code: String, privateKey: PrivateKey, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(transfer)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        guard let abiJson = try? AbiJson(code: code, action: "transfer", json: jsonString!) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: nil))
            return
        }
        
        TransactionUtil.pushTransaction(abi: abiJson, account: transfer.from, privateKey: privateKey, completion: completion)
    }
}
