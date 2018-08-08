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
        print("Success: \(chainInfo!)")
    } else {
        print("Error: \(error!.localizedDescription)")
    }
}

EOSRPC.sharedInstance.getBlock(blockNumOrId: 5 as AnyObject) { (blockInfo, error) in
    if error == nil {
        print("Success: \(blockInfo!)")
    } else {
        print("Error: \(error!.localizedDescription)")
    }
}

let (pk, pub) = generateRandomKeyPair(enclave: .Secp256k1)
print("private key: \(pk!.rawPrivateKey())")
print("public key : \(pub!.rawPublicKey())")


//let importedPk = try PrivateKey(keyString: "5HsaHvRCPrjU3yhapB5rLRyuKHuFTsziidA13Uw6WnQTeJAG3t4")
//let importedPub = PublicKey(privateKey: importedPk!)
//print("imported private key: \(importedPk!.wif())")
//print("imported public key : \(importedPub.wif())")
//
//var transfer = Transfer()
//transfer.from = "raoji"
//transfer.to = "raojiraoji12"
//transfer.quantity = "1.0000 EOS"
//transfer.memo = "test"

//Currency.transferCurrency(tranfer: transfer, privateKey: importedPk!)

RunLoop.main.run()
