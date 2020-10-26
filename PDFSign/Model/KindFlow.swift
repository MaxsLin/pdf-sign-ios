//
//  KindFlow.swift
//  PDFSign
//
//  Created by kawu on 10/20/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation

struct KindFlow {
    let kindId: String
    let kindName: String
    var forms: [FormInfo] = []

    init(kindId: String, kindName: String, forms: [FormInfo]) {
        self.kindId = kindId
        self.kindName = kindName
        self.forms = forms
    }

    init(dict: [String: Any]) {
        self.kindId = dict["kindID"] as? String ?? ""
        self.kindName = dict["kindName"] as? String ?? ""

        if let pdfList = dict["pdfList"] as? [[String: Any]] {
            pdfList.forEach({ forms.append(FormInfo(dict: $0)) })
        }
    }
}
