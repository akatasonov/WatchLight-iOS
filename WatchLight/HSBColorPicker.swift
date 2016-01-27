//
//  HSBColorPicker.swift
//  WatchLight
//
//  Created by Andrew Katasonov on 1/5/16.
//  Copyright © 2016 Andrew Katasonov. All rights reserved.
//

import Foundation
import UIKit

internal protocol HSBColorPickerDelegate : NSObjectProtocol {
    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizerState)
}

@IBDesignable
class HSBColorPicker : UIView {
    
    weak internal var delegate: HSBColorPickerDelegate?
    
    @IBInspectable var elementSize: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func initialize() {
        self.clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: "touchedColor:")
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.max
        self.addGestureRecognizer(touchGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        for var y = CGFloat(0.0); y < rect.height; y=y+elementSize {
            let saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : CGFloat(1.0)
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
            
            for var x = CGFloat(0.0); x < rect.width; x=x+elementSize {
                let hue = x / rect.width
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                CGContextSetFillColorWithColor(context, color.CGColor)
                CGContextFillRect(context, CGRect(x:x, y:y, width:elementSize,height:elementSize))
            }
        }
    }
    
    func getColorAtPoint(point:CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
            y:elementSize * CGFloat(Int(point.y / elementSize)))
        let saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height : CGFloat(1.0)
        let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        let hue = roundedPoint.x / self.bounds.width
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    func touchedColor(gestureRecognizer: UILongPressGestureRecognizer){
        let point = gestureRecognizer.locationInView(self)
        let color = getColorAtPoint(point)
        
        self.delegate?.HSBColorColorPickerTouched(self, color: color, point: point, state:gestureRecognizer.state)
    }
}