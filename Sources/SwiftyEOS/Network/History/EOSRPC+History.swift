//
//  EOSRPC+History.swift
//  SwiftyEOS
//
//  Created by croath on 2018/7/19.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

extension EOSRPC {
    func getKeyAccounts(pub: String, completion: @escaping (_ result: KeyAccountsResult?, _ error: Error?) -> ()) {
        let router = HistoryRouter(endpoint: .GetKeyAccounts(pub: pub))
        internalRequest(router: router, completion: completion)
    }
}
