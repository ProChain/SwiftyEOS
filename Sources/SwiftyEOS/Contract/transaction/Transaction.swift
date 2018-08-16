//
//  Transaction.swift
//  SwiftyEOS
//
//  Created by croath on 2018/8/16.
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

extension String {
    func hexadecimal() -> Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

@objcMembers class AbiJson: NSObject, Encodable {
    var code: String
    var action: String
    var args: Dictionary<String, AnyCodable>
    
    init(code: String, action: String, json: String) throws {
        self.code = code
        self.action = action
        
        let decoder = JSONDecoder()
        self.args = try decoder.decode([String: AnyCodable].self, from: json.data(using: .utf8)!)
    }
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

@objcMembers class Transaction: NSObject, Codable {
    var refBlockNum: Int
    var refBlockPrefix: Int
    var expiration: Date
    var actions: [Action]
    var authorizations: [Authorization]
    
    init(blockInfo: BlockInfo, actions: [Action]) {
        refBlockNum = blockInfo.blockNum
        refBlockPrefix = blockInfo.refBlockPrefix
        expiration = Date(timeIntervalSinceNow: 120)
        self.actions = actions
        authorizations = []
    }
}

struct SignedTransaction: Codable {
    var compression: String
    var signatures: [String]
    var packedContextFreeData: String
    var packedTrx: String
    
    init(packedTx: PackedTransaction) {
        compression = packedTx.compression
        signatures = packedTx.signatures
        packedContextFreeData = ""
        packedTrx = packedTx.packedTrx
    }
}

struct DataWriter {
    var bytesList: [UInt8] = []
    
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
    
    mutating func pushData(data: Data) {
        if data.count == 0 {
            pushVariableUInt(value: 0)
        } else {
            pushVariableUInt(value: CUnsignedInt(data.count))
            bytesList.append(contentsOf: [UInt8](data))
        }
    }
    
    mutating func pushString(string: String) {
        if string.count == 0 {
            pushVariableUInt(value: 0)
        } else {
            pushVariableUInt(value: CUnsignedInt(string.count))
            bytesList.append(contentsOf: [UInt8](string.data(using: .utf8)!))
        }
    }
    
    mutating func pushActions(actions: [Action]) {
        pushVariableUInt(value: CUnsignedInt(actions.count))
        for action in actions {
            pushLong(value: action.account.eosTypeNameToLong())
            pushLong(value: action.name.eosTypeNameToLong())
            pushPermission(permissions: action.authorization)
            if action.data != nil {
                pushData(data: action.data!.hexadecimal()!)
            } else {
                pushVariableUInt(value: 0)
            }
        }
    }
    
    static func dataForSignature(chainId: String?, pkt: PackedTransaction) -> Data {
        var writer = DataWriter()
        
        if chainId != nil {
            writer.bytesList.append(contentsOf: chainId!.hexadecimal()!)
        }
        writer.pushInt(value: Int(UInt32(pkt.transaction.expiration.timeIntervalSince1970) & 0xFFFFFFFF))
        writer.pushShort(value: pkt.transaction.refBlockNum & 0xFFFF)
        writer.pushInt(value: Int(pkt.transaction.refBlockPrefix & 0xFFFFFFFF))
        writer.pushVariableUInt(value: 0) // max_net_usage_words
        writer.pushVariableUInt(value: 0) // max_kcpu_usage
        writer.pushVariableUInt(value: 0) // delay_sec
        writer.pushVariableUInt(value: 0) // context_free_actions
        writer.pushActions(actions: pkt.transaction.actions)
        writer.pushVariableUInt(value: 0) // transaction_extensions
        if chainId != nil {
            writer.bytesList.append(contentsOf: Data(repeating: 0x00, count: 32))
        }
        
        return Data(bytes: writer.bytesList)
    }
}

struct PackedTransaction {
    var transaction: Transaction
    var signatures: [String] = []
    var compression: String
    
    var packedTrx: String = ""
    
    init(transaction: Transaction, compression: String) {
        self.transaction = transaction
        self.compression = compression
        
        packedTrx = DataWriter.dataForSignature(chainId: nil, pkt: self).hexEncodedString()
    }
    
    mutating func sign(pk: PrivateKey, chainId: String) {
        let packedBytes: [UInt8] = [UInt8](DataWriter.dataForSignature(chainId: chainId, pkt: self))
        
        let digest = Data(bytes: packedBytes, count: packedBytes.count).sha256()
        let packedSha256 = [UInt8](digest)
        
        var signature = Data(repeating: UInt8(0), count: 32*2)
        let rectId = signature.withUnsafeMutableBytes { bytes -> Int32 in
            return uECC_sign_forbc([UInt8](pk.data), packedSha256, UInt32(packedSha256.count), bytes, curve(enclave: pk.enclave))
        }
        if rectId == -1 {
            return
        } else {
            let binLength = 65 + 4
            var bin = Data(repeating: UInt8(0), count: binLength)
            let headerBytes = rectId + 27 + 4
            bin[0] = UInt8(headerBytes)
            
            signature.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                bin.withUnsafeMutableBytes { prt -> Void in
                    memcpy(prt+1, bytes, 64)
                }
            }
            
            var temp = Data(repeating: UInt8(0), count: 67)
            
            bin.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                temp.withUnsafeMutableBytes({ prt -> Void in
                    memcpy(prt, bytes, 65)
                })
            }
            
            temp.withUnsafeMutableBytes({ prt -> Void in
                memcpy(prt + 65, pk.enclave.rawValue, 2)
            })
            
            var tempBytes = [UInt8](temp)
            let rmdHash = RMD(&tempBytes, 67)
            
            bin.withUnsafeMutableBytes({ prt -> Void in
                memcpy(prt+1+32*2, rmdHash, 4)
            })
            
            var sigBinLength = 100
            var sigBin = Data(repeating: UInt8(0), count: sigBinLength)
            
            let s = bin.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Data? in
                
                let success = sigBin.withUnsafeMutableBytes { ptr -> Bool in
                    return se_b58enc(ptr, &sigBinLength, bytes, binLength)
                }
                if success {
                    return sigBin.subdata(in: 0..<(sigBinLength-1))
                } else {
                    return nil
                }
            }
            
            if s != nil {
                let sigString = String(data: s!, encoding: .utf8)
                signatures.append(["SIG", pk.enclave.rawValue, sigString!].joined(separator: PrivateKey.delimiter))
                return
            }
        }
    }
}
