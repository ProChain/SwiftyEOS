//
//  EOSRPC+Chain.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/4.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

extension EOSRPC {
    func chainInfo(completion: @escaping (_ result: ChainInfo?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .GetInfo())
        internalRequest(router: router, completion: completion)
    }
    
    func getBlock(blockNumOrId: AnyObject, completion: @escaping (_ result: BlockInfo?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .GetBlock(blockNumberOrId: blockNumOrId))
        internalRequest(router: router, completion: completion)
    }
    
    func abiJsonToBin(abi: AbiJson, completion: @escaping (_ result: AbiBinResult?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .AbiJsonToBin(abi: abi))
        internalRequest(router: router, completion: completion)
    }
    
    func pushTransaction(transaction: SignedTransaction, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .PushTransaction(transaction: transaction))
        internalRequest(router: router, completion: completion)
    }
    
    func getCurrencyBalance(account: String, symbol: String, code: String, completion: @escaping (_ result: NSDecimalNumber?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .GetCurrencyBalance(account: account, symbol: symbol, code: code))
        internalRequest(router: router) { (resultArray: [String]?, error: Error?) in
            if error != nil || resultArray == nil {
                completion(nil, error)
                return
            }
            
            if resultArray?.count == 0 {
                completion(NSDecimalNumber.zero, nil)
                return
            }
            let balanceString = resultArray!.first
            let parts = balanceString!.components(separatedBy: " ")
            if parts.count != 2 || parts[1] != "EOS" {
                completion(NSDecimalNumber.zero, nil)
                return
            }
            completion(NSDecimalNumber(string: parts[0]), nil)
        }
    }
    
    func getAccount(account: String, completion: @escaping (_ result: Account?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .GetAccount(account: account))
        internalRequest(router: router, completion: completion)
    }
    
    func getTableRows<T: Codable>(param: TableRowRequestParam, completion: @escaping (_ result: TableRowResponse<T>?, _ error: Error?) -> ()) {
        let router = ChainRouter(endpoint: .GetTableRows(param: param))
        internalRequest(router: router, completion: completion)
    }
    
    func getTableRows<T: Codable>(scope: String, code: String, table: String, completion: @escaping (_ result: TableRowResponse<T>?, _ error: Error?) -> ()) {
        let param = TableRowRequestParam(scope: scope, code: code, table: table, json: true, lowerBound: nil, upperBound: nil, limit: nil)
        let router = ChainRouter(endpoint: .GetTableRows(param: param))
        internalRequest(router: router, completion: completion)
    }
}
