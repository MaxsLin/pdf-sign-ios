//
//  UserService.swift
//  PDFSign
//
//  Created by kawu on 8/10/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit
import Foundation

class Response<T> {
    var success: Bool = false
    var json: Any?
    var error: Error?
    var model: T?
    var taskError: Error?

    init(success: Bool, json: Any? = nil, error: Error? = nil, model: T? = nil, taskError: Error? = nil) {
        self.success = success
        self.json = json
        self.error = error
        self.model = model
        self.taskError = taskError
    }
}

class NetworkService: NSObject {
    enum NetworkError: Error {
        case noData
        case conversionFailed
        case invalidResponseFormat
        case preparingRequestFailed
        case timeout
    }
}

class UserService: NetworkService {

    static let deviceID: String = "F4GT1C2YHG6X"
    static var deviceId: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    static var custId: String?

    var onResponse: ((Response<Any>) -> Void)?
    var request: UserRequest?

    // checkLogin(identity: "IhV/S8wcPnDjxcceoG48PzNQ5DEo9Q3ma7hiaGd3vZA=", pwd: "D5E2g+j7/uGWqWGWDKpBuA==")
    func checkLogin(custId: String, password: String) {
        self.request = UserRequest(type: .checkLogin)

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")
//        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceId ?? "")|\(custId)")
        let pwd = Encryption.encrypt(sourceText: password)

        // SOAP message
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "checkLogin"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><checkLogin xmlns ='http://tempuri.org/'><identity>\(identity)</identity><pwd>\(pwd)</pwd></checkLogin></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("checkLogin failure: \(error)")
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()

//                let parsedJson = try? JSONSerialization.jsonObject(with: data, options: [])
//                guard let json = parsedJson as? NSDictionary else {
//                    return .failure(NetworkError.conversionFailed)
//                    return
//                }
            }
        }
        task.resume()
    }

    func checkStaffLogin(custId: String, accountId: String, password: String) {
        self.request = UserRequest(type: .checkStaffLogin)

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")
        let pwd = Encryption.encrypt(sourceText: password)

        // SOAP message
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "checkStaffLogin"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><checkStaffLogin xmlns ='http://tempuri.org/'><identity>\(identity)</identity><accountID>\(accountId)</accountID><pwd>\(pwd)</pwd></checkStaffLogin></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("checkStaffLogin failure: \(error)")
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        }
        task.resume()
    }

    func changeStaffPassword(custId: String, accountId: String, password: String) {

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")
        let pwd = Encryption.encrypt(sourceText: password)

        // SOAP message
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "changeStaffPwd"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><changeStaffPwd xmlns ='http://tempuri.org/'><identity>\(identity)</identity><accountID>\(accountId)</accountID><pwd>\(pwd)</pwd></changeStaffPwd></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("checkStaffLogin failure: \(error)")
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        }
        task.resume()
    }

    // registerDevice(identity: "jNf+e6+7WEDfjjzAVEV67A==", deviceInfo: [:])
    func registerDevice(custId: String) {
        self.request = UserRequest(type: .registerDevice)

        let identity = Encryption.encrypt(sourceText: "000|\(custId)")
        let info = ["deviceID": "F4GT1C2YHG6X",// UserService.deviceId,
                    "deviceName": "",
                    "operatingSys": "1",
                    "brand": "apple",
                    "model": "",
                    "custID": custId]
        let json = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted)
        let infoString = String(data: json ?? Data(), encoding: .ascii)
        // SOAP message
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "registerDevice"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><registerDevice xmlns ='http://tempuri.org/'><identity>\(identity)</identity><deviceInfo>\(infoString!)</deviceInfo></registerDevice></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("registerDevice failure: \(error)")
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    func getRunMode(custId: String) {
        self.request = UserRequest(type: .registerDevice)

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")

        // SOAP message
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "getRunMode"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><getRunMode xmlns ='http://tempuri.org/'><identity>\(identity)</identity></getRunMode></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("registerDevice failure: \(error)")
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    func getKindFlow(custId: String) {
        self.request = UserRequest(type: .getKindFlow)

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")

        // SOAP message
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "getKindFlowByCustID"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><getKindFlowByCustID xmlns ='http://tempuri.org/'><identity>\(identity)</identity><custID>\(custId)</custID></getKindFlowByCustID></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("getKindFlow failure: \(error)")
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    var parsedResult: String = ""
}

extension UserService: XMLParserDelegate {

    func parserDidStartDocument(_ parser: XMLParser) {
        parsedResult = ""
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        guard let data = parsedResult.data(using: .utf8),
            let response = request?.validateResponse(data: data)
        else {
            onResponse?(Response<Any>(success: false))
            return
        }
        onResponse?(response)
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parser error: \(parseError.localizedDescription)")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        guard
//            let data = string.data(using: .utf8)
//            let response = request?.validateResponse(data: data)
//        else {
//            onResponse?(Response<Any>(success: false))
//            return
//        }
        parsedResult.append(string)
    }
}
