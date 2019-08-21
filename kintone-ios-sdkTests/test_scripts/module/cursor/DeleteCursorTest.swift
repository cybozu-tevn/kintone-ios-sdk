//
// kintone-ios-sdkTests
// Created on 8/20/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class DeleteCursorTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.APP_ID!
        let nonexistentId = TestConstant.Common.NONEXISTENT_ID
        var recordIds = [Int]()
        var recordGuestSpaceIds = [Int]()

        let textField: String = TestConstant.InitData.TEXT_FIELD
        let numberField: String = TestConstant.InitData.NUMBER_FIELD

        let cursorModule = Cursor(TestCommonHandling.createConnection())

        describe("DeleteCursor") {
            it("Test_067_Success") {
                // Create cursor
                let createCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], nil, 1)) as! CreateRecordCursorResponse
                let cursorId = createCursorRsp.getId()

                // Delete cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))

                // Verify cursor is deleted
                _verifyCursorIdNotExisting(cursorModule: cursorModule, cursorId: cursorId)
            }

            it("Test_069_Error_DeleteCursorOfOtherUser") {
                let cursorModuleOtherUser = Cursor(TestCommonHandling.createConnection(TestConstant.InitData.USERS[3].username, TestConstant.InitData.USERS[3].password))
                let createCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOtherUser.createCursor(appId, [textField], nil, 1)) as! CreateRecordCursorResponse
                let cursorId = createCursorRsp.getId()

                let result = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)

                _ = TestCommonHandling.awaitAsync(cursorModuleOtherUser.deleteCursor(cursorId))
            }

            it("Test_070_Error_InvalidCursor") {
                let cursorId = "InvalidCursorId"
                let result = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId)) as! KintoneAPIException

                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }

//            it("Test_072_Error_WithoutCursor") {
//                // Error is detected by xcode editor
//                let result = TestCommonHandling.awaitAsync(cursorModule.deleteCursor()) as! KintoneAPIException
//            }


            it("Test_073_Success_GuestSpace") {
                let cursorModuleGuestSpace = Cursor(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))

                let createCursorRsp = TestCommonHandling.awaitAsync(cursorModuleGuestSpace.createCursor(TestConstant.InitData.GUEST_SPACE_APP_ID!, [textField], nil, 1)) as! CreateRecordCursorResponse
                let cursorId = createCursorRsp.getId()

                _ = TestCommonHandling.awaitAsync(cursorModuleGuestSpace.deleteCursor(cursorId))

                _verifyCursorIdNotExisting(cursorModule: cursorModuleGuestSpace, cursorId: cursorId)
            }

             it("Test_067_Success_ApiToken") {
                let cursorModuleApiToken = Cursor(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let createCursorRsp = TestCommonHandling.awaitAsync(cursorModuleApiToken.createCursor(appId, [textField], nil, 1)) as! CreateRecordCursorResponse
                let cursorId = createCursorRsp.getId()

                _ = TestCommonHandling.awaitAsync(cursorModuleApiToken.deleteCursor(cursorId))

                _verifyCursorIdNotExisting(cursorModule: cursorModuleApiToken, cursorId: cursorId)
            }
        }

        func _verifyCursorIdNotExisting(cursorModule: Cursor, cursorId: String) {
            let result = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
            
            let actualError = result.getErrorResponse()!
            let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
            TestCommonHandling.compareError(actualError, expectedError)
        }
    }
}
