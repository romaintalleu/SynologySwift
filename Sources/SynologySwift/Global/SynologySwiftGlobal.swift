//
//  SynologySwiftGlobal.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 07/01/2019.
//  Copyright © 2019 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwiftGlobal {
    
    static var APIsInfo: SynologySwiftGlobalObjectMapper.APIsInfo?
    
    static func resolveAvailableAPIs(dsInfos: SynologySwiftURLResolver.DSInfos? = SynologySwiftURLResolver.dsResultInfos, completion: @escaping (SynologySwift.Result<SynologySwiftGlobalObjectMapper.APIsInfo>) -> ()) {
        
        /* Return existing APIs infos if already exist */
        if let apisInfos = APIsInfo {return completion(.success(apisInfos))}
        
        guard let dsInfos = dsInfos else {
            return completion(.failure(.other("Please provide DSInfos. See SynologySwiftURLResolver tool if necessary.")))
        }
        
        let params = [
            "api": "SYNO.API.Info",
            "method": "query",
            "query": "all",
            "version": "1"
        ]
        
        SynologySwiftTools.logMessage("Global : Resolve available APIs")
        
        SynologySwiftCoreNetwork.performRequest(with: "http://\(dsInfos.host):\(dsInfos.port)/webapi/query.cgi", for: SynologySwiftGlobalObjectMapper.APIsInfo.self, method: .POST, params: params, contentType: "application/x-www-form-urlencoded; charset=utf-8") { (result) in
            switch result {
            case .success(let apisInfos):
                /* Check data integrity */
                if apisInfos.success {
                    self.APIsInfo = apisInfos
                    completion(.success(apisInfos))
                } else {
                    let errorDescription: String
                    if let code = apisInfos.error?["code"], let error = SynologySwiftCoreNetwork.RequestQuickConnectCommonError(rawValue: code) {
                        errorDescription = "An error occured - \(error.description)"
                    } else {
                        errorDescription = "An error occured - APIs infos not reachable"
                    }
                    completion(.failure(.other(SynologySwiftTools.errorMessage(errorDescription))))
                }
            case .failure(let error):
                completion(.failure(.requestError(error)))
            }
        }
    }
    
    static func serviceInfoForName(_ name: String) -> SynologySwiftGlobalObjectMapper.APIInfo? {
        guard let apisInfos = APIsInfo else {return nil}
        return apisInfos.apiList?.filter({ $0.key == name }).first?.value
    }
}
