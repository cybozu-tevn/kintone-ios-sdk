//
// kintone-ios-sdkTests
// Created on 5/29/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class ConnectionTest: QuickSpec {
    override func spec() {
        let appId: Int = TestConstant.InitData.APP_ID!
        
        describe("Connection") {
            it("Test_002_Success_ValidRequest") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(TestConstant.Connection.PROXY_IP, TestConstant.Connection.PROXY_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, [:])) is AddRecordResponse
                
                expect(result).to(beTruthy())
            }
            
            it("Test_002_Success_ValidRequest_GuestSpace") {
                let guestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let auth = Auth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth, guestSpaceId)
                conn.setProxy(TestConstant.Connection.PROXY_IP, TestConstant.Connection.PROXY_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(guestSpaceAppId, [:])) is AddRecordResponse
                
                expect(result).to(beTruthy())
            }
            
            it("Test_002_Success_ValidRequest_ApiToken") {
                let apiToken: String = TestConstant.InitData.APP_API_TOKEN
                let auth = Auth().setApiToken(apiToken)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(TestConstant.Connection.PROXY_IP, TestConstant.Connection.PROXY_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, [:])) is AddRecordResponse
                
                expect(result).to(beTruthy())
            }
            
            it("Test_003_005_Error_InvalidRequest") {
                let invalidProxyIp: String = TestConstant.Common.INVALID_PROXY_IP
                let invalidProxyPort: Int = TestConstant.Common.INVALID_PROXY_HOST_PORT
                let auth = Auth().setPasswordAuth(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(invalidProxyIp, invalidProxyPort)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, [:])) is NSError
                
                expect(result).to(beTruthy())
            }
        }
    }
}
