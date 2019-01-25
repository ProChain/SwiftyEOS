//
//  ActionModels.swift
//  SwiftyEOS
//
//  Created by ysoftware on 27/12/2018.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

// After reaching sequence number of 2^32, sequence value is being represented as a string instead of int
// This is used to make sure both options work
typealias ActionSeq = AnyCodable

// Use intValue to unpack sequence number as Int
extension ActionSeq {
	var intValue:Int {
		if let i = value as? Int { return i }
		else if let s = value as? String, let i = Int(s) { return i }
		return 0 // fall back
	}
}

struct ActionsResult: Codable {
	let actions:[ActionReceipt]
	let lastIrreversibleBlock:Int
}

struct ActionReceipt: Codable {
	let blockNum:Int
	let globalActionSeq:ActionSeq
	let accountActionSeq:ActionSeq
	let blockTime:String
	let actionTrace: ActionTrace
}

struct ActionTrace: Codable {
	let receipt:Receipt
	let act:ActionDetails
	let contextFree:Bool
	let elapsed:Int
	let console:String
	let trxId:String
	let blockNum:Int
	let blockTime:String
	let producerBlockId:String? // can be null on a testnode
	let accountRamDeltas:[ActionRamDelta]
	let inlineTraces:[ActionTrace]
	let except:AnyCodable?
}

struct ActionRamDelta: Codable {
	let account:String
	let delta:Int
}

struct Receipt: Codable {
	let receiver:String
	let actDigest:String
	let globalSequence: ActionSeq
	let recvSequence:Int
	let authSequence:[AnyCodable]
	let codeSequence:Int
	let abiSequence:Int
}

struct ActionDetails: Codable {
	let authorization: [Authorization]
	let data: AnyCodable
	let account: String
	let name: String
	let hexData: String?
}
