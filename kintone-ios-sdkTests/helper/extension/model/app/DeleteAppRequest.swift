//
//  DeleteAppRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/24/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//
import Foundation

open class DeleteAppRequest: NSObject, Codable {
    private var app: Int
    
    public init(_ app: Int) {
        self.app = app
    }
}
