//
//  Currency.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/29.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

extension Character {
    func unicodeScalarCodePoint() -> UInt32 {
        let scalars = self.unicodeScalars
        return scalars[scalars.startIndex].value
    }
    
    func eosSymbol() -> UInt32 {
        if self >= "a" && self <= "z" {
            return self.unicodeScalarCodePoint() - "a".unicodeScalarCodePoint() + 6
        } else if self >= "1" && self <= "5" {
            return self.unicodeScalarCodePoint() - "1".unicodeScalarCodePoint() + 1
        } else {
            return 0
        }
    }
}

extension String {
    func unicodeScalarCodePoint() -> UInt32 {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
    
    func eosTypeNameToLong() -> CLong {
        let max_index = 12
        
        var c = 0
        var value = 0
        for i in 0...max_index + 1 {
            if i < count && i <= max_index {
                c = Int(self[self.index(self.startIndex, offsetBy: i)].eosSymbol())
            }
            if i < max_index {
                c &= 0x1f
                c <<= 64-5*(i+1)
            } else {
                c &= 0x0f
            }
            value |= c
        }
        return value
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

struct AbiJson: Codable {
    var code: String
    var action: String
    var args: Transfer
}

struct AbiBinResult: Codable {
    var binargs: String
    var requiredScope: [String]?
    var requiredAuth: [String]?
}

struct Authorization: Codable {
    var actor: String
    var permission: String
}

struct Action: Codable {
    var account: String
    var name: String
    var authorization: [Authorization]
    var data: String?
}

struct Transaction: Codable {
    var refBlockNum: String
    var refBlockPrefix: String
    var expiration: Date
    var scope: [String]
    var actions: [Action]
    var authorizations: [String]
}

struct PackedTransaction: Codable {
    var transaction: Transaction
    var signatures: [String] = []
    var compression: String
    
    var bytesList: [UInt8] = []
    var packedTrx: String = ""
    
    init(transaction: Transaction, compression: String) {
        self.transaction = transaction
        self.compression = compression
        
        pushInt(value: Int(transaction.expiration.timeIntervalSince1970) & 0xffffffff)
        pushShort(value: Int(transaction.refBlockNum)! & 0xffff)
        pushInt(value: Int(transaction.refBlockPrefix)! & 0xffffffff)
        pushVariableUInt(value: 0)
        pushVariableUInt(value: 0)
        pushVariableUInt(value: 0)
        pushActions(actions: [])
        pushActions(actions: transaction.actions)
        pushVariableUInt(value: 0)
        
        packedTrx = Data(bytes: bytesList).hexEncodedString()
    }
    
    mutating func pushBase(value: IntegerLiteralType, stride: StrideTo<Int>) {
        for i in stride {
            bytesList.append(UInt8(0xff & value >> i))
        }
    }
    
    mutating func pushShort(value: Int) {
        pushBase(value: IntegerLiteralType(value), stride: stride(from: 0, to: 9, by: 8))
    }
    
    mutating func pushInt(value: Int) {
        pushBase(value: IntegerLiteralType(value), stride: stride(from: 0, to: 25, by: 8))
    }
    
    mutating func pushLong(value: Int) {
        pushBase(value: IntegerLiteralType(value), stride: stride(from: 0, to: 57, by: 8))
    }
    
    mutating func pushChar(value: CChar) {
        bytesList.append(UInt8(value))
    }
    
    mutating func pushVariableUInt(value: CUnsignedInt) {
        var b = value & 0x7f
        var newValue = value >> 7
        if newValue > 0 {
            b = b | (1 << 7)
        } else {
            b = b | (0 << 7)
        }
        pushChar(value: CChar(b))
        
        while newValue != 0 {
            b = value & 0x7f
            newValue = value >> 7
            if newValue > 0 {
                b = b | (1 << 7)
            } else {
                b = b | (0 << 7)
            }
            pushChar(value: CChar(b))
        }
    }
    
    mutating func pushPermission(permissions: [Authorization]) {
        pushVariableUInt(value: CUnsignedInt(permissions.count))
        for permission in permissions {
            pushLong(value: permission.actor.eosTypeNameToLong())
            pushLong(value: permission.permission.eosTypeNameToLong())
        }
    }
    
    mutating func pushData(data: String) {
        
    }
    
    mutating func pushActions(actions: [Action]) {
        pushVariableUInt(value: CUnsignedInt(actions.count))
        for action in actions {
            pushLong(value: action.account.eosTypeNameToLong())
            pushLong(value: action.name.eosTypeNameToLong())
            pushPermission(permissions: action.authorization)
            if action.data != nil {
                pushData(data: action.data!)
            } else {
                pushVariableUInt(value: 0)
            }
        }
    }
    
    mutating func sign(pk: PrivateKey, chainId: String) {
        let packedBytes: [UInt8] = Array(chainId.utf8)
        var digest = Data(bytes: packedBytes, count: packedBytes.count)
        digest = digest.sha256().sha256()
        let packedSha256 = [UInt8](digest)
        var signature = Data(repeating: UInt8(0), count: 32*2)
        let rectId = signature.withUnsafeMutableBytes { bytes -> Int32 in
            return uECC_sign([UInt8](pk.data), packedSha256, UInt32(packedSha256.count), bytes, uECC_secp256k1())
        }
        if rectId == -1 {
            
        } else {
            let binLength = 65 + 4
            var bin = Data(repeating: UInt8(0), count: binLength)
            let headerBytes = rectId + 27 + 4
            bin[0] = UInt8(headerBytes)
            
            signature.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                bin.withUnsafeMutableBytes({ prt -> Void in
                    memcpy(prt+1, bytes, 32*2)
                })
            }
            
            var temp = Data(repeating: UInt8(0), count: binLength)
            
            bin.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                temp.withUnsafeMutableBytes({ prt -> Void in
                    memcpy(prt, bytes, 65)
                })
            }
            bin.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                temp.withUnsafeMutableBytes({ prt -> Void in
                    memcpy(prt + 65, "K1", 2)
                })
            }
            
            var tempBytes = [UInt8](temp)
            let rmdHash = RMD(&tempBytes, Int32(binLength))
            
            bin.withUnsafeMutableBytes({ prt -> Void in
                memcpy(prt+1+32*2, rmdHash, 4)
            })
            
            var sigBinLength = 100
            var sigBin = Data(repeating: UInt8(0), count: sigBinLength)
            
            let s = bin.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Data? in
                
                let success = sigBin.withUnsafeMutableBytes { ptr -> Bool in
                    return b58enc(ptr, &sigBinLength, bytes, binLength)
                }
                if success {
                    return sigBin.subdata(in: 0..<(sigBinLength-1))
                } else {
                    return nil
                }
            }
            
            if s != nil {
                let sigString = String(data: s!, encoding: .ascii)
                signatures.append("SIG_K1_\(sigString!)")
            }
            
        }
    }
}

struct Transfer: Codable {
    var from: String = ""
    var to: String = ""
    var quantity: String = ""
    var memo: String = ""
}

struct Currency {
    static func transferCurrency(tranfer: Transfer, privateKey: PrivateKey) {
        EOSRPC.sharedInstance.chainInfo { (chainInfo, error) in
            if error != nil {
                return
            }
            
            EOSRPC.sharedInstance.getBlock(blockNumOrId: "\(chainInfo!.lastIrreversibleBlockNum)" as AnyObject, completion: { (blockInfo, error) in
                if error != nil {
                    return
                }
                
                let abiJson = AbiJson(code: "eosio.token", action: "transfer", args: tranfer)
                
                EOSRPC.sharedInstance.abiJsonToBin(abi: abiJson, completion: { (bin, error) in
                    if error != nil {
                        return
                    }
                    
                    let auth = Authorization(actor: tranfer.from, permission: "active")
                    let action = Action(account: abiJson.code, name: abiJson.action, authorization: [auth], data: bin!.binargs)
                    let rawTx = Transaction(refBlockNum: "\(blockInfo!.blockNum)", refBlockPrefix: "\(blockInfo!.refBlockPrefix)", expiration: Date(), scope: [transfer.from, transfer.to], actions: [action], authorizations: [])
                    
                    var tx = PackedTransaction(transaction: rawTx, compression: "none")
                    tx.sign(pk: privateKey, chainId: chainInfo!.chainId!)
                    EOSRPC.sharedInstance.pushTransaction(transaction: tx, completion: { (txResult, error) in
                        
                    })
                })
            })
        }
    }
}
