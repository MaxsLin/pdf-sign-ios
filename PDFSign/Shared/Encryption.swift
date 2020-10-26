//
//  Encryption.swift
//  PDFSign
//
//  Created by kawu on 8/23/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation
import CryptoSwift

class Encryption {
    static var authKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8") // using Taiwan's TimeZone
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: Date()) + "WeShinE"
    }

    static func encrypt(sourceText: String) -> String {
        guard let keyData = authKey.data(using: .ascii)?.bytes else { return "" }

        var result = ""
        do {
            let keyMD5 = intArrayToByteArray((keyData)).md5()
            let aes = try AES(key: keyMD5, blockMode: CBC(iv: keyMD5), padding: .pkcs5)
            let encryptBytes = try aes.encrypt(sourceText.bytes)
            result = encryptBytes.toBase64() ?? ""
        } catch {
            print("Failed to encrypt source")
        }
        return result
    }

    class func intArrayToByteArray(_ array: [UInt8]) -> [UInt8] {
        var uint8Array = [UInt8]()
        for i in 0...array.count - 1 {
            uint8Array.append(array[i])
            uint8Array.append(0)
            uint8Array.append(0)
            uint8Array.append(0)
        }
        return uint8Array
    }
}
