//
//  ChainRouter.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/4.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

enum ChainEndpoint {
    case GetInfo()
    case GetBlock(blockNumberOrId: AnyObject)
    case PushTransaction(transaction: SignedTransaction)
    case AbiJsonToBin(abi: AbiJson)
    case GetCurrencyBalance(account: String, symbol: String, code: String)
    case GetAccount(account: String)
    case GetTableRows(param: TableRowRequestParam)
}

class ChainRouter: BaseRouter {
    var endpoint: ChainEndpoint
    init(endpoint: ChainEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: HTTPMethod {
        return .post
    }
    
    override var path: String {
        switch endpoint {
        case .GetInfo: return "/chain/get_info"
        case .GetBlock: return "/chain/get_block"
        case .PushTransaction: return "/chain/push_transaction"
        case .AbiJsonToBin: return "/chain/abi_json_to_bin"
        case .GetCurrencyBalance: return "/chain/get_currency_balance"
        case .GetAccount: return "/chain/get_account"
        case .GetTableRows: return "/chain/get_table_rows"
        }
    }
    
    override var parameters: QueryParams {
        switch endpoint {
        default: return [:]
        }
    }
    
    override var body: Data? {
        switch endpoint {
        case .GetInfo(): return nil
        case .GetBlock(let blockNumberOrId):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try! encoder.encode(["block_num_or_id": "\(blockNumberOrId)"])
            return jsonData
        case .PushTransaction(let transaction):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try! encoder.encode(transaction)
            return jsonData
        case .AbiJsonToBin(let abi):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .useDefaultKeys
            let jsonData = try! encoder.encode(abi)
            return jsonData
        case .GetCurrencyBalance(let account, let symbol, let code):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try! encoder.encode(["account": account, "symbol": symbol, "code": code])
            return jsonData
        case .GetAccount(let account):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try! encoder.encode(["account_name": account])
            return jsonData
        case .GetTableRows(let param):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try! encoder.encode(param)
            return jsonData
        }
    }
}
