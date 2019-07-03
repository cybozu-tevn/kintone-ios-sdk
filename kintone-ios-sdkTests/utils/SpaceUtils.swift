//
// kintone-ios-sdkTests
// Created on 6/4/19
//

import kintone_ios_sdk
@testable import Promises

class SpaceUtils {
    typealias this = SpaceUtils
    static let auth = DevAuth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
    static let conn = DevConnection(TestConstant.Connection.DOMAIN, auth)
    static let devAppModule = DevApp(conn)
    
    /// Add Space
    ///
    /// - Parameters:
    ///   - idTemplate: Int | Space template id
    ///   - name: String | The space name
    ///   - members: [SpaceMember] | Space member list
    ///   - isGuest: Bool | The space will be set as guest space
    ///   - isPrivate: Bool | The space will be set private
    /// - Returns: Space id
    static func addSpace(idTemplate: Int, name: String, members: [SpaceMember], isGuest: Bool = false, isPrivate: Bool = false) -> Int {
        var id: Int!
        devAppModule.addSpace(idTemplate: idTemplate, name: name, members: members, isGuest: isGuest, isPrivate: isPrivate)
            .then {response in
                id = response.getId()
                print("Add Space: \(response.getId())")
            }.catch {error in
                let errorVal  = error as! KintoneAPIException
                fatalError(errorVal.toString()!)
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return id
    }
    
    /// Delete space
    ///
    /// - Parameters:
    ///   - id: Int | The space id
    ///   - guestSpaceId: Int | The guest space id
    static func deleteSpace(_ id: Int, _ guestSpaceId: Int = -1) {
        devAppModule.deleteSpace(id, guestSpaceId).then {
            print("Delete Space: \(id)")
            }.catch {error in
                let errorVal  = error as! KintoneAPIException
                fatalError(errorVal.toString()!)
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
    }
}
