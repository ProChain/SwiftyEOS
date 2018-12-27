//
//  ActionModels.swift
//  SwiftyEOS
//
//  Created by ysoftware on 27/12/2018.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

struct ActionsResult: Codable {
	let actions:[ActionReceipt]
	let lastIrreversibleBlock:Int
}

struct ActionReceipt: Codable {
	let blockNum:Int
	let globalActionSeq:Int
	let accountActionSeq:Int
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
	let producerBlockId:String
	let accountRamDeltas:[ActionRamDelta]
	// TO-DO: unknown types for these fields
//	let except:Int?
//	let inlineTraces:[Int]
}

struct ActionRamDelta: Codable {
	let account:String
	let delta:Int
}

struct Receipt: Codable {
	let receiver:String
	let actDigest:String
	let globalSequence: Int
	let recvSequence:Int
	let authSequence:[AnyCodable]
	let codeSequence:Int
	let abiSequence:Int
}

struct ActionDetails: Codable {
	let authorization: [Authorization]
	let data: [String:AnyCodable]
	let account: String
	let name: String
	let hexData: String
}
