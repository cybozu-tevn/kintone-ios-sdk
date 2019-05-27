//
//  UpdateMiscSettingsRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/16/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class UpdateMiscSettingsRequest: NSObject, Codable {
    private var code: String
    private var decimalPrecision: Int
    private var decimalScale: Int
    private var enableBulkDeletion: Bool
    private var fiscalYearStartMonth: Int
    private var id: Int
    private var name: String
    private var roundingMode: String
    private var useComment: Bool
    private var useHistory: Bool
    private var useThumbnail: Bool
    
    public func getCode() -> String {
        return self.code
    }
    
    public func getId() -> Int {
        return self.id
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public init(code: String,
                id: Int,
                name: String,
                decimalPrecision: Int,
                decimalScale: Int,
                enableBulkDeletion: Bool,
                fiscalYearStartMonth: Int,
                roundingMode: String,
                useComment: Bool,
                useHistory: Bool,
                useThumbnail: Bool) {
        self.code = code
        self.id = id
        self.name = name
        self.decimalPrecision = decimalPrecision
        self.decimalScale = decimalScale
        self.enableBulkDeletion = enableBulkDeletion
        self.fiscalYearStartMonth = fiscalYearStartMonth
        self.roundingMode = roundingMode
        self.useComment = useComment
        self.useHistory = useHistory
        self.useThumbnail = useThumbnail
    }
}
