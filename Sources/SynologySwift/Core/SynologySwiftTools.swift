//
//  SynologySwiftTools.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 20/12/2018.
//  Copyright © 2018 Thomas Le Gravier. All rights reserved.
//

import Foundation
import CommonCrypto


class SynologySwiftTools {
    
    /* Log message with module prefix */
    static func logMessage(_ message: String) {
        guard SynologySwiftConstants.logsEnabled else {return}
        print("SynologySwift - \(message)")
    }

    /* Format error message from Synology request */
    static func errorMessage(_ message: String) -> String {
        guard let match = message.range(of: "\\[.*?\\]$", options: .regularExpression, range: nil, locale: nil) else {return message}
        return String(message[match.lowerBound..<match.upperBound])
    }
    
    /* Generate random string with specific length */
    static func generateRandomString(length: Int) -> String {
        let chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+-/"
        return String((0..<length).map{ _ in chars.randomElement()! })
    }
    
    /* Format data to MD5 */
    static func dataToMD5(_ data: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ =  data.withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(data.count), &digest)
        }
        return Data(digest)
    }
    
    /* Format params dictonary to query string */
    static func queryStringForParams(_ params: [String: Any]) -> String? {
        var postComponents = URLComponents()
        postComponents.queryItems = params.map{ URLQueryItem(name: $0.key, value: $0.value as? String) }
        return postComponents.percentEncodedQuery!.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "+").inverted)
    }
}
