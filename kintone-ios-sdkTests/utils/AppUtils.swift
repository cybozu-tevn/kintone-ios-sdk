@testable import Promises
@testable import kintone_ios_sdk

class AppUtils {
    static let auth = DevAuth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
    static let conn = DevConnection(TestConstant.Connection.DOMAIN, auth)
    static let devAppModule = DevApp(conn)
    
    static func _waitForDeployAppSucceed(appModule: App, appId: Int) {
        var isDeployed = false
        while (!isDeployed) {
            appModule.getAppDeployStatus([appId])
                .then { response in
                    let status = response.getApps()![0].getStatus()?.rawValue
                    // print("Deploying app status \(String(describing: status))")
                    
                    if(status == AppDeployStatus.Status.SUCCESS.rawValue) {
                        isDeployed = true
                    }
                }.catch { error in
                    if let errorVal = error as? KintoneAPIException {
                        fatalError(errorVal.toString()!)
                    } else {
                        fatalError(error.localizedDescription)
                    }
            }
            _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        }
    }
    
    static func _deployApp(appModule: App, apps: [PreviewApp]) {
        var appIds = [Int]()
        appModule.deployAppSettings(apps)
            .then {
                for app in apps {
                    appIds.append(app.getApp()!)
                    print("Deploying app: \(app.getApp()!)")
                }
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        
        for id in appIds {
            self._waitForDeployAppSucceed(appModule: appModule, appId: id)
        }
    }
    
    static func createApp(appModule: App, appName: String = "App created by kintone-ios-sdk test scripts", spaceId: Int? = nil, threadId: Int? = nil) -> Int {
        var apps = [PreviewApp]()
        var appId: Int!
        appModule.addPreviewApp(appName, spaceId, threadId)
            .then { response in
                apps.append(response)
                appId = response.getApp()
                print("Creating app: \(response.getApp()!)")
            }.catch { error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self._deployApp(appModule: appModule, apps: apps)
        return appId
    }
    
    static func createApps(appModule: App, appName: String = "App created by kintone-ios-sdk test scripts", spaceId: Int? = nil, threadId: Int? = nil, amount: Int = 1) -> [Int] {
        var apps = [PreviewApp]()
        var appIds = [Int]()
        for index in 0...amount-1 {
            appModule.addPreviewApp(appName + String(index), spaceId, threadId)
                .then {response in
                    apps.append(response)
                    appIds.append(response.getApp()!)
                    print("Creating app: \(response.getApp()!)")
                }.catch {error in
                    if let errorVal = error as? KintoneAPIException {
                        fatalError(errorVal.toString()!)
                    } else {
                        fatalError(error.localizedDescription)
                    }
            }
            _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        }
        self._deployApp(appModule: appModule, apps: apps)
        return appIds
    }
    
    static func deleteApp(appId: Int) {
        self.devAppModule.deleteApp(appId)
            .then { _ in
                // print("Delete app: \(appId)")
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
    }
    
    static func deleteApps(appIds: [Int]) {
        for appId in appIds {
            self.deleteApp(appId: appId)
        }
    }
    
    static func getListAPIsToken(_ appId: Int) -> [ApiToken] {
        var apiTokens = [ApiToken]()
        devAppModule.getListAPIsToken(appId)
            .then {response in
                apiTokens = response.getResult().getItems()
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return apiTokens
    }
    
    /// <#Description#>
    /// Generate a API token without permission
    /// - Parameters:
    ///   - appModule: appModule description
    ///   - appId: Id of app
    /// - Returns: String
    static func generateToken(_ appModule: App, _ appId: Int) -> String {
        //When update an API Token, it should update other existed tokens
        var apiToken: String!
        let getListAPIsTokenResponse = self.getListAPIsToken(appId)
        var tokens = [TokenEntity]()
        for item in getListAPIsTokenResponse {
            tokens.append(item.getToken())
        }
        devAppModule.generateAPIToken(appId).then {response -> Promise<Void> in
            apiToken = response.getResult().getItem()
            tokens.append(TokenEntity(tokenString: apiToken))
            print("Generate API Token app \(appId): \(apiToken!)")
            return devAppModule.updateAPIToken(appId, tokens)
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self._deployApp(appModule: appModule, apps: [PreviewApp(appId)])
        return apiToken
    }
    
    static func updateTokenPermission(appModule: App, appId: Int, token: TokenEntity) {
        //When update an API Token, it should update other existed tokens
        let getListAPIsTokenResponse = self.getListAPIsToken(appId)
        var tokens = [TokenEntity]()
        for item in getListAPIsTokenResponse {
            if(item.getToken().getTokenString() != token.getTokenString()) {
                tokens.append(item.getToken())
            }
        }
        tokens.append(token)
        devAppModule.updateAPIToken(appId, tokens)
            .then {
                print("""
                    ==========================================================================
                    Update permission for API Token in app \(appId): \(token.getTokenString())
                    View Record: \(token.getViewRecord())
                    Add Record: \(token.getAddRecord())
                    Edit Record: \(token.getEditRecord())
                    Delete Record: \(token.getDeleteRecord())
                    Edit App: \(token.getEditApp())
                    ==========================================================================
                    """)
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self._deployApp(appModule: appModule, apps: [PreviewApp(appId)])
    }
    
    static func getAppPermissions(appId: Int) -> [UserRightEntity] {
        var userRights = [UserRightEntity]()
        devAppModule.getAppPermissions(appId).then {response in
            userRights = response.getRights()
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        return userRights
    }
    
    static func updateAppPermissions(appModule: App, appId: Int, userRight: UserRightEntity) -> String {
        //When update permission, it should update other existed rights
        var revision: String!
        var userRights = self.getAppPermissions(appId: appId)
        userRights.append(userRight)
        devAppModule.updateAppPermissions(appId, userRights).then {response in
            print("""
                ==========================================================================
                Update permission for \(userRight.getDevMember().getCode()) in app \(appId):
                Record Viewable: \(userRight.getRecordViewable())
                Record Addable: \(userRight.getRecordAddable())
                Record Editable: \(userRight.getRecordEditable())
                Record Deleteable: \(userRight.getRecordDeletable())
                Record Importable: \(userRight.getRecordImportable())
                Record Exportable: \(userRight.getRecordExportable())
                App Editable: \(userRight.getAppEditable())
                ==========================================================================
                """)
            revision = response.getRevision()
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self._deployApp(appModule: appModule, apps: [PreviewApp(appId)])
        return revision
    }
    
    static func updateMiscSetting(appModule: App,
                                  code: String,
                                  id: Int,
                                  name: String,
                                  decimalPrecision: Int = 16,
                                  decimalScale: Int = 4,
                                  enableBulkDeletion: Bool = false,
                                  fiscalYearStartMonth: Int = 4,
                                  roundingMode: String = "HALF_EVEN",
                                  useComment: Bool = true,
                                  useHistory: Bool = true,
                                  useThumbnail: Bool = true) {
        devAppModule.updateMiscSettings(code: code, id: id, name: name).then {
            print("""
                ==========================================================================
                Update misc settings in app \(id):
                code: \(code)
                decimalPrecision: \(decimalPrecision)
                decimalScale: \(decimalScale)
                enableBulkDeletion: \(enableBulkDeletion)
                fiscalYearStartMonth: \(fiscalYearStartMonth)
                roundingMode: \(roundingMode)
                useComment: \(useComment)
                useHistory: \(useHistory)
                useThumbnail: \(useThumbnail)
                ==========================================================================
                """)
            }.catch {error in
                if let errorVal = error as? KintoneAPIException {
                    fatalError(errorVal.toString()!)
                } else {
                    fatalError(error.localizedDescription)
                }
        }
        _ = waitForPromises(timeout: TestConstant.Common.PROMISE_TIMEOUT)
        self._deployApp(appModule: appModule, apps: [PreviewApp(id)])
    }
}
