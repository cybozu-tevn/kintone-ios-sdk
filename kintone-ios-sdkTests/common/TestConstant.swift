//
//  TestsConstants.swift
//  kintone-ios-sdkTests
//
//  Created by h001218 on 2018/10/05.
//  Copyright © 2018年 Cybozu. All rights reserved.
//

public class TestConstant {
    class Connection {
        static let DOMAIN = "https://te-phong.cybozu-dev.com"
        static let ADMIN_USERNAME = "cybozu"
        static let ADMIN_PASSWORD = "cybozu@123"
        static let CERT_NAME = "YOUR_CERT_NAME"
        static let CERT_PASSWORD = "YOUR_CERT_PASSWORD"
        static let CERT_EXTENSION = "YOUR_CERT_EXTENSION"
        static let PROXY_HOST = "10.224.136.41"
        static let PROXY_PORT = 3128
        static let GUEST_SPACE_ID = 1234
        static let MAX_VALUE = 2147483647
    }
    
    class Common {
        static let PROMISE_TIMEOUT = 30.0
    }
}
