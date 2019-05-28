//
//  DevApp.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/24/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation
import kintone_ios_sdk

public class DevApp: NSObject {
    var devConnection: DevConnection?
    var parser = DevAppParser()
    
    public init(_ connection: DevConnection?) {
        self.devConnection = connection
    }
}

extension DevApp: DevAppApp {}
