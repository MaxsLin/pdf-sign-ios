//
//  PDFEditor.swift
//  PDFSign
//
//  Created by kawu on 9/17/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit
import PDFKit

class PDFEditor {
    var title: String = ""
    var pdfWidth: CGFloat = 0
    var pdfHeight: CGFloat = 0
    var pdfView: PDFView?

    convenience init(title: String, pdfWidth: CGFloat = 0, pdfHeight: CGFloat = 0) {
        self.init()
        self.title = title
        self.pdfWidth = pdfWidth
        self.pdfHeight = pdfHeight
    }

    func embed(pdfView: PDFView) {
        self.pdfView = pdfView
    }

    func generatePDF() -> Data {

        let pdfMetaData = [kCGPDFContextTitle: title]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pdfWidth, height: pdfHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
          context.beginPage()

//          let titleBottom = addTitle(pageRect: pageRect)
//          let imageBottom = addImage(pageRect: pageRect, imageTop: titleBottom + 18.0)
//          addBodyText(pageRect: pageRect, textTop: imageBottom + 18.0)

          let context = context.cgContext
//          drawTearOffs(context, pageRect: pageRect, tearOffY: pageRect.height * 4.0 / 5.0, numberTabs: 8)
//          drawContactLabels(context, pageRect: pageRect, numberTabs: 8)
        }

        return data
    }

    func insertFormFieldsInto(_ page: PDFPage, bounds: CGRect) {
        let textField = PDFAnnotation(bounds: bounds, forType: .widget, withProperties: nil)
        textField.widgetFieldType = .text
        textField.backgroundColor = UIColor.yellow
        page.addAnnotation(textField)
    }

    func insertRadioButtonsInfo(_ page: PDFPage) {

    }

    func addBlock(pageRect: CGRect) {
        
    }
}
