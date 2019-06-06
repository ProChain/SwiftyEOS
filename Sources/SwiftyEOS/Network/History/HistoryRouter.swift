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
	case GetActions(accountName: String, pos: Int, offset: Int)
}

class HistoryRouter: BaseRouter {
    var endpoint: HistoryEndpoint
    init(endpoint: HistoryEndpoint) {
        self.endpoint = endpoint
    }
    
    override var method: HTTPMethod {
        switch endpoint {
		case .GetKeyAccounts: return .post
		case .GetActions: return .post
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetKeyAccounts: return "/history/get_key_accounts"
		case .GetActions: return "/history/get_actions"
        }
    }
    
    override var parameters: QueryParams {
        switch endpoint {
        default: return [:]
        }
    }
    
    override var body: Data? {
		let encoder = JSONEncoder()
        switch endpoint {
        case .GetKeyAccounts(let pub):
            let jsonData = try! encoder.encode(["public_key": "\(pub)"])
            return jsonData
		case .GetActions(let accountName, let pos, let offset):
			let data = ["account_name": accountName, "pos": "\(pos)", "offset": "\(offset)"]
			return try! encoder.encode(data)
        }
    }
}

