//
//  FeedbackViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/10/19.
//  Copyright © 2019 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SWRevealViewController
import MessageUI
//import SkyFloatingLabelTextField
import SVProgressHUD
import AFNetworking
import SwiftyJSON
import MBProgressHUD

class FeedbackViewController: UIViewController, SWRevealViewControllerDelegate {

    
    //MARK:- Vaiables
    
    let composer = MFMailComposeViewController()

    
    //MARK:- IBOutlet
    
    @IBOutlet weak var txtFristName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLastName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPhoneNumber: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtMessage: SkyFloatingLabelTextField!
    
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
 
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()

        [btnCancle,btnAdd].forEach{(btn) in
            btn?.layer.cornerRadius = (btn?.frame.height)! / 2
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: SWRevealViewController Delegate Method
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
//        txtComment.resignFirstResponder()
    }
    
    //MARK:- Action
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancleAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnAddAction(_ sender: Any) {
        FeedbackApi()
    }
 
}

extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

// -----------------------------------
//  MARK: - UITextView Delegate Method -

extension FeedbackViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
//            textView.text = "Comment"
            textView.textColor = UIColor.lightGray
        }
    }
}

//MARK:- FeedbackApi

extension FeedbackViewController {
    
    func FeedbackApi(){
        
        if !validation() {
            return
        }
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        
        var param = [String:Any]()
        param[message] = txtMessage.text
        param[kFirstName] = txtFristName.text
        param[kLastName] = txtLastName.text
        param[kEmail] = txtEmail.text
        param[kPhone] = txtPhoneNumber.text
        
        APICall.call_API_ALL(url: API.FEEDBACK, param: param) { (object, error) in
            hud .hide(animated: true)
            
            if let error = error {
                DisplayAlert(title: oppsmsg , message: error.localizedDescription, vc: self)
            }else{
                let object = JSON(object as Any)
                print(object)
                DisplayAlertwithBack(title: "", message: object["data"]["message"].stringValue , vc: self)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
//                    self.navigationController?.popViewController(animated: true)
//                }
            }
        }
        
    }
    
    func validation() -> Bool {
        
        if txtFristName.text == "" {
            DisplayAlert(title: "Oops!", message: "First Name is required!", vc: self)
            return false
        }else if txtLastName.text == ""{
            DisplayAlert(title: "Oops!", message: "Last Name is required!", vc: self)
            return false
        }else if txtPhoneNumber.text == ""{
            DisplayAlert(title: "Oops!", message: "Phone Number is required!", vc: self)
            return false
        }else if txtEmail.text == ""{
            DisplayAlert(title: "Oops!", message: "Email is required!", vc: self)
            return false
        }else if txtMessage.text == ""{
            DisplayAlert(title: "Oops!", message: "Feedback is required!", vc: self)
            return false
        }
        return true
    }

}
