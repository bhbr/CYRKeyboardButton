

//
//  CYRKeyboardButton.swift
//  Converted to Swift by Ben Hambrecht on 10.02.17.
//
//
//
//  CYRKeyboardButton.h
//
//  Created by Illya Busigin on 7/19/14.
//  Copyright (c) 2014 Cyrillian, Inc.
//  Portions Copyright (c) 2013 Nigel Timothy Barber (TurtleBezierPath)
//
//  Distributed under MIT license.
//  Get the latest version from here:
//
//  https://github.com/illyabusigin/CYRKeyboardButton
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Cyrillian, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




import UIKit



enum CYRKeyboardButtonPosition {
    case Left
    case Inner
    case Right
    case Count
}





/**
 The style of the keyboard button. You use these constants to set the value of the keyboard button style.
 */

enum CYRKeyboardButtonStyle {
    case Phone
    case Tablet
}

/**
 Notifies observers that the keyboard button has been pressed. The affected button is stored in the object parameter of the notification. The userInfo dictionary contains the pressed key and can be accessed with the CYRKeyboardButtonKeyPressedKey key.
 */

extension Notification.Name {
        static let buttonPressed = Notification.Name("CYRKeyboardButtonPressed")
        static let buttonDidShowExpandedInput = Notification.Name("CYRKeyboardButtonDidShowExpandedInput")
        static let buttonDidHideExpandedInput = Notification.Name("CYRKeyboardButtonDidHideExpandedInput")
        static let buttonKeyPressedKey = Notification.Name("CYRKeyboardButtonKeyPressedKey")
}




class CYRKeyboardButton: UIControl, UIGestureRecognizerDelegate {
    
    
    var _font: UIFont? = .systemFont(ofSize: 22.0)
    var font: UIFont? {
        
        get {
            return _font
        }
        
        set(newFont) {

            if (_font != newFont) {
                willChangeValue(forKey: "_font")
                _font = newFont
                didChangeValue(forKey: "_font")
                inputLabel.font = newFont
                }
        }
        
    }
    
    
    
    var inputOptionsFont: UIFont?
    var keyColor: UIColor?
    
    
    var _keyTextColor: UIColor? = .clear
    var keyTextColor: UIColor? {
        
        get {
            return _keyTextColor
        }
        
        set(newKeyTextColor) {
            willChangeValue(forKey: "_keyTextColor")
            _keyTextColor = newKeyTextColor
            didChangeValue(forKey: "_keyTextColor")
            inputLabel.textColor = newKeyTextColor
        }

    }

    var keyShadowColor: UIColor?
    var keyHighlightedColor: UIColor?
    
    var _input: String? = ""
    var input: String? {
        
        get {
            return _input
        }
        
        set(newInput) {
            willChangeValue(forKey: "_input")
            _input = newInput
            inputLabel.text = newInput
        }
    }
    
    
    
    var _inputOptions: Array<String>? = []
    var inputOptions: Array<String>? {
        
        get {
            return _inputOptions
        }
        
        set(newInputOptions) {
            willChangeValue(forKey: "_inputOptions")
            _inputOptions = newInputOptions
            didChangeValue(forKey: "_inputOptions")
            if ((inputOptions?.count)! > 0) {
                setupInputOptionsConfiguration()
            } else {
                tearDownInputOptionsConfiguration()
            }
        }
    }
    
    weak var _textInput: UITextInput? = nil
    var textInput: UITextInput? {
        
        get {
            return _textInput
        }
        
        set(newTextInput) {
            if let _ = newTextInput as UITextInput? {
                // nothing to see here
            } else {
                NSLog("<CYRKeyboardButton> The text input object must conform to the UITextInput protocol!")
            }
            willChangeValue(forKey: "_textInput")
            _textInput = newTextInput
            didChangeValue(forKey: "_textInput")
        }
        
    }
    
    var _style: CYRKeyboardButtonStyle
    var style: CYRKeyboardButtonStyle {
        
        get {
            return _style
        }
        
        set(newStyle) {
            willChangeValue(forKey: "_style")
            _style = newStyle
            didChangeValue(forKey: "_style")
            updateDisplayStyle()
        }
        
    }
    
    var buttonView: CYRKeyboardButtonView?
    
    var expandedButtonView: CYRKeyboardButtonView?
    lazy var position: CYRKeyboardButtonPosition = .Inner
    lazy var optionsViewRecognizer = UILongPressGestureRecognizer()
    lazy var panGestureRecognizer = UIPanGestureRecognizer()
    
    lazy var keyCornerRadius: CGFloat = 0.0
    
    var inputLabel = UILabel()
    
    
    
    
    init() {
        let frame = CGRect(x:50,y:50,width:30,height:45)
        _style = .Phone
        super.init(frame:frame)
        commonInit()
    }
    
    override init(frame: CGRect) {
        _style = .Phone
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        _style = .Phone
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            style = .Phone
            break
        case .pad:
            style = .Tablet
            break
        default:
            break
        }
        
        // Default appearance
        font = .systemFont(ofSize: 22.0)
        inputOptionsFont = .systemFont(ofSize: 24.0)
        keyColor = .white
        keyTextColor = .black
        keyShadowColor = UIColor(red: 136.0/255.0, green: 138.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        keyHighlightedColor = UIColor(red: 213.0/255.0, green: 214.0/255.0, blue: 216.0/255.0, alpha: 1.0)
        
        // Styling
        backgroundColor = .clear
        clipsToBounds = false
        layer.masksToBounds = false
        contentHorizontalAlignment = .center
        
        // State handling
        addTarget(self, action: #selector(CYRKeyboardButton.handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(CYRKeyboardButton.handleTouchUpInside), for: .touchUpInside)
        
        
        // Input label
        let newInputLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        newInputLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newInputLabel.textAlignment = .center
        newInputLabel.backgroundColor = .clear
        newInputLabel.isUserInteractionEnabled = false
        newInputLabel.textColor = keyTextColor
        newInputLabel.font = font
        
        newInputLabel.text = ""
        
        self.inputLabel = newInputLabel
        
        self.addSubview(newInputLabel)
        
        updateDisplayStyle()
    }
    
    
    override func didMoveToSuperview() {
        updateButtonPosition()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
        updateButtonPosition()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only allow simultaneous recognition with our internal recognizers
        return (gestureRecognizer == panGestureRecognizer || gestureRecognizer == optionsViewRecognizer) && (otherGestureRecognizer == panGestureRecognizer || optionsViewRecognizer == optionsViewRecognizer)
    }
    
    override var description: String {
        let description = String(format: "<%@ %p>; frame = %@; input = %@; inputOptions = %@", String(describing: type(of:self)), self, String(describing: frame), input!, inputOptions!)
        return description
    }
    
    func showInputView() {
        
        if (style == .Phone) {
            hideInputView()
            buttonView = CYRKeyboardButtonView(keyboardButton: self, newType: .Input)
            window?.addSubview(buttonView!)
        } else {
            setNeedsDisplay()
        }
        
    }
    
    func showExpandedInputView(recognizer: UILongPressGestureRecognizer) {
        
        if (recognizer.state == .began) {
            
            if (expandedButtonView == nil) {
                
                let newExpandedButtonView = CYRKeyboardButtonView(keyboardButton: self, newType: .Expanded)
                window?.addSubview(newExpandedButtonView)
                expandedButtonView = newExpandedButtonView
                
                NotificationCenter.default.post(name: .buttonDidShowExpandedInput, object: self)
                hideInputView()
                
            }
            
        } else if (recognizer.state == .cancelled || recognizer.state == .ended) {
            
            if (panGestureRecognizer.state != .recognized) {
                handleTouchUpInside()
            }
            
        }
        
    }
    
    func hideInputView() {
        buttonView?.removeFromSuperview()
        buttonView = nil
        setNeedsDisplay()
    }
    
    func hideExpandedInputView() {
        
        if expandedButtonView?.type == .Expanded {
            NotificationCenter.default.post(name: .buttonDidHideExpandedInput, object: self)
        }
        
        expandedButtonView?.removeFromSuperview()
        expandedButtonView = nil
    }
    
    func updateDisplayStyle() {
        
        switch style {
        case .Phone:
            keyCornerRadius = 4.0
            break
        case .Tablet:
            keyCornerRadius = 6.0
            break
        }
    
        setNeedsDisplay()
        
    }
    
    func insertText(text: String) {
        
        var shouldInsertText = true
        if (textInput is UITextView) {
            // Call UITextViewDelegate methods is necessary
            let textView = textInput as! UITextView
            let selectedRange = textView.selectedRange
            shouldInsertText = (textView.delegate?.textView!(textView, shouldChangeTextIn: selectedRange, replacementText: text))!
        } else if textInput is UITextField {
            // Call UITextFieldDelegate methods if necessary
            let textField = self.textInput as! UITextField
            let selectedRange = textInputSelectedRange()
            shouldInsertText = (textField.delegate?.textField!(textField, shouldChangeCharactersIn: selectedRange, replacementString: text))!
        }
        
        if shouldInsertText {
            textInput?.insertText(text)
            NotificationCenter.default.post(name: .buttonPressed, object: self, userInfo: [Notification.Name.buttonKeyPressedKey: text])
        }
    }
    
    func textInputSelectedRange() -> NSRange {
        
        let beginning = textInput?.beginningOfDocument
        let selectedRange = textInput?.selectedTextRange
        let selectionStart = selectedRange?.start
        let selectionEnd = selectedRange?.end
        
        let location = textInput?.offset(from: beginning!, to: selectionStart!)
        let length = textInput?.offset(from: selectionStart!, to: selectionEnd!)
        
        return NSMakeRange(location!, length!)
        
    }
    
    func updateButtonPosition() {
        
        // Determine the button's position state based on the superview padding
        let leftPadding = frame.minX
        let rightPadding = (superview?.frame.maxX)! - frame.maxX
        let minimumClearance = frame.width * 0.5 + 8.0
        
        if (leftPadding >= minimumClearance && rightPadding >= minimumClearance) {
            position = .Inner
        } else if (leftPadding > rightPadding) {
            position = .Left
        } else {
            position = .Right
        }
    }
    
    func setupInputOptionsConfiguration() {
        
        tearDownInputOptionsConfiguration()
        
        if ((inputOptions?.count)! > 0) {
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showExpandedInputView(recognizer:)))
            longPressGestureRecognizer.minimumPressDuration = 0.3
            longPressGestureRecognizer.delegate = self
            addGestureRecognizer(longPressGestureRecognizer)
            optionsViewRecognizer = longPressGestureRecognizer
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(_handlePanning(recognizer:)))
            panGestureRecognizer.delegate = self
            addGestureRecognizer(panGestureRecognizer)
            self.panGestureRecognizer = panGestureRecognizer
            
        }
    }
    
    func tearDownInputOptionsConfiguration() {
        removeGestureRecognizer(optionsViewRecognizer)
        removeGestureRecognizer(panGestureRecognizer)
    }
    
    func handleTouchDown() {
        UIDevice.current.playInputClick()
        showInputView()
    }
    
    func handleTouchUpInside() {
        insertText(text: input!)
        hideInputView()
        hideExpandedInputView()
    }
    
    func _handlePanning(recognizer: UIPanGestureRecognizer) {
        
        if (recognizer.state == .ended || recognizer.state == .cancelled) {
            if expandedButtonView?.selectedInputIndex != NSNotFound {
                let inputOption = inputOptions?[(expandedButtonView?.selectedInputIndex)!]
                insertText(text: inputOption!)
            }
        
            hideExpandedInputView()
            
        } else {
            let location = recognizer.location(in: superview)
            expandedButtonView?.updateSelectedInputIndex(forPoint: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hideInputView()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        hideInputView()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var color = keyColor
        if (style == .Tablet && state == .highlighted) {
            color = keyHighlightedColor
        }
        let shadow = keyShadowColor
        let shadowOffset = CGSize(width: 0.1, height: 1.1)
        let shadowBlurRadius: CGFloat = 0.0
        
        let roundedRectanglePath = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height - 1.0), cornerRadius: keyCornerRadius)
        context?.saveGState()
        context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow?.cgColor)
        color?.setFill()
        roundedRectanglePath.fill()
        context?.restoreGState()
    }
    
    
    
}




























