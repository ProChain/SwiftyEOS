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

// account

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
    var netLimit: ResourceLimit?
    var cpuLimit: ResourceLimit?
    var ramQuota: String?
    var ramUsage: UInt64 = 0
    var ramLimit: ResourceLimit? {
        get {
            return ResourceLimit(used: ramUsage, available: UInt64(ramQuota!)!-ramUsage, max: UInt64(ramQuota!)!)
        }
    }
    var refundRequest: RefundRequest?
}

@objcMembers class ResourceLimit: NSObject, Codable {
    var used: UInt64
    var available: UInt64
    var max: UInt64
    
    private enum CodingKeys: String, CodingKey {
        case used, available, max
    }
    
    init(used: UInt64, available: UInt64, max: UInt64) {
        self.used = used
        self.available = available
        self.max = max
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.used = try container.decode(UInt64.self, forKey: .used)
        guard let available = try UInt64(container.decode(String.self, forKey: .available)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.available], debugDescription: "Expecting string representation of UInt64"))
        }
        self.available = available
        guard let max = try UInt64(container.decode(String.self, forKey: .max)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.max], debugDescription: "Expecting string representation of UInt64"))
        }
        self.max = max
    }
}

@objcMembers class RefundRequest: NSObject, Codable {
    var owner: String?
    var requestTime: Date?
    var netAmount: String?
    var cpuAmount: String?
}

// table

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

// transaction result

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
