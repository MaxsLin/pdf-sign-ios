//
//  FormView.swift
//  PDFSign
//
//  Created by kawu on 9/16/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import UIKit

protocol StaticCellProtocol {
    var definedHeight: CGFloat {get}
    func setup()
}

class StaticCell: UIView, StaticCellProtocol {
    var definedHeight: CGFloat {
        return 44
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {}
}

private let animationDuration: Double = 0.3

class TextField: UITextField {
    private var keyboardHeight: CGFloat = 0.0

    var onBegin: ((_ textField: TextField) -> Void)?
    var onChange: ((_ text: String) -> Void)?
    var shouldChange: ((_ range: NSRange, _ string: String) -> Bool)?
    var onClear: ((_ textField: TextField) -> Void)?
    var onReturn: ((_ textField: TextField) -> Void)?

    var allowNumbersOnly = false
    var disablePaste = false
    var movesWindowOnKeyboardEdit = false
    private var clearButtonWidth: CGFloat?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.delegate = self
        smartDashesType = .no
        smartQuotesType = .no
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if disablePaste && action == #selector(paste(_:)) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }

//    @discardableResult
//    func createCustomClearButton(accessibilityId: String) -> UIButton {
//        let image = UIImage(named: "icon-clear")?.withRenderingMode(.alwaysTemplate)
//        let clearButton = UIButton(type: .custom)
//        clearButtonWidth = image?.size.width
//
//        clearButton.setImage(image, for: .normal)
//        clearButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
//        clearButton.contentMode = .scaleAspectFit
//        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
//        clearButton.tintColor = .gray
//        clearButton.accessibilityIdentifier = accessibilityId
//        rightView = clearButton     /// set custom clear button to right overlay view
//        rightViewMode = .always
//        clearButtonMode = .never    /// hide internal clear button
//
//        return clearButton /// return  clearButton to client
//    }

    @objc private func clearText() {
        self.text = ""
        onClear?(self)
    }

//    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//        guard let buttonSize = clearButtonWidth else { return bounds }
//
//        /// return rect for the installed custom clear button. clear button will be placed in middle of this rect
//        let width = 1.8 * buttonSize
//        let x = self.bounds.width - width
//        let y = (self.bounds.height - buttonSize) / 2
//        let newBounds = CGRect(x: x, y: y, width: width, height: buttonSize)
//
//        return newBounds
//    }

    private func isValidNumber(string: String) -> Bool {
        guard let first = string.first, (first >= "0" && first <= "9") else {
            return false
        }
        var gotDelimiter = false

        for char in string {
            if char == "," || char == "." {
                if !gotDelimiter {
                    gotDelimiter = true
                } else {
                    return false
                }
            } else if !(char >= "0" && char <= "9") {
                return false
            }
        }

        return true
    }
}

extension TextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.onBegin?(self)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let shouldChange = shouldChange, true != shouldChange(range, string) {
            return false
        }

        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        if allowNumbersOnly && text.count > 0 {
            if self.isValidNumber(string: text) {
                self.onChange?(text)
                return true
            } else {
                return false
            }
        }

        self.onChange?(text)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onReturn?(self)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        onClear?(self)
        return true
    }

    func setPlaceholder(_ text: String, color: UIColor = UIColor.gray) {
        attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
    }

    @discardableResult override open func becomeFirstResponder() -> Bool {
        let response = super.becomeFirstResponder()
        guard let window = window,
            movesWindowOnKeyboardEdit
        else {
            return response
        }
        let frameInWindow = convert(self.frame, to: nil)
        let bottomOfFrame = frameInWindow.origin.y + frameInWindow.size.height
        let windowMinusKeyboard = window.frame.size.height - keyboardHeight
        if bottomOfFrame > windowMinusKeyboard {
            UIView.animate(withDuration: animationDuration, animations: {
                window.frame = CGRect(x: 0,
                                      y: windowMinusKeyboard - bottomOfFrame,
                                      width: window.frame.width,
                                      height: window.frame.height)
            })
        }
        return response
    }

    @discardableResult open override func resignFirstResponder() -> Bool {
        let response = super.resignFirstResponder()
        guard let window = window,
            movesWindowOnKeyboardEdit
        else {
            return response
        }
        if window.frame.origin.y != 0 {
            UIView.animate(withDuration: animationDuration, animations: {
                window.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
            })
        }
        return response
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height > keyboardHeight {
                keyboardHeight = keyboardSize.height
            }
        }
    }
}

protocol FormViewDelegate: class {
    func formViewActiveFieldDidChange(_ activeField: TextField?)
}

extension FormViewDelegate {
    func formViewActiveFieldDidChange(_ activeField: TextField?) {}
}

class FormView: UIStackView {

    private(set) var cells = [StaticCell]()
    private var textFields = [TextField]()
    weak var formDelegate: FormViewDelegate?

    func addCell(_ cell: StaticCell) {
        cells.append(cell)
        self.addArrangedSubview(cell)

        let fields = textFieldsInCell(cell)
        for f in fields {
            let currentOnBegin = f.onBegin
            f.onBegin = { [weak self, currentOnBegin] (textField) -> Void in
                currentOnBegin?(textField)
                self!.formDelegate?.formViewActiveFieldDidChange(textField)
            }

            let currentOnReturn = f.onReturn
            f.onReturn = { [weak self, currentOnReturn] (textField) -> Void in
                currentOnReturn?(textField)
                self!.processReturn(textField)
            }
            textFields.append(f)
        }
    }

    func addCells(_ cells: [StaticCell]) {
        for cell in cells {
            addCell(cell)
        }
    }

    func removeAtIndex(_ index: Int) {
        let cell = cells[index]
        let tf = textFieldsInCell(cell)

        textFields = textFields.filter { (element) -> Bool in
            for textField in tf where textField === element {
                return false
            }

            return true
        }

        cells.remove(at: index)
    }

    func processReturn(_ current: TextField) {
        if current === textFields.last {
            current.resignFirstResponder()
            formDelegate?.formViewActiveFieldDidChange(nil)
        } else {
            moveOnNext(current)
        }
    }

    func moveOnPrevious(_ current: TextField) {
        if current !== textFields.first {
            for i in Array((0..<textFields.count).reversed()) where textFields[i] === current {
                let previous = textFields[i-1]
                previous.becomeFirstResponder()
                formDelegate?.formViewActiveFieldDidChange(previous)
            }
        }
    }

    func moveOnNext(_ current: TextField) {
        if current !== textFields.last {
            for i in 0..<textFields.count where textFields[i] === current {
                for k in (i+1)..<textFields.count {
                    let next = textFields[k]

                    if !next.isHidden && next.isUserInteractionEnabled {
                        next.becomeFirstResponder()
                        formDelegate?.formViewActiveFieldDidChange(next)
                        return
                    }
                }

                // No suitable next was found
                current.resignFirstResponder()
                formDelegate?.formViewActiveFieldDidChange(nil)
            }
        } else {
            current.resignFirstResponder()
            formDelegate?.formViewActiveFieldDidChange(nil)
        }
    }

    private func textFieldsInCell(_ cell: StaticCell) -> [TextField] {
        var fields = [TextField]()

        for view in cell.subviews {
            if let textField = view as? TextField {
                fields.append(textField)
            }
        }

        return fields
    }
}
