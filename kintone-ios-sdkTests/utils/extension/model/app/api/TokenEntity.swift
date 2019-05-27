//
//  Token.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/28/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation

open class TokenEntity: NSObject, Codable {
    var token: String!
    var viewRecord: Bool!
    var addRecord: Bool!
    var editRecord: Bool!
    var deleteRecord: Bool!
    var editApp: Bool!
    
    public func getTokenString() -> String {
        return self.token
    }
    
    public func setTokenString(_ tokenString: String) {
        self.token = tokenString
    }
    
    public func getViewRecord() -> Bool {
        return self.viewRecord
    }
    
    public func setViewRecord(_ viewRecord: Bool) {
        self.viewRecord = viewRecord
    }
    
    public func getAddRecord() -> Bool {
        return self.addRecord
    }
    
    public func setAddRecord(_ addRecord: Bool) {
        self.addRecord = addRecord
    }
    
    public func getEditRecord() -> Bool {
        return self.editRecord
    }
    
    public func setEditRecord(_ editRecord: Bool) {
        self.editRecord = editRecord
    }
    
    public func getDeleteRecord() -> Bool {
        return self.deleteRecord
    }
    
    public func setDeleteRecord(_ deleteRecord: Bool) {
        self.deleteRecord = deleteRecord
    }
    
    public func getEditApp() -> Bool {
        return self.editApp
    }
    
    public func setEditApp(_ editApp: Bool) {
        self.editApp = editApp
    }
    
    public init(tokenString: String, viewRecord: Bool = false, addRecord: Bool = false, editRecord: Bool = false,
                deleteRecord: Bool = false, editApp: Bool = false) {
        self.token = tokenString
        self.viewRecord = viewRecord
        self.addRecord = addRecord
        self.editRecord = editRecord
        self.deleteRecord = deleteRecord
        self.editApp = editApp
    }
}
