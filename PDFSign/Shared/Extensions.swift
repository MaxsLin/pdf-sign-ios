//
//  Extensions.swift
//  PDFSign
//
//  Created by kawu on 9/9/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

// MARK: - UIColor Extension

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIView {
    func addBorder(color: UIColor, width: CGFloat = 1) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }

    @discardableResult func setRoundedCorners(cornerRadius: CGFloat = 5) -> Self {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        return self
    }
}

// MARK: - FileManager Extension

extension FileManager {
    static func directoryUrl(in location: FileManager.SearchPathDirectory, path: String? = nil) -> URL? {
        let fileManager = FileManager()
        do {
            let baseUrl = try fileManager.url(for: location,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: false)

            guard let path = path else {
                return baseUrl
            }

            let directories = path.components(separatedBy: "/")
            var directoryUrl = baseUrl

            for directory in directories {
                directoryUrl = directoryUrl.appendingPathComponent(directory)

                var isDirectory: ObjCBool = ObjCBool(true)
                let directoryExists = fileManager.fileExists(atPath: directoryUrl.path, isDirectory: &isDirectory)

                if !directoryExists {
                    try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
                }
            }

            return directoryUrl
        } catch {
            print("Error: Could not get directoryUrl: \(error)")
            return nil
        }
    }
}

// MARK: - UIFont Extension

extension UIFont {
    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }

    func bold() -> UIFont {
        return withTraits(.traitBold)
    }

    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }

    private func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {

        // create a new font descriptor with the given traits
        if let fd = fontDescriptor.withSymbolicTraits(traits) {
            // return a new font with the created font descriptor
            return UIFont(descriptor: fd, size: pointSize)
        }

        // the given traits couldn't be applied, log error and return self
        print("Error: UIFont could not be attributed traits for styling: \(traits).")
        return self
    }
}

// MARK: - Date Extension

extension Date {
    enum CalendarType {
        case standard, taiwan
    }

    struct DateFormat {
        var calendar: CalendarType
        var date: String?
        var time: String?
    }

    func formattedDateString(format: DateFormat) -> String? {

        var dateFormat: String = ""
        if let date = format.date {
            dateFormat.append(date)

            if let time = format.time {
                dateFormat.append(" \(time)")
            }
        } else if let time = format.time {
            dateFormat.append(time)
        } else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8")
        dateFormatter.amSymbol = "上午"
        dateFormatter.pmSymbol = "下午"
        if format.calendar == .taiwan {
            dateFormatter.calendar = Calendar(identifier: .republicOfChina)
        }

        return dateFormatter.string(from: self)
    }

    static func getDateAndTimeStyle(format: String) -> DateFormat {
        let codes = format.split(separator: "@")

        guard codes.count == 2 else { return DateFormat(calendar: .standard, date: nil, time: nil) }

        var timeFormat: String?
        var dateFormat: String?
        var calendar: CalendarType = .standard

        if codes[1] == "1" {
            timeFormat = "HH:mm"
        } else if codes[1] == "2" {
            timeFormat = "HH:mm:ss"
        } else if codes[1] == "3" {
            timeFormat = "a hh:mm"
        } else if codes[1] == "4" {
            timeFormat = "a hh:mm:ss"
        } else {
            timeFormat = nil
        }

        if codes[0] == "1" {
            dateFormat = "yyyy/MM/dd"
        } else if codes[0] == "2" {
            dateFormat = "yyyy-MM-dd"
        } else if codes[0] == "3" {
            dateFormat = "yyyy年MM月dd日"
        } else if codes[0] == "4" {
            calendar = .taiwan
            dateFormat = "yyy/MM/dd"
        } else if codes[0] == "5" {
            calendar = .taiwan
            dateFormat = "yyy-MM-dd"
        } else if codes[0] == "6" {
            calendar = .taiwan
            dateFormat = "yyy年MM月dd日"
        } else {
            dateFormat = nil
        }

        return DateFormat(calendar: calendar, date: dateFormat, time: timeFormat)
    }
}

// MARK: - UIDatePicker Extension

extension UIDatePicker {
    func configureDateMode(info: BlockInfo) {
        let dateFormat = Date.getDateAndTimeStyle(format: info.format)
        if dateFormat.date == nil && dateFormat.time == nil {
            return
        } else {
            if dateFormat.date == nil {
                self.datePickerMode = .time
            } else if dateFormat.time == nil {
                self.datePickerMode = .date
            } else {
                self.datePickerMode = .dateAndTime
            }
        }
    }
}

// MARK: - String Extension

extension String {
    var boolValue: Bool {
        return self == "true"
    }
}

// MARK: - Dictionary Extension

extension Dictionary {
    func formatAsQueryParameters() -> String {
        var query = "?"

        for (key, value) in self where "\(value)" != "" {
            query += "\(key)=\(value)&"
        }
        query.removeLast(1)

        return query
    }
}
