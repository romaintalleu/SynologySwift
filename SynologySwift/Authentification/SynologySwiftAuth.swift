//
//  SynologySwiftAuth.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 24/12/2018.
//  Copyright © 2018 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwiftAuth {

    struct DSAuthInfos {
        var sid: String?
        var account: String?
        var encryptionInfos: SynologySwiftAuthObjectMapper.EncryptionInfos?
    }
    
    static var authInfos = DSAuthInfos()
    
    /*
     * Auth method with encryption support.
     * Thanks to : https://github.com/openstack/cinder/blob/master/cinder/volume/drivers/synology/synology_common.py
     */
    static func login(dsInfos: SynologySwiftURLResolver.DSInfos? = SynologySwiftURLResolver.dsResultInfos, encryptionServicePath: String? = nil, authServicePath: String? = nil, login: String, password: String, completion: @escaping (SynologySwift.Result<DSAuthInfos>) -> ()) {
        
        /* Return current auth infos session for account */
        if authInfos.account == login && authInfos.sid != nil {return completion(.success(authInfos))}
        
        /* Global DS infos */
        guard let dsInfos = dsInfos else {
            return completion(.failure(.other("Please provide DSInfos. See SynologySwiftURLResolver tool if necessary.")))
        }
        
        /* Encryption service path */
        guard let encryptionServicePath = encryptionServicePath ?? SynologySwiftGlobal.serviceInfoForName("SYNO.API.Encryption")?.path else {
            return completion(.failure(.other("Please provide encryption service path. See SynologySwiftGlobal resolveAvailableAPIs tool if necessary.")))
        }
        
        /* Auth service path */
        guard let authServicePath = authServicePath ?? SynologySwiftGlobal.serviceInfoForName("SYNO.API.Auth")?.path else {
            return completion(.failure(.other("Please provide auth service path. See SynologySwiftGlobal resolveAvailableAPIs tool if necessary.")))
        }
        
        /* Save account id */
        authInfos.account = login
        
        /* Get encryption data if necessary */
        if authInfos.account == login, let encryptionInfos = authInfos.encryptionInfos {
            
            SynologySwiftTools.logMessage("Auth : Start login process")
            
            /* Launch login */
            processLogin(dsInfos: dsInfos, encryptionInfos: encryptionInfos, authServicePath: authServicePath, login: login, password: password) { (result) in
                switch result {
                case .success(let authInfos):
                    SynologySwiftTools.logMessage("Auth : Success with sid \(authInfos.infos?.sid ?? "")")
                    self.authInfos.sid = authInfos.infos?.sid
                    completion(.success(self.authInfos))
                case .failure(let error): completion(.failure(error))
                }
            }
        } else {
            
            SynologySwiftTools.logMessage("Auth : Fetch encryption informations")
            
            fetchEncryptionInfos(dsInfos: dsInfos, encryptionServicePath: encryptionServicePath) { (result) in
                switch result {
                case .success(let encryptionInfos):
                    self.authInfos.encryptionInfos = encryptionInfos
                    
                    SynologySwiftTools.logMessage("Auth : Start login process")
                    
                    /* Launch login */
                    processLogin(dsInfos: dsInfos, encryptionInfos: encryptionInfos, authServicePath: authServicePath, login: login, password: password) { (result) in
                        switch result {
                        case .success(let authInfos):
                            SynologySwiftTools.logMessage("Auth : Success with sid \(authInfos.infos?.sid ?? "")")
                            self.authInfos.sid = authInfos.infos?.sid
                            completion(.success(self.authInfos))
                        case .failure(let error): completion(.failure(error))
                        }
                    }
                    
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    /*
     * Get encryption infos
     */
    
    private static func fetchEncryptionInfos(dsInfos: SynologySwiftURLResolver.DSInfos, encryptionServicePath: String, completion: @escaping (SynologySwift.Result<SynologySwiftAuthObjectMapper.EncryptionInfos>) -> ()) {
        
        let params = [
            "api": "SYNO.API.Encryption",
            "method": "getinfo",
            "version": "1"
        ]
        SynologySwiftCoreNetwork.performRequest(with: "http://\(dsInfos.host):\(dsInfos.port)/webapi/\(encryptionServicePath)", for: SynologySwiftAuthObjectMapper.EncryptionInfos.self, method: .POST, params: params, contentType: "application/x-www-form-urlencoded; charset=utf-8") { (result) in
            switch result {
            case .success(let encryptionInfos):
                if encryptionInfos.success && encryptionInfos.infos != nil {completion(.success(encryptionInfos))}
                else {
                    let errorDescription: String
                    if let code = encryptionInfos.error?["code"], let error = SynologySwiftCoreNetwork.RequestQuickConnectCommonError(rawValue: code) {
                        errorDescription = "An error occured - \(error.description)"
                    } else {
                        errorDescription = "An error occured - Encryption infos not reachable"
                    }
                    completion(.failure(.other(SynologySwiftTools.errorMessage(errorDescription))))
                }
            case .failure(let error):
                completion(.failure(.requestError(error)))
            }
        }
    }
    
    /*
     * Get login infos
     */
    
    private static func processLogin(dsInfos: SynologySwiftURLResolver.DSInfos, encryptionInfos: SynologySwiftAuthObjectMapper.EncryptionInfos, authServicePath: String, login: String, password: String, completion: @escaping (SynologySwift.Result<SynologySwiftAuthObjectMapper.AuthInfos>) -> ()) {
        
        guard let encryptionInfo = encryptionInfos.infos else {return completion(.failure(.other("An error occured - Encryption info not found")))}
        
        var params = [
            "api": "SYNO.API.Auth",
            "method": "login",
            "version": "6",
            "session": "dsm",
        ]
        
        let data = [
            "account": login,
            "passwd": password,
            "session": "dsm",
            "format": "sid",
            encryptionInfo.cipherToken: String(encryptionInfo.serverTime)
        ]
        
        /* Generate RSA */
        let passphrase = SynologySwiftTools.generateRandomString(length: 501)
        
        guard
            let rsaK = try? RSAUtils.encryptWithRSAPublicKey(str: passphrase, pubkeyBase64: encryptionInfo.publicKey),
            let rsa = rsaK
        else {
            return completion(.failure(.other("An error occured - Failed to generate encrypt auth RSA params")))
        }
        
        /* Generate AES */
        guard let paramsStr = SynologySwiftTools.queryStringForParams(data),
              let aes = try? synologyAuthAES(str: paramsStr, password: passphrase)
        else {
            return completion(.failure(.other("An error occured - Failed to generate encrypt auth AES params")))
        }
        
        let cipherData = [
            "rsa": rsa.base64EncodedString(),
            "aes": aes.base64EncodedString()
        ]
        guard let cipherJSONData = try? JSONSerialization.data(withJSONObject: cipherData, options: []) else {
                return completion(.failure(.other("An error occured - Failed to generate encrypt auth cypher json params params")))
        }
        
        params[encryptionInfo.cipherKey] = String(data: cipherJSONData, encoding: .utf8)!
        
        SynologySwiftCoreNetwork.performRequest(with: "http://\(dsInfos.host):\(dsInfos.port)/webapi/\(authServicePath)", for: SynologySwiftAuthObjectMapper.AuthInfos.self, method: .POST, params: params, contentType: "application/x-www-form-urlencoded; charset=utf-8") { (result) in
            switch result {
            case .success(let authInfos):
                /* Check data integrity */
                if authInfos.success && authInfos.infos?.sid != nil {
                    completion(.success(authInfos))
                } else {
                    let errorDescription: String
                    if let code = authInfos.error?["code"], let error = SynologySwiftCoreNetwork.RequestQuickConnectCommonError(rawValue: code) {
                        errorDescription = "An error occured - \(error.description)"
                    } else {
                        errorDescription = "An error occured - Unknown auth error"
                    }
                    completion(.failure(.other(SynologySwiftTools.errorMessage(errorDescription))))
                }
            case .failure(let error):
                completion(.failure(.requestError(error)))
            }
        }
    }
    
    private static func synologyAuthAES(str: String, password: String) throws -> Data {
        func paddedString(_ str: String, alignment: Int) -> Data {
            assert(alignment <= 255)
            let data = Data(str.utf8)
            let sizeAdded = alignment - data.count%alignment
            return data + Data(repeating: UInt8(sizeAdded), count: sizeAdded)
        }
        func deriveKeyAndIV(password: Data, salt: Data, keyLength: Int, ivLength: Int) throws -> (key: Data, iv: Data) {
            var d = Data(), di = Data()
            while d.count < keyLength + ivLength {
                let data = di + password + salt
                di = SynologySwiftTools.dataToMD5(data)
                d += di
            }
            return (key: d[..<keyLength], iv: d[keyLength..<keyLength+ivLength])
        }
        
        let keyLength = 32
        let alignmentSize = 16
        let saltMagic = Data("Salted__".utf8)
        let saltData = AES256Crypter.randomData(length: alignmentSize - saltMagic.count)
        let fullSalt = saltMagic + saltData
        
        let (key, iv) = try deriveKeyAndIV(password: Data(password.utf8), salt: saltData, keyLength: keyLength, ivLength: alignmentSize)
        let paddedStr = paddedString(str, alignment: alignmentSize)
        
        let aes = try AES256Crypter(key: key, iv: iv)
        let encryptedData = try aes.encrypt(paddedStr)
        return fullSalt + encryptedData
    }
}
