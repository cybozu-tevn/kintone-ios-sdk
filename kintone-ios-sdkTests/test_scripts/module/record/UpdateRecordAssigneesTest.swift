//
//  UpdateRecordAssigneesTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordAssigneesTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.APP_ID_HAS_PROCESS!
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        var recordId: Int!
        var revision: Int!
        var assignees = [TestConstant.InitData.USERS[0].username]
        let startAction = TestConstant.InitData.ACTION_START
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        // ---------------- NORMAL SPACE
        describe("UpdateRecordAssignees_1") {
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
            }
            
            it("Test_155_Success_OneAssignee") {
                // Update Assignees for current state
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased by 1
                // - Assignee is updated
                expect(updateRecordResponse.getRevision()).to(equal(revision + 1))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
            }
            
            it("Test_157_Success_MultiAssignees") {
                // Update status: Start action --> "In progress" state
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision += 2
                
                // Update Assignees for current state
                let assignees = [TestConstant.InitData.USERS[0].username, TestConstant.InitData.USERS[1].username]
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                revision += 1
                
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased
                // - Assignees are updated
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
                expect(recordAssignees[1].getName()).to(equal(assignees[1]))
            }
            
            xit("Test_158_Success_100Assignees") {
                // Update status: Start action --> "In progress" state
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision += 2
                
                // Set 100 assignees for current state of record
                let assignees = _prepareAssigneeList(100)
                
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                revision += 1
                
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased
                // - Assignees are updated
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                for i in 0...99 {
                    expect(recordAssignees[i].getName()).to(equal(assignees[i]))
                }
            }
            
            xit("Test_159_Error_MoreThan100Assignees") {
                // Update status: Start action --> "In progress" state
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision += 2
                
                // Set more than 100 assignees for current state of record
                let assignees = DataRandomization.generateDataItems(numberOfItems: 101, prefix: "user")
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.ASSIGNEES_MORE_THAN_100_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_160_Error_InvalidRecordID") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, TestConstant.Common.NONEXISTENT_ID, assignees, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_161_Error_InvalidRevision") {
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, 9999)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_162_Success_DefaultRevision") {
                let defaultRevision = -1
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, defaultRevision)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                expect(updateRecordResponse.getRevision()).to(equal(revision + 1))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
            }
            
            it("Test_163_Success_DuplicateAssignee") {
                let assignees = [TestConstant.InitData.USERS[0].username, TestConstant.InitData.USERS[0].username]
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                expect(result.getRevision()).to(equal(revision + 1))
                expect(recordAssignees.count).to(equal(1))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
            }
            
            it("Test_164_Error_NonexistentAssignee") {
                let nonexistentUser = ["nonexistent user blah blah"]
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(appId, recordId, nonexistentUser, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: nonexistentUser[0])
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_165_Error_NoPermissionApp") {
                let recordModuleWithoutPermissionApp = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionApp.updateRecordAssignees(appId, recordId, assignees, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_166_Error_NoPermissionRecord") {
                let recordModuleWithoutPermissionRecord = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionRecord.updateRecordAssignees(appId, recordId, assignees, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_167_Error_NoPermissionField") {
                let recordModuleWithoutPermissionField = Record(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(
                    recordModuleWithoutPermissionField.updateRecordAssignees(appId, recordId, assignees, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_169_Error_InvalidAppID") {
                // nonexistent appID
                var result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(TestConstant.Common.NONEXISTENT_ID, recordId, assignees, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // negative appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(-1, recordId, assignees, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
                
                // zero appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordAssignees(0, recordId, assignees, nil)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            //            it("Test_170_Error_MissingAppID") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordAssignees(nil, recordId, assignees, nil))
            //            }
            //
            //            it("Test_171_Error_MissingRecordID") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordAssignees(AppId, nil, assignees, nil))
            //            }
            //
            //            it("Test_172_Error_MissingAssignees") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordAssignees(AppId, recordId, [nil], nil))
            //                let blankAssignee = [String]
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordAssignees(AppId, recordId, blankAssignee, nil))
            //            }
            //
            //            it("Test_174_Error_InvalidInputType") {
            //                // Error is detected by xcode editor
            //                let result = TestCommonHandling.awaitAsync(recordModule.updateRecordAssignees("9", recordId, assignees, nil))
            //            }
            
            it("Test_175_Error_DisableProcessManagement") {
                // Currently the process management must be disabled by MANUAL
                // -> You should set break point here, then disable process management by manual
                // let result = TestCommonHandling.awaitAsync(
                // recordModule.updateRecordAssignees(AppId, recordId, assignees, nil)) as! KintoneAPIException
                //
                // let actualError = result.getErrorResponse()
                // let expectedError = KintoneErrorParser.PROCESS_MANAGEMENT_DISABLED_ERROR()!
                // TestCommonHandling.compareError(actualError, expectedError)
            }
        }
        
        // ---------------- GUEST SPACE
        describe("UpdateRecordAssignees_2") {
            let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
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
            
            it("Test_155_Success_OneAssignee_GuestSpace") {
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordAssignees(guestSpaceAppId, recordId, assignees, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased by 1
                // - Assignee is updated
                expect(updateRecordResponse.getRevision()).to(equal(revision + 1))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
            }
            
            it("Test_157_Success_MultiAssignees_GuestSpace") {
                // Update status: Start action --> "In progress" state
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil))
                revision += 2
                
                // Update Assignees for current state
                let assignees = [TestConstant.InitData.USERS[0].username, TestConstant.InitData.USERS[1].username]
                let updateRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordAssignees(guestSpaceAppId, recordId, assignees, nil)) as! UpdateRecordResponse
                revision += 1
                
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased
                // - Assignees are updated
                expect(updateRecordResponse.getRevision()).to(equal(revision))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
                expect(recordAssignees[1].getName()).to(equal(assignees[1]))
            }
            
            //            it("Test_158_100Assignees") {
            //                // Must add 100 users to the Guest space before executing this case <= currently MANUAL
            //                // Update status: Start action --> "In progress" state
            //                _ = TestCommonHandling.awaitAsync(
            //                    recordModuleGuestSpace.updateRecordStatus(guestSpaceAppId, recordId, startAction, nil, nil))
            //                revision += 2
            //
            //                // Set 100 assignees for current state of record
            //                let assignees = DataRandomization.generateDataItems(numberOfItems: 100, prefix: "user")
            //                let updateRecordResponse = TestCommonHandling.awaitAsync(
            //                    recordModuleGuestSpace.updateRecordAssignees(guestSpaceAppId, recordId, assignees, nil)) as! UpdateRecordResponse
            //                revision += 1
            //
            //                let getRecordResponse = TestCommonHandling.awaitAsync(
            //                    recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId)) as! GetRecordResponse
            //                let recordData = getRecordResponse.getRecord()!
            //                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
            //
            //                // Verify:
            //                // - Revision is increased
            //                // - Assignees are updated
            //                expect(updateRecordResponse.getRevision()).to(equal(revision))
            //                for i in 0...99 {
            //                    expect(recordAssignees[i].getName()).to(equal(assignees[i]))
            //                }
            //            }
        }
        
        // ---------------- API TOKEN
        describe("UpdateRecordAssignees_3") {
            let recordModuleAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_WITH_PROCESS_API_TOKEN))
            
            beforeEach {
                let testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                revision = addRecordResponse.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(
                    recordModule.deleteRecords(appId, [recordId]))
            }
            
            it("Test_155_Success_OneAssignee_APIToken") {
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased by 1
                // - Assignee is updated
                expect(result.getRevision()).to(equal(revision + 1))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
            }
            
            it("Test_157_Success_MultiAssignees_APIToken") {
                // Update status: Start action --> "In progress" state
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision += 2
                
                // Update Assignees for current state
                let assignees = [TestConstant.InitData.USERS[0].username, TestConstant.InitData.USERS[1].username]
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                revision += 1
                
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased
                // - Assignees are updated
                expect(result.getRevision()).to(equal(revision))
                expect(recordAssignees[0].getName()).to(equal(assignees[0]))
                expect(recordAssignees[1].getName()).to(equal(assignees[1]))
            }
            
            xit("Test_158_Success_100Assignees_APIToken") {
                // Update status: Start action --> "In progress" state
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordStatus(appId, recordId, startAction, nil, nil))
                revision += 2
                
                // Set 100 assignees for current state of record
                let assignees = _prepareAssigneeList(100)
                let result = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordAssignees(appId, recordId, assignees, nil)) as! UpdateRecordResponse
                revision += 1
                
                let getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let recordData = getRecordResponse.getRecord()!
                let recordAssignees = recordData["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased
                // - Assignees are updated
                expect(result.getRevision()).to(equal(revision))
                for i in 0...99 {
                    expect(recordAssignees[i].getName()).to(equal(assignees[i]))
                }
            }
        }
        
        func _prepareAssigneeList(_ numberOfAssignees: Int) -> Array<String> {
            var assignees = DataRandomization.generateDataItems(numberOfItems: numberOfAssignees, prefix: "user")
            // Sort users following order:
            // user10, user100, user11, user12, ..., user19, user20, user21, user22, ..., user98, user99, user1, user2
            assignees = assignees.sorted(by: <)
            assignees.insert(assignees[0], at: 100)
            assignees.remove(at: 0)
            assignees.insert(assignees[11], at: 100)
            assignees.remove(at: 11)
            
            return assignees
        }
    }
}
