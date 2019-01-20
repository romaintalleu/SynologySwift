//
//  SynologySwiftURLResolverObjectMapper.swift
//  SynologySwift
//
//  Created by Thomas le Gravier on 13/12/2018.
//  Copyright © 2018 Thomas Le Gravier. All rights reserved.
//

import Foundation


class SynologySwiftURLResolverObjectMapper {
    
    /*
     *   SERVERINFO
     */
    
    struct ServerInfos: Decodable {
        let error: Int // Not failable, not optional
        let command: String // Not failable, not optional
        
        var environment: ServerInfosEnvironment?
        var server: ServerInfosServer?
        var service: ServerInfosService?
        var errorInfo: String?
        
        private enum CodingKeys: String, CodingKey {
            case error =       "errno"
            case errorInfo =   "errinfo"
            case command =     "command"
            case environment = "env"
            case server =      "server"
            case service =     "service"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            error = try values.decode(Int.self, forKey: .error)
            command = try values.decode(String.self, forKey: .command)
            environment = try values.decodeIfPresent(ServerInfosEnvironment.self, forKey: .environment)
            server = try values.decodeIfPresent(ServerInfosServer.self, forKey: .server)
            service = try values.decodeIfPresent(ServerInfosService.self, forKey: .service)
            errorInfo = try values.decodeIfPresent(String.self, forKey: .errorInfo)
        }
    }
    
    /// ENVIRONMENT
    struct ServerInfosEnvironment: Decodable {
        var host: String?
        var region: String?
        
        private enum CodingKeys: String, CodingKey {
            case host =   "control_host"
            case region = "relay_region"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            host = try values.decodeIfPresent(String.self, forKey: .host)
            region = try values.decodeIfPresent(String.self, forKey: .region)
        }
    }
    
    
    /// SERVICE
    struct ServerInfosService: Decodable {
        var relayIp: String?
        var relayIpv6: String?
        var relayPort: Int?
        var port: Int?
        var externPort: Int?
        
        private enum CodingKeys: String, CodingKey {
            case relayIp =    "relay_ip"
            case relayIpv6 =  "relay_ipv6"
            case relayPort =  "relay_port"
            case port =       "port"
            case externPort = "ext_port"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            relayIp = try values.decodeIfPresent(String.self, forKey: .relayIp)
            relayIpv6 = try values.decodeIfPresent(String.self, forKey: .relayIpv6)
            relayPort = try values.decodeIfPresent(Int.self, forKey: .relayPort)
            port = try values.decodeIfPresent(Int.self, forKey: .port)
            externPort = try values.decodeIfPresent(Int.self, forKey: .externPort)
        }
    }
    
    /// SERVER
    struct ServerInfosServer: Decodable {
        var ddns: String?
        var fqdn: String?
        var dsState: String?
        var gateway: String?
        
        var interface: [ServerInfosServerInterface]?
        var external: ServerInfosServerExternal?
        
        private enum CodingKeys: String, CodingKey {
            case ddns =      "ddns"
            case dsState =   "ds_state"
            case gateway =   "gateway"
            case interface = "interface"
            case external =  "external"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            ddns = try values.decodeIfPresent(String.self, forKey: .ddns)
            dsState = try values.decodeIfPresent(String.self, forKey: .dsState)
            gateway = try values.decodeIfPresent(String.self, forKey: .gateway)
            
            interface = try values.decodeIfPresent(Array<ServerInfosServerInterface>.self, forKey: .interface)
            external = try values.decodeIfPresent(ServerInfosServerExternal.self, forKey: .external)
        }
    }
    
    struct ServerInfosServerInterface: Decodable {
        var ip: String?
        var ipv6: [ServerInfosServerInterfaceIPV6]?
    }
    
    struct ServerInfosServerInterfaceIPV6: Decodable {
        let address: String
        let scope: String
        
        var addressType: Int?
        var prefixLength: Int?
        
        private enum CodingKeys: String, CodingKey {
            case address =       "address"
            case scope =         "scope"
            case addressType =   "addr_type"
            case prefixLength =  "prefix_length"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            address = try values.decode(String.self, forKey: .address)
            scope = try values.decode(String.self, forKey: .scope)
            addressType = try values.decodeIfPresent(Int.self, forKey: .addressType)
            prefixLength = try values.decodeIfPresent(Int.self, forKey: .prefixLength)
        }
    }
    
    struct ServerInfosServerExternal: Decodable {
        var ip: String?
        var ipv6: String?
        var port: Int?
        
        private enum CodingKeys: String, CodingKey {
            case ip =   "ip"
            case ipv6 = "ipv6"
            case port = "ext_port"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            ip = try values.decodeIfPresent(String.self, forKey: .ip)
            ipv6 = try values.decodeIfPresent(String.self, forKey: .ipv6)
            port = try values.decodeIfPresent(Int.self, forKey: .port)
        }
    }
    
    /*
     *   PINGPONG
     */
    
    struct PingPongInfos: Decodable {
        let bootDone: Bool
        let diskHibernation: Bool
        let success: Bool
        
        var host: String?
        var port: Int?
        
        private enum CodingKeys: String, CodingKey {
            case bootDone =        "boot_done"
            case diskHibernation = "disk_hibernation"
            case success =         "success"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            bootDone = try values.decode(Bool.self, forKey: .bootDone)
            diskHibernation = try values.decode(Bool.self, forKey: .diskHibernation)
            success = try values.decode(Bool.self, forKey: .success)
        }
    }
    
}
