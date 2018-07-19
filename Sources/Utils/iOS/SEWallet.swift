//
//  SEWallet.swift
//  SwiftyEOS
//
//  Created by croath on 2018/7/18.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

class SEKeystore: NSObject {
    let keyUrl: URL
    init(keyDir: String) {
        keyUrl = URL(fileURLWithPath: keyDir)
    }
    
    func importAccount(privateKey: String, passcode: String) throws -> SELocalAccount {
        let account = try SELocalAccount(privateKey: privateKey, passcode: passcode)
        try! account.write(to: keyUrl.appendingPathComponent(account.publicKey!))
        return account
    }
    
    func newLocalAccount(passcode: String) -> SELocalAccount {
        let account = SELocalAccount(passcode: passcode)
        try! account.write(to: keyUrl.appendingPathComponent(account.publicKey!))
        return account
    }
    
    func defaultAccount() -> SELocalAccount? {
        do {
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: keyUrl, includingPropertiesForKeys: nil)
            // process files
            if fileURLs.count > 0 {
                let fileUrl = fileURLs.first
                let data = try Data(contentsOf: fileUrl!)
                let account = try SELocalAccount(fileData: data)
                return account
            } else {
                return nil
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            return nil
        }
    }
    
//    func accounts() -> [SELocalAccount] {
//        let fileManager = FileManager.default
//        do {
//            let fileURLs = try fileManager.contentsOfDirectory(at: keyUrl, includingPropertiesForKeys: nil)
//            // process files
//        } catch {
//            print("Error while enumerating files: \(error.localizedDescription)")
//        }
//    }
}

struct RawKeystore: Codable {
    var data: String
    var iv: String
    var publicKey: String
    
    func write(to: URL) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(self)
        try jsonData.write(to: to)
    }
}

class SELocalAccount: NSObject {
    static let aesIv = "A-16-Byte-String"
    
    var publicKey: String?
    private var rawKeystore: RawKeystore
    
    convenience init(passcode: String) {
        let (pk, _) = generateRandomKeyPair(enclave: .Secp256k1)
        self.init(pk: pk!, passcode: passcode)
    }
    
    convenience init(privateKey: String, passcode: String) throws {
        let pk = try PrivateKey(keyString: privateKey)
        self.init(pk: pk!, passcode: passcode)
    }
    
    init(pk: PrivateKey, passcode: String) {
        let pub = PublicKey(privateKey: pk)
        publicKey = pub.wif()
        
        let pkData = pk.wif().data(using:String.Encoding.utf8)!
        let encrytedData = AESCrypt(inData: pkData,
                                    keyData: passcode.data(using:String.Encoding.utf8)!,
                                    ivData: SELocalAccount.aesIv.data(using:String.Encoding.utf8)!,
                                    operation: kCCEncrypt)
        rawKeystore = RawKeystore(data: String(data: encrytedData, encoding: .utf8)!,
                                  iv: SELocalAccount.aesIv,
                                  publicKey: publicKey!)
    }
    
    init(fileData: Data) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let fileKeystore = try decoder.decode(RawKeystore.self, from: fileData)
//        let decryptedData = AESCrypt(inData:fileKeystore.data.data(using: .utf8)!,
//                                     keyData:fileKeystore.key.data(using:String.Encoding.utf8)!,
//                                     ivData:fileKeystore.iv.data(using:String.Encoding.utf8)!,
//                                     operation:kCCDecrypt)
//        let pkString = String(data:decryptedData, encoding:String.Encoding.utf8)
//        let pk = try PrivateKey(keyString: pkString!)
//        let pub = PublicKey(privateKey: pk!)
//        guard pub.wif() == fileKeystore.publicKey else {
//            throw NSError(domain: "", code: 0, userInfo: nil)
//        }
        rawKeystore = fileKeystore
        publicKey = fileKeystore.publicKey
    }
    
    func write(to: URL) throws {
        try rawKeystore.write(to: to)
    }
}

class SEWallet: NSObject {
//    static func newWallet(passcode: String) -> SEWallet {
//
//    }
}
