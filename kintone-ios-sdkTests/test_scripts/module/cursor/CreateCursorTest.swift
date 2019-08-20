//
// kintone-ios-sdkTests
// Created on 8/19/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class CreateCursorTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let query = "Created_by in (LOGINUSER()) and Created_datetime = TODAY() order by $id asc"
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let guestSpaceRecordModule = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            guestSpaceId))
        let cursorModule = Cursor(TestCommonHandling.createConnection())
        let guestSpaceCursorModule = Cursor(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            guestSpaceId))
        var recordIds = [Int]()
        var recordGuestSpaceIds = [Int]()
        
        describe("CreateCursor") {
            it("AddTestData_BeforeSuiteWorkaround") {
                recordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
                recordGuestSpaceIds = RecordUtils.addRecords(guestSpaceRecordModule, guestSpaceAppId, 500, textField)
            }
            
            it("Test_010_Success_ValidRequest_FullOptions") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, 1)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_011_Success_ValidRequest_DefaultSizeIs100") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, nil)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_012_Success_ValidRequest_SizeIs500") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, 500)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_013_Error_InvalidAppId") {
                let noneExistentAppId = TestConstant.Common.NONEXISTENT_ID
                let negativeAppId = TestConstant.Common.NEGATIVE_ID
                let zeroAppId = 0
                
                // Test with unexisted app id
                var addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(noneExistentAppId, [textField], query, 500)) as! KintoneAPIException
                
                var actualError = addRecordCursorRsp.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentAppId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Test with negative app id
                addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(negativeAppId, [textField], query, 500)) as! KintoneAPIException
                
                actualError = addRecordCursorRsp.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeAppId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Test with zero app id
                addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(zeroAppId, [textField], query, 500)) as! KintoneAPIException
                
                actualError = addRecordCursorRsp.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(zeroAppId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_014_Success_InvalidFields") {
                let invalidField = "InvalidField"
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [invalidField], query, 500)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_015_Error_InvalidQuery") {
                let invalidQuery = "InvalidQuery"
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], invalidQuery, 500)) as! KintoneAPIException
                
                let actualError = addRecordCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_QUERY_GET_DATA_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_016_Error_InvalidSize") {
                let negativeSize = -1
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, negativeSize)) as! KintoneAPIException
                
                let actualError = addRecordCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_CURSOR_NEGATIVE_SIZE()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_018_Success_WithoutFields") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, nil, query, 1)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_019_Success_WithoutQuery") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], nil, 1)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_020_Success_WithoutSize") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, nil)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_021_Error_WithoutRecordViewPermission") {
                let usernameWithoutViewRecordPermission = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION
                let passwordWithoutViewRecordPermission = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION
                let cursorModuleWithoutViewPermissionRecord = Cursor(TestCommonHandling.createConnection(
                    usernameWithoutViewRecordPermission,
                    passwordWithoutViewRecordPermission))
                
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleWithoutViewPermissionRecord.createCursor(appId, [textField], query, nil)) as! KintoneAPIException
                
                let actualError = addRecordCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_023_Error_WithoutRecordViewPermission_ApiToken") {
                let apiTokenWithoutViewRecordPermission = TestConstant.InitData.SPACE_APP_API_TOKEN_WITHOUT_VIEW_RECORD_PERMISSION
                let cursorModuleWithoutViewPermissionRecord = Cursor(TestCommonHandling.createConnection(apiTokenWithoutViewRecordPermission))
                
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleWithoutViewPermissionRecord.createCursor(appId, [textField], query, nil)) as! KintoneAPIException
                
                let actualError = addRecordCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_024_Success_FullOptions_GuestSpace") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceAppId, [textField], query, 1)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_025_Success_DefaultSizeIs100_GuestSpace") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceAppId, [textField], query, nil)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_026_Success_SizeIs500_GuestSpace") {
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceAppId, [textField], query, 500)) as! CreateRecordCursorResponse
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addRecordCursorRsp.getId()))
            }
            
            it("Test_027_Error_SizeLargerThan500") {
                let invalidSize = 501
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, invalidSize)) as! KintoneAPIException
                
                let actualError = addRecordCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.EXCEED_CURSOR_SIZE_LIMIT()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_028_029_Error_MaximumCursorsIs10") {
                var cursorIds = _addMaximumRecordCursor()
                
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, nil)) as! KintoneAPIException
                
                let actualError = addRecordCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.MAXIMUM_LIMIT_CURSOR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _deleteCursors(cursorIds)
            }
            
            it("Test_032_034_Success_CreateCursorAfterRemoveCurorWhenMaximum") {
                var cursorIds = _addMaximumRecordCursor()
                
                // Delete one of 10 cursor after created
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorIds[0]))
                cursorIds.removeFirst()
                
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, nil)) as! CreateRecordCursorResponse
                cursorIds.append(addRecordCursorRsp.getId())
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _deleteCursors(cursorIds)
            }
            
            it("Test_033_Success_ObtainedExistingCursor") {
                var cursorIds = _addMaximumRecordCursor()
                
                // Verify that can not add new cursor
                let addRecordCursorErrorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, nil)) as! KintoneAPIException
                
                let actualError = addRecordCursorErrorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.MAXIMUM_LIMIT_CURSOR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Delete one of 10 cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorIds[0]))
                cursorIds.removeFirst()
                
                // Add new one cursor
                let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, 500)) as! CreateRecordCursorResponse
                cursorIds.append(addRecordCursorRsp.getId())
                
                expect(addRecordCursorRsp.getId()).toNot(beNil())
                expect(addRecordCursorRsp.getTotalCount()).toNot(beNil())
                
                _deleteCursors(cursorIds)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, recordIds))
                _ = TestCommonHandling.awaitAsync(guestSpaceRecordModule.deleteRecords(guestSpaceAppId, recordGuestSpaceIds))
            }
            
            func _addMaximumRecordCursor() -> [String] {
                var cursorIds = [String]()
                for _ in 0...9 {
                    let addRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], query, nil)) as! CreateRecordCursorResponse
                    cursorIds.append(addRecordCursorRsp.getId())
                }
                
                return cursorIds
            }
            
            func _deleteCursors(_ cursorIds: [String]) {
                for id in cursorIds {
                    _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(id))
                }
            }
        }
    }
}
