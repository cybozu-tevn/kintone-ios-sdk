//
//  DevAppApp.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/24/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//
import Foundation
import Promises
import kintone_ios_sdk
public protocol DevAppApp {
    
}
let baseDevUrl = "/k/api/dev/{API_NAME}.json"
let baseUrl = "/k/v1/{API_NAME}.json"

public extension DevAppApp where Self:DevApp {
    
    func addSpace(idTemplate: Int, name: String, members: [MemberSpace], isGuest: Bool = false, isPrivate: Bool = false) -> Promise<AddSpaceResponse> {
        return Promise<AddSpaceResponse> {fulfill, reject in
            do {
                let addSpaceRequest = AddSpaceRequest(idTemplate, name, members, isGuest, isPrivate)
                let body = try self.parser.parseObject(addSpaceRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseUrl, "POST", "template/space", jsonBody).then{response in
                    let addSpaceResponse = try self.parser.parseJson(AddSpaceResponse.self, response)
                    fulfill(addSpaceResponse)
                    }.catch {error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func deleteSpace(_ id: Int, _ guestSpaceId: Int = -1) -> Promise<Void> {
        return Promise<Void> {fulfill, reject in
            do {
                let deleteSpaceRequest = DeleteSpaceRequest(id)
                let body = try self.parser.parseObject(deleteSpaceRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                if(guestSpaceId != -1) {
                    self.devConnection?.request("/k/guest/\(guestSpaceId)/v1/{API_NAME}.json", "DELETE", "space", jsonBody).then{response in
                        fulfill(())
                        }.catch {error in
                            reject(error)
                    }
                } else {
                    self.devConnection?.request(baseUrl, "DELETE", "space", jsonBody).then{response in
                        fulfill(())
                        }.catch {error in
                            reject(error)
                    }
                }
                
            }catch {
                reject(error)
            }
        }
    }
    
    func deleteApp(_ appId: Int)  -> Promise<Void> {
        
        // execute DELETE RECORDS API
        return Promise<Void> { fulfill, reject in
            do {
                let deleteAppRequest = DeleteAppRequest(appId)
                let body = try self.parser.parseObject(deleteAppRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseDevUrl, "POST", "app/delete", jsonBody).then{response in
                    fulfill(())
                    }.catch { error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func getListAPIsToken(_ appId: Int) -> Promise<GetListAPIsTokenResponse> {
        return Promise<GetListAPIsTokenResponse> {fulfill, reject in
            do  {
                let getListAPIsTokenRequest = GetListAPIsTokenRequest(appId)
                let body = try self.parser.parseObject(getListAPIsTokenRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseDevUrl, "POST", "app/token/list", jsonBody).then{response in
                    let parseResponseToJson = try self.parser.parseJson(GetListAPIsTokenResponse.self, response)
                    fulfill(parseResponseToJson)
                    }.catch{error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func generateAPIToken(_ appId: Int) -> Promise<GenerateAPITokenResponse> {
        return Promise<GenerateAPITokenResponse> {fulfill, reject in
            do  {
                let generateAPITokenRequest = GenerateAPITokenRequest(appId)
                let body = try self.parser.parseObject(generateAPITokenRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseDevUrl, "POST", "app/token/generate", jsonBody).then{response in
                    let parseResponseToJson = try self.parser.parseJson(GenerateAPITokenResponse.self, response)
                    fulfill(parseResponseToJson)
                    }.catch{error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func updateAPIToken(_ appId: Int, _ tokens: [Token]) -> Promise<Void> {
        return Promise<Void> {fulfill, reject in
            do  {
                let updateAPITokenRequest = UpdateAPITokenRequest(appId, tokens)
                let body = try self.parser.parseObject(updateAPITokenRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseDevUrl, "POST", "app/token/update", jsonBody).then{response in
                    fulfill(())
                    }.catch{error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func getAppPermissions(_ appId: Int, _ isPreview: Bool? = false) -> Promise<GetAppPermissionsResponse> {
        return Promise<GetAppPermissionsResponse> {fulfill, reject in
            do {
                let getAppPermissionsRequest = GetAppPermissionsRequest(appId)
                let body = try self.parser.parseObject(getAppPermissionsRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                let url = (isPreview! ? "preview/app/acl" : "app/acl")
                self.devConnection?.request(baseUrl, "GET", url, jsonBody).then {response in
                    let getAppPermissionResponse = try self.parser.parseJson(GetAppPermissionsResponse.self, response)
                    fulfill(getAppPermissionResponse)
                    }.catch {error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func updateAppPermissions(_ appId: Int, _ rights: [Right]) -> Promise<UpdateAppPermissionsResponse> {
        return Promise<UpdateAppPermissionsResponse> {fulfill, reject in
            do {
                let updateAppPermissionsRequest = UpdateAppPermissionsRequest(appId, rights)
                let body = try self.parser.parseObject(updateAppPermissionsRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseUrl, "PUT", "app/acl", jsonBody).then{response in
                    let parseResponseToJson = try self.parser.parseJson(UpdateAppPermissionsResponse.self, response)
                    fulfill(parseResponseToJson)
                    }.catch {error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
    
    func updateMiscSettings(code: String, id: Int, name: String, decimalPrecision: Int = 16, decimalScale: Int = 4, enableBulkDeletion: Bool = false, fiscalYearStartMonth: Int = 4, roundingMode: String = "HALF_EVEN", useComment: Bool = true, useHistory: Bool = true, useThumbnail: Bool = true) -> Promise<Void> {
        return Promise<Void> {fulfill, reject in
            do  {
                let updateMiscSettingsRequest = UpdateMiscSettingsRequest(code: code, id: id, name: name, decimalPrecision: decimalPrecision, decimalScale: decimalScale, enableBulkDeletion: enableBulkDeletion, fiscalYearStartMonth: fiscalYearStartMonth, roundingMode: roundingMode, useComment: useComment, useHistory: useHistory, useThumbnail: useThumbnail)
                let body = try self.parser.parseObject(updateMiscSettingsRequest)
                let jsonBody = String(data: body, encoding: .utf8)!
                self.devConnection?.request(baseDevUrl, "POST", "app/update", jsonBody).then{response in
                    fulfill(())
                    }.catch{error in
                        reject(error)
                }
            }catch {
                reject(error)
            }
        }
    }
}
