//
//  BlockInfo.swift
//  PDFSign
//
//  Created by kawu on 9/9/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit
import Foundation

struct BlockInfo {
    enum ApiKey: String {
        case Name, blockType = "Type", Serno, KeyCol, Content, IsRequired, GroupID, Format
        case FontSize, FontFamily, FontColor, TextLimit, ChkValue, IsBgTransparent, TextAlign
        case IsFillLoginName, IsReadOnly, SignGroupID, SimpleUISeq, SimpleUIDisplay
        case X, Y, W, H, XW, YH
    }

    enum TextAlign: String {
        case left, center, right, none
    }

    enum FieldType: String {
        case text, check, customDate = "cusDate", fixDate, image, attachment = "attach", sign
    }

    static let defaultFontSize: Int = 32
    static let defaultTextLimit: Int = 16
    static let invalidValue: Int = -1

    var name: String = ""
    var type: FieldType = .text
    var serno: Int = 1
    var isKeyColumn: Bool = false
    var content: String = ""
    var isRequired: Bool = false
    var groupId: String = ""
    var format: String = ""
    var fontSize: Int = defaultFontSize
    var fontFamily: String = ""
    var fontColor: UIColor = .black
    var textLimit: Int = defaultTextLimit
    var chkValue: String = ""
    var isBgTransparent: Bool = false
    var textAlign: TextAlign = .none
    var isFilledLoginName: Bool = false
    var isReadOnly: Bool = false
    var signGroupId: String = ""
    var simpleUISequence: Int = invalidValue
    var simpleUIDisplayable: Bool = false

    var highlightColor: UIColor {
        return isRequired ? UIColor.blue.withAlphaComponent(0.2) : UIColor.lightGray.withAlphaComponent(0.2)
    }

    // Coordinate
    var X: Double = 0
    var Y: Double = 0
    var W: Double = 0
    var H: Double = 0
    var XW: Double = 0
    var YH: Double = 0

    init(dict: [String: Any]) {
        self.name = dict[ApiKey.Name.rawValue] as? String ?? ""
        self.serno = dict[ApiKey.Serno.rawValue] as? Int ?? 1
        self.content = dict[ApiKey.Content.rawValue] as? String ?? ""
        self.groupId = dict[ApiKey.GroupID.rawValue] as? String ?? ""
        self.format = dict[ApiKey.Format.rawValue] as? String ?? ""
        self.fontSize = dict[ApiKey.FontSize.rawValue] as? Int ?? BlockInfo.defaultFontSize
        self.fontFamily = dict[ApiKey.FontFamily.rawValue] as? String ?? ""
        self.textLimit = dict[ApiKey.TextLimit.rawValue] as? Int ?? BlockInfo.defaultTextLimit
        self.chkValue = dict[ApiKey.ChkValue.rawValue] as? String ?? ""
        self.signGroupId = dict[ApiKey.SignGroupID.rawValue] as? String ?? ""
        self.simpleUISequence = dict[ApiKey.SimpleUISeq.rawValue] as? Int ?? BlockInfo.invalidValue

        self.X = dict[ApiKey.X.rawValue] as? Double ?? 0
        self.Y = dict[ApiKey.Y.rawValue] as? Double ?? 0
        self.W = dict[ApiKey.W.rawValue] as? Double ?? 0
        self.H = dict[ApiKey.H.rawValue] as? Double ?? 0
        self.XW = dict[ApiKey.XW.rawValue] as? Double ?? 0
        self.YH = dict[ApiKey.YH.rawValue] as? Double ?? 0


        if let typeString = dict[ApiKey.blockType.rawValue] as? String, let fieldType = FieldType(rawValue: typeString) {
            self.type = fieldType
        }

        if let isKey = dict[ApiKey.KeyCol.rawValue] as? Int {
            self.isKeyColumn = isKey == 1
        }

        if let isRequired = dict[ApiKey.IsRequired.rawValue] as? Int {
            self.isRequired = isRequired == 1
        }

        if let hex = dict[ApiKey.FontColor.rawValue] as? String, let color = UIColor(hex: hex) {
            self.fontColor = color
        }

        if let bgTransparent = dict[ApiKey.IsBgTransparent.rawValue] as? Int {
            self.isBgTransparent = bgTransparent == 1
        }

        if let textAlignString = dict[ApiKey.TextAlign.rawValue] as? String, let textAlign = TextAlign(rawValue: textAlignString) {
            self.textAlign = textAlign
        }

        if let isFilled = dict[ApiKey.IsFillLoginName.rawValue] as? Int {
            self.isFilledLoginName = isFilled == 1
        }

        if let readOnly = dict[ApiKey.IsReadOnly.rawValue] as? Int {
            self.isReadOnly = readOnly == 1
        }

        if let displayable = dict[ApiKey.SimpleUIDisplay.rawValue] as? Int {
            self.simpleUIDisplayable = displayable == 1
        }
    }
}
