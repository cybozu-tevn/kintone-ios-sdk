//
//  Right.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class UserRightEntity: NSObject, Codable {
    private var devMember: DevMemberEntity!
    private var appEditable: Bool!
    private var recordViewable: Bool!
    private var recordAddable: Bool!
    private var recordEditable: Bool!
    private var recordDeletable: Bool!
    private var recordImportable: Bool!
    private var recordExportable: Bool!
    
    public func getDevMember() -> DevMemberEntity {
        return self.devMember
    }
    
    public func setDevMeber(_ devMember: DevMemberEntity) {
        self.devMember = devMember
    }
    
    public func getAppEditable() -> Bool {
        return self.appEditable
    }
    
    public func setAppEditable(_ appEditable: Bool) {
        self.appEditable = appEditable
    }
    
    public func getRecordViewable() -> Bool {
        return self.recordViewable
    }
    
    public func setRecordViewable(_ recordViewable: Bool) {
        self.recordViewable = recordViewable
    }
    
    public func getRecordAddable() -> Bool {
        return self.recordAddable
    }
    
    public func setRecordAddable(_ recordAddable: Bool) {
        self.recordAddable = recordAddable
    }
    
    public func getRecordEditable() -> Bool {
        return self.recordEditable
    }
    
    public func setRecordEditable(_ recordEditable: Bool) {
        self.recordEditable = recordEditable
    }
    
    public func getRecordDeletable() -> Bool {
        return self.recordDeletable
    }
    
    public func setRecordDeletable(_ recordDeletable: Bool) {
        self.recordDeletable = recordDeletable
    }
    
    public func getRecordImportable() -> Bool {
        return self.recordImportable
    }
    
    public func setRecordImportable(_ recordImportable: Bool) {
        self.recordImportable = recordImportable
    }
    
    public func getRecordExportable() -> Bool {
        return self.recordExportable
    }
    
    public func setRecordExportable(_ recordExportable: Bool) {
        self.recordExportable = recordExportable
    }
    
    public init(devMember: DevMemberEntity,
                appEditable: Bool = false,
                recordViewable: Bool = false,
                recordAddable: Bool = false,
                recordEditable: Bool = false,
                recordDeletable: Bool = false,
                recordImportable: Bool = false,
                recordExportable: Bool = false) {
        self.devMember = devMember
        self.appEditable = appEditable
        self.recordViewable = recordViewable
        self.recordAddable = recordAddable
        self.recordEditable = recordEditable
        self.recordDeletable = recordDeletable
        self.recordImportable = recordImportable
        self.recordExportable = recordExportable
    }
}
