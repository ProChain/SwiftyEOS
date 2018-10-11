//
//  AccountUtil.swift
//  SwiftyEOS
//
//  Created by liu nian on 2018/9/7.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

@objcMembers class NewAccountParam: NSObject, Codable {
    var creator: String = ""
    var name: String = ""
    var owner: RequiredAuth?
    var active: RequiredAuth?
}
@objcMembers class AccountUtil: NSObject {
    
    static func stakeNewAccountAbiJson(creator: String, account: String, ownerKey: String, activeKey: String) -> AbiJson {
        
        let ownerAuthKey = AuthKey()
        ownerAuthKey.key = ownerKey
        ownerAuthKey.weight = 1
        
        let activeAuthKey = AuthKey()
        activeAuthKey.key = activeKey
        activeAuthKey.weight = 1
        
        let ownerRequiredAuth = RequiredAuth()
        ownerRequiredAuth.keys = [ownerAuthKey]
        ownerRequiredAuth.threshold = 1
        
        let activeRequiredAuth = RequiredAuth()
        activeRequiredAuth.keys = [activeAuthKey]
        activeRequiredAuth.threshold = 1
        
        let param = NewAccountParam()
        param.creator = creator
        param.name = account
        param.owner = ownerRequiredAuth
        param.active = activeRequiredAuth
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(param)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return try! AbiJson(code: "eosio", action: "newaccount", json: jsonString!)
    }
    
    /// creator help someone create an account
    ///
    /// - Parameters:
    ///   - account: account that need to be created
    ///   - ownerKey: ownerKey(privatekey) for account
    ///   - activeKey: activeKey(privatekey) for account
    ///   - creator: creator
    ///   - pkString: privatekey
    ///   - ramEos: ram resource
    ///   - netEos: net resource
    ///   - cpuEos: cpu resource
    ///   - transfer: Whether to transfer creator's resources(ram,cpu,net) to account
    ///   - completion: callback
    static func stakeCreateAccount(account: String, ownerKey: String, activeKey: String, creator: String, pkString: String, ramEos:Float, netEos: Float, cpuEos: Float, transfer: Bool, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let newaccountAbiJson = self.stakeNewAccountAbiJson(creator: creator,account: account, ownerKey: ownerKey, activeKey: activeKey)
        let buyRamAbiJson = ResourceUtil.buyRamAbiJson(payer: creator, receiver: account, ramEos: ramEos)
        let delegatebwAbiJson = ResourceUtil.stakeResourceAbiJson(from: creator, receiver: account, transfer: transfer ? 1: 0, net: netEos, cpu: cpuEos)
        
        guard let privateKey = try? PrivateKey(keyString: pkString) else {
            completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "invalid private key"]))
            return
        }

        TransactionUtil.pushTransaction(abis: [newaccountAbiJson, buyRamAbiJson, delegatebwAbiJson], account: creator, privateKey: privateKey!, completion: completion)
    }
}
