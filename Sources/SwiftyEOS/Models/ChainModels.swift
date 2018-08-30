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
    var ramQuota: UInt64 = 0
    var ramUsage: UInt64 = 0
    var ramLimit: ResourceLimit? {
        get {
            return ResourceLimit(used: ramUsage, available: ramQuota-ramUsage, max: ramQuota)
        }
    }
    var refundRequest: RefundRequest?
    var selfDelegatedBandwidth: DelegatedBandwidth?
    var coreLiquidBalance: String? = ""
    
    private enum CodingKeys: String, CodingKey {
        case accountName
        case permissions
        case netLimit
        case cpuLimit
        case ramQuota
        case ramUsage
        case refundRequest
        case selfDelegatedBandwidth
        case coreLiquidBalance
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.accountName = try container.decode(String.self, forKey: .accountName)
        self.permissions = try container.decode([AccountPermission].self, forKey: .permissions)
        self.netLimit = try container.decode(ResourceLimit.self, forKey: .netLimit)
        self.cpuLimit = try container.decode(ResourceLimit.self, forKey: .cpuLimit)
        
        if let ramQuota = try? container.decode(UInt64.self, forKey: .ramQuota) {
            self.ramQuota = ramQuota
        } else if let ramQuota = try UInt64(container.decode(String.self, forKey: .ramQuota)) {
            self.ramQuota = ramQuota
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.ramQuota], debugDescription: "Expecting string or number representation of UInt64"))
        }
        
        if let ramUsage = try? container.decode(UInt64.self, forKey: .ramUsage) {
            self.ramUsage = ramUsage
        } else if let ramUsage = try UInt64(container.decode(String.self, forKey: .ramUsage)) {
            self.ramUsage = ramUsage
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.ramUsage], debugDescription: "Expecting string or number representation of UInt64"))
        }
        
        self.refundRequest = try container.decode(RefundRequest.self, forKey: .refundRequest)
        self.selfDelegatedBandwidth = try container.decode(DelegatedBandwidth.self, forKey: .selfDelegatedBandwidth)
        self.coreLiquidBalance = try container.decode(String.self, forKey: .coreLiquidBalance)
    }
}

@objcMembers class ResourceLimit: NSObject, Codable {
    var used: UInt64 = 0
    var available: UInt64 = 0
    var max: UInt64 = 0
    
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
        
        if let used = try? container.decode(UInt64.self, forKey: .used) {
            self.used = used
        } else if let used = try UInt64(container.decode(String.self, forKey: .used)) {
            self.used = used
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.used], debugDescription: "Expecting string or number representation of UInt64"))
        }
        
        if let available = try? container.decode(UInt64.self, forKey: .available) {
            self.available = available
        } else if let available = try UInt64(container.decode(String.self, forKey: .available)) {
            self.available = available
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.available], debugDescription: "Expecting string or number representation of UInt64"))
        }
        
        if let max = try? container.decode(UInt64.self, forKey: .max) {
            self.max = max
        } else if let max = try UInt64(container.decode(String.self, forKey: .max)) {
            self.max = max
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.max], debugDescription: "Expecting string or number representation of UInt64"))
        }
    }
}

@objcMembers class RefundRequest: NSObject, Codable {
    var owner: String?
    var requestTime: Date?
    var netAmount: String?
    var cpuAmount: String?
}

@objcMembers class DelegatedBandwidth: NSObject, Codable {
    var from: String = ""
    var to: String = ""
    var netWeight: String = ""
    var cpuWeight: String = ""
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
