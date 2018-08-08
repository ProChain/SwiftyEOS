//
//  Crypto.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/14.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation
import Security

/*
 let message     = "base58 or base64"
 let messageData = message.data(using:String.Encoding.utf8)!
 let keyData     = "16BytesLengthKey".data(using:String.Encoding.utf8)!
 let ivData      = "A-16-Byte-String".data(using:String.Encoding.utf8)!
 
 let decryptedData = testCrypt(inData:messageData, keyData:keyData, ivData:ivData, operation:kCCEncrypt)
 var decrypted     = String(data:decryptedData, encoding:String.Encoding.utf8)
 print(decrypted)
 */

func AESCrypt(inData:Data, keyData:Data, ivData:Data, operation:Int) -> Data {
    var data : Data
    if operation == kCCDecrypt {
        data = Data(base64Encoded: inData)!
    } else {
        data = inData
    }
    
    let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
    var cryptData = Data(count:cryptLength)
    
    let keyLength = size_t(kCCKeySizeAES128)
    let options   = CCOptions(kCCOptionPKCS7Padding)
    
    
    var numBytesEncrypted :size_t = 0
    
    let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
        data.withUnsafeBytes {dataBytes in
            ivData.withUnsafeBytes {ivBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(operation),
                            CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes, keyLength,
                            ivBytes,
                            dataBytes, data.count,
                            cryptBytes, cryptLength,
                            &numBytesEncrypted)
                }
            }
        }
    }
    
    if UInt32(cryptStatus) == UInt32(kCCSuccess) {
        cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        
    } else {
        print("Error: \(cryptStatus)")
    }
    
    if operation == kCCDecrypt {
        return cryptData
    } else {
        return cryptData.base64EncodedData()
    }
}

enum SecureEnclave: String {
    case Secp256k1 = "K1"
    case Secp256r1 = "R1"
}

func curve(enclave: SecureEnclave) -> uECC_Curve {
    if enclave == .Secp256k1 {
        return uECC_secp256k1()
    } else {
        return uECC_secp256r1()
    }
}

public func ccSha256(_ digest: UnsafeMutableRawPointer?, _ data: UnsafeRawPointer?, _ size: Int) -> Bool {
    let opaquePtr = OpaquePointer(digest)
    return CC_SHA256(data, CC_LONG(size), UnsafeMutablePointer<UInt8>(opaquePtr)).pointee != 0
}

let setSHA256Implementation: Void = {
    b58_sha256_impl = ccSha256
}()

extension String {
    public func decodeChecked(version: UInt8) -> Data? {
        _ = setSHA256Implementation
        let source = self.data(using: .utf8)!
        
        var bin = [UInt8](repeating: 0, count: source.count)
        
        var size = bin.count
        let success = source.withUnsafeBytes { (sourceBytes: UnsafePointer<CChar>) -> Bool in
            if se_b58tobin(&bin, &size, sourceBytes, source.count) {
                bin = Array(bin[(bin.count - size)..<bin.count])
                return se_b58check(bin, size, sourceBytes, source.count) == Int32(version)
            }
            return false
        }
        
        if success {
            return Data(bytes: bin[1..<(bin.count-4)])
        }
        return nil
    }
}

extension Data {
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
                    return se_b58enc(ptr, &size, bytes, self.count)
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
                return se_b58check_enc(ptr, &size, version, bytes, self.count)
            }
            if success {
                return enc.subdata(in: 0..<(size-1))
            } else {
                fatalError()
            }
        }
        return s!
    }
    
    public static func decode(base58: String) -> Data? {
        let source = base58.data(using: .utf8)!
        
        var bin = [UInt8](repeating: 0, count: source.count)
        
        var size = bin.count
        let success = source.withUnsafeBytes { (sourceBytes: UnsafePointer<CChar>) -> Bool in
            if se_b58tobin(&bin, &size, sourceBytes, source.count) {
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
