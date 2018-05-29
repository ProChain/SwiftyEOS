//
//  Currency.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/29.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

struct AbiJson: Codable {
    var code: String
    var action: String
    var args: Dictionary<String, String>
}

struct Authorization: Codable {
    var account: String
    var permission: String
}

struct Action: Codable {
    var code: String
    var type: String
    var recipients: [String]
    var authorization: [Authorization]
    var data: String
}

struct Transaction: Codable {
    var refBlockNum: String
    var refBlockPrefix: String
    var expiration: Date
    var scope: [String]
    var actions: [Action]
    var signatures: [String]
    var authorizations: [String]
}

struct Transfer: Codable {
    var from: String
    var to: String
    var quantity: UInt64
}

struct Currency {
    static func transferCurrency(tranfer: Transfer) {
        EOSRPC.sharedInstance.chainInfo { (chainInfo, error) in
            if error == nil {
                EOSRPC.sharedInstance.getBlock(blockNumOrId: chainInfo?.lastIrreversibleBlockNum as AnyObject, completion: { (blockInfo, error) in
                    if error == nil {
                        let authorization = Authorization(account: tranfer.from, permission: "active")
                        
                        var action = Action(code: "currency",
                                            type: "transfer",
                                            recipients: [tranfer.from, tranfer.to],
                                            authorization: [authorization],
                                            data: "")
                        
                        var tx = Transaction(refBlockNum: "\(blockInfo!.blockNum)",
                                             refBlockPrefix: "\(blockInfo!.refBlockPrefix)",
                                             expiration: Date(timeInterval: 1000, since: Date()),
                                             scope: [tranfer.from, tranfer.to],
                                             actions: [action],
                                             signatures: [],
                                             authorizations: [])
                    }
                })
            }
        }
    }
}
