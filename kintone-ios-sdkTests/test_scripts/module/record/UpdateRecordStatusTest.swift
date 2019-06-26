//
//  UpdateRecordStatusTest.swift
//  kintone-ios-sdkTests
//

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordStatusTest: QuickSpec {
    
    override func spec() {
        let AppId = TestConstant.InitData.APP_ID_HAS_PROCESS!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        var recordId: Int!
        var revision: Int!
        let startAction = TestConstant.InitData.ACTION_START
        let testAction = TestConstant.InitData.ACTION_TEST
        let reviewAction = TestConstant.InitData.ACTION_REVIEW
        let completeAction = TestConstant.InitData.ACTION_COMPLETE
        let inProgressStatus = TestConstant.InitData.STATE_IN_PROGRESS
        let testingStatus = TestConstant.InitData.STATE_TESTING
        let reviewingStatus = TestConstant.InitData.STATE_REVIEWING
        let completedStatus = TestConstant.InitData.STATE_COMPLETED
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        // ---------------- NORMAL SPACE
        describe("UpdateRecordStatus_1") {
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.addRecord(AppId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            afterEach {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, [recordId]))
            }
            
            it("Test_176_180_StatusOnly") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_177_StatusAndAssignee") {
                // Update record status
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                var result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                revision = revision + 2
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. assignee (user1) updates status: Review action
                let recordModuleUser1 = Record(TestCommonHandling.createConnection(
                    assignee.username, assignee.password))
                result = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(AppId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
            }
            
            it("Test_178_Error_NotAssigneeChangeStatus") {
                // Update record status
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                
                // 3. non-assignee (user2) updates status: Review action
                let notAssignee = TestConstant.InitData.USERS[1]
                let recordModuleUser2 = Record(TestCommonHandling.createConnection(
                    notAssignee.username, notAssignee.password))
                let result = TestCommonHandling.awaitAsync(
                    recordModuleUser2.updateRecordStatus(AppId, recordId, reviewAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NOT_ASSIGNEE_CHANGE_STATUS_ERROR()!)
            }
            //
            //            it("Test_179_LocalizationStatus_JA") {
            //                // Change language of user to JA => this is currently MANUAL
            //                //        let STATUS_JA = "In progress JA"
            //                //        let ACTION_JA = "Start JA"
            //                //        let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(AppId, recordId, ACTION_JA, nil, nil)) as! UpdateRecordResponse
            //                //
            //                //        // Revision is increased by 2: execute Action + change status
            //                //        expect(result.getRevision()).to(equal(revision + 2))
            //                //
            //                //        // Status is changed is added
            //                //        let resultRecord = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
            //                //        let resultData:  Dictionary<String, FieldValue> = resultRecord.getRecord()!
            //                //
            //                //        expect(resultData["Status"]?.getValue() as? String).to(equal(STATUS_JA))
            //            }
            //
            //            it("Test_179_LocalizationStatus_ZH") {
            //                // Change language of user to ZH => this is currently MANUAL
            //                //        let STATUS_ZH = "In progress ZH"
            //                //        let ACTION_ZH = "Start ZH"
            //                //        let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(AppId, recordId, ACTION_ZH, nil, nil)) as! UpdateRecordResponse
            //                //
            //                //        // Revision is increased by 2: execute Action + change status
            //                //        expect(result.getRevision()).to(equal(revision + 2))
            //                //
            //                //        // Status is changed is added
            //                //        let resultRecord = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
            //                //        let resultData:  Dictionary<String, FieldValue> = resultRecord.getRecord()!
            //                //
            //                //        expect(resultData["Status"]?.getValue() as? String).to(equal(STATUS_ZH))
            //            }
            //
            //            it("Test_179_LocalizationStatus_EN") {
            //                // Change language of user to EN => this is currently MANUAL
            //                //        let STATUS_EN = "In progress EN"
            //                //        let ACTION_EN = "Start EN"
            //                //        let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(AppId, recordId, ACTION_EN, nil, nil)) as! UpdateRecordResponse
            //                //
            //                //        // Revision is increased by 2: execute Action + change status
            //                //        expect(result.getRevision()).to(equal(revision + 2))
            //                //
            //                //        // Status is changed is added
            //                //        let resultRecord = TestCommonHandling.awaitAsync(recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
            //                //        let resultData:  Dictionary<String, FieldValue> = resultRecord.getRecord()!
            //                //
            //                //        expect(resultData["Status"]?.getValue() as? String).to(equal(STATUS_EN))
            //            }
            //
            it("Test_181_Error_ChangeStatusWithoutAsssignee") {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, testAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!)
            }
            
            it("Test_182_Error_ChangeStatusWithAssigneeForStartAction") {
                let assignee = TestConstant.InitData.USERS[1]
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, assignee.username, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.UNSPECIFIED_ASSIGNEE_UPDATED_STATUS_ERROR()!)
            }
            
            it("Test_183_Error_InvalidAction") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, "Invalid_action", nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INVALID_STATUS_ERROR()!)
            }
            
            it("Test_185_Error_NonexistentAssignee") {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let nonexistentUser = "nonexistent user blah blah"
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, testAction, nonexistentUser, nil)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: nonexistentUser)
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_186_Error_InvalidRevision") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, 9999)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!)
            }
            
            it("Test_187_DefaultRevision") {
                let defaultRevision = -1
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_188_Error_RecordHasAssignee") {
                // same with 178
            }
            
            it("Test_189_RecordHasAssignee") {
                // 1. cybozu updates status: Start action
                var result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. user1 updates status: Review action
                let recordModuleUser1 = Record(TestCommonHandling.createConnection(
                    assignee.username, assignee.password))
                result = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(AppId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
                
                // 3. all users (cybozu, user1, user2) update status: Complete action
                // 3.1. updated by user user1
                result = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(AppId, recordId, completeAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
                
                // 3.2. updated by user user2
                let user2 = TestConstant.InitData.USERS[1]
                let recordModuleUser2 = Record(TestCommonHandling.createConnection(
                    user2.username, user2.password))
                result = TestCommonHandling.awaitAsync(
                    recordModuleUser2.updateRecordStatus(AppId, recordId, completeAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
                
                // 3.3. updated by user cybozu
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, completeAction, nil, nil)) as! UpdateRecordResponse
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                revision = revision + 2
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(completedStatus))
            }
            
            it("Test_190_Error_NoPermissionApp") {
                let recordModuleWithoutPermissionApp = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionApp.updateRecordStatus(
                        AppId, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
            
            it("Test_191_Error_NoPermissionRecord") {
                let recordModuleWithoutPermissionRecord = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionRecord.updateRecordStatus(
                        AppId, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
            
            it("Test_192_NoPermissionField") {
                let recordModuleWithoutPermissionField = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionField.updateRecordStatus(
                        AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_193_Error_InvalidAppID") {
                // nonexistent appID
                var result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(TestConstant.Common.NONEXISTENT_ID, recordId, startAction, nil, nil)) as! KintoneAPIException
                var errorMessage = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                errorMessage.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(result.getErrorResponse(), errorMessage)
                
                // negative appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(-1, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
                
                // zero appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(0, recordId, startAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            //            it("Test_194_Error_MissingAppID") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(nil, recordId, startAction, nil, nil))
            //            }
            //
            //            it("Test_195_Error_MissingRecordID") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(1, nil, startAction, nil, nil))
            //            }
            //
            //            it("Test_196_Error_MissingAssignees") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus(1, recordId, nil, nil, nil))
            //            }
            //
            //            it("Test_198_Error_InvalidInputType") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordStatus("9", recordId, assignee, nil, nil))
            //            }
            
            it("Test_199_Error_DisableProcessManagement") {
                // Currently the process management must be disabled by MANUAL
                // -> You should set break point here, then disable process management by manual
                // let result = TestCommonHandling.awaitAsync(
                // recordModule.updateRecordStatus(AppId_ProcessOneUserTakesAction, recordId, startAction, nil, nil)) as! KintoneAPIException
                //
                // TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PROCESS_MANAGEMENT_DISABLED_ERROR()!)
            }
        }
        
        // ---------------- GUEST SPACE
        describe("UpdateRecordStatus_2") {
            let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                TestConstant.Connection.CRED_ADMIN_USERNAME,
                TestConstant.Connection.CRED_ADMIN_PASSWORD,
                TestConstant.InitData.GUEST_SPACE_ID!))
            
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordId]))
            }
            
            it("Test_176_GuestSpace_StatusOnly") {
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_177_GuestSpace_StatusAndAssignee") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                var result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                revision = revision + 2
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. user1 updates status: Review action
                let conn = TestCommonHandling.createConnection(assignee.username, assignee.password, TestConstant.InitData.GUEST_SPACE_ID!)
                let recordModuleGuestSpaceUser1 = Record(conn)
                result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpaceUser1.updateRecordStatus(guestSpaceAppId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
            }
            
            it("Test_178_GuestSpace_NotAssigneeChangeStatus") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                
                // 3. non-assignee (user2) updates status: Review action
                let user2 = TestConstant.InitData.USERS[1]
                let conn = TestCommonHandling.createConnection(user2.username, user2.password, TestConstant.InitData.GUEST_SPACE_ID!)
                let recordModuleGuestSpaceUser2 = Record(conn)
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpaceUser2.updateRecordStatus(guestSpaceAppId, recordId, reviewAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NOT_ASSIGNEE_CHANGE_STATUS_ERROR()!)
            }
            
            it("Test_181_GuestSpace_Error_ChangeStatusWithoutAsssignee") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                
                // 2. cybozu updates status: Test action + without assignee
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, testAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!)
            }
            
            it("Test_187_GuestSpace_DefaultRevision") {
                // Update record status
                let defaultRevision = -1
                let result = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
        }
        
        // ---------------- API TOKEN
        describe("UpdateRecordStatus_3") {
            let recordModuleAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_WITH_PROCESS_API_TOKEN))
            
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.addRecord(AppId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecords(AppId, [recordId]))
            }
            
            it("Test_176_APIToken_StatusOnly") {
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(AppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_177_APIToken_StatusAndAssignee") {
                // 1. Updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                
                // 2. Updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                var result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                revision = revision + 2
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(AppId, recordId)) as! GetRecordResponse
                var recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(testingStatus))
                
                // 3. user1 updates status: Review action
                // This step confirms that the update status with assignee from above step is reflected, and user1 can process this step normally
                let recordModuleUser1 = Record(TestCommonHandling.createConnection(
                    assignee.username, assignee.password))
                result = TestCommonHandling.awaitAsync(
                    recordModuleUser1.updateRecordStatus(AppId, recordId, reviewAction, nil, nil)) as! UpdateRecordResponse
                revision = revision + 2
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, recordId)) as! GetRecordResponse
                recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision))
                expect(recordData["Status"]?.getValue() as? String).to(equal(reviewingStatus))
            }
            
            it("Test_178_APIToken_NotAssigneeChangeStatus") {
                // 1. cybozu updates status: Start action
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                
                // 2. cybozu updates status: Test action + assignee (user1)
                let assignee = TestConstant.InitData.USERS[0]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(AppId, recordId, testAction, assignee.username, nil)) as! UpdateRecordResponse
                
                // 3. non-assignee (in this case, API Token is presented for Administrator user who is non-assignee) updates status: Review action
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, reviewAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NOT_ASSIGNEE_CHANGE_STATUS_ERROR()!)
            }
            
            it("Test_181_APIToken_Error_ChangeStatusWithoutAsssignee") {
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, startAction, nil, nil)) as! UpdateRecordResponse
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, testAction, nil, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!)
            }
            
            it("Test_187_APIToken_DefaultRevision") {
                let defaultRevision = -1
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordStatus(AppId, recordId, startAction, nil, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(AppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                
                expect(result.getRevision()).to(equal(revision + 2))
                expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
        }
    }
}
