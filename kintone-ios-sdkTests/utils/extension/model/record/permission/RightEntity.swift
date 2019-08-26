//
// kintone-ios-sdkTests
// Created on 8/22/19
//

import Foundation

open class RightEntity: NSObject, Codable {
    private var entity: DevMemberEntity!
    private var viewable: Bool!
    private var editable: Bool!
    private var deletable: Bool!
    
    public func getDevMember() -> DevMemberEntity {
        return self.entity
    }
    
    public func setDevMember(_ devMember: DevMemberEntity) {
        self.entity = devMember
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
    
    public init(entity: DevMemberEntity,
                viewable: Bool = false,
                editable: Bool = false,
                deletable: Bool = false) {
        self.entity = entity
        self.viewable = viewable
        self.editable = editable
        self.deletable = deletable
    }
}
