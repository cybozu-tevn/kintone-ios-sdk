//
//  SpaceMember.swift
//  kintone-ios-sdkTests
//

import Foundation

open class SpaceMember: NSObject, Codable {
    private var devMember: DevMemberEntity!
    private var isAdmin: Bool!
    
    public func getDevMember() -> DevMemberEntity {
        return self.devMember
    }
    
    public func setDevMember(_ devMember: DevMemberEntity) {
        self.devMember = devMember
    }
    
    public func getIsAdmin() -> Bool {
        return self.isAdmin
    }
    
    public func setIsAdmin(_ isAdmin: Bool) {
        self.isAdmin = isAdmin
    }
    
    public init(_ devMember: DevMemberEntity, _ isAdmin: Bool = false) {
        self.devMember = devMember
        self.isAdmin = isAdmin
    }
}
