//
//  PublicKey.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/14.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

extension Data {
    func publicKeyEncodeString(enclave: SecureEnclave) -> String {
        let size_of_data_to_hash = count
        let size_of_hash_bytes = 4
        var data: Array<UInt8> = Array(repeating: UInt8(0), count: size_of_data_to_hash+size_of_hash_bytes)
        var bytes = [UInt8](self)
        for i in 0..<size_of_data_to_hash {
            data[i] = bytes[i]
        }
        let hash = RMD(&bytes, 33)
        for i in 0..<size_of_hash_bytes {
            data[size_of_data_to_hash+i] = hash![i]
        }
        let base58 = Data(bytes: data, count: size_of_data_to_hash+size_of_hash_bytes).base58EncodedData()
        return "PUB_\(enclave.rawValue)_\(String(data: base58, encoding: .ascii)!)"
    }
}

struct PublicKey {
    var data: Data
    var enclave: SecureEnclave
    
    init(privateKey: PrivateKey) {
        var publicBytes: Array<UInt8> = Array(repeating: UInt8(0), count: 64)
        var compressedPublicBytes: Array<UInt8> = Array(repeating: UInt8(0), count: 33)
        
        var curve: uECC_Curve
        
        switch privateKey.enclave {
        case .Secp256r1:
            curve = uECC_secp256r1()
        default:
            curve = uECC_secp256k1()
        }
        uECC_compute_public_key([UInt8](privateKey.data), &publicBytes, curve)
        uECC_compress(&publicBytes, &compressedPublicBytes, curve)
        
        data = Data(bytes: compressedPublicBytes, count: 33)
        enclave = privateKey.enclave
    }
    
    func wif() -> String {
        return self.data.publicKeyEncodeString(enclave: enclave)
    }
    
    func rawPublicKey() -> String {
        let withoutDelimiter = self.wif().components(separatedBy: "_").last
        guard withoutDelimiter!.hasPrefix("EOS") else {
            return "EOS\(withoutDelimiter!)"
        }
        return withoutDelimiter!
    }
}
