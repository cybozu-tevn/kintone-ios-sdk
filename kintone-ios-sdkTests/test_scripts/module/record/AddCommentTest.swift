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
        let appId: Int = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_ID!
        let appGuestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let noneExistentId = TestConstant.Common.NONEXISTENT_ID
        let apiToken: String = TestConstant.InitData.SPACE_APP_API_TOKEN
        var recordId: Int!
        var recordGuestSpaceId: Int!
        
        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = DataRandomization.generateString(prefix: "AddComment", length: 10)
        var mention: CommentMention!
        var comment: CommentContent!
        var mentionList = [CommentMention]()
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            guestSpaceId))
        let recordModuleApiToken = Record(TestCommonHandling.createConnection(apiToken))
        
        describe("AddComment") {
            beforeSuite {
                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, addData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(appGuestSpaceId, addData)) as! AddRecordResponse
                recordGuestSpaceId = addRecordGuestSpaceResponse.getId()
                
                mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                mentionList.append(mention)
                
                comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions(mentionList)
            }

            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(appGuestSpaceId, [recordGuestSpaceId]))
            }
            
            it("Test_236_Success_ValidData") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
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
                let resultRecord = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_Success_SpecialCharacter") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_238_Success_MentionMultiUsers") {
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
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(mentionCode))
                expect(mentions?[0].getType()).to(equal(mentionType))
                expect(mentions?[1].getCode()).to(equal(TestConstant.InitData.DEPARTMENT_CODE))
                expect(mentions?[1].getType()).to(equal(TestConstant.InitData.DEPARTMENT_TYPE))
                expect(mentions?[2].getCode()).to(equal(TestConstant.InitData.GROUP_CODE))
                expect(mentions?[2].getType()).to(equal(TestConstant.InitData.GROUP_TYPE))
            }
            
            it("Test_240_Success_NoMention") {
                comment.setMentions(nil)
                comment.setText(commentContent)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentions?.count))
                expect(commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_241_Error_BlankContent") {
                let commentBlank = CommentContent()
                
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, commentBlank)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_COMMENT_TEXT_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String("text"))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_242_Error_NonexistentMentionUser") {
                let mentionInvalidUser = CommentMention()
                mentionInvalidUser.setCode("NONEXISTENT_USER")
                mentionInvalidUser.setType(mentionType)
                mentionList.append(mentionInvalidUser)
                comment.setMentions(mentionList)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String("NONEXISTENT_USER"))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_243_Error_NoPermissionForApp") {
                mentionList.removeAll()
                mentionList.append(mention)
                comment.setMentions(mentionList)
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment)) as! KintoneAPIException
                
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
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_245_Success_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                
                mentionList.removeAll()
                mentionList.append(mention)
                
                comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentContent + " ").to(equal(result.getComments()?[0].getText()))
                expect(TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION).to(equal(result.getComments()?[0].getCreator()?.code))
            }
            
            it("Test_246_Error_InvalidAppId") {
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(noneExistentId, recordId, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))

                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_247_Error_InvalidRecordId") {
                let result = TestCommonHandling.awaitAsync(recordModule.addComment(appId, noneExistentId, comment)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_255_Success_MentionInactiveUserDepartmentGroup") {
                let mentionInactiveUser = CommentMention()
                mentionInactiveUser.setCode(TestConstant.Connection.CRED_USERNAME_INACTIVE)
                mentionInactiveUser.setType(mentionType)
                mentionList = [mentionInactiveUser]
                comment.setMentions(mentionList)
                
                _ = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(TestConstant.Connection.CRED_USERNAME_INACTIVE))
                expect(mentions?[0].getType()).to(equal(mentionType))
            }
            
            // GUEST SPACE
            it("Test_236_Success_ValidData_GuestSpace") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(appGuestSpaceId, recordGuestSpaceId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
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
                let resultRecord = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(appGuestSpaceId, recordGuestSpaceId)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
            }
            
            it("Test_237_Success_SpecialCharacter_GuestSpace") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(appGuestSpaceId, recordGuestSpaceId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
                
            }
            
            it("Test_240_Success_NoMention_GuestSpace") {
                comment.setMentions(nil)
                comment.setText(commentContent)
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(appGuestSpaceId, recordGuestSpaceId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(appGuestSpaceId, recordGuestSpaceId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(0).to(equal(mentions?.count))
                expect(commentContent + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            // API TOKEN
            it("Test_236_Success_ValidData_ApiToken") {
                let getCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                let totalComment = getCommentResponse.getComments()!.count
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
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
                let resultRecord = TestCommonHandling.awaitAsync(recordModuleApiToken.getRecord(appId, recordId)) as! GetRecordResponse
                let resultData: Dictionary<String, FieldValue> = resultRecord.getRecord()!
                let revision = resultData["$revision"]?.getValue() as! String
                expect(Int(revision)).to(equal(1))
                
            }
            
            it("Test_237_Success_SpecialCharacter_ApiToken") {
                let commentSpecialChars: String = "わたしは、あなたを愛しています"
                comment.setText(commentSpecialChars)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                // 1 comment is added + details is correct
                expect(mentionCode + " \n" + commentSpecialChars + " ").to(equal(result.getComments()?[0].getText()))
            }
            
            it("Test_238_239_Success_MentionMultiUsers_ApiToken") {
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
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?[0].getCode()).to(equal(mentionCode))
                expect(mentions?[0].getType()).to(equal(mentionType))
                expect(mentions?[1].getCode()).to(equal(TestConstant.InitData.DEPARTMENT_CODE))
                expect(mentions?[1].getType()).to(equal(TestConstant.InitData.DEPARTMENT_TYPE))
                expect(mentions?[2].getCode()).to(equal(TestConstant.InitData.GROUP_CODE))
                expect(mentions?[2].getType()).to(equal(TestConstant.InitData.GROUP_TYPE))
            }
            
            it("Test_240_Success_NoMention_ApiToken") {
                comment.setMentions(nil)
                comment.setText(commentContent)
                
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                let mentions = result.getComments()?[0].getMentions()
                expect(mentions?.count).to(equal(0))
                expect(result.getComments()?[0].getText()).to(equal(commentContent + " "))
            }
            
            it("Test_254_Success_CommentPostedByAdministrator_ApiToken") {
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(appId, recordId, comment))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse

                expect(result.getComments()?[0].getCreator()?.code).to(equal(TestConstant.Common.ADMINISTRATOR_USER))
            }
        }
    }
}
