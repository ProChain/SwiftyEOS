//
//  ChainInfo.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/4.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

struct ChainInfo: Codable {
    var serverVersion: String?
    var chainId: String?
    var headBlockNum: UInt64
    var lastIrreversibleBlockNum: UInt64
    var lastIrreversibleBlockId: String?
    var headBlockId: String?
    var headBlockTime: Date?
    var headBlockProducer: String?
    var virtualBlockCpuLimit: UInt64
    var blockCpuLimit: UInt64
    var blockNetLimit: UInt64
}

@objcMembers class BlockInfo: NSObject, Codable {
    var previous: String?
    var timestamp: Date?
    var transactionMerkleRoot: String?
    var producer: String?
    var producerChanges: [String]?
    var producerSignature: String?
    var cycles: [String]?
    var id: String?
    var blockNum: Int = 0
    var refBlockPrefix: Int = 0
    
    // not metioned in the doc
    var actionMerkleRoot: String?
    var blockMerkleRoot: String?
    var scheduleVersion: UInt64 = 0
    var newProducers: [String]?
    var inputTransactions: [String]?
    //    var regions: [Any]?
    
    override init() {
        
    }
}

@objcMembers class KeyAccountsResult: NSObject, Codable {
    var accountNames: [String] = []
}

@objcMembers class AuthKey: NSObject, Codable {
    var key: String?
    var weight: Int = 0
}

@objcMembers class RequiredAuth: NSObject, Codable {
    var keys: [AuthKey]?
}

@objcMembers class AccountPermission: NSObject, Codable {
    var permName: String?
    var parent: String?
    var requiredAuth: RequiredAuth?
}

@objcMembers class Account: NSObject, Codable {
    var accountName: String = ""
    var permissions: [AccountPermission]?
}

@objcMembers class TableRowResponse<T: Codable>: NSObject, Codable {
    var rows: [T]?
    var more: Bool = false
}

struct TableRowRequestParam: Codable {
    var scope: String
    var code: String
    var table: String
    var json: Bool
    var lowerBound: Int32?
    var upperBound: Int32?
    var limit: Int32?
}

@objcMembers class TransactionResultProcessedReceipt: NSObject, Codable {
    var status: String = ""
    var cpuUsageUs: UInt64 = 0
    var netUsageWords: UInt64 = 0
}

@objcMembers class TransactionResultProcessed: NSObject, Codable {
    var id: String = ""
    var receipt: TransactionResultProcessedReceipt?
}

@objcMembers class TransactionResult: NSObject, Codable {
    var transactionId: String = ""
    var processed: TransactionResultProcessed?
}
