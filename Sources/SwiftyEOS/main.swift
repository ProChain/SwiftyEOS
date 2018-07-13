//
//  main.swift
//  SwiftyEOS
//
//  Created by croath on 2018/4/23.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

print("Hello, SwiftyEOS!")

//EOSRPC.sharedInstance.chainInfo { (chainInfo, error) in
//    if error == nil {
//        print("Success: \(String(describing: chainInfo))")
//    } else {
//        print("Error: \(String(describing: error?.localizedDescription))")
//    }
//}
//
//EOSRPC.sharedInstance.getBlock(blockNumOrId: 5 as AnyObject) { (blockInfo, error) in
//    if error == nil {
//        print("Success: \(String(describing: blockInfo))")
//    } else {
//        print("Error: \(String(describing: error?.localizedDescription))")
//    }
//}

//let (pk, pub, err) = generateRandomKeyPair(enclave: .Secp256k1)
//print("private key: \(pk!.wif())")
//print("public key : \(pub!.wif())")

let importedPk = try PrivateKey(keyString: "5J3Aa7Z98cZn9Rjy4aEaYUsN2EmYveLvh4YgCHCvvNB6EYJ94PA")
let importedPub = PublicKey(privateKey: importedPk!)
print("imported private key: \(importedPk!.wif())")
print("imported public key : \(importedPub.wif())")

var transfer = Transfer()
transfer.from = "raoji"
transfer.to = "raojiraoji12"
transfer.quantity = "10.0000 EOS"
transfer.memo = "test"

Currency.transferCurrency(tranfer: transfer, privateKey: importedPk!)

RunLoop.main.run()
