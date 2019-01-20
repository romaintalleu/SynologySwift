//
//  SynologySwift.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 13/12/2018.
//  Copyright © 2018 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwift {
    
    enum Result<T> {
        case success(T)
        case failure(ResultError)
    }
    
    enum ResultError: Error {
        case requestError(SynologySwiftCoreNetwork.RequestError)
        case other(String)
    }
    
    /*
     * Public interfaces
     */
    
    /// Global connect login whole process
    static func login(quickConnectid: String, login: String, password: String, completion: @escaping (SynologySwift.Result<SynologySwiftAuth.DSAuthInfos>) -> ()) {
        /* Get global DSM path infos */
        SynologySwift.resolveURL(quickConnectId: quickConnectid) { (dsInfos) in
            /* Get APIsInfos */
            SynologySwift.resolveAvailableAPIs(completion: { (apisInfos) in
                /* Start Auth login */
                SynologySwiftAuth.login(login: login, password:  password, completion: completion)
            })
        }
    }
    
    /// Resolve DS reachable interface for a specific quickConnectId
    static func resolveURL(quickConnectId: String, completion: @escaping (SynologySwift.Result<SynologySwiftURLResolver.DSInfos>) -> ()) {
        SynologySwiftURLResolver.resolve(quickConnectId: quickConnectId, completion: completion)
    }
    
    /// Liste available APIs on DS
    static func resolveAvailableAPIs(dsInfos: SynologySwiftURLResolver.DSInfos? = SynologySwiftURLResolver.dsResultInfos, completion: @escaping (SynologySwift.Result<SynologySwiftGlobalObjectMapper.APIsInfo>) -> ()) {
        SynologySwiftGlobal.resolveAvailableAPIs(dsInfos: dsInfos, completion: completion)
    }
    
    /// Auth connection with encryption
    static func resolveLogin(dsInfos: SynologySwiftURLResolver.DSInfos? = SynologySwiftURLResolver.dsResultInfos, encryptionServicePath: String? = nil, authServicePath: String? = nil, login: String, password: String, completion: @escaping (SynologySwift.Result<SynologySwiftAuth.DSAuthInfos>) -> ()) {
        SynologySwiftAuth.login(dsInfos: dsInfos, encryptionServicePath: encryptionServicePath, authServicePath: authServicePath, login: login, password: password, completion: completion)
    }

}
