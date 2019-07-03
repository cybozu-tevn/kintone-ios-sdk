//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class AddCommentTest: QuickSpec {
    override func spec() {
        let APP_ID: Int = TestConstant.InitData.APP_ID!
        let GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_ID!
        let APP_GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
        let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN
        
        var recordID: Int!
        var recordGuestSpaceID: Int!
        
        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = "add comment test"
        let RECORD_TEXT_FIELD: String! = "text"
        var mention: CommentMention!
        var comment: CommentContent!
        var mentionList = [CommentMention]()
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            GUEST_SPACE_ID))
        let recordModuleApiToken = Record(TestCommonHandling.createConnection(API_TOKEN))
        
        describe("AddCommen") {
            beforeSuite {
                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, addData)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(APP_GUEST_SPACE_ID, addData)) as! AddRecordResponse
                recordGuestSpaceID = addRecordGuestSpaceResponse.getId()
                
                mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                mentionList.append(mention)
                
                comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions(mentionList)
            }

            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordID]))
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(APP_GUEST_SPACE_ID, [recordGuestSpaceID]))
            }
            
            it("Test_236_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(mentionCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentions = result.getComments()?[0].getMentions()
                for user in mentions! {
                    expect(mentionCode).to(equal(user.getCode()))
                    expect(mentionType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(recordModule.getRecord(APP_ID, recordID)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_238_MentionMultiUsers") {
                let mentionDept = CommentMention()
                mentionDept.setCode(TestConstant.InitData.DEPARTMENT_CODE)
                mentionDept.setType(TestConstant.InitData.DEPARTMENT_TYPE)
                mentionList.append(mentionDept)
                
                let mentionGroup = CommentMention()
                mentionGroup.setCode(TestConstant.InitData.GROUP_CODE)
                mentionGroup.setType(TestConstant.InitData.GROUP_TYPE)
                mentionList.append(mentionGroup)

                comment.setText(commentContent)
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(mentionCode))
                expect(mentions?[0].getType()).to(equal(mentionType))
                expect(mentions?[1].getCode()).to(equal(TestConstant.InitData.DEPARTMENT_CODE))
                expect(mentions?[1].getType()).to(equal(TestConstant.InitData.DEPARTMENT_TYPE))
                expect(mentions?[2].getCode()).to(equal(TestConstant.InitData.GROUP_CODE))
                expect(mentions?[2].getType()).to(equal(TestConstant.InitData.GROUP_TYPE))
            }
            
            it("Test_240_NoMention") {
                comment.setMentions(nil)
                comment.setText(commentContent)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentions?.count))
                expect(commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_241_Error_BlankContent") {
                let commentBlank = CommentContent()
                
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, commentBlank)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_COMMENT_TEXT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(RECORD_TEXT_FIELD))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_242_Error_NonexistentMentionUser") {
                let mentionInvalidUser = CommentMention()
                mentionInvalidUser.setCode("NONEXISTENT_USER")
                mentionInvalidUser.setType(mentionType)
                mentionList.append(mentionInvalidUser)
                comment.setMentions(mentionList)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_243_Error_NoPermissionForApp") {
                mentionList.removeAll()
                mentionList.append(mention)
                comment.setMentions(mentionList)
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(APP_ID, recordID, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_244_Error_NoPermissionForRecord") {
                mentionList.removeAll()
                mentionList.append(mention)
                comment.setMentions(mentionList)
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(APP_ID, recordID, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_245_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                mentionList.removeAll()
                mentionList.append(mention)
                
                comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION).to(equal(result.getComments()?[0].getCreator()?.code))
            }
            
            it("Test_246_Error_InvalidAppId") {
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(NONEXISTENT_ID, recordID, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))

                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_247_Error_InvalidRecordId") {
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, NONEXISTENT_ID, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("test_255_MentionInactiveUserDepartmentGroup") {
                let mentionInactiveUser = CommentMention()
                mentionInactiveUser.setCode(TestConstant.Connection.CRED_USERNAME_INACTIVE)
                mentionInactiveUser.setType(mentionType)
                mentionList = [mentionInactiveUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(TestConstant.Connection.CRED_USERNAME_INACTIVE))
                expect(mentions?[0].getType()).to(equal(mentionType))
            }
            
            /***
             * GUEST SPACE TESTING
             ***/
            
            it("Test_236_GuestSpace_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(APP_GUEST_SPACE_ID, recordGuestSpaceID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(mentionCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentions = result.getComments()?[0].getMentions()
                for user in mentions! {
                    expect(mentionCode).to(equal(user.getCode()))
                    expect(mentionType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(APP_GUEST_SPACE_ID, recordGuestSpaceID)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_GuestSpace_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(APP_GUEST_SPACE_ID, recordGuestSpaceID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
                
            }
            
            it("Test_240_GuestSpace_NoMention") {
                comment.setMentions(nil)
                comment.setText(commentContent)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(APP_GUEST_SPACE_ID, recordGuestSpaceID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentions?.count))
                expect(commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            /***
             * API TOKEN TESTING
             ***/
            
            it("Test_236_APIToken_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(totalComment + 1).to(equal(result.getComments()?.count))
                expect(mentionCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Common.ADMINISTRATOR_USER).to(equal(result.getComments()?[0].getCreator()?.code))
                let mentions = result.getComments()?[0].getMentions()
                for user in mentions! {
                    expect(mentionCode).to(equal(user.getCode()))
                    expect(mentionType).to(equal(user.getType()))
                }
                
                // Revision is not increased
                let resultRecord = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(APP_ID, recordID)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
                
            }
            
            it("Test_237_APIToken_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_238_239_APIToken_MentionMultiUsers") {
                let mentionDept = CommentMention()
                mentionDept.setCode(TestConstant.InitData.DEPARTMENT_CODE)
                mentionDept.setType(TestConstant.InitData.DEPARTMENT_TYPE)
                mentionList.append(mentionDept)
                
                let mentionGroup = CommentMention()
                mentionGroup.setCode(TestConstant.InitData.GROUP_CODE)
                mentionGroup.setType(TestConstant.InitData.GROUP_TYPE)
                mentionList.append(mentionGroup)
                
                comment.setText(commentContent)
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(mentionCode))
                expect(mentions?[0].getType()).to(equal(mentionType))
                expect(mentions?[1].getCode()).to(equal(TestConstant.InitData.DEPARTMENT_CODE))
                expect(mentions?[1].getType()).to(equal(TestConstant.InitData.DEPARTMENT_TYPE))
                expect(mentions?[2].getCode()).to(equal(TestConstant.InitData.GROUP_CODE))
                expect(mentions?[2].getType()).to(equal(TestConstant.InitData.GROUP_TYPE))
            }
            
            it("Test_240_APIToken_NoMention") {
                comment.setMentions(nil)
                comment.setText(commentContent)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?.count).to(equal(0))
                expect(result.getComments()?[0].getText()).to(equal(commentContent + " "))
            }
            
            it("Test_254_APIToken_CommentPostedByAdministrator") {
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(APP_ID, recordID, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse

                expect(result.getComments()?[0].getCreator()?.code).to(equal(TestConstant.Common.ADMINISTRATOR_USER))
            }
        }
    }
}
