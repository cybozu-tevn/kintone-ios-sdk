//
//  ItemAPI.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class ItemAPI: TokenEntity {
    private var appFacadeId: String!
    
    public func getAppFacadeId() -> String {
        return self.appFacadeId
    }
    
    private enum CodingKeys: String, CodingKey {
        case appFacadeId
    }
    
    public func getToken() -> TokenEntity {
        let token = TokenEntity(tokenString: self.token,
                          viewRecord: self.viewRecord,
                          addRecord: self.addRecord,
                          editRecord: self.editRecord,
                          deleteRecord: self.deleteRecord,
                          editApp: self.editApp)
        return token
    }
    
    public func setAppFacadeId(_ appFacadeId: String) {
        self.appFacadeId = appFacadeId
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.appFacadeId = try container.decode(String.self, forKey: .appFacadeId)
            try super.init(from: decoder)
        } catch {
            throw error
        }
    }
}
