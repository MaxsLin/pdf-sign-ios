//
//  UserRequest.swift
//  PDFSign
//
//  Created by kawu on 10/20/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation

struct UserRequest {
    enum RequestType {
        case registerDevice, checkLogin, checkStaffLogin, getRunMode, getKindFlow

        func message(_ value: String) -> Any? {
            switch self {
            case .registerDevice:
                return RegisterDeviceMessage(rawValue: value)
            case .checkLogin:
                return LoginMessage(rawValue: value)
            case .getRunMode:
                return RunModeMessage(rawValue: value)
            default:
                return nil
            }
        }

        func validateResponse(_ dict: [String: Any]?) -> Response<Any> {
            switch self {
            case .checkLogin, .registerDevice, .getRunMode:
                guard
                    let success = dict?["result"] as? Bool,
                    let message = dict?["message"] as? String
                else {
                    return Response<Any>(success: false)
                }
                return Response<Any>(success: success, model: self.message(message))
            case .checkStaffLogin:
                guard
                    let success = dict?["result"] as? Bool,
                    let message = dict?["message"] as? [String: Any]
                else {
                    return Response<Any>(success: false)
                }
                let account = StaffAccount(dict: message)
                return Response<Any>(success: success, model: account)
            case .getKindFlow:
                guard
                    let success = dict?["result"] as? Bool,
                    let message = dict?["message"] as? [[String: Any]]
                else {
                    return Response<Any>(success: false)
                }

                var kindFlows: [KindFlow] = []
                for item in message {
                    let kindFlow  = KindFlow(dict: item)
                    kindFlows.append(kindFlow)
                }
                return Response<Any>(success: success, model: kindFlows)
            }
        }
    }

    enum UserError: String {
        case invalidUser = "0"
        case userNotExist = "1"
        case noRegisteredDevice = "2"
    }

    enum LoginMessage: String {
        case changePassword = "0"
        case success = "1"
        case wrongPassword = "2"
        case deviceNotRegistered = "3"
        case deviceExceededLimit = "4"
    }

    enum RegisterDeviceMessage: String {
        case success = "1"
        case deviceWasRegistered = "2"
        case deviceExceededLimit = "3"
    }

    enum RunModeMessage: String {
        case local = "0"
        case cloud = "1"
    }

    var type: RequestType

    init(type: RequestType) {
        self.type = type
    }

    func validateResponse(data: Data) -> Response<Any> {
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            let parsedJson = json as? [String: Any]

            return type.validateResponse(parsedJson)
        } catch let error {
            return Response<Any>(success: false, error: error)
        }
    }
}
