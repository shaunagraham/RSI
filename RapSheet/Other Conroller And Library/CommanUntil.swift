//
//  CommanUntil.swift
//  Scene
//
//  Created by Kalpesh Satasiya on 01/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SDWebImage

class CommanUntil: NSObject {

}

func isUserLogin() -> Bool {
    if (UserDefaults .standard.object(forKey: "isUserLogin") != nil) {
        return true
    }
    return false
}

//MARK: Comman AlertView Method

func DisplayAlert(title:String,message:String, vc:UIViewController)  {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
    
}

func DisplayAlertwithBack(title:String,message:String, vc:UIViewController)  {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alert in
        vc.navigationController?.popViewController(animated: true)
    }))
    vc.present(alert, animated: true, completion: nil)
    
}

func Alertview(title: String, body: String, cancelbutton: String, okbutton: String, completion:@escaping () -> Void) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
    
    
    // Create the actions
    let cancelAction = UIAlertAction(title: cancelbutton, style: UIAlertAction.Style.cancel) {
        UIAlertAction in
    }
    
    let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.default) {
        UIAlertAction in
        completion()
    }
    // Add the actions
    alertController.addAction(okAction)
    if cancelbutton != ""{
        alertController.addAction(cancelAction)
    }
    return alertController
}

//MARK: Attribute String

func setAttributSting(str:String,string_first:String, string_second:String) -> NSMutableAttributedString {
    let attributedString = NSMutableAttributedString(string:str)
    let range = (str as NSString).range(of: string_first)
    let range_first = (str as NSString).range(of: string_second)
    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.black, range: range)
    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range_first)
    attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "futura", size: 16)!, range: range)
    attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "futura", size: 16)!, range: range_first)
    return attributedString
}

//MARK: Error Convert To String

func setErrorMessage(string:String) -> NSError {
    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : string])
    return error
}

//MARK: Load Image


func setSd_ImageWithLoader(imageView : UIImageView) {
    imageView.sd_setIndicatorStyle(UIActivityIndicatorView.Style.gray)
    imageView.sd_addActivityIndicator()
}

func loadImageWithURL(url:String,view:UIImageView)
{
    if let imgurl = URL(string: url)
    {
        view.sd_setImage(with: imgurl, placeholderImage: nil, options: [.refreshCached, .allowInvalidSSLCertificates], completed: { (img, err, type, u) in
        })
    }
}

//MARK: RGB TO Conver Hexa Color

func hexa (_ hexStr : NSString, alpha : CGFloat) -> UIColor {
    let realHexStr = hexStr.replacingOccurrences(of: "#", with: "")
    let scanner = Scanner(string: realHexStr as String)
    var color: UInt32 = 0
    if scanner.scanHexInt32(&color) {
        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000FF) / 255.0
        return UIColor(red:r,green:g,blue:b,alpha:alpha)
    } else {
        print("invalid hex string", terminator: "")
        return UIColor.white
    }
}

func convertDataSubscription(date:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = dateFormatter.date(from: date)
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: date!)
}

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
//    let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
    let label:UILabel = UILabel(frame: CGRect (x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}



