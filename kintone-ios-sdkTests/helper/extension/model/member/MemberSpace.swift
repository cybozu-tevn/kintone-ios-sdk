//
//  MemberSpace.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/4/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class MemberSpace: NSObject, Codable {
    private var entity: Entity!
    private var isAdmin: Bool!
    
    public func getEntiry() -> Entity {
        return self.entity
    }
    
    public func setEntity(_ entity: Entity) {
        self.entity = entity
    }
    
    public func getIsAdmin() -> Bool {
        return self.isAdmin
    }
    
    public func setIsAdmin(_ isAdmin: Bool) {
        self.isAdmin = isAdmin
    }
    
    public init(_ entity: Entity, _ isAdmin: Bool = false) {
        self.entity = entity
        self.isAdmin = isAdmin
    }
}
