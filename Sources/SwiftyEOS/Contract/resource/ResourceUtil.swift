//
//  ResourceUtil.swift
//  SwiftyEOS
//
//  Created by croath on 2018/8/27.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

@objcMembers class DelegateParam: NSObject, Codable {
    var from: String = ""
    var receiver: String = ""
    var stake_net_quantity: String = ""
    var stake_cpu_quantity: String = ""
    var transfer: UInt = 0
}

@objcMembers class UndelegateParam: NSObject, Codable {
    var from: String = ""
    var receiver: String = ""
    var unstake_net_quantity: String = ""
    var unstake_cpu_quantity: String = ""
    var transfer: UInt = 0
}

@objcMembers class BuyRamParam: NSObject, Codable {
    var payer: String = ""
    var receiver: String = ""
    var quant: String = ""
}

@objcMembers class SellRamParam: NSObject, Codable {
    var account: String = ""
    var bytes: Float = 0.0
}

@objcMembers class ResourceUtil: NSObject {
    static func stakeResourceAbiJson(account: String, net: Float, cpu: Float) -> AbiJson {
        return stakeResourceAbiJson(from: account, receiver: account, transfer: 0, net: net, cpu: cpu)
    }
    
    static func stakeResourceAbiJson(from: String, receiver: String,transfer: UInt, net: Float, cpu: Float) -> AbiJson {
        let param = DelegateParam()
        param.from = from
        param.receiver = receiver
        param.stake_net_quantity = String(format: "%.4f EOS", net)
        param.stake_cpu_quantity = String(format: "%.4f EOS", cpu)
        param.transfer = transfer
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(param)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return try! AbiJson(code: "eosio", action: "delegatebw", json: jsonString!)
    }
    
    static func stakeResource(account: String, net: Float, cpu: Float, pkString: String, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = self.stakeResourceAbiJson(account: account, net: net, cpu: cpu)
        guard let privateKey = try? PrivateKey(keyString: pkString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "invalid private key"]))
            return
        }
        
        TransactionUtil.pushTransaction(abi: abiJson, account: account, privateKey: privateKey!, completion: completion)
    }
    
    static func unstakeResourceAbiJson(account: String, net: Float, cpu: Float) -> AbiJson {
        let param = UndelegateParam()
        param.from = account
        param.receiver = account
        param.unstake_net_quantity = String(format: "%.4f EOS", net)
        param.unstake_cpu_quantity = String(format: "%.4f EOS", cpu)
        param.transfer = 0
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(param)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return try! AbiJson(code: "eosio", action: "undelegatebw", json: jsonString!)
    }
    
    static func unstakeResource(account: String, net: Float, cpu: Float, pkString: String, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = self.unstakeResourceAbiJson(account: account, net: net, cpu: cpu)
        guard let privateKey = try? PrivateKey(keyString: pkString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "invalid private key"]))
            return
        }
        
        TransactionUtil.pushTransaction(abi: abiJson, account: account, privateKey: privateKey!, completion: completion)
    }
    
    static func buyRamAbiJson(account: String, ramEos: Float) -> AbiJson {
        return buyRamAbiJson(payer: account, receiver: account, ramEos: ramEos)
    }
    
    static func buyRamAbiJson(payer: String, receiver: String, ramEos: Float) -> AbiJson {
        let param = BuyRamParam()
        param.payer = payer
        param.receiver = receiver
        param.quant = String(format: "%.4f EOS", ramEos)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(param)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return try! AbiJson(code: "eosio", action: "buyram", json: jsonString!)
    }
    
    static func buyRam(account: String, ramEos: Float, pkString: String, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = self.buyRamAbiJson(account: account, ramEos: ramEos)
        guard let privateKey = try? PrivateKey(keyString: pkString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "invalid private key"]))
            return
        }
        
        TransactionUtil.pushTransaction(abi: abiJson, account: account, privateKey: privateKey!, completion: completion)
    }
    
    static func sellRamAbiJson(account: String, ramBytes: Float) -> AbiJson {
        let param = SellRamParam()
        param.account = account
        param.bytes = ramBytes
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(param)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return try! AbiJson(code: "eosio", action: "sellram", json: jsonString!)
    }
    
    static func sellRam(account: String, ramBytes: Float, pkString: String, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = self.sellRamAbiJson(account: account, ramBytes: ramBytes)
        guard let privateKey = try? PrivateKey(keyString: pkString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "invalid private key"]))
            return
        }
        
        TransactionUtil.pushTransaction(abi: abiJson, account: account, privateKey: privateKey!, completion: completion)
    }
}
