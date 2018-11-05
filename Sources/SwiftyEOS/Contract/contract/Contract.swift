//
//  Contract.swift
//  SwiftyEOS
//
//  Created by croath on 2018/11/5.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

@objcMembers class AbiType: NSObject, Decodable {
    var newTypeName: String?
    var type: String?
}

@objcMembers class AbiField: NSObject, Decodable {
    var name: String
    var type: String
}

@objcMembers class AbiSturct: NSObject, Decodable {
    var name: String
    var base: String?
    var fields: [AbiField]
}

@objcMembers class AbiAction: NSObject, Decodable {
    var name: String
    var type: String
    var ricardianContract: String?
}

@objcMembers class AbiTable: NSObject, Decodable {
    var name: String
    var type: String
    var indexType: String?
    var keyNames: [String]?
    var keyTypes: [String]?
}

@objcMembers class AbiCore: NSObject, Decodable {
    var version: String?
    var types: [AbiType]?
    var structs: [AbiSturct]
    var actions: [AbiAction]
    var tables: [AbiTable]
}

@objcMembers class Abi: NSObject, Decodable {
    var accountName: String
    var abi: AbiCore
    
    func generateAbiJson(action: String, paramsJson: String) throws -> AbiJson {
        var found = false
        var usingStruct: AbiSturct?
        for abiAction in abi.actions {
            if abiAction.name == action {
                let structName = abiAction.type
                for abiStruct in abi.structs {
                    if abiStruct.name == structName {
                        usingStruct = abiStruct
                        found = true
                        break
                    }
                }
                if found {
                    break
                }
            }
        }
        
        if !found {
            throw NSError(domain: "", code: 91001, userInfo: [NSLocalizedDescriptionKey: "no such action or struct"])
        }
        
        let decoder = JSONDecoder()
        let params = try decoder.decode([AnyCodable].self, from: paramsJson.data(using: .utf8)!)
        
        if usingStruct!.fields.count != params.count {
            throw NSError(domain: "", code: 91001, userInfo: [NSLocalizedDescriptionKey: "params count not match"])
        }
        
        var dict = Dictionary<String, AnyCodable>()
        for (field, param) in zip(usingStruct!.fields, params) {
            dict[field.name] = param
        }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try encoder.encode(dict)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        return try AbiJson(code: accountName, action: action, json: jsonString!)
    }
}
