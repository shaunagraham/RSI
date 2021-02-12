//
//  Globar_File.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 13/01/19.
//  Copyright © 2019 Kalpesh Satasiya. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

extension UITextField{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    func setLeftImage(imageName:String){
           let imageView = UIImageView(frame: CGRect(x: 20, y: 0, width: 20, height: 20))
           imageView.image = UIImage(named: imageName)
           let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
           imageContainerView.center = imageView.center
           imageContainerView.addSubview(imageView)
           leftView = imageContainerView
           leftViewMode = .always
         }

}

extension UIViewController {
    
    func showToast(message: String, backgroundColor: UIColor? = nil) {
        // create a new style
        var style = ToastStyle()
        
        // this is just one of many style options
        style.messageColor = .white
        if let backgroundColor = backgroundColor {
            style.backgroundColor = backgroundColor
        }
        
        // toggle "tap to dismiss" functionality
        ToastManager.shared.isTapToDismissEnabled = true
        
        // toggle queueing behavior
        ToastManager.shared.isQueueEnabled = true
        
        // present the toast with the new style
        view.makeToast(message, duration: 2.0, position: .bottom, style: style)
    }
    
}

extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    @IBInspectable var shouldRoundedView: Bool {
        get {
            return false
        } set {
            if newValue {
                self.layer.cornerRadius = self.frame.size.width / 2
                self.layer.masksToBounds = true
            }
        }
    }
    
    func viewTopCornerRadious(radius: CGFloat)  {
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner ,.layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func roundCorners(withMaskedCorners maskedCorners: CACornerMask, cornerRadius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadius
            self.layer.maskedCorners = maskedCorners
        } else {
            // Fallback on earlier versions
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    func applyCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func applyCircle() {
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
    }
}


extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
