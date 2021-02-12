//
//  RemoveResultVC.swift
//  RapSheet
//
//  Created by MACMINI on 07/11/20.
//  Copyright © 2020 Kalpesh Satasiya. All rights reserved.
//

import UIKit
//import SkyFloatingLabelTextField


class RemoveResultVC: UIViewController {

    //MARK:- OUTLET
    
    @IBOutlet weak var lblRemove: UILabel!
    @IBOutlet weak var txtPhoneNumber: SkyFloatingLabelTextField!
    
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    
    //MARK:- VARIABLE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblRemove.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
        lblRemove.tintColor = .white
        [btnCancle,btnRemove].forEach{(btn) in
            btn?.layer.cornerRadius = (btn?.frame.height)! / 2
        }
    }
    
    
    //MARK:- ACTION
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btncancleAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRemoveAction(_ sender: Any) {
        DisplayAlertwithBack(title: "", message: "Remove Request Sent.", vc: self)
        self.navigationController?.popViewController(animated: true)
    }
    
}

// -----------------------------------
//  MARK: - UITextView Delegate Method -
//

extension RemoveResultVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
        }
    }
}
