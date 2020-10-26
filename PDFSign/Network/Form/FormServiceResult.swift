//
//  FormServiceResult.swift
//  PDFSign
//
//  Created by kawu on 10/20/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation

protocol FormServiceResult {
    mutating func set(element: String, value: String)
}

struct CheckFileResult: FormServiceResult {
    enum ApiKey: String {
        case fileurl, guid, ishave, nowcount, totalcount
    }

    var fileURL: String = ""
    var guid: String = ""
    var isHave: Bool = false
    var nowCount: Int = 0
    var totalCount: Int = 0

    mutating func set(element: String, value: String) {
        if element.contains(ApiKey.fileurl.rawValue) {
            self.fileURL = value
        } else if element.contains(ApiKey.guid.rawValue) {
            self.guid = value
        } else if element.contains(ApiKey.fileurl.rawValue) {
            self.isHave = value.boolValue
        } else if element.contains(ApiKey.nowcount.rawValue) {
            self.nowCount = Int(value) ?? 0
        } else if element.contains(ApiKey.totalcount.rawValue) {
            self.totalCount = Int(value) ?? 0
        }
    }
}

struct GetDataResult: FormServiceResult {
    enum ApiKey: String {
        case Filedatas, Status
    }

    var dataString: String = ""
    var Status: String = ""

    mutating func set(element: String, value: String) {
        if element.contains(ApiKey.Filedatas.rawValue) {
            self.dataString = value
        } else if element.contains(ApiKey.Status.rawValue) {
            self.Status = value
        }
    }
}

struct GetAreaByFormIDResult: FormServiceResult {
    enum ApiKey: String {
        case result, message
    }

    var success: Bool = false
    var pdfDetails: PDFDetails?

    mutating func set(element: String, value: String) {
         guard
            let data = value.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let success = dict["result"] as? Bool,
            let message = dict["message"] as? [String: Any]
        else {
            return
        }
        self.success = success
        self.pdfDetails = PDFDetails(dict: message)
    }
}
