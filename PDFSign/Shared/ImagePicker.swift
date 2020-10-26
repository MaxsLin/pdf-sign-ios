//
//  ImagePicker.swift
//  PDFSign
//
//  Created by kawu on 9/24/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

class ImagePicker: NSObject {
    var alert: UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let camera = self.action(for: .camera, title: "Take a Photo") {
            alert.addAction(camera)
        }

        if let photoLibrary = self.action(for: .photoLibrary, title: "Photo Library") {
            alert.addAction(photoLibrary)
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        return alert
    }
    var onSelect: ((UIImage) -> Void)?

    private let pickerController = UIImagePickerController()
    private var hostVC: UIViewController

    init(hostViewController: UIViewController, allowsEditing: Bool = false) {
        hostVC = hostViewController
        super.init()

        pickerController.delegate = self
        pickerController.allowsEditing = allowsEditing
        pickerController.mediaTypes = ["public.image"]
    }

    func present() {
        hostVC.present(alert, animated: true)
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else { return nil }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.hostVC.present(self.pickerController, animated: true)
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        guard let image = info[.editedImage] as? UIImage else { return }

        onSelect?(image)
        pickerController.dismiss(animated: true, completion: nil)
    }
}

