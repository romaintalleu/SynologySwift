//
//  SynologySwiftAuthObjectMapper.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 11/01/2019.
//  Copyright © 2019 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwiftAuthObjectMapper {

    /*
     *   Encryption infos
     */
    
    struct EncryptionInfos: Decodable {
        let success: Bool // Not failable, not optional
        
        var infos: EncryptionInfo?
        
        var error: [String: Int]?
        
        private enum CodingKeys: String, CodingKey {
            case infos = "data"
            case success = "success"
            case error   = "error"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            success = try values.decode(Bool.self, forKey: .success)
            infos = try values.decodeIfPresent(EncryptionInfo.self, forKey: .infos)
            error = try values.decodeIfPresent([String: Int].self, forKey: .error)
        }
    }
    
    struct EncryptionInfo: Decodable {
        let cipherKey: String
        let cipherToken: String
        let publicKey: String
        let serverTime: Int
        
        private enum CodingKeys: String, CodingKey {
            case cipherKey   = "cipherkey"
            case cipherToken = "ciphertoken"
            case publicKey   = "public_key"
            case serverTime  = "server_time"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            cipherKey = try values.decode(String.self, forKey: .cipherKey)
            cipherToken = try values.decode(String.self, forKey: .cipherToken)
            publicKey = try values.decode(String.self, forKey: .publicKey)
            serverTime = try values.decode(Int.self, forKey: .serverTime)
        }
    }
    
    /*
     *   Auth infos
     */
    
    struct AuthInfos: Decodable {
        let success: Bool // Not failable, not optional
        
        var infos: AuthInfo?
        
        var error: [String: Int]?
        
        private enum CodingKeys: String, CodingKey {
            case infos = "data"
            case success = "success"
            case error   = "error"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            success = try values.decode(Bool.self, forKey: .success)
            infos = try values.decodeIfPresent(AuthInfo.self, forKey: .infos)
            error = try values.decodeIfPresent([String: Int].self, forKey: .error)
        }
    }
    
    struct AuthInfo: Decodable {
        let sid: String
    }
}
