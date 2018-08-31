//
//  SEWallet.swift
//  SwiftyEOS
//
//  Created by croath on 2018/7/18.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation

extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}


@objcMembers class SEKeystoreService: NSObject {
    public class var sharedInstance: SEKeystoreService {
        struct Singleton {
            static let instance : SEKeystoreService = SEKeystoreService()
        }
        return Singleton.instance
    }
    
    lazy var keystore: SEKeystore! = {
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        return SEKeystore(keyDir: libraryDirectory.appending("/keystore"))
    }()
    
    func importAccount(privateKey: String, passcode: String, succeed: ((_ account: SELocalAccount) -> Void)?, failed:((_ error: Error) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            do {
                let account = try self.keystore.importAccount(privateKey: privateKey, passcode: passcode)
                if succeed != nil {
                    DispatchQueue.main.async {
                        succeed!(account)
                    }
                }
            } catch {
                if failed != nil {
                    DispatchQueue.main.async {
                        failed!(error)
                    }
                }
            }
        }
    }
    
    func newAccount(passcode: String, succeed: ((_ account: SELocalAccount) -> Void)?, failed:((_ error: Error) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            do {
                let account = try self.keystore.newLocalAccount(passcode: passcode)
                if succeed != nil {
                    DispatchQueue.main.async {
                        succeed!(account)
                    }
                }
            } catch {
                if failed != nil {
                    DispatchQueue.main.async {
                        failed!(error)
                    }
                }
            }
        }
    }
    
    func deleteAccount(passcode: String, account: SELocalAccount, succeed: (() -> Void)?, failed:((_ error: Error) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            do {
                try self.keystore.deleteAccount(passcode: passcode, account: account)
                if succeed != nil {
                    DispatchQueue.main.async {
                        succeed!()
                    }
                }
            } catch {
                if failed != nil {
                    DispatchQueue.main.async {
                        failed!(error)
                    }
                }
            }
        }
    }
    
    func changeAccountPasscode(oldcode: String, newcode: String, account: SELocalAccount, succeed: (() -> Void)?, failed:((_ error: Error) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            do {
                let _ = try self.keystore.changeAccountPasscode(oldcode: oldcode, newcode: newcode, account: account)
                if succeed != nil {
                    DispatchQueue.main.async {
                        succeed!()
                    }
                }
            } catch {
                if failed != nil {
                    DispatchQueue.main.async {
                        failed!(error)
                    }
                }
            }
        }
    }
    
    func exportAccountPrivateKey(passcode: String, account: SELocalAccount, succeed: ((_ pk: String) -> Void)?, failed:((_ error: Error) -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            do {
                let pk = try account.decrypt(passcode: passcode)
                if succeed != nil {
                    DispatchQueue.main.async {
                        succeed!(pk.wif())
                    }
                }
            } catch {
                if failed != nil {
                    DispatchQueue.main.async {
                        failed!(error)
                    }
                }
            }
        }
    }
    
    static func literalValid(keyString: String) -> Bool {
        return PrivateKey.literalValid(keyString:keyString)
    }
}

@objcMembers class SEKeystore: NSObject {
    let keyUrl: URL
    init(keyDir: String) {
        keyUrl = URL(fileURLWithPath: keyDir)
        do {
            try FileManager.default.createDirectory(at: keyUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    func importAccount(privateKey: String, passcode: String) throws -> SELocalAccount {
        let account = try SELocalAccount(privateKey: privateKey, passcode: passcode)
        try account.write(to: keyUrl.appendingPathComponent(account.publicKey!))
        return account
    }
    
    func newLocalAccount(passcode: String) throws -> SELocalAccount {
        let account = SELocalAccount(passcode: passcode)
        try account.write(to: keyUrl.appendingPathComponent(account.publicKey!))
        return account
    }
    
    func deleteAccount(passcode: String, account: SELocalAccount) throws {
        let _ = try account.decrypt(passcode: passcode)
        try FileManager.default.removeItem(at: keyUrl.appendingPathComponent(account.publicKey!))
        SELocalAccount.__account = nil
    }
    
    func changeAccountPasscode(oldcode: String, newcode: String, account: SELocalAccount) throws -> SELocalAccount {
        let pk = try account.decrypt(passcode: oldcode)
        try FileManager.default.removeItem(at: keyUrl.appendingPathComponent(account.publicKey!))
        let newAccount = SELocalAccount(pk: pk, passcode: newcode)
        try newAccount.write(to: keyUrl.appendingPathComponent(account.publicKey!))
        SELocalAccount.__account = newAccount
        return newAccount
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
    
    func decrypt(passcode: String) throws -> PrivateKey {
        let decryptedData = AESCrypt(inData:self.data.data(using: .utf8)!,
                                     keyData:passcode.data(using:String.Encoding.utf8)!,
                                     ivData:self.iv.data(using:String.Encoding.utf8)!,
                                     operation:kCCDecrypt)
        let pkString = String(data:decryptedData, encoding:String.Encoding.utf8)
        if pkString == nil {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        let pk = try PrivateKey(keyString: pkString!)
        if pk == nil {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        let pub = PublicKey(privateKey: pk!)
        guard pub.wif() == self.publicKey else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return pk!
    }
    
    func write(to: URL) throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(self)
        try jsonData.write(to: to)
    }
}

@objcMembers class SELocalAccount: NSObject {
    public class var currentAccount: SELocalAccount? {
        if __account == nil {
            __account = existingAccount()
        }
        return __account
    }
    
    public static var __account: SELocalAccount?
    class func existingAccount() -> SELocalAccount? {
        return SEKeystoreService.sharedInstance.keystore.defaultAccount()
    }
    
    //FIXME: Fill with your own iv.
    static let aesIv = "ReplaceWithYourIv"
    
    var publicKey: String?
    var rawPublicKey: String? {
        get {
            let withoutDelimiter = publicKey?.components(separatedBy: "_").last
            guard withoutDelimiter!.hasPrefix("EOS") else {
                return "EOS\(withoutDelimiter!)"
            }
            return withoutDelimiter
        }
    }
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
        rawKeystore = fileKeystore
        publicKey = fileKeystore.publicKey
    }
    
    func write(to: URL) throws {
        try rawKeystore.write(to: to)
    }
    
    func getEosBalance(account: String, succeed: ((_ balance: NSDecimalNumber) -> Void)?, failed:((_ error: Error) -> Void)?) {
        EOSRPC.sharedInstance.getCurrencyBalance(account: account, symbol: "EOS", code: "eosio.token") { (balance: NSDecimalNumber?, error: Error?) in
            if error != nil {
                if failed != nil {
                    failed!(error!)
                }
                return
            }
            
            if succeed != nil {
                succeed!(balance!)
            }
        }
    }
    
    func getEpraBalance(account: String, succeed: ((_ balance: NSDecimalNumber) -> Void)?, failed:((_ error: Error) -> Void)?) {
        EOSRPC.sharedInstance.getCurrencyBalance(account: account, symbol: "EPRA", code: "eosio.token") { (balance: NSDecimalNumber?, error: Error?) in
            if error != nil {
                if failed != nil {
                    failed!(error!)
                }
                return
            }
            
            if succeed != nil {
                succeed!(balance!)
            }
        }
    }
    
    func decrypt(passcode: String) throws -> PrivateKey {
        return try rawKeystore.decrypt(passcode:passcode)
    }
    
    private var unlockTimeout: Date = Date(timeIntervalSince1970: 0)
    private var tempKeystore: RawKeystore?
    private var tempPass: String?
    
    func timedUnlock(passcode: String, timeout: TimeInterval) throws {
        guard passcode != "" else {
            throw NSError(domain: "", code: 90001, userInfo: [NSLocalizedDescriptionKey: "passcode not right"])
        }
        guard let pk = try? rawKeystore.decrypt(passcode: passcode) else {
            throw NSError(domain: "", code: 90001, userInfo: [NSLocalizedDescriptionKey: "passcode not right"])
        }
        
        let tempIv = String.random(length: 16)
        tempPass = String.random(length: 16)
        
        let pkData = pk.wif().data(using:String.Encoding.utf8)!
        let encrytedData = AESCrypt(inData: pkData,
                                    keyData: tempPass!.data(using:String.Encoding.utf8)!,
                                    ivData: tempIv.data(using:String.Encoding.utf8)!,
                                    operation: kCCEncrypt)
        tempKeystore = RawKeystore(data: String(data: encrytedData, encoding: .utf8)!,
                                   iv: tempIv,
                                   publicKey: publicKey!)
        unlockTimeout = Date(timeIntervalSinceNow: timeout)
    }
    
    func isLocked() -> Bool {
        guard tempKeystore != nil && tempPass != nil else {
            return true
        }
        
        guard Date().timeIntervalSince(unlockTimeout) < 0 else {
            tempKeystore = nil
            tempPass = nil
            return true
        }
        
        return false
    }
    
    func lock() {
        tempKeystore = nil
        tempPass = nil
    }
    
    private func retrievePrivateKey() throws -> PrivateKey {
        guard tempKeystore != nil && tempPass != nil else {
            throw NSError(domain: "", code: 90000, userInfo: [NSLocalizedDescriptionKey: "no saved key"])
        }
        
        guard Date().timeIntervalSince(unlockTimeout) < 0 else {
            tempKeystore = nil
            tempPass = nil
            throw NSError(domain: "", code: 90000, userInfo: [NSLocalizedDescriptionKey: "no saved key"])
        }
        
        return try tempKeystore!.decrypt(passcode: tempPass!)
    }
    
    func pushTransaction(abi: AbiJson, account: String, unlockOncePasscode: String?, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        var pk: PrivateKey
        
        do {
            if unlockOncePasscode != nil {
                pk = try decrypt(passcode: unlockOncePasscode!)
            } else {
                pk = try retrievePrivateKey()
            }
        } catch let error as NSError {
            completion(nil, error)
            return
        }
        
        TransactionUtil.pushTransaction(abi: abi, account: account, pkString: pk.wif(), completion: completion)
    }
    
    func stakeResource(account: String, net: Float, cpu: Float, unlockOncePasscode: String?, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = ResourceUtil.stakeResourceAbiJson(account: account, net: net, cpu: cpu)
        pushTransaction(abi: abiJson, account: account, unlockOncePasscode: unlockOncePasscode, completion: completion)
    }
    
    func unstakeResource(account: String, net: Float, cpu: Float, unlockOncePasscode: String?, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = ResourceUtil.unstakeResourceAbiJson(account: account, net: net, cpu: cpu)
        pushTransaction(abi: abiJson, account: account, unlockOncePasscode: unlockOncePasscode, completion: completion)
    }
    
    func buyRam(account: String, ramEos: Float, unlockOncePasscode: String?, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = ResourceUtil.buyRamAbiJson(account: account, ramEos: ramEos)
        pushTransaction(abi: abiJson, account: account, unlockOncePasscode: unlockOncePasscode, completion: completion)
    }
    
    func sellRam(account: String, ramBytes: Float, unlockOncePasscode: String?, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let abiJson = ResourceUtil.sellRamAbiJson(account: account, ramBytes: ramBytes)
        pushTransaction(abi: abiJson, account: account, unlockOncePasscode: unlockOncePasscode, completion: completion)
    }
    
    func transferToken(transfer: Transfer, code: String, unlockOncePasscode: String?, completion: @escaping (_ result: TransactionResult?, _ error: Error?) -> ()) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonData = try! encoder.encode(transfer)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        let abiJson = try! AbiJson(code: code, action: "transfer", json: jsonString!)
        
        pushTransaction(abi: abiJson, account: transfer.from, unlockOncePasscode: unlockOncePasscode, completion: completion)
    }
}

class SEWallet: NSObject {
    //    static func newWallet(passcode: String) -> SEWallet {
    //
    //    }
}
