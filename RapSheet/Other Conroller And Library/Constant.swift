//
//  Constant.swift
//  RapSheet
//
//  Created by DREAMWORLD on 02/11/20.
//  Copyright © 2020 Kalpesh Satasiya. All rights reserved.
//

import Foundation
import UIKit

var defaults = UserDefaults.standard
var txtSearchNumber = String()
let appDelegate = UIApplication.shared.delegate as! AppDelegate


let TAB_SELECTED_COLOR = RGBA(29, g: 173, b: 169, alpha: 1.0)
let TAB_UNSELECTED_COLOR = RGBA(99, g: 114, b: 128, alpha: 1.0)
let TAB_BACKGROUND_COLOR = RGBA(248, g: 248, b: 248, alpha: 1.0)
let BACKGROUND_COLOR = RGBA(249, g: 189, b: 53, alpha: 1.0)
let LABEL_COLOR = RGBA(155, g: 169, b: 182, alpha: 1.0)
let APP_WHITE_COLOR = RGBA(255, g: 255, b: 255, alpha: 1.0)
let APP_DETAILSCREEN_COLOR = RGBA(155, g: 169, b: 182, alpha: 1.0)


func RGBA(_ r: CGFloat, g: CGFloat, b:CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
}

//MARK:- FONT

let APP_FUTURA_FONT = "futura"
let APP_MEDIUM_FONT = "SFProText-Medium"
let APP_SEMIBOLD_FONT = "SFProText-Semibold"
let APP_DISPLAY_THIN_FONT = "SFProDisplay-Thin"
let APP_DISPLAY_BOLD_FONT = "SFProDisplay-Bold"
let APP_DISPLAY_REGULER_FONT = "SFProText-Regular"



extension UITableView {

    func setEmptyMessage(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension  UIViewController {

    func showAlert(withTitle title: String, withMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
        })
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}
