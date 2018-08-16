//
//  TransactionUtil.swift
//  SwiftyEOS
//
//  Created by croath on 2018/8/16.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

@objcMembers class TransactionUtil: NSObject {
    static func pushTransaction(abi: AbiJson, account: String, pkString: String, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        guard let privateKey = try? PrivateKey(keyString: pkString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "invalid private key"]))
            return
        }
        
        pushTransaction(abi: abi, account: account, privateKey: privateKey!, completion: completion)
    }
    
    static func pushTransaction(abi: AbiJson, account: String, privateKey: PrivateKey, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        EOSRPC.sharedInstance.chainInfo { (chainInfo, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            EOSRPC.sharedInstance.getBlock(blockNumOrId: "\(chainInfo!.lastIrreversibleBlockNum)" as AnyObject, completion: { (blockInfo, error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                
                EOSRPC.sharedInstance.abiJsonToBin(abi: abi, completion: { (bin, error) in
                    if error != nil {
                        completion(nil, error)
                        return
                    }
                    let auth = Authorization(actor: account, permission: "active")
                    let action = Action(account: abi.code, name: abi.action, authorization: [auth], data: bin!.binargs)
                    let rawTx = Transaction(blockInfo: blockInfo!, actions: [action])
                    
                    var tx = PackedTransaction(transaction: rawTx, compression: "none")
                    tx.sign(pk: privateKey, chainId: chainInfo!.chainId!)
                    let signedTx = SignedTransaction(packedTx: tx)
                    EOSRPC.sharedInstance.pushTransaction(transaction: signedTx, completion: { (txResult, error) in
                        if error != nil {
                            completion(nil, error)
                            return
                        }
                        completion(txResult, nil)
                    })
                })
            })
        }
    }
}
