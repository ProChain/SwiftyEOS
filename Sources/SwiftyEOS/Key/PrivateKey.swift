//
//  PrivateKey.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/14.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation
import Security

extension Data {
    func wifStringPureSwift(enclave: SecureEnclave) -> String {
        let size_of_data_to_hash = count + 1
        let size_of_hash_bytes = 4
        var data: Array<UInt8> = Array(repeating: UInt8(0), count: size_of_data_to_hash+size_of_hash_bytes)
        data[0] = UInt8(0x80)
        let bytes = [UInt8](self)
        for i in 1..<size_of_data_to_hash {
            data[i] = bytes[i-1]
        }
        var digest = Data(bytes: data, count: size_of_data_to_hash)
        digest = digest.sha256().sha256()
        for i in 0..<size_of_hash_bytes {
            data[size_of_data_to_hash+i] = ([UInt8](digest))[i]
        }
        let base58 = Data(bytes: data, count: size_of_data_to_hash+size_of_hash_bytes).base58EncodedData()
        return "PVT_\(enclave.rawValue)_\(String(data: base58, encoding: .ascii)!)"
    }
    
    func wifString(enclave: SecureEnclave) -> String {
        return "PVT_\(enclave.rawValue)_\(String(data: base58CheckEncodedData(version: 0x80), encoding: .ascii)!)"
    }
}

extension String {
    func parseWif() throws -> Data? {
        guard let data = decodeChecked(version: 0x80) else {
            throw NSError(domain: "com.swiftyeos.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid base58: \(self)"])
        }
        return data
    }
}

struct PrivateKey {
    static let prefix = "PVT"
    static let delimiter = "_"
    var enclave: SecureEnclave
    var data: Data
    
    init?(keyString: String) throws {
        if keyString.range(of: PrivateKey.delimiter) == nil {
            enclave = .Secp256k1
            data = try keyString.parseWif()!
        } else {
            let dataParts = keyString.components(separatedBy: PrivateKey.delimiter)
            guard dataParts[0] == PrivateKey.prefix else {
                throw NSError(domain: "com.swiftyeos.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Private Key \(keyString) has invalid prefix: \(PrivateKey.delimiter)"])
            }
            
            guard dataParts.count != 2 else {
                throw NSError(domain: "com.swiftyeos.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Private Key has data format is not right: \(keyString)"])
            }
            
            enclave = SecureEnclave(rawValue: dataParts[1])!
            let dataString = dataParts[2]
            data = try dataString.parseWif()!
        }
    }
    
    init(enclave: SecureEnclave, data: Data) {
        self.enclave = enclave
        self.data = data
    }
    
    init?(enclave: SecureEnclave, mnemonicString: String) throws {
        self.enclave = enclave
        
        let phraseStr = mnemonicString.cString(using: .utf8)
        if mnemonic_check(phraseStr) == 0 {
            throw NSError(domain: "com.swiftyeos.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Mnemonic"])
        }
        
        var seed = Data(count: 512/8)
        seed.withUnsafeMutableBytes { bytes in
            mnemonic_to_seed(phraseStr, "", bytes, nil)
        }
        
        var node = seed.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> HDNode in
            var node = HDNode()
            hdnode_from_seed(bytes, Int32(seed.count), UnsafePointer<Int8>("secp256k1"), &node)
            return node
        }
        
        hdnode_private_ckd(&node, (0x80000000 | (44)));   // 44' - BIP 44 (purpose field)
        hdnode_private_ckd(&node, (0x80000000 | (194)));  // 194'- EOS (see SLIP 44)
        hdnode_private_ckd(&node, (0x80000000 | (0)));    // 0'  - Account 0
        hdnode_private_ckd(&node, 0);                     // 0   - External
        hdnode_private_ckd(&node, 0);                     // 0   - Slot #0
        
        let data =  withUnsafeBytes(of: &node.private_key) { (rawPtr) -> Data in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return Data(bytes: ptr, count: 32)
        }
        
        self.data = data
    }
    
    func wif() -> String {
        return self.data.wifString(enclave: enclave)
    }
    
    func rawPrivateKey() -> String {
        return self.wif().components(separatedBy: "_").last!
    }
    
    static func randomPrivateKey(enclave: SecureEnclave = .Secp256k1) -> PrivateKey? {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes { (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
        }
        if result == errSecSuccess {
            return PrivateKey(enclave: enclave, data: keyData)
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }
    
    static func randomPrivateKeyAndMnemonic(enclave: SecureEnclave = .Secp256k1) -> (PrivateKey?, String?) {
        var data = Data(count: 16)
        let result = data.withUnsafeMutableBytes { (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, 16, mutableBytes)
        }
        if result == errSecSuccess {
            let mnemonic = data.withUnsafeBytes({ (sourceBytes: UnsafePointer<UInt8>) -> String in
                return String(cString: mnemonic_from_data(sourceBytes, 16), encoding: .utf8)!
            })
            return try! (PrivateKey(enclave: enclave, mnemonicString: mnemonic), mnemonic)
        } else {
            print("Problem generating random bytes")
            return (nil, nil)
        }
    }
    
    static func literalValid(keyString: String) -> Bool {
        if keyString.range(of: PrivateKey.delimiter) == nil {
            return keyString.count == 51
        } else {
            let dataParts = keyString.components(separatedBy: PrivateKey.delimiter)
            guard dataParts.count != 2 else {
                return false
            }
            guard dataParts[0] == PrivateKey.prefix else {
                return false
            }
            guard dataParts[1].count == 51 else {
                return false
            }
            return true
        }
    }
}
