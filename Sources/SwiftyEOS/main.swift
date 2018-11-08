//
//  main.swift
//  SwiftyEOS
//
//  Created by croath on 2018/4/23.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

print("Hello, SwiftyEOS!")

let (pk, pub, mn) = generateRandomKeyPair(enclave: .Secp256k1)
print("private key: \(pk!.rawPrivateKey())")
print("public key : \(pub!.rawPublicKey())")
print("mnemonic : \(mn ?? "")")

//EOSRPC.sharedInstance.chainInfo { (chainInfo, error) in
//    if error == nil {
//        print("Success: \(chainInfo!)")
//    } else {
//        print("Error: \(error!.localizedDescription)")
//    }
//}
//
//EOSRPC.sharedInstance.getBlock(blockNumOrId: 5 as AnyObject) { (blockInfo, error) in
//    if error == nil {
//        print("Success: \(blockInfo!)")
//    } else {
//        print("Error: \(error!.localizedDescription)")
//    }
//}

//MARK: Jungle TestNet
//let liuAccount = "liulian12345"
//let privateKey = "5Hsk6wB2MPqGPrU53jSVGHm3uvoqWJk3rCrnkGzEGc7HrH28n7t"
//let privatePk = try PrivateKey(keyString: privateKey)
//let testNeedCreateAccount = "liunian12341"
//let testNeedCreatePubKey = "EOS5uLxwJQgpEJteBxBTKiqWnyWiJTQAzAqx71M5AuMZ917oMv4g4"
//
//AccountUtil.stakeCreateAccount(account: testNeedCreateAccount,
//                               ownerKey: testNeedCreatePubKey,
//                               activeKey: testNeedCreatePubKey,
//                               creator: liuAccount,
//                               pkString: privateKey,
//                               ramEos: 1.0,
//                               netEos: 1.0,
//                               cpuEos: 1.0,
//                               transfer: true) { (result, error) in
//                                if error != nil {
//                                    if (error! as NSError).code == RPCErrorResponse.ErrorCode {
//                                        print("\(((error! as NSError).userInfo[RPCErrorResponse.ErrorKey] as! RPCErrorResponse).errorDescription())")
//                                    } else {
//                                        print("other error: \(String(describing: error?.localizedDescription))")
//                                    }
//                                } else {
//                                    print("Ok. Txid: \(result!.transactionId)")
//                                }
//}

//let (pk, pub) = generateRandomKeyPair(enclave: .Secp256k1)
//print("private key: \(pk!.rawPrivateKey())")
//print("public key : \(pub!.rawPublicKey())")


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
//
//Currency.transferCurrency(transfer: transfer, code: "eosio.token", privateKey: importedPk!, completion: { (result, error) in
//    if error != nil {
//        if (error! as NSError).code == RPCErrorResponse.ErrorCode {
//            print("\(((error! as NSError).userInfo[RPCErrorResponse.ErrorKey] as! RPCErrorResponse).errorDescription())")
//        } else {
//            print("other error: \(String(describing: error?.localizedDescription))")
//        }
//    } else {
//        print("Ok. Txid: \(result!.transactionId)")
//    }
//})
//

//let account = "raoji"
//let asset = "1.0000 EPRA"
//
//let data = "{\"withdrawRequest\": {\"account\":\"" + account  + "\", \"quantity\":\"" + asset + "\"}}"
//let abi = try! AbiJson(code: "prabox1", action: "withdraw", json: data)
//
//TransactionUtil.pushTransaction(abi: abi, account: account, privateKey: importedPk!, completion: { (result, error) in
//    if error != nil {
//        if (error! as NSError).code == RPCErrorResponse.ErrorCode {
//            print("\(((error! as NSError).userInfo[RPCErrorResponse.ErrorKey] as! RPCErrorResponse).errorDescription())")
//        } else {
//            print("other error: \(String(describing: error?.localizedDescription))")
//        }
//    } else {
//        print("Ok. Txid: \(result!.transactionId)")
//    }
//})

//EOSRPC.sharedInstance.getAccount(account: "raoji") { (account, error) in
//
//    let net = ByteCountFormatter.string(fromByteCount: Int64(account!.netLimit!.max), countStyle: .binary)
//    let cpu = DateComponentsFormatter().string(from: TimeInterval(account!.cpuLimit!.max))!
//    let ram = ByteCountFormatter.string(fromByteCount: Int64(account!.ramLimit!.max), countStyle: .binary)
//    print("cpu: \(cpu) net: \(net) ram: \(ram)")
//    ResourceUtil.stakeResource(account: "raoji", net: 1.0, cpu: 1.0, pkString: "5HsaHvRCPrjU3yhapB5rLRyuKHuFTsziidA13Uw6WnQTeJAG3t4", completion: { (result, error) in
//        EOSRPC.sharedInstance.getAccount(account: "raoji") { (account, error) in
//            let net = ByteCountFormatter.string(fromByteCount: Int64(account!.netLimit!.max), countStyle: .binary)
//            let cpu = DateComponentsFormatter().string(from: TimeInterval(account!.cpuLimit!.max))!
//            let ram = ByteCountFormatter.string(fromByteCount: Int64(account!.ramLimit!.max), countStyle: .binary)
//            print("cpu: \(cpu) net: \(net)) ram: \(ram)")
//        }
//    })
//
//    ResourceUtil.buyRam(account: "raoji", ramEos: 10000, pkString: "5HsaHvRCPrjU3yhapB5rLRyuKHuFTsziidA13Uw6WnQTeJAG3t4", completion: { (result, error) in
//        EOSRPC.sharedInstance.getAccount(account: "raoji") { (account, error) in
//            let net = ByteCountFormatter.string(fromByteCount: Int64(account!.netLimit!.max), countStyle: .binary)
//            let cpu = DateComponentsFormatter().string(from: TimeInterval(account!.cpuLimit!.max))!
//            let ram = ByteCountFormatter.string(fromByteCount: Int64(account!.ramLimit!.max), countStyle: .binary)
//            print("cpu: \(cpu) net: \(net)) ram: \(ram)")
//        }
//    })
//
//    ResourceUtil.sellRam(account: "raoji", ramBytes: 1024*1024*512, pkString: "5HsaHvRCPrjU3yhapB5rLRyuKHuFTsziidA13Uw6WnQTeJAG3t4", completion: { (result, error) in
//        EOSRPC.sharedInstance.getAccount(account: "raoji") { (account, error) in
//            let net = ByteCountFormatter.string(fromByteCount: Int64(account!.netLimit!.max), countStyle: .binary)
//            let cpu = DateComponentsFormatter().string(from: TimeInterval(account!.cpuLimit!.max))!
//            let ram = ByteCountFormatter.string(fromByteCount: Int64(account!.ramLimit!.max), countStyle: .binary)
//            print("cpu: \(cpu) net: \(net)) ram: \(ram)")
//        }
//    })
//}


//var transJson = """
//[ "raoji", "raojiraoji12", "1.0000 EOS", "test" ]
//"""
//
//TransactionUtil.pushTransaction(code: "eosio.token", action: "transfer", paramsJson: transJson, account: "raoji", pkString: importedPk!.rawPrivateKey()) { (result, error) in
//    if error != nil {
//        if (error! as NSError).code == RPCErrorResponse.ErrorCode {
//            print("\(((error! as NSError).userInfo[RPCErrorResponse.ErrorKey] as! RPCErrorResponse).errorDescription())")
//        } else {
//            print("other error: \(String(describing: error?.localizedDescription))")
//        }
//    } else {
//        print("Ok. Txid: \(result!.transactionId)")
//    }
//}

RunLoop.main.run()
