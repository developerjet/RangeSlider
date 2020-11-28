//
//  Slider+Extension.swift
//  TJRangeSlider
//
//  Created by codertj on 2020/11/28.
//

import UIKit
import Foundation

// MARK: - UIView

extension UIView {
    
    /// x
    public var x : CGFloat {
        
        get {
            return self.frame.origin.x
        }
        set (x) {
            var frame = self.frame
            frame.origin.x = x
            self.frame = frame
        }
    }
    
    
    /// y
    public var y : CGFloat {
        
        get {
            return self.frame.origin.y
        }
        set (y) {
            var frame = self.frame
            frame.origin.y = y
            self.frame = frame
        }
    }
    
    
    /// maxX
    public var maxX : CGFloat {
        
        get {
            return self.frame.maxX
        }
        set(maxX) {
            self.frame.origin.x = maxX - self.frame.size.width
        }
    }
    
    /// maxY
    public var maxY : CGFloat {
        
        get {
            return self.frame.maxY
        }
        set(maxY) {
            self.frame.origin.y = maxY - self.frame.size.height
        }
    }
    
    
    /// width
    public var width : CGFloat {
        
        get {
            return self.frame.size.width
        }
        set (width) {
            var frame = self.frame
            frame.size.width = width
            self.frame = frame
        }
    }
    
    
    /// height
    public var height : CGFloat {
        
        get {
            return self.frame.size.height
        }
        set (height) {
            var frame = self.frame
            frame.size.height = height
            self.frame = frame
        }
    }
    
    
    /// centerX
    public var centerX : CGFloat {
        
        get {
            return self.center.x
        }
        set (centerX) {
            var center = self.center
            center.x = centerX
            self.center = center
        }
    }
    
    
    /// centerY
    public var centerY : CGFloat {
        
        get {
            return self.center.y
        }
        set (centerY) {
            var center = self.center
            center.y = centerY
            self.center = center
        }
    }
    
    
    /// size
    public var size : CGSize {
        
        get {
            return self.frame.size
        }
        set (size) {
            var newSize = self.frame.size
            newSize = CGSize(width: size.width, height: size.height)
            self.frame.size = newSize
        }
    }
    
    
    /// origin
    public var origin : CGPoint {
        
        get {
            return self.frame.origin
        }
        set (origin) {
            var newOrigin = self.frame.origin
            newOrigin = CGPoint(x: origin.x, y: origin.y)
            self.frame.origin = newOrigin
        }
    }
    
    /// borderColor
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            // Fix React-Native conflict issue
            guard String(describing: type(of: color)) != "__NSCFType" else { return }
            layer.borderColor = color.cgColor
        }
    }

    /// SwifterSwift: Border width of view; also inspectable from Storyboard.
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    /// SwifterSwift: Corner radius of view; also inspectable from Storyboard.
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
}


// MARK: - UIColor

extension UIColor {
    
    /// 16进制转化Color
    ///
    /// - Parameter hex: 16进制
    /// - Returns: Color
    class func colorWithHexStr(_ hex: String) -> UIColor {
        
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasSuffix("#")) {
            let index = cString.index(cString.startIndex, offsetBy: 1)
            //cString = cString.substring(from: index)
            cString = String(cString[index...]) // Swift 4
        }
        
        if (cString.count != 6) {
            
            return UIColor.red
        }
    
        let rIndex = cString.index(cString.startIndex, offsetBy: 2)
        //let rString = cString.substring(to: rIndex)
        let rString = String(cString[..<rIndex])
        
        //let otherString = cString.substring(from: rIndex)
        let otherString = String(cString[rIndex...])
        
        let gIndex = otherString.index(otherString.startIndex, offsetBy: 2)
        
        //let gString = otherString.substring(to: gIndex)
        let gString =  String(otherString[..<gIndex])
        
        let bIndex = cString.index(cString.endIndex, offsetBy: -2)
        //let bString = cString.substring(from: bIndex)
        let bString = String(cString[bIndex...])
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: (1))
    }
    
    
    /// 16进制转化Color
    ///
    /// - Parameters:
    ///   - hex: 16进制
    ///   - alpha: 透明度
    /// - Returns: Color
    class func colorWithHexStr(_ hex: String, alpha: CGFloat) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    
    /// RGB的颜色设置
    class func rgbColor(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
    }
    
    /// 随机颜色
    class func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256))
        let green = CGFloat(arc4random_uniform(256))
        let blue = CGFloat(arc4random_uniform(256))
        return rgbColor(r: red, g: green, b: blue)
    }
}


// MARK: - NSArray

extension Array {
    
    subscript (safe index:Int) -> Element?{
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    func toJSonString() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return strJson! as String
    }
    
    func toData() -> Data {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        return data!
    }
}

extension Array where Element: Hashable {
    // 数组去重处理
    var unique:[Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}



