//
// kintone-ios-sdkTests
// Created on 6/26/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class UpdateViewsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appModuleGuestSpace = App(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            TestConstant.InitData.GUEST_SPACE_ID!))
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        // View Data
        var currentViews: [String: ViewModel] = [String: ViewModel]()
        var viewEntry: [String: ViewModel] = [String: ViewModel]()
        let updateViewModel: ViewModel = ViewModel()
        var currentGuestSpaceAppViews: [String: ViewModel] = [String: ViewModel]()
        var viewGuestSpaceAppEntry: [String: ViewModel] = [String: ViewModel]()
        let updateViewGuestSpaceAppModel: ViewModel = ViewModel()
        let viewName = DataRandomization.generateString(prefix: "ViewTest", length: 5)
        let viewSort = "Record_number desc"
        let viewType = ViewModel.ViewType.LIST
        let viewFilter = "Created_datetime = LAST_WEEK()"
        let viewIndex = 1
        let viewFields = TestConstant.InitData.FIELD_CODES
        
        let language = LanguageSetting.DEFAULT
        let isPreview = false
        var totalOfAllView: Int = 0
        var totalOfAllViewGuestSpaceApp: Int = 0
        
        beforeSuite {
            // Prepare view entry for test app in normal space
            let getViewsResponse = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT, false)) as! GetViewsResponse
            currentViews = getViewsResponse.getViews()!
            viewEntry = currentViews
            updateViewModel.setName(viewName)
            updateViewModel.setSort(viewSort)
            updateViewModel.setType(viewType)
            updateViewModel.setFilterCond(viewFilter)
            updateViewModel.setIndex(viewIndex)
            updateViewModel.setFields(viewFields)
            viewEntry[viewName] = updateViewModel
            totalOfAllView = viewEntry.count
        
            // Prepare view entry for test app in guest space
            let getViewsGuestSpaceAppResponse = TestCommonHandling.awaitAsync(appModule.getViews(appId, LanguageSetting.DEFAULT, false)) as! GetViewsResponse
            currentGuestSpaceAppViews = getViewsGuestSpaceAppResponse.getViews()!
            viewGuestSpaceAppEntry = currentGuestSpaceAppViews
            updateViewGuestSpaceAppModel.setName(viewName)
            updateViewGuestSpaceAppModel.setSort(viewSort)
            updateViewGuestSpaceAppModel.setType(viewType)
            updateViewGuestSpaceAppModel.setFilterCond(viewFilter)
            updateViewGuestSpaceAppModel.setIndex(viewIndex)
            updateViewGuestSpaceAppModel.setFields(viewFields)
            viewGuestSpaceAppEntry[viewName] = updateViewGuestSpaceAppModel
            totalOfAllViewGuestSpaceApp = viewGuestSpaceAppEntry.count
        }
        
        afterSuite {
            // Remove data after tested
            let previewApp: PreviewApp? = PreviewApp(appId, -1)
            _ = TestCommonHandling.awaitAsync(appModule.updateViews(appId, currentViews))
            _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!], false))
            AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
            
            let previewGuestSpaceApp: PreviewApp? = PreviewApp(guestSpaceAppId, -1)
            _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateViews(guestSpaceAppId, currentGuestSpaceAppViews))
            _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewGuestSpaceApp!], false))
            AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guestSpaceAppId)

        }
        
        describe("UpdateViews") {
            // API TOKEN
            it("Test_015_ApiToken_Error_APITokenAuthentication") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.updateViews(appId, viewEntry)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // NORMAL SPACE
            it("Test_016_Success_ValidRequest") {
                let getViewResponse = TestCommonHandling.awaitAsync(appModule.getViews(appId, language, isPreview)) as! GetViewsResponse
                let currentRevision = getViewResponse.getRevision()!
                
                // Update view with current revision + deploy
                _ = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntry, currentRevision))
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!]))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
                
                // Revision is increased by 1
                let result = TestCommonHandling.awaitAsync(appModule.getViews(appId, language, isPreview)) as! GetViewsResponse
                expect(result.getRevision()).to(equal(currentRevision + 1))
                // Views is added correctly
                let viewsList = result.getViews()
                expect(viewsList?.count).to(equal(totalOfAllView))

                for view in viewsList! {
                    if(view.key == viewName) {
                        expect(view.key).to(equal(viewName))
                        expect(view.value.getName()).to(equal(viewName))
                        expect(view.value.getSort()).to(equal(viewSort))
                        expect(view.value.getType()).to(equal(viewType))
                        expect(view.value.getFilterCond()).to(equal(viewFilter))
                        expect(view.value.getIndex()).to(equal(viewIndex))
                        expect(view.value.getFields()).to(equal(viewFields))
                    }
                }
            }
            
            it("Test_020_Error_MissingViewIndex") {
                var viewEntryNoIndex: [String: ViewModel] = [String: ViewModel]()
                let viewModelNoIndex: ViewModel = ViewModel()
                viewModelNoIndex.setName(viewName)
                viewModelNoIndex.setSort(viewSort)
                viewModelNoIndex.setType(viewType)
                viewModelNoIndex.setFilterCond(viewFilter)
                viewModelNoIndex.setFields(viewFields)
                viewEntryNoIndex[viewName] = viewModelNoIndex
                
                let result = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntryNoIndex)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_VIEWS_INDEX_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(viewName))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_021_Error_MissingViewType") {
                var viewEntryNoType: [String: ViewModel] = [String: ViewModel]()
                let viewModelNoType: ViewModel = ViewModel()
                viewModelNoType.setName(viewName)
                viewModelNoType.setSort(viewSort)
                viewModelNoType.setIndex(viewIndex)
                viewModelNoType.setFilterCond(viewFilter)
                viewModelNoType.setFields(viewFields)
                viewEntryNoType[viewName] = viewModelNoType
                
                let result = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntryNoType)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_VIEWS_TYPE_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(viewName))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_022_Error_InvalidViewKey") {
                let invalidKey = "INVALID_NAME"
                var viewEntryInvalidName: [String: ViewModel] = [String: ViewModel]()
                viewEntryInvalidName[invalidKey] = updateViewModel
                let result = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntryInvalidName)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INVALID_VIEWS_KEY_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%KEY", newTemplate: String(invalidKey))
                expectedError.replaceMessage(oldTemplate: "%NAME", newTemplate: String(viewName))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_023_Error_InvalidAppID") {
                var result = TestCommonHandling.awaitAsync(appModule.updateViews(TestConstant.Common.NONEXISTENT_ID, viewEntry)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                
                result = TestCommonHandling.awaitAsync(appModule.updateViews(TestConstant.Common.NEGATIVE_ID, viewEntry)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(appModule.updateViews(0, viewEntry)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_024_Error_InvalidRevision") {
                let invalidRevision = 999
                let result = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntry, invalidRevision)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_025_Error_InvalidViewType") {
                var viewEntryInvalidType: [String: ViewModel] = [String: ViewModel]()
                let viewModelInvalidType: ViewModel = ViewModel()
                viewModelInvalidType.setName(viewName)
                viewModelInvalidType.setSort(viewSort)
                viewModelInvalidType.setIndex(viewIndex)
                viewModelInvalidType.setFilterCond(viewFilter)
                viewModelInvalidType.setFields(viewFields)
                viewModelInvalidType.setType(ViewModel.ViewType.init(rawValue: "INVALID"))
                viewEntryInvalidType[viewName] = viewModelInvalidType
                
                let result = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntryInvalidType)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.MISSING_VIEWS_TYPE_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(viewName))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("test_027_Success_DefaultRevision") {
                // Get current Revision
                let getViewResponse = TestCommonHandling.awaitAsync(appModule.getViews(appId, language, isPreview)) as! GetViewsResponse
                let currentRevision = getViewResponse.getRevision()!
                
                // Update view with revision is -1 + deploy
                _ = TestCommonHandling.awaitAsync(appModule.updateViews(appId, viewEntry, -1))
                let previewApp: PreviewApp? = PreviewApp(appId, -1)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp!]))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)

                // Revision is increased by 1
                let result = TestCommonHandling.awaitAsync(appModule.getViews(appId, language, isPreview)) as! GetViewsResponse
                expect(result.getRevision()).to(equal(currentRevision + 1))
                // Views is added correctly
                let viewsList = result.getViews()
                expect(viewsList?.count).to(equal(totalOfAllView))
                
                for view in viewsList! {
                    if(view.key == viewName) {
                        expect(view.key).to(equal(viewName))
                        expect(view.value.getName()).to(equal(viewName))
                        expect(view.value.getSort()).to(equal(viewSort))
                        expect(view.value.getType()).to(equal(viewType))
                        expect(view.value.getFilterCond()).to(equal(viewFilter))
                        expect(view.value.getIndex()).to(equal(viewIndex))
                        expect(view.value.getFields()).to(equal(viewFields))
                    }
                }
            }
            
            it("Test_028_Error_WithoutManageAppPermission") {
                let appModuleWithoutPermission = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                
                let result = TestCommonHandling.awaitAsync(appModuleWithoutPermission.updateViews(appId, viewEntry, -1)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // GUEST SPACE
            it("Test_016_Success_ValidRequest_GuestSpace") {
                let getViewGuestSpaceAppResponse = TestCommonHandling.awaitAsync(appModuleGuestSpace.getViews(guestSpaceAppId, language, isPreview)) as! GetViewsResponse
                let currentRevision = getViewGuestSpaceAppResponse.getRevision()!
                
                // Update view with current revision + deploy
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateViews(guestSpaceAppId, viewGuestSpaceAppEntry, currentRevision))
                let previewGuestSpaceApp: PreviewApp? = PreviewApp(guestSpaceAppId, -1)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewGuestSpaceApp!]))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guestSpaceAppId)
                
                // Revision is increased by 1
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getViews(guestSpaceAppId, language, isPreview)) as! GetViewsResponse
                expect(result.getRevision()).to(equal(currentRevision + 1))
                // Views is added correctly
                let viewsList = result.getViews()
                expect(viewsList?.count).to(equal(totalOfAllViewGuestSpaceApp))
                
                for view in viewsList! {
                    if(view.key == viewName) {
                        expect(view.key).to(equal(viewName))
                        expect(view.value.getName()).to(equal(viewName))
                        expect(view.value.getSort()).to(equal(viewSort))
                        expect(view.value.getType()).to(equal(viewType))
                        expect(view.value.getFilterCond()).to(equal(viewFilter))
                        expect(view.value.getIndex()).to(equal(viewIndex))
                        expect(view.value.getFields()).to(equal(viewFields))
                    }
                }
            }
            
            it("Test_027_Success_DefaultRevision_GuestSpace") {
                // Get current Revision
                let getViewGuestSpaceAppResponse = TestCommonHandling.awaitAsync(appModuleGuestSpace.getViews(guestSpaceAppId, language, isPreview)) as! GetViewsResponse
                let currentRevision = getViewGuestSpaceAppResponse.getRevision()!
                
                // Update view with revision is -1 + deploy
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateViews(guestSpaceAppId, viewGuestSpaceAppEntry, -1))
                let previewGuestSpaceApp: PreviewApp? = PreviewApp(guestSpaceAppId, -1)
                _ = TestCommonHandling.awaitAsync(appModuleGuestSpace.deployAppSettings([previewGuestSpaceApp!]))
                AppUtils.waitForDeployAppSucceed(appModule: appModuleGuestSpace, appId: guestSpaceAppId)
                
                // Revision is increased by 1
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getViews(guestSpaceAppId, language, isPreview)) as! GetViewsResponse
                expect(result.getRevision()).to(equal(currentRevision + 1))
                // Views is added correctly
                let viewsList = result.getViews()
                expect(viewsList?.count).to(equal(totalOfAllViewGuestSpaceApp))
                
                for view in viewsList! {
                    if(view.key == viewName) {
                        expect(view.key).to(equal(viewName))
                        expect(view.value.getName()).to(equal(viewName))
                        expect(view.value.getSort()).to(equal(viewSort))
                        expect(view.value.getType()).to(equal(viewType))
                        expect(view.value.getFilterCond()).to(equal(viewFilter))
                        expect(view.value.getIndex()).to(equal(viewIndex))
                        expect(view.value.getFields()).to(equal(viewFields))
                    }
                }
            }
        }
    }
}
