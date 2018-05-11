//
//  Key.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/8.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation
import Security

enum SecureEnclave: String {
    case Secp256k1 = "K1"
    case Secp256r1 = "R1"
}

public func ccSha256(_ digest: UnsafeMutableRawPointer?, _ data: UnsafeRawPointer?, _ size: Int) -> Bool {
    let opaquePtr = OpaquePointer(digest)
    return CC_SHA256(data, CC_LONG(size), UnsafeMutablePointer<UInt8>(opaquePtr)).pointee != 0
}

let setSHA256Implementation: Void = {
    b58_sha256_impl = ccSha256
}()

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

    func sha256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(count), &hash)
        }

        return Data(bytes: hash)
    }

    public func base58EncodedData() -> Data {
        var mult = 2
        while true {
            var enc = Data(repeating: 0, count: self.count * mult)
            let s = self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Data? in
                var size = enc.count
                let success = enc.withUnsafeMutableBytes { ptr -> Bool in
                    return b58enc(ptr, &size, bytes, self.count)
                }
                if success {
                    return enc.subdata(in: 0..<(size-1))
                } else {
                    return nil
                }
            }

            if let s = s {
                return s
            }

            mult += 1
        }
    }
    
    public func base58CheckEncodedData(version: UInt8) -> Data {
        _ = setSHA256Implementation
        var enc = Data(repeating: 0, count: self.count * 3)
        let s = self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Data? in
            var size = enc.count
            let success = enc.withUnsafeMutableBytes { ptr -> Bool in
                return b58check_enc(ptr, &size, version, bytes, self.count)
            }
            if success {
                return enc.subdata(in: 0..<(size-1))
            } else {
                fatalError()
            }
        }
        return s!
    }
    
    public static func decodeChecked(base58: String, version: UInt8) -> Data? {
        _ = setSHA256Implementation
        let source = base58.data(using: .utf8)!
        
        var bin = [UInt8](repeating: 0, count: source.count)
        
        var size = bin.count
        let success = source.withUnsafeBytes { (sourceBytes: UnsafePointer<CChar>) -> Bool in
            if b58tobin(&bin, &size, sourceBytes, source.count) {
                bin = Array(bin[(bin.count - size)..<bin.count])
                return b58check(bin, size, sourceBytes, source.count) == Int32(version)
            }
            return false
        }
        
        if success {
            return Data(bytes: bin[1..<(bin.count-4)])
        }
        return nil
    }
    
    public static func decode(base58: String) -> Data? {
        let source = base58.data(using: .utf8)!
        
        var bin = [UInt8](repeating: 0, count: source.count)
        
        var size = bin.count
        let success = source.withUnsafeBytes { (sourceBytes: UnsafePointer<CChar>) -> Bool in
            if b58tobin(&bin, &size, sourceBytes, source.count) {
                return true
            }
            return false
        }
        
        if success {
            return Data(bytes: bin[(bin.count - size)..<bin.count])
        }
        return nil
    }
}

func randomData() -> Data? {
    var keyData = Data(count: 32)
    let result = keyData.withUnsafeMutableBytes { (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
        SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
    }
    if result == errSecSuccess {
        return keyData
    } else {
        print("Problem generating random bytes")
        return nil
    }
}

func create(enclave: SecureEnclave) -> String? {
    let randomPrivateKey = randomData()!
    
    let attributes: [String: Any] =
        [kSecAttrKeyType as String:            kSecAttrKeyTypeECSECPrimeRandom,
         kSecAttrKeySizeInBits as String:      256
    ]
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateFromData(attributes as CFDictionary, randomPrivateKey as CFData, &error) else {
        print("error: \(error!.takeRetainedValue())")
        return nil
    }
    
    if let cfdata = SecKeyCopyExternalRepresentation(privateKey, &error) {
        let data:Data = cfdata as Data
        print("private key: \(data.wifString(enclave: enclave))")
        print("private key: \(data.wifStringPureSwift(enclave: enclave))")
    }
    
    do {
        var publicBytes: Array<UInt8> = Array(repeating: UInt8(0), count: 64)
        var compressedPublicBytes: Array<UInt8> = Array(repeating: UInt8(0), count: 33)
        
        var curve: uECC_Curve
        
        switch enclave {
        case .Secp256r1:
            curve = uECC_secp256r1()
        default:
            curve = uECC_secp256k1()
        }
        uECC_compute_public_key([UInt8](randomPrivateKey), &publicBytes, curve)
        uECC_compress(&publicBytes, &compressedPublicBytes, curve)
        let publicKey = Data(bytes: compressedPublicBytes, count: 33)
        print("public key:  \(publicKey.publicKeyEncodeString(enclave: enclave))")
    }
    
    return privateKey as? String
}
