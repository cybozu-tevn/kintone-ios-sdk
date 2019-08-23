//
// kintone-ios-sdkTests
// Created on 8/22/19
//

import Foundation

open class RightEntity: NSObject, Codable {
    private var entityId: Int!
    private var entityType: DevMemberType!
    private var viewable: Bool!
    private var editable: Bool!
    private var deletable: Bool!
    
    public func getDevMemberId() -> Int {
        return self.entityId
    }
    
    public func setDevMemberId(_ entityId: Int) {
        self.entityId = entityId
    }
    
    public func getDevMemberType() -> DevMemberType {
        return self.entityType
    }
    
    public func setDevMemberType(_ entityType: DevMemberType) {
        self.entityType = entityType
    }
    
    public func getViewable() -> Bool {
        return self.viewable
    }
    
    public func setViewable(_ viewable: Bool) {
        self.viewable = viewable
    }
    
    public func getEditable() -> Bool {
        return self.editable
    }
    
    public func setEditable(_ editable: Bool) {
        self.editable = editable
    }
    
    public func getDeletable() -> Bool {
        return self.deletable
    }
    
    public func setDeletable(_ deletable: Bool) {
        self.deletable = deletable
    }
    
    public init(entityId: Int,
                entityType: DevMemberType = DevMemberType.USER,
                viewable: Bool = false,
                editable: Bool = false,
                deletable: Bool = false) {
        self.entityId = entityId
        self.entityType = entityType
        self.viewable = viewable
        self.editable = editable
        self.deletable = deletable
    }
}
