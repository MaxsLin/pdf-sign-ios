//
//  PDFViewerVC.swift
//  PDFSign
//
//  Created by kawu on 9/14/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit
import PDFKit
import UberSignature

class PDFViewerVC: UIViewController {

    var folderpath: URL?
    var form: FormInfo?
    var pdfDetails: PDFDetails?
    var pdfHeightScale: CGFloat = 0
    var pdfWidthScale: CGFloat = 0
    var pdfDocument: PDFDocument?
    var currentPage: PDFPage? {
        return pdfDocument?.page(at: 0)
    }
    var highlights: [Annotation] = []
    var selectedAnnotation: Annotation?

    private let formService = FormService()
    private let nextPageButton = UIButton(type: .system)
    private let prevPageButton = UIButton(type: .system)
    private let attachmentButton = UIButton(type: .system)
    private let pdfView = PDFView()
    private let thumbnailView = PDFThumbnailView()
    private let editor = PDFEditor()
    private let datePicker = UIDatePicker()
    private var signature: UIImage?
    private var imagePicker: ImagePicker?

    convenience init(folderpath: URL, formInfo: FormInfo) {
        self.init()

        self.folderpath = folderpath
        self.form = formInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    func reloadForm() {
        guard let pdfURL = form?.localArchivedURL else { return }

        pdfDocument = PDFDocument(url: pdfURL)
        pdfView.document = pdfDocument
        pdfView.minScaleFactor = 1.0
        pdfView.autoScales = true
    }

    func loadFormData() {
        guard let path = folderpath, let details = pdfDetails else { return }

        pdfDocument = PDFDocument()

        for (index, page) in details.pages.enumerated() {
            let pdfURL = path.appendingPathComponent(page.pageFilename)

            do {
                let imageData = try Data(contentsOf: pdfURL)

                if let image = UIImage(data: imageData), let pdfPage = PDFPage(image: image) {
                    pdfDocument?.insert(pdfPage, at: index)
                }
            } catch let error {
                print("Failed to retrieve image data: \(error.localizedDescription)")
            }
        }

        pdfView.document = pdfDocument
        pdfView.minScaleFactor = 1.0
        pdfView.autoScales = true
    }

    func loadFormDetails() {
        guard let custId = UserService.custId, let formId = form?.pdfId else { return }

        formService.onResponse = { [weak self] (response) in
            guard let result = response.model as? GetAreaByFormIDResult,
                result.success,
                let pdfDetails = result.pdfDetails
            else {
                print("Failed to retrieve PDF details.")
                return
            }
            self?.pdfDetails = pdfDetails

            for (index, pageDetails) in pdfDetails.pages.enumerated() {
                DispatchQueue.main.async {
                    self?.loadFormData()

                    guard let page = self?.pdfDocument?.page(at: index) else { return }

                    pageDetails.blocks.forEach({ self?.configureBlock($0, page: page) })
                }
            }
        }
        formService.getFormArea(custId: custId, formId: formId)
    }

    func configureBlock(_ info: BlockInfo, page: PDFPage) {
        insertHighlightInto(page, info: info)

        switch info.type {
        case .text:
            insertTextFieldInto(page, info: info)
        case .check:
            insertCheckBoxInto(page, info: info)
        case .sign:
            insertSignatureField(page, info: info)
        case .fixDate:
            insertDateFieldInto(page, info: info)
        case .customDate:
            insertCustomDateField(page, info: info)
        case .image:
            insertImageFieldInto(page, info: info)
        default:
            break
        }
    }

    func insertTextFieldInto(_ page: PDFPage, info: BlockInfo, isMultiline: Bool = false) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let textField = Annotation(bounds: bounds, forType: .widget, withProperties: nil)
        textField.widgetFieldType = .text
        textField.fieldName = info.name
        textField.isMultiline = isMultiline
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.font = UIFont.systemFont(ofSize: CGFloat(info.fontSize))
        textField.fontColor = info.fontColor
        page.addAnnotation(textField)
    }

    func insertCheckBoxInto(_ page: PDFPage, info: BlockInfo) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let checkBox = Annotation(bounds: bounds, forType: .widget, withProperties: nil)
        checkBox.widgetFieldType = .button
        checkBox.widgetControlType = .checkBoxControl
        checkBox.fieldName = String(info.name.dropLast(info.chkValue.count))
        checkBox.buttonWidgetStateString = info.chkValue
        page.addAnnotation(checkBox)
    }

    func insertRadioButton(_ page: PDFPage, info: BlockInfo) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let button = Annotation(bounds: bounds, forType: .widget, withProperties: nil)
        button.widgetFieldType = .button
        button.widgetControlType = .radioButtonControl
        button.fieldName = String(info.name.dropLast(info.chkValue.count))
        button.buttonWidgetStateString = info.chkValue
        page.addAnnotation(button)
    }

    func insertSignatureField(_ page: PDFPage, info: BlockInfo) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let annotation = ImageStampAnnotation(nil, bounds: bounds, properties: nil)
        annotation.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        annotation.fieldName = info.name
        annotation.info = info
        page.addAnnotation(annotation)

        let rect = pdfView.convert(bounds, from: page)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnSignatureBlock(_:)))
        let view = UIView(frame: rect)
        view.backgroundColor = .clear
        view.addGestureRecognizer(tap)
        pdfView.addSubview(view)
    }

    func insertDateFieldInto(_ page: PDFPage, info: BlockInfo) {
        let date = Date().formattedDateString(format: Date.getDateAndTimeStyle(format: info.format))
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let field = Annotation(bounds: bounds, forType: .widget, withProperties: nil)
        field.widgetFieldType = .text
        field.widgetStringValue = date
        field.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        field.font = UIFont.systemFont(ofSize: CGFloat(info.fontSize))
        field.fieldName = info.name
        field.isReadOnly = true
        page.addAnnotation(field)
    }

    func insertCustomDateField(_ page: PDFPage, info: BlockInfo) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let annotation = Annotation(bounds: bounds, forType: .widget, withProperties: nil)
        annotation.widgetFieldType = .text
        annotation.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        annotation.font = UIFont.systemFont(ofSize: CGFloat(info.fontSize))
        annotation.fieldName = info.name
        annotation.info = info
        page.addAnnotation(annotation)

        let rect = pdfView.convert(bounds, from: page)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnDateBlock(_:)))
        let view = UITextField(frame: rect)
        view.inputView = datePicker
        view.backgroundColor = .clear
        view.addGestureRecognizer(tap)
        pdfView.addSubview(view)
    }

    func insertImageFieldInto(_ page: PDFPage, info: BlockInfo) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let annotation = ImageStampAnnotation(nil, bounds: bounds, properties: nil)
        annotation.fieldName = info.name
        annotation.info = info
        page.addAnnotation(annotation)

        let rect = pdfView.convert(bounds, from: page)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnImageBlock(_:)))
        let view = UIView(frame: rect)
        view.backgroundColor = .clear
        view.addGestureRecognizer(tap)
        pdfView.addSubview(view)
    }

    func insertHighlightInto(_ page: PDFPage, info: BlockInfo) {
        let pageBounds = page.bounds(for: .cropBox)
        let bounds = CGRect(x: info.X, y: Double(pageBounds.size.height) - info.H, width: info.XW, height: info.YH)
        let highlight = Annotation(bounds: bounds, forType: .highlight, withProperties: nil)
        highlight.fieldName = info.name
        highlight.color = info.highlightColor
        page.addAnnotation(highlight)
        highlights.append(highlight)
    }

    private func saveForm() {
        guard let path = folderpath, let document = pdfDocument, var form = form else { return }

        do {
            let pdfURL = path.appendingPathComponent(form.filename)
            print("Saving PDF to URL: \(pdfURL)")
            try document.dataRepresentation()?.write(to: pdfURL)
            form.localArchivedURL = pdfURL
            DownloadManager.shared.savedDocument[form.filename] = form
        } catch let error {
            print("Failed to write PDF: \(error.localizedDescription)")
        }

//        guard let custId = UserService.custId else { return }
//
//        formService.checkArchiveFile(custId: custId, filename: form.filename)
    }

    private func removeHighlights(_ highlights: [PDFAnnotation], in page: PDFPage) {
        highlights.forEach({ page.removeAnnotation($0) })
    }

    private func setupViews() {
        thumbnailView.thumbnailSize = CGSize(width: 50, height: 50)
        thumbnailView.layoutMode = .horizontal
        thumbnailView.pdfView = pdfView

        view.backgroundColor = .white
        view.addSubview(pdfView)
        view.addSubview(thumbnailView)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneEditing))

        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)

        imagePicker = ImagePicker(hostViewController: self, allowsEditing: true)

        let bottomBarView = UIView()
        bottomBarView.backgroundColor = .white
        view.addSubview(bottomBarView)

        attachmentButton.addTarget(self, action: #selector(onSelectAttachment), for: .touchUpInside)
        attachmentButton.setImage(UIImage(systemName: "folder.badge.plus"), for: .normal)
        bottomBarView.addSubview(attachmentButton)

        pdfView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(thumbnailView.snp.top)
        }

        thumbnailView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBarView.snp.top)
            make.height.equalTo(50)
        }

        bottomBarView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        attachmentButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(30)
        }
    }

    @objc private func onSelectAttachment() {
        imagePicker?.onSelect = { [weak self] (image) in
            guard let page = PDFPage(image: image), let document = self?.pdfDocument else { return }

            document.insert(page, at: document.pageCount)
        }
        imagePicker?.present()
    }

    @objc private func onDismiss() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func onDoneEditing() {
        guard let document = pdfDocument else { return }

        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { return }

            removeHighlights(highlights, in: page)
        }
        saveForm()
        dismiss(animated: true, completion: nil)
    }

    @objc private func onSimpleEditForm() {
        guard let details = pdfDetails else { return }

        let vc = PDFSimpleEditorVC(pdfDetails: details)
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }

    @objc private func didTapOnImageBlock(_ sender: UITapGestureRecognizer?) {
        if let point = sender?.location(in: pdfView),
            let page = currentPage,
            let annotation = page.annotation(at: pdfView.convert(point, to: page)) as? ImageStampAnnotation
        {
            selectedAnnotation = annotation
            imagePicker?.onSelect = { [weak self] (image) in
                guard let imageAnnotation = self?.selectedAnnotation as? ImageStampAnnotation else { return }

                imageAnnotation.image = image
            }
            imagePicker?.present()
        }
    }

    @objc private func didTapOnSignatureBlock(_ sender: UITapGestureRecognizer?) {
        if let point = sender?.location(in: pdfView),
            let page = currentPage,
            let annotation = page.annotation(at: pdfView.convert(point, to: page)) as? ImageStampAnnotation
        {
            selectedAnnotation = annotation

            let vc = SignatureVC()
            vc.delegate = self
            let controller = UINavigationController(rootViewController: vc)
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        }
    }

    @objc private func didTapOnDateBlock(_ sender: UITapGestureRecognizer?) {
        if let point = sender?.location(in: pdfView),
            let page = currentPage,
            let annotation = page.annotation(at: pdfView.convert(point, to: page)) as? Annotation,
            let info = annotation.info,
            info.type == .customDate
        {
            selectedAnnotation = annotation
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .compact
            }
            datePicker.configureDateMode(info: info)
            sender?.view?.becomeFirstResponder()
        }
    }

    @objc private func didChangeDate() {
        guard let format = selectedAnnotation?.info?.format else { return }

        selectedAnnotation?.widgetStringValue = datePicker.date.formattedDateString(format: Date.getDateAndTimeStyle(format: format))
    }
}

extension PDFViewerVC: SignatureVCDelegate {
    func didFinishSign(image: UIImage?) {
        guard let image = image, let imageAnnotation = selectedAnnotation as? ImageStampAnnotation else { return }

        imageAnnotation.image = image
    }
}
