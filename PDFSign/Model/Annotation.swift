//
//  Annotation.swift
//  PDFSign
//
//  Created by kawu on 10/20/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation
import PDFKit

class Annotation: PDFAnnotation {
    var info: BlockInfo?
}

class ImageStampAnnotation: Annotation {
    var image: UIImage? {
        didSet {
            // TODO: Trigger redraw on setting new image
            self.isHighlighted = false
        }
    }

    convenience init(_ image: UIImage?, bounds: CGRect, properties: [AnyHashable : Any]?) {
        self.init(bounds: bounds, forType: .ink, withProperties: properties)
        self.image = image
    }

    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)

        guard let cgImage = image?.cgImage else { return }

        context.draw(cgImage, in: bounds)
    }
}
