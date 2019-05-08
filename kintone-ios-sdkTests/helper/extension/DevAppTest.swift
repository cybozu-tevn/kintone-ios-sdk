//
//  Play.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/25/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation
import XCTest
import kintone_ios_sdk
@testable import Promises

class Play:XCTestCase{
    let appModule = App(TestCommonHandling.createConnection())
    
    func test_generateApiToken() {
        let xyz = AppUtils.generateToken(appModule, 5)
        print(xyz)
    }
}
