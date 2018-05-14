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

struct PrivateKey {
    var enclave: SecureEnclave
    var data: Data
    
    static func randomPrivateKey(enclave: SecureEnclave = .Secp256r1) -> PrivateKey? {
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
}
