//
//  HistoryRouter.swift
//  SwiftyEOS
//
//  Created by croath on 2018/7/19.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

enum HistoryEndpoint {
    case GetKeyAccounts(pub: String)
}

class HistoryRouter: BaseRouter {
    var endpoint: HistoryEndpoint
    init(endpoint: HistoryEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: HTTPMethod {
        switch endpoint {
        case .GetKeyAccounts: return .post
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetKeyAccounts: return "/history/get_key_accounts"
        }
    }
    
    override var parameters: QueryParams {
        switch endpoint {
        default: return [:]
        }
    }
    
    override var body: Data? {
        switch endpoint {
        case .GetKeyAccounts(let pub):
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(["public_key": "\(pub)"])
            return jsonData
        }
    }
}

