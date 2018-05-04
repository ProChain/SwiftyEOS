//
//  main.swift
//  SwiftyEOS
//
//  Created by croath on 2018/4/23.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

print("Hello, SwiftyEOS!")

EOSRPC.sharedInstance.chainInfo { (chainInfo, error) in
    if error == nil {
        print("Success: \(String(describing: chainInfo))")
    } else {
        print("Error: \(String(describing: error?.localizedDescription))")
    }
}

EOSRPC.sharedInstance.getBlock(blockNumOrId: 5 as AnyObject) { (blockInfo, error) in
    if error == nil {
        print("Success: \(String(describing: blockInfo))")
    } else {
        print("Error: \(String(describing: error?.localizedDescription))")
    }
}

RunLoop.main.run()
