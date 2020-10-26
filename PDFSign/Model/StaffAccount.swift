//
//  StaffAccount.swift
//  PDFSign
//
//  Created by kawu on 10/20/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation

struct StaffAccount {
    let name: String
    let email: String
    let phone: String
    let expireIn: Int // Minutes

    init(name: String, email: String, phone: String, expireIn: Int) {
        self.name = name
        self.email = email
        self.phone = phone
        self.expireIn = expireIn
    }

    init(dict: [String: Any]) {
        self.name = dict["name"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.phone = dict["phone"] as? String ?? ""
        self.expireIn = dict["logoutTime"] as? Int ?? 0
    }
}
