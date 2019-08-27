//
// kintone-ios-sdkTests
// Created on 8/19/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class GetRecordsByCursorTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let recordModule = Record(TestCommonHandling.createConnection())
        let cursorModule = Cursor(TestCommonHandling.createConnection())
        
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let queryOfCursor = "Created_by in (LOGINUSER()) and Created_datetime = TODAY() order by $id asc"
        var recordIds = [Int]()
        
        describe("GetRecordsByCursor") {
            it("AddTestData_BeforeSuiteWorkaround") {
                recordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
            }
            
            it("Test_035_Success_ValidRequest_GetRecordsByCursorId") {
                let sizeOfCursor = 10
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                _verifyGetRecordCursorResultCorrectly(getRecordCursorRsp, textField, sizeOfCursor)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_036_Success_ValidRequest_GetRecordsIsCorrectly") {
                let sizeOfCursor = 10
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
 
                _verifyGetRecordCursorResultCorrectly(getRecordCursorRsp, textField, sizeOfCursor)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_037_Success_ValidRequest_RecordDependentGetRecords") {
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                // Add new 100 record after created cursor
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 100, textField)
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getRecords()).toNot(beNil())
                expect(getRecordCursorRsp.getNext()).to(equal(false))
                expect(getRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))

                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("Test_038_Success_ValidRequest_OrderOfRecord") {
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                let firstGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                expect(firstGetRecordCursorRsp.getRecords()).toNot(beNil())
                expect(firstGetRecordCursorRsp.getNext()).to(equal(true))
                expect(firstGetRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                let secondGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                expect(secondGetRecordCursorRsp.getRecords()).toNot(beNil())
                expect(secondGetRecordCursorRsp.getNext()).to(equal(false))
                expect(secondGetRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                let thirdGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
                let actualError = thirdGetRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_039_Error_CanNotGetRecordByOtherUser") {
                let username = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let password = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleOfOtherUser = Cursor(TestCommonHandling.createConnection(username, password))

                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleOfOtherUser.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_040_Error_InvalidCursorId") {
                let nonexistentCursorId = String(TestConstant.Common.NONEXISTENT_ID)
                let negativeCursorId = String(TestConstant.Common.NEGATIVE_ID)
                let zeroCursorId = String(0)
            
                // Get records with cursor id is nonexistent
                var getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(nonexistentCursorId)) as! KintoneAPIException
                
                var actualError = getRecordCursorRsp.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Get records with cursor id is negative
                getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(negativeCursorId)) as! KintoneAPIException
                
                actualError = getRecordCursorRsp.getErrorResponse()
                expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Get records with cursor id is zero
                getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(zeroCursorId)) as! KintoneAPIException
                
                actualError = getRecordCursorRsp.getErrorResponse()
                expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_043_Error_WithoutViewRecordsPermissionOnApp") {
                let usernameHasAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHasAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleHasAllPermission = Cursor(TestCommonHandling.createConnection(usernameHasAllRecordPermission, passwordHasAllRecordPermission))
                
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllPermission.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                // Deny all permission
                _updatePermissionOnApp(appModule, appId, false, false, false, false, false, false, false)
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllPermission.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _updatePermissionOnApp(appModule, appId, true, true, true, true, true, true, true)
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_044_Error_WithoutViewRecordsPermissionOnRecord") {
                // user1 has all record permission
                let usernameHasAllRecordPermission = TestConstant.Connection.CRED_USERNAME_HAVE_ALL_RECORD_PERMISSION
                let passwordHasAllRecordPermission = TestConstant.Connection.CRED_PASSWORD_HAVE_ALL_RECORD_PERMISSION
                let cursorModuleHasAllPermission = Cursor(TestCommonHandling.createConnection(usernameHasAllRecordPermission, passwordHasAllRecordPermission))
                
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllPermission.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                // Update permission of user on record
                let defaultUserRights = _getDefaultPermissionOfRecord()
                var updateUserRights = [RightEntity]()
                let user1 = DevMemberEntity(DevMemberType.USER, "user1")
                let user1Permission = RightEntity(entity: user1, viewable: false, editable: false, deletable: false)
                updateUserRights.append(user1Permission)
                updateUserRights.append(contentsOf: defaultUserRights)
                
                var recordRights = RecordRightEntity(entities: updateUserRights)
                RecordUtils.updateRecordPermissions(appModule: appModule, appId: appId, rights: [recordRights])
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModuleHasAllPermission.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getRecords().count).to(equal(0))
                
                recordRights = RecordRightEntity(entities: defaultUserRights)
                RecordUtils.updateRecordPermissions(appModule: appModule, appId: appId, rights: [recordRights])
                _ = TestCommonHandling.awaitAsync(cursorModuleHasAllPermission.deleteCursor(cursorId))
            }
            
            it("Test_046_Error_WithoutViewRecordsPermission_ApiToken") {
                let apiToken = TestConstant.InitData.SPACE_APP_API_TOKEN
                let appApiTokenCursorModule = Cursor(TestCommonHandling.createConnection(apiToken))
                
                let sizeOfCursor = 250
                let addCursorRsp = TestCommonHandling.awaitAsync(appApiTokenCursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                var token = TokenEntity(
                    tokenString: apiToken,
                    viewRecord: false,
                    addRecord: false,
                    editRecord: false,
                    deleteRecord: false,
                    editApp: false)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appId, token: token)
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(appApiTokenCursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = getRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                token = TokenEntity(
                    tokenString: apiToken,
                    viewRecord: true,
                    addRecord: true,
                    editRecord: true,
                    deleteRecord: true,
                    editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appId, token: token)
                _ = TestCommonHandling.awaitAsync(appApiTokenCursorModule.deleteCursor(cursorId))
            }
            
            it("Test_047_Success_ValidRequest_GetRecordsByCursorId_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let guestSpaceRecordModule = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                let guestSpaceCursorModule = Cursor(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                var guestSpaceRecordIds = [Int]()
                guestSpaceRecordIds = RecordUtils.addRecords(guestSpaceRecordModule, guestSpaceAppId, 500, textField)
                
                let sizeOfCursor = 10
                let addCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                _verifyGetRecordCursorResultCorrectly(getRecordCursorRsp, textField, sizeOfCursor)
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(cursorId))
                RecordUtils.deleteRecords(guestSpaceRecordModule, guestSpaceAppId, guestSpaceRecordIds)
            }
            
            it("Test_048_Success_ValidRequest_LimitationIs500") {
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_049_Success_ValidRequest_StatusOfNextIsTrue") {
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
                
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getNext()).to(equal(true))
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("Test_050_Success_ValidRequest_StatusOfNextIsFalse") {
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(getRecordCursorRsp.getNext()).to(equal(false))
                expect(sizeOfCursor).to(equal(getRecordCursorRsp.getRecords().count))
            }
            
            it("Test_051_Success_ValidRequest_CursorIsDeleted") {
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                
                var firstGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(firstGetRecordCursorRsp.getNext()).to(equal(false))
                
                let secondGetdRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = secondGetdRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_052_053_Susscess_Combination") {
                let newRecordIds = RecordUtils.addRecords(recordModule, appId, 1500, textField)
                
                let sizeOfCursor = 500
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                var cursorId = addCursorRsp.getId()
                
                // Get getRecords with cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId))
                
                // Get getAllRecords with cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.getAllRecords(cursorId))
                
                // Get getRecords with cursor
                let fistGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! KintoneAPIException
                
                let actualError = fistGetRecordCursorRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.INVALID_CURSOR_ID()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Add new cursor
                let addNewCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, sizeOfCursor)) as! CreateRecordCursorResponse
                cursorId = addNewCursorRsp.getId()
                
                // Get getRecords with cursor
                let secondGetRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                expect(secondGetRecordCursorRsp.getNext()).to(equal(true))
                expect(secondGetRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
                RecordUtils.deleteRecords(recordModule, appId, newRecordIds)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                RecordUtils.deleteRecords(recordModule, appId, recordIds)
            }
        }
        
        func _verifyGetRecordCursorResultCorrectly(
            _ getRecordCursorRsp: GetRecordCursorResponse,
            _ textField: String,
            _ sizeOfCursor: Int) {
            let fieldCodeArray = Array(getRecordCursorRsp.getRecords()[0].keys)
            
            expect(fieldCodeArray.count).to(equal(1))
            expect(fieldCodeArray[0] as String).to(equal(textField))
            expect(getRecordCursorRsp.getRecords()).toNot(beNil())
            expect(getRecordCursorRsp.getNext()).toNot(beNil())
            expect(getRecordCursorRsp.getRecords().count).to(equal(sizeOfCursor))
        }
        
        func _getDefaultPermissionOfRecord () -> [RightEntity] {
            var defaultUserRights = [RightEntity]()
            let user4 = DevMemberEntity(DevMemberType.USER, "user4")
            let user5 = DevMemberEntity(DevMemberType.USER, "user5")
            let user6 = DevMemberEntity(DevMemberType.USER, "user6")
            let everyone = DevMemberEntity(DevMemberType.GROUP, "everyone")
            let user4Permission = RightEntity(entity: user4, viewable: true, editable: true, deletable: false)
            let user5Permission = RightEntity(entity: user5, viewable: true, editable: false, deletable: true)
            let user6Permission = RightEntity(entity: user6, viewable: true, editable: false, deletable: false)
            let everyonePermission = RightEntity(entity: everyone, viewable: true, editable: true, deletable: true)
            
            defaultUserRights.append(user4Permission)
            defaultUserRights.append(user5Permission)
            defaultUserRights.append(user6Permission)
            defaultUserRights.append(everyonePermission)
            
            return defaultUserRights
        }
        
        func _updatePermissionOnApp(
            _ appModule: App,
            _ appId: Int,
            _ appEditable: Bool,
            _ recordViewable: Bool,
            _ recordAddable: Bool,
            _ recordEditable: Bool,
            _ recordDeletable: Bool,
            _ recordImportable: Bool,
            _ recordExportable: Bool) {
            var rights = AppUtils.getAppPermissions(appId: appId)
            rights[0].setAppEditable(appEditable)
            rights[0].setRecordViewable(recordViewable)
            rights[0].setRecordAddable(recordAddable)
            rights[0].setRecordEditable(recordEditable)
            rights[0].setRecordDeletable(recordDeletable)
            rights[0].setRecordExportable(recordImportable)
            rights[0].setRecordImportable(recordExportable)
            
            _ = AppUtils.updateAppPermissions(appModule: appModule, appId: appId, rights: rights)
        }
    }
}
