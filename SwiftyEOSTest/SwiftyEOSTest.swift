//
//  SwiftyEOSTest.swift
//  SwiftyEOSTest
//
//  Created by croath on 2018/8/3.
//  Copyright © 2018 ProChain. All rights reserved.
//

import XCTest

class SwiftyEOSTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKeyPairsGeneration() {
        // K1 key pairs generated using `cleos create key`
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5KPdJ94w4M2fVqy4sSraQ3MetBLS4Q77FuRRoJBF9tQoNN1xThm")!).rawPublicKey(), "EOS5DMUwxsdppLMbLri6fbFyG9hq7r9PrmmDV4TArnGeYbQbWCat6")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5JFmVWXxzLjHhFFEFPnJzT97TtozEj4uXkRUUFrrs8SCborCztB")!).rawPublicKey(), "EOS7R36G3onnoFep11Hmi71351FHbGsdB8MYMwCFMGv21ocY9Z6Sh")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5JNrfzW1y3bSwupkRggLQ13zsyZrbsuHXm5TJTfVQLwdh5GHoTu")!).rawPublicKey(), "EOS7DPRLaRTKhtgKthFPDE4rawMa1W6mNizWKmRMj2gemkDmkeKKN")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5JMa5WspNhLvuqYHSS4PQvYsemQwkW8TRhuPdiLdML67u8Q3xcj")!).rawPublicKey(), "EOS88KmSURWa4px3sGEzCRY6iGK1aLrsWPTbGiVH1Whfr4R2Yvrkr")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5JsPkD2maDyDRZpWARXPuSLkqRF689mGd87vfY1hekV38fXYpBR")!).rawPublicKey(), "EOS5FphXKhXiVJFLTSYmkeCTMc1thTJAajnvpoazifCz7sozzKpvH")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5KhvZ88UtmrAafdcMC8FPxWYgTXo3WTSgM9qX2iUQGDKovvEiJ1")!).rawPublicKey(), "EOS848NHqsPsnRfucPLN2Ri25vTQ87758qkvRjMuABqk6env7GYtt")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5KdNfaYGDRB5t1EoxFm2BKif5uMTD6Y4XaB2NU4MW3kbUGLbagG")!).rawPublicKey(), "EOS5SBbDCs7s9sFdHHymbbGMcyNqCaThwy9x5Z3raK2nkPbhNe5og")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5KhCr6U497weS8McPZyaDU4z394nhK7aH1aWdEuLVvaEFCcBEnK")!).rawPublicKey(), "EOS52TKoL16ohyd6w6ZH6yayv6KntgRDBKjWyUc4PrXL51fiDuhTV")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5KB8CRDHURF68zfqRfMt4tHju5mmWZ9wKakS2xi8EToNkkBw6p1")!).rawPublicKey(), "EOS4trNb4VeFikbeaqXdd7xMiqHVdTWPEbM1XYog3b6ry65Cw1iZt")
        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "5JrKSKDUPxQf2fWEnTMeXkP43infabxNG6Lc8RqFFgCHGuDPdR3")!).rawPublicKey(), "EOS7EneFnFXv6w9RMhY89QrVehnUvuVLC7Tn8tbhfpwLSJZW6XWcm")
        
        // R1 key not supported yet.
        // R1 key pairs generated using `cleos create key --r1`
//        XCTAssertEqual(PublicKey(privateKey: try PrivateKey(keyString: "PVT_R1_2MX2F1ABY39AWcvk5nZDBemeGnfgMfsYCp9RbovCSkMNeoniNZ")!).wif(), "PUB_R1_63Wp9XUA7UtnfAEDuKtKzX3YFAPzpC14vHiEX7L28mVoMSNWFG")
    }
    
}
