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

enum CYRKeyboardButtonViewType {
    case Input
    case Expanded
}


class CYRKeyboardButtonView: UIView {
    
    var type: CYRKeyboardButtonViewType
    var selectedInputIndex: NSInteger
    
    weak var button: CYRKeyboardButton?
    var expandedPosition: CYRKeyboardButtonPosition
    var inputOptionsRects: Array<CGRect>?
    
    
    init(keyboardButton newButton: CYRKeyboardButton, newType: CYRKeyboardButtonViewType) {
        
        var frame = UIScreen.main.bounds
        
        if (UIDevice.current.orientation.isLandscape) {
            frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
        
        
        button = newButton
        type = newType
        selectedInputIndex = 0
        
        
        if (newButton.position != .Inner) {
            expandedPosition = newButton.position
        } else {
            // Determine the position
            let leftPadding = newButton.frame.minX
            let rightPadding = (newButton.superview?.frame.maxX)! - newButton.frame.maxX
            expandedPosition = (leftPadding > rightPadding ? .Left : .Right)
        }
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateSelectedInputIndex(forPoint point: CGPoint) -> () {
        
        var selectedInputIndex: NSInteger = NSNotFound
        let testRect = CGRect(x: point.x, y: point.y, width: 0, height: 0)
        let location = convert(testRect, from: button?.superview).origin
        
        for keyRect: CGRect in inputOptionsRects! {
            var infiniteKeyRect = CGRect(x: keyRect.minX, y: 0.0, width: keyRect.width, height: CGFloat.infinity)
            infiniteKeyRect = infiniteKeyRect.insetBy(dx: -3, dy: 0)
            
            if (infiniteKeyRect.contains(location)) {
                selectedInputIndex = (inputOptionsRects?.index(of: keyRect))!
                break
            }
        }
        
        if (self.selectedInputIndex != selectedInputIndex) {
            self.selectedInputIndex = selectedInputIndex
            setNeedsDisplay()
        }
    }
    
    
    override func didMoveToSuperview() {
        if (type == .Expanded) {
            determineExpandedKeyGeometries()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        switch type {
        case .Input:
            drawInputView(rect)
        default:
            drawExpandedInputView(rect)
            break
        }
    }
    
    func drawInputView(_ rect: CGRect) {
        
        // Generate the overlay
        let bezierPath = inputViewPath()
        let inputString = button?.input
        
        // Position the overlay
        let keyRect = convert((button?.frame)!, from: button?.superview)
        let context = UIGraphicsGetCurrentContext()
        
        // Overlay path & shadow
        
        //// Shadow Declarations
        var shadow = UIColor.black.withAlphaComponent(0.5)
        var shadowOffset = CGSize(width: 0, height: 0.5)
        var shadowBlurRadius = 2.0
        
        //// Rounded Rectangle Drawing
        context?.saveGState()
        context?.setShadow(offset: shadowOffset, blur: CGFloat(shadowBlurRadius), color: shadow.cgColor)
        button?.keyColor?.setFill()
        bezierPath.fill()
        context!.restoreGState()
        
        
        // Draw the key shadow sliver
        
        //// Color Declarations
        let color = button?.keyColor
        
        //// Shadow Declarations
        shadow = (button?.keyShadowColor)!
        shadowOffset = CGSize(width: 0.1, height: 1.1)
        shadowBlurRadius = 0.0
        
        //// Rounded Rectangle Drawing
        let roundedRectanglePath = UIBezierPath.init(roundedRect: CGRect(x: keyRect.origin.x, y: keyRect.origin.y, width: keyRect.size.width, height: keyRect.size.height - 1.0), cornerRadius: 4.0)
        context?.saveGState()
        context?.setShadow(offset: shadowOffset, blur: CGFloat(shadowBlurRadius), color: shadow.cgColor)
        color?.setFill()
        roundedRectanglePath.fill()
        context?.restoreGState()
        
        // Text drawing
        let stringColor = button?.keyTextColor
        let stringRect = bezierPath.bounds
        let p = NSMutableParagraphStyle.init()
        p.alignment = NSTextAlignment.center
        let attributedString = NSAttributedString.init(string: inputString!, attributes: [NSFontAttributeName: UIFont.init(name: "HelveticaNeue-Light", size: 44) ?? UIFont.systemFont(ofSize: 44), NSForegroundColorAttributeName: stringColor!, NSParagraphStyleAttributeName: p])
        attributedString.draw(in: stringRect)
        
    }
    
    
    func drawExpandedInputView(_ rect: CGRect) {
        
        // Generate the overlay
        let bezierPath = expandedInputViewPath()
        
        // Position the overlay
        let keyRect = convert((button?.frame)!, from: button?.superview)
        
        let context = UIGraphicsGetCurrentContext()
        
        // Overlay path & shadow
        
        var shadowAlpha: CGFloat = 0.0
        var shadowOffset = CGSize.zero
        
        switch (UIDevice.current.userInterfaceIdiom) {
        case .phone:
            shadowAlpha = 0.5
            shadowOffset = CGSize(width: 0.0, height: 0.5)
            break
        case .pad:
            shadowAlpha = 0.25
            shadowOffset = CGSize.zero
            break
        default:
            break
        }
        
        //// Shadow Declarations
        let shadow = UIColor.black.withAlphaComponent(shadowAlpha)
        let shadowBlurRadius: CGFloat = 2.0
        
        //// Rounded Rectangle Drawing
        context?.saveGState()
        context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
        button?.keyColor?.setFill()
        bezierPath.fill()
        context?.restoreGState()
        
        
        // Draw the key shadow sliver
        if (button?.style == CYRKeyboardButtonStyle.Phone) {
            let color = button?.keyColor
            
            //// Shadow Declarations
            let shadow = button?.keyShadowColor
            let shadowOffset = CGSize(width: 0.1, height: 1.1)
            let shadowBlurRadius: CGFloat = 0.0
            
            //// Rounded Rectangle Drawing
            let roundedRectanglePath = UIBezierPath.init(roundedRect: CGRect(x: keyRect.origin.x, y: keyRect.origin.y, width: keyRect.size.width, height: keyRect.size.height - 1.0), cornerRadius: 4.0)
            context?.saveGState()
            context?.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow?.cgColor)
            color?.setFill()
            roundedRectanglePath.fill()
            context?.restoreGState()
        }
        
        drawExpandedInputViewOptions()
        
    }
    
    func drawExpandedInputViewOptions() {
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShadow(offset: CGSize.zero, blur: 0, color: UIColor.clear.cgColor)
        context?.saveGState()
        
        let inputOptions = button?.inputOptions
        for optionString: String in inputOptions! {
            
            let idx: NSInteger = (inputOptions?.index(of: optionString))!
            let optionRect: CGRect = (inputOptionsRects?[idx])!
            let selected = (idx == selectedInputIndex)
            
            if (selected) {
                // Draw selection background
                let roundedRectanglePath = UIBezierPath(roundedRect: optionRect, cornerRadius: 4.0)
                tintColor.setFill()
                roundedRectanglePath.fill()
            }
            
            // Draw the text
            let stringColor = (selected ? UIColor.white : button?.keyTextColor)
            let stringSize = optionString.size(attributes: [NSFontAttributeName: (button?.inputOptionsFont)!])
            let stringRect = CGRect(x: optionRect.midX - stringSize.width * 0.5, y: optionRect.midY - stringSize.height * 0.5, width: stringSize.width, height: stringSize.height)
            let p = NSMutableParagraphStyle()
            p.alignment = NSTextAlignment.center
            let attributedString = NSAttributedString.init(string: optionString, attributes: [NSFontAttributeName: (button?.inputOptionsFont)!, NSForegroundColorAttributeName: stringColor!, NSParagraphStyleAttributeName: p])
            attributedString.draw(in: stringRect)
            
        }
        
        context?.restoreGState()
    }
    
    
    
    
    // INTERNAL
    
    func inputViewPath() -> UIBezierPath {
        
        let keyRect = convert((button?.frame)!, from: button?.superview)
        let insets = UIEdgeInsets(top: 7.0, left: 13.0, bottom: 7.0, right: 13.0)
        let upperWidth = (button?.frame.width)! + insets.left + insets.right
        let lowerWidth = (button?.frame.width)!
        let majorRadius: CGFloat = 10.0
        let minorRadius: CGFloat = 4.0
        
        let path = TurtleBezierPath()
        path.home()
        path.lineWidth = 0.0
        path.lineCapStyle = CGLineCap.round
        
        switch (button?.position)! {
            
        case .Inner:
            
            path.rightArc(majorRadius, turn: 90.0) // #1
            path.forward(upperWidth - 2.0 * majorRadius) // #2 top
            path.rightArc(majorRadius, turn: 90.0) // #3
            path.forward(keyRect.height -  2.0 * majorRadius + insets.top + insets.bottom) // #4 right big
            path.rightArc(majorRadius, turn: 48.0) // #5
            path.forward(8.5)
            path.leftArc(majorRadius, turn: 48.0) // #6
            path.forward(keyRect.height - 8.5 + 1.0)
            path.rightArc(minorRadius, turn: 90.0)
            path.forward(lowerWidth - 2.0 * minorRadius) // lowerWidth - 2.0 * minorRadius + 0.5
            path.rightArc(minorRadius, turn: 90.0)
            path.forward(keyRect.height - 2 * minorRadius)
            path.leftArc(majorRadius, turn: 48.0)
            path.forward(8.5)
            path.rightArc(majorRadius, turn: 48.0)
            
            var offsetX: CGFloat = 0.0
            var offsetY: CGFloat = 0.0
            let pathBoundingBox = path.bounds
            
            offsetX = keyRect.midX - path.bounds.midX
            offsetY = keyRect.maxY - pathBoundingBox.height + 10.0
            
            path.apply(CGAffineTransform(translationX: offsetX, y: offsetY))
            
            break
            
            
        case .Left:
            
            path.rightArc(majorRadius, turn: 90.0) // #1
            path.forward(upperWidth - 2.0 * majorRadius) // #2 top
            path.rightArc(majorRadius, turn: 90.0) // #3
            path.forward(keyRect.height - 2.0 * majorRadius + insets.top + insets.bottom) // #4 right big
            path.rightArc(majorRadius, turn: 45.0) // #5
            path.forward(28.0) // #6
            path.leftArc(majorRadius, turn: 45.0) // #7
            path.forward(keyRect.height - 26.0 + (insets.left + insets.right) * 0.25) // #8
            path.rightArc(minorRadius, turn: 90.0) // #9
            path.forward(path.currentPoint.x - minorRadius) // #10
            path.rightArc(minorRadius, turn: 90.0) // #11
            
            var offsetX: CGFloat = 0.0
            var offsetY: CGFloat = 0.0
            let pathBoundingBox = path.bounds
            
            offsetX = keyRect.maxX - path.bounds.width
            offsetY = keyRect.maxY - pathBoundingBox.height - path.bounds.minY
            
            path.apply(CGAffineTransform(scaleX: -1.0, y: 1.0).translatedBy(x: -offsetX - path.bounds.width, y: offsetY))
            
            break
            
            
        case .Right:
            
            path.rightArc(majorRadius, turn: 90.0) // #1
            path.forward(upperWidth - 2.0 * majorRadius) // #2
            path.rightArc(majorRadius, turn: 90.0) // #3
            path.forward(keyRect.height - 2.0 * majorRadius + insets.top + insets.bottom) // #4 right big
            path.rightArc(majorRadius, turn: 45.0) // #5
            path.forward(28.0) // #6
            path.leftArc(majorRadius, turn: 45.0) // #7
            path.forward(keyRect.height - 26.0 + (insets.left + insets.right) * 0.25) // #8
            path.rightArc(minorRadius, turn: 90.0) // #9
            path.forward(path.currentPoint.x - minorRadius) // #10
            path.rightArc(minorRadius, turn: 90.0) // #11
            
            var offsetX: CGFloat = 0.0
            var offsetY: CGFloat = 0.0
            let pathBoundingBox = path.bounds
            
            offsetX = keyRect.minX
            offsetY = keyRect.maxY - pathBoundingBox.height - path.bounds.minY
            
            path.apply(CGAffineTransform(translationX: offsetX, y: offsetY))
                
            break
            
        default:
            
            break
            
        }
        
        return path
        
    }
    
    
    func expandedInputViewPath() -> UIBezierPath {
        
        let keyRect = convert((button?.frame)!, from: button?.superview)
        let insets = UIEdgeInsets(top: 7.0, left: 13.0, bottom: 7.0, right: 13.0)
        let margin: CGFloat = 7.0
        let nbKeys = CGFloat((button?.inputOptions?.count)!)
        let upperWidth = insets.left + insets.right + nbKeys * keyRect.width + margin * (nbKeys - 1) - margin * 0.5
        let lowerWidth = (button?.frame.width)!
        let majorRadius: CGFloat = 10.0
        let minorRadius: CGFloat = 4.0
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        
        switch expandedPosition {
        case .Right:
            switch (button?.style)! {
            case .Phone:
                
                let path = TurtleBezierPath()
                path.home()
                
                path.lineWidth = 0.0
                path.lineCapStyle = CGLineCap.round
                path.rightArc(majorRadius, turn: 90.0) // #1
                path.forward(upperWidth - 2.0 * majorRadius) // #2 top
                path.rightArc(majorRadius, turn: 90.0) // #3
                path.forward(keyRect.height - 2.0 * majorRadius + insets.top + insets.bottom - 3.0) // #4 right big
                path.rightArc(majorRadius, turn: 90.0) // #5
                path.forward(path.currentPoint.x - (keyRect.width + 2.0 * majorRadius + 3.0))
                path.leftArc(majorRadius, turn: 90.0) // #6
                path.forward(keyRect.height - minorRadius)
                path.rightArc(minorRadius, turn: 90.0)
                path.forward(lowerWidth - 2.0 * minorRadius) //  lowerWidth - 2 * minorRadius + 0.5
                path.rightArc(minorRadius, turn: 90.0)
                path.forward(keyRect.height - 2.0 * minorRadius)
                path.leftArc(majorRadius, turn: 48.0)
                path.forward(8.5)
                path.rightArc(majorRadius, turn: 48.0)
                
                offsetX = keyRect.maxX - keyRect.width - insets.left
                offsetY = keyRect.maxY - path.bounds.height + 10.0
                
                path.apply(CGAffineTransform(translationX: offsetX, y: offsetY))
                
                return path
                
            case .Tablet:
                
                
                let firstRect = inputOptionsRects?[0]
                let path = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: (firstRect?.width)! * CGFloat((button?.inputOptions?.count)!) + 12.0, height: firstRect!.height + 12.0), cornerRadius: 6.0)
                
                path.lineWidth = 0.0
                path.lineCapStyle = CGLineCap.round
                
                offsetX = keyRect.minX
                offsetY = (firstRect?.minY)! - 6.0
                
                path.apply(CGAffineTransform(translationX: offsetX, y: offsetY))
                
                return path
            }
            
        case .Left:
            
            switch (button?.style)! {
            case .Phone:
                
                let path = TurtleBezierPath()
                path.home()
                
                path.lineWidth = 0.0
                path.lineCapStyle = CGLineCap.round
                
                path.rightArc(majorRadius, turn: 90.0) // #1
                path.forward(upperWidth - 2.0 * majorRadius) // #2 top
                path.rightArc(majorRadius, turn: 90.0) // #3
                path.forward(keyRect.height - 2.0 * majorRadius + insets.top + insets.bottom - 3.0) // #4 right big
                path.rightArc(majorRadius, turn: 48.0)
                path.forward(8.5)
                path.leftArc(majorRadius, turn: 48.0)
                path.forward(keyRect.height - minorRadius)
                path.rightArc(minorRadius, turn: 90.0)
                path.forward(lowerWidth - 2.0 * minorRadius) //  lowerWidth - 2 * minorRadius + 0.5
                path.rightArc(minorRadius, turn: 90.0)
                path.forward(keyRect.height - 2.0 * minorRadius)
                path.leftArc(majorRadius, turn: 90.0) // #5
                path.forward(path.currentPoint.x - majorRadius)
                path.rightArc(majorRadius, turn: 90.0) // #6
                
                offsetX = keyRect.maxX - path.bounds.width + insets.left
                offsetY = keyRect.maxY - path.bounds.height + 10.0
                
                path.apply(CGAffineTransform(translationX: offsetX, y: offsetY))
                
                return path
                
            case .Tablet:
                
                let firstRect = inputOptionsRects?[0]
                let path = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: (firstRect?.width)! * CGFloat((button?.inputOptions?.count)!) + 12.0, height: firstRect!.height + 12.0), cornerRadius: 6.0)
                
                path.lineWidth = 0.0
                path.lineCapStyle = CGLineCap.round
                
                offsetX = keyRect.maxX - path.bounds.width
                offsetY = (firstRect?.minY)! - 6.0
                
                path.apply(CGAffineTransform(translationX: offsetX, y: offsetY))
                
                return path
            }
            
            break
            
            
        default:
            break
        }
        
        return UIBezierPath()
        
    }
    
  
    
    
    func determineExpandedKeyGeometries() {
        
        let keyRect = convert((button?.frame)!, from: button?.superview)
        var inputOptionsRects = Array<CGRect>()
        inputOptionsRects.reserveCapacity((button?.inputOptions?.count)!)
        
        var offset: CGFloat = 0.0
        var spacing: CGFloat = 0.0
        
        var optionRect = CGRect.zero
        
        switch (button?.style)! {
        case .Phone:
            
            offset = keyRect.width
            spacing = 6.0
            optionRect = keyRect.insetBy(dx: 0.0, dy: 0.5).offsetBy(dx: 0.0, dy: -(keyRect.height + 15.0))
            break
            
        case .Tablet:
            spacing = 0.0
            optionRect = keyRect.insetBy(dx: 6.0, dy: 6.5).offsetBy(dx: 0.0, dy: -(keyRect.height + 3.0))
            offset =  optionRect.width
            break
        }

        
        
        for _ in (button?.inputOptions)! {
            
            inputOptionsRects.append(optionRect)
            
            // Offset the option rect
            switch expandedPosition {
            case .Right:
                optionRect = optionRect.offsetBy(dx: offset + spacing, dy: 0.0)
                break
            case .Left:
                optionRect = optionRect.offsetBy(dx: -offset - spacing, dy: 0.0)
                break
            default:
                break
            }
            
        }
        
        self.inputOptionsRects = inputOptionsRects
        
    }
    
    
}






















































