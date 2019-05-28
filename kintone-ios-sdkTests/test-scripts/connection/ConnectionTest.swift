///**
/**
 kintone-ios-sdkTests
 Created on 5/28/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class ConnectionTest: QuickSpec {
    let APP_ID: Int = 1
    let GUEST_SPACE_ID: Int = 5
    let GUEST_SPACE_APP_ID: Int = 30
    let TOKEN_API: String = "Yy1jJ1DkDNeUh5AQBpIV9IiYptxN2SGIwaVOxv9m"
    let TOKEN_API_APP_ID: Int = 31
    
    override func spec() {
        describe("Connection") {
            it("Test_002_ValidRequest") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(TestConstant.Connection.PROXY_HOST, TestConstant.Connection.PROXY_PORT)
                
                let recordModule = Record(conn)
                
                if TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, [:])) is AddRecordResponse {
                    expect(true).to(beTruthy())
                } else {
                    expect(false).to(beTruthy())
                }
            }
            
            it("Test_002_ValidRequestGuestSpace") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth, self.GUEST_SPACE_ID)
                conn.setProxy(TestConstant.Connection.PROXY_HOST, TestConstant.Connection.PROXY_PORT)
                
                let recordModule = Record(conn)
                
                if TestCommonHandling.awaitAsync(recordModule.addRecord(self.GUEST_SPACE_APP_ID, [:])) is AddRecordResponse {
                    expect(true).to(beTruthy())
                } else {
                    expect(false).to(beTruthy())
                }
            }
            
            it("Test_002_ValidRequestTokenApi") {
                let auth = Auth().setApiToken(self.TOKEN_API)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy(TestConstant.Connection.PROXY_HOST, TestConstant.Connection.PROXY_PORT)
                
                let recordModule = Record(conn)
                
                if TestCommonHandling.awaitAsync(recordModule.addRecord(self.TOKEN_API_APP_ID, [:])) is AddRecordResponse {
                    expect(true).to(beTruthy())
                } else {
                    expect(false).to(beTruthy())
                }
            }
            
            it("Test_003_005_InvalidRequest") {
                let auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
                let conn = Connection(TestConstant.Connection.DOMAIN, auth)
                conn.setProxy("HOST NOT FOUND", -999)
                
                let recordModule = Record(conn)
                
                if TestCommonHandling.awaitAsync(recordModule.addRecord(self.APP_ID, [:])) is NSError {
                    expect(true).to(beTruthy())
                } else {
                    expect(false).to(beTruthy())
                }
            }
        }
    }
}
