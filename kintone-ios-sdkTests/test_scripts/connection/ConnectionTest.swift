///**
/**
 kintone-ios-sdkTests
 Created on 5/29/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class ConnectionTest: QuickSpec {
    let TEST_APP_ID: Int = 31
    let TOKEN_API_TEST_APP: String = "Yy1jJ1DkDNeUh5AQBpIV9IiYptxN2SGIwaVOxv9m"
    let GUEST_SPACE_ID: Int = 5
    let GUEST_SPACE_APP_ID: Int = 30
    
    //Invalid host to test
    let INVALID_PROXY_HOST: String = "HOST NOT FOUND"
    let INVALID_PROXY_HOST_PORT: Int = -999
    
    override func spec() {
        describe("Connection") {
            it("Test_002_ValidRequest") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(TestConstant.Connection.PROXY_HOST, TestConstant.Connection.PROXY_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.TEST_APP_ID, [:])) is AddRecordResponse
                expect(result).to(beTruthy())
            }
            
            it("Test_002_ValidRequestGuestSpace") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth, self.GUEST_SPACE_ID)
                conn.setProxy(TestConstant.Connection.PROXY_HOST, TestConstant.Connection.PROXY_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.GUEST_SPACE_APP_ID, [:])) is AddRecordResponse
                expect(result).to(beTruthy())
            }
            
            it("Test_002_ValidRequestTokenApi") {
                let auth = Auth().setApiToken(self.TOKEN_API_TEST_APP)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(TestConstant.Connection.PROXY_HOST, TestConstant.Connection.PROXY_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.TEST_APP_ID, [:])) is AddRecordResponse
                expect(result).to(beTruthy())
            }
            
            it("Test_003_005_InvalidRequest") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(self.INVALID_PROXY_HOST, self.INVALID_PROXY_HOST_PORT)
                let recordModule = Record(conn)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(self.TEST_APP_ID, [:])) is NSError
                expect(result).to(beTruthy())
            } //End it
        } //End describe
    } //End spec func
}
