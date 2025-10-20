//
//  File.swift
//  
//
//  Created by Caleb Saunderson on 21/01/2024.
//

import Foundation
import Vapor
import CommonCrypto
class Hash {
    //Hashes the data with sha256
    func sha256(_ data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    //Adds the passsword and the salt then calls the function to hash it
    func hashPassword(password: String, withSalt salt: String) -> String {
        let data = (password + salt).data(using: .utf8)!
        let hashedData = sha256(data)
        return hashedData.map { String(format: "%02hhx", $0) }.joined()
    }

    //Pre-generated UUID salt
    func returnSalt() -> String {
        return "e3a8f9b3-c28b-4c19-8196-69251a1914ca"
    }

    
}
