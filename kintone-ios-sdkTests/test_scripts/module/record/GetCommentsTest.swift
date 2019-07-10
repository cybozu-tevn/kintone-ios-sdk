//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetCommentsTest: QuickSpec {
    override func spec() {
        let appId: Int = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceId: Int = TestConstant.InitData.GUEST_SPACE_ID!
        let guestSpaceAppId: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let apiToken: String = TestConstant.InitData.SPACE_APP_API_TOKEN
        var recordId: Int!
        var recordGuestSpaceId: Int!
        
        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = DataRandomization.generateString(prefix: "GetComments", length: 10)
        var commentId: Int!
        var commentGuestSpaceId: Int!
        var comments: [Int] = []
        var commentsGuestSpace: [Int] = []
        
        let noneExistentId = TestConstant.Common.NONEXISTENT_ID
        let negativeId: Int = TestConstant.Common.NEGATIVE_ID
        let numberOfComments: Int = 10
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            guestSpaceId))
        let recordModuleApiToken = Record(TestCommonHandling.createConnection(apiToken))
        
        describe("GetComments") {
            it("AddTestData_BeforeSuiteWorkaround") {
                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, addData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, addData)) as! AddRecordResponse
                recordGuestSpaceId = addRecordGuestSpaceResponse.getId()
                
                let mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                
                let comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions([mention])
                
                // Add >10 comments - Normal Space
                for _ in 0...14 {
                    let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(appId, recordId, comment)) as! AddCommentResponse
                    commentId = addCommentResponse.getId()
                    comments.append(Int(commentId))
                    
                    let addCommentGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(
                        guestSpaceAppId,
                        recordGuestSpaceId,
                        comment)) as! AddCommentResponse
                    commentGuestSpaceId = addCommentGuestSpaceResponse.getId()
                    commentsGuestSpace.append(Int(commentGuestSpaceId))
                }
            }
            
            it("Test_215_Success_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentId)
                for comment in result.getComments()! {
                    let expectedResult = mentionCode + " \n" + commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(mentionCode).to(equal(user.getCode()))
                        expect(mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_Success_SortAscending") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_Success_SortDescending") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = comments.count - 1
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_218_Error_InvalidOrder") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "invalid", nil, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_COMMENT_ORDER_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_219_Success_OffsetValue") {
                let offsetValue = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, offsetValue, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentIndex = comments.count - 1 - offsetValue
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_220_Success_OffsetIsZero") {
                let offsetValue = 0
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, offsetValue, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentId = comments.count
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            it("Test_221_Error_OffsetIsInvalid") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, -10, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_222_Success_LimitValue") {
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
            }
            
            it("Test_223_Success_LimitIsZero") {
                let limitValue = 0
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, limitValue)) as! GetCommentsResponse
                
                expect(limitValue ).to(equal(result.getComments()?.count))
            }
            
            it("Test_224_Error_LimitIsMoreThan10") {
                let limitValue = 11
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, nil, nil, limitValue)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_10_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_225_Success_AscOrderOffsetLimitCombination") {
                let offsetvalue = 5
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "asc", offsetvalue, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
                var expectedCommentId = comments.count - offsetvalue - limitValue + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_Success_DescOrderOffsetLimitCombination") {
                let offsetvalue = 5
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, recordId, "desc", offsetvalue, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
                var commentId = Int(commentId) - offsetvalue
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            it("Test_227_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.getComments(
                    appId,
                    recordId,
                    nil,
                    nil,
                    nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_228_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.getComments(
                    appId,
                    recordId,
                    nil,
                    nil,
                    nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_229_Error_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.getComments(
                    appId,
                    recordId,
                    nil,
                    nil,
                    nil)) as! GetCommentsResponse
                
                expect(numberOfComments).to(equal(result.getComments()?.count))
            }
            
            it("Test_230_Error_InvalidAppId") {
                var result = TestCommonHandling.awaitAsync(recordModule.getComments(noneExistentId, recordId, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(negativeId, recordId, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(0, recordId, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_231_Error_InvalidRecordId") {
                var result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, noneExistentId, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(appId, negativeId, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // GUEST SPACE
            it("Test_215_Success_ValidData_GuestSpace") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(
                    guestSpaceAppId,
                    recordGuestSpaceId,
                    nil,
                    nil,
                    nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentGuestSpaceId)
                for comment in result.getComments()! {
                    let expectedResult = mentionCode + " \n" + commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(mentionCode).to(equal(user.getCode()))
                        expect(mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_Success_SortAscending_GuestSpace") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_Success_SortDescending_GuestSpace") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = commentsGuestSpace.count - 1
                
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_Success_OffsetValue_GuestSpace") {
                let offsetValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, nil, offsetValue, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentIndex = commentsGuestSpace.count - 1 - offsetValue
                for value in result.getComments()! {
                    expect(commentsGuestSpace[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_Success_LimitValue_GuestSpace") {
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, nil, nil, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
            }
            
            it("Test_225_Success_AscOrderOffsetLimitCombination_GuestSpace") {
                let offsetValue = 5
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "asc", offsetValue, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
                var expectedCommentId = commentsGuestSpace.count - offsetValue - limitValue + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_Success_DescOrderOffsetLimitCombination_GuestSpace") {
                let offsetValue = 5
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(guestSpaceAppId, recordGuestSpaceId, "desc", offsetValue, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
                var commentId = Int(commentGuestSpaceId) - offsetValue
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            // API TOKEN
            it("Test_215_Success_ValidData_ApiToken") {
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentId)
                for comment in result.getComments()! {
                    let expectedResult = mentionCode + " \n" + commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(mentionCode).to(equal(user.getCode()))
                        expect(mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_Success_SortAscending_ApiToken") {
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_SortDescending_ApiToken") {
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = comments.count - 1
                
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_Success_OffsetValue_ApiToken") {
                let offsetValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, offsetValue, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(numberOfComments).to(equal(result.getComments()?.count))
                
                var commentIndex = comments.count - 1 - offsetValue
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_Success_LimitValue_ApiToken") {
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, nil, nil, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
            }
            
            it("Test_225_Success_AscOrderOffsetLimitCombination_ApiToken") {
                let offsetValue = 5
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "asc", offsetValue, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
                var expectedCommentId = comments.count - offsetValue - limitValue + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_ApiToken_DescOrderOffsetLimitCombination") {
                let offsetValue = 5
                let limitValue = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(appId, recordId, "desc", offsetValue, limitValue)) as! GetCommentsResponse
                
                expect(limitValue).to(equal(result.getComments()?.count))
                var commentId = Int(commentId) - offsetValue
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId]))
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordGuestSpaceId]))
            }
        }
    }
}
