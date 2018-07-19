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

struct BlockInfo: Codable {
    var previous: String?
    var timestamp: Date?
    var transactionMerkleRoot: String?
    var producer: String?
    var producerChanges: [String]?
    var producerSignature: String?
    var cycles: [String]?
    var id: String?
    var blockNum: UInt64
    var refBlockPrefix: UInt64
    
    // not metioned in the doc
    var actionMerkleRoot: String?
    var blockMerkleRoot: String?
    var scheduleVersion: UInt64
    var newProducers: [String]?
    var inputTransactions: [String]?
//    var regions: [Any]?
}

struct Account {
    
}

struct KeyAccountsResult: Codable {
    var accountNames: [String]
}
