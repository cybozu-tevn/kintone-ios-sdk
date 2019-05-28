//
//  AddSpaceRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/4/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class AddSpaceRequest: NSObject, Codable {
    private var id: Int!
    private var name: String!
    private var members: [SpaceMember]!
    private var isGuest: Bool!
    private var isPrivate: Bool!
    
    public func getId() -> Int {
        return self.id
    }
    
    public func setId(_ id: Int) {
        self.id = id
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func setName(_ name: String) {
        self.name = name
    }
    
    public func getMembers() -> [SpaceMember] {
        return self.members
    }
    
    public func setMembers(_ members: [SpaceMember]) {
        self.members = members
    }
    
    public func getIsGuest() -> Bool {
        return self.isGuest
    }
    
    public func setIsGuest(_ isGuest: Bool) {
        self.isGuest = isGuest
    }
    
    public func getIsPrivate() -> Bool {
        return self.isPrivate
    }
    
    public func setIsPrivate(_ isPrivate: Bool) {
        self.isPrivate = isPrivate
    }
    
    public init(_ id: Int, _ name: String, _ members: [SpaceMember], _ isGuest: Bool = false, _ isPrivate: Bool = false) {
        self.id = id
        self.name = name
        self.members = members
        self.isGuest = isGuest
        self.isPrivate = isPrivate
    }
}
