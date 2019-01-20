//
//  SynologySwiftGlobalObjectMapper.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 07/01/2019.
//  Copyright © 2019 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwiftGlobalObjectMapper {
    
    /*
     *   APIsInfo
     */
    
    struct APIsInfo: Decodable {
        let success: Bool // Not failable, not optional
        
        var apiList: [String: APIInfo]?
        
        var error: [String: Int]?
        
        private enum CodingKeys: String, CodingKey {
            case apiList = "data"
            case success = "success"
            case error   = "error"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            success = try values.decode(Bool.self, forKey: .success)
            apiList = try values.decodeIfPresent([String: APIInfo].self, forKey: .apiList)
            error = try values.decodeIfPresent([String: Int].self, forKey: .error)
        }
    }
    
    struct APIInfo: Decodable {
        let path: String // Not failable, not optional
        
        var maxVersion: Int?
        var minVersion: Int?
        var requestFormat: String?
    }
}
