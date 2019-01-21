[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7CmacOS%20%7C%20watchOS%20%7C%20tvOS-4E4E4E.svg?colorA=28a745)](#installation)

[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/Thomaslegravier/SynologySwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/Thomaslegravier/SynologySwift)

[![Twitter](https://img.shields.io/badge/Twitter-@lebasalte-blue.svg?style=flat)](https://twitter.com/lebasalte)

# SynologySwift
Swift library for accessing Synology NAS and use DiskStation APIs.

Tools :
- Resolve NAS host/ip base on QuickConnectId
- List available APIs
- Login with encryption

Installation
------------

### Swift 4.2+

With Cocoapods:

```
pod 'SynologySwift'
```

With Carthage:

```
github "Thomaslegravier/SynologySwift"
```

Usage
-----

Resolve DS reachable interface for a specific QuickConnectId :

```
SynologySwift.resolveURL(quickConnectId: "your-quick-id") { (result) in
    switch result {
    case .success(let data):
        let dsPort = data.port
        let dsHost = data.host
    case .failure(let error): break
    }
}
```

List available APIs on your DS :

```
SynologySwift.resolveAvailableAPIs { (result) in
    switch result {
    case .success(let data):
        for service in data.apiList! {
            let serviceName = service.key        // Exemple : SYNO.API.Auth
            let servicePath = service.value.path // Exemple : auth.cgi
        }
    case .failure(let error): break
    }
}
```

Auth connection with encryption :

```
SynologySwift.login(quickConnectid: "your-quick-id", login: "login", password: "password") { (result) in
    switch result {
    case .success(let data):
        let accountName = data.account // Account name
        let sessionId = data.sid       // Sid param for futher connected calls
    case .failure(let error): break
    }
}
```

Details
-------

Login helper: 
- Resolve automatically your DS host base on the quickConnectId
- List available APIs on your DS
- Fetch encryption details
- Login with your account informations.

Your login and password are encrypted and not stored.

Credits
-------

- Thanks to @Frizlab fro RSA/AES encryption part.
- Thanks to @btnguyen2k for swift-rsautils implementation
