//
//  EvryAPIContactDetailViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 16/01/19.
//  Copyright © 2019 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SwiftyJSON

class EvryAPIContactDetailViewController: UIViewController {
    
    var dictContactDetail:JSON?

    
    
    //MARK: Outlet
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var lblGender: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblCName: UILabel!
    @IBOutlet var lblMMSEmail: UILabel!
    @IBOutlet var lblSMSEMail: UILabel!
    @IBOutlet var lblCarrierName: UILabel!
    
    @IBOutlet var imgWidthConstraints: NSLayoutConstraint!
    @IBOutlet var imgHeightConstraints: NSLayoutConstraint!
    @IBOutlet var imgRightConstraints: NSLayoutConstraint!
    
    @IBOutlet var lblGenedarTopConstraints: NSLayoutConstraint!
    @IBOutlet var lblCarrierTopConstraints: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        callEvryOneApi()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Call Evry On Api
    
    func callEvryOneApi() {
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        hud.backgroundColor = UIColor.white
        
        let strSearchURL = "\(everyOneAPI)\(dictContactDetail?["details"]["number"].stringValue ?? "")\(Auth_Token)"
        
        
        APICall.call_API_Get_Mehotd(url: strSearchURL) { (dictObject) in
            hud .hide(animated: true)
            
            
            print(dictObject)
            let dictRespnse = JSON(dictObject .value(forKey: "data") as Any)
            
            let strProfile = dictRespnse["profile"].stringValue
            let strName = dictRespnse["name"].stringValue
            
            if strProfile == "" {
                self.imgRightConstraints.constant = 0
                self.imgWidthConstraints.constant = 0
                self.imgHeightConstraints.constant = 0
            }else{
                loadImageWithURL(url: strProfile, view: self.imgUser)
            }

            if strName == "" {
                
                let attributedString = setAttributSting(str: "Name: \(self.dictContactDetail?["details"]["first_name"].stringValue.capitalized ?? "") " + "\(self.dictContactDetail?["details"]["last_name"].stringValue.capitalized ?? "")", string_first: "Name:", string_second: "\(self.dictContactDetail?["details"]["first_name"].stringValue.capitalized ?? "") " + "\(self.dictContactDetail?["details"]["last_name"].stringValue.capitalized ?? "")")
                self.lblName.attributedText = attributedString
                
            } else {
                let attributedString = setAttributSting(str: "Name: \(dictRespnse["name"].stringValue.capitalized)", string_first: "Name:", string_second: "\(dictRespnse["name"].stringValue.capitalized)")
                self.lblName.attributedText = attributedString

            }
            
            let mobileNumber = formatNumber(phoneNumber: self.dictContactDetail?["number"].stringValue ?? "", shouldRemoveLastDigit: false)
            
            let attributedMobileString = setAttributSting(str: "Number: \(mobileNumber)", string_first: "Number:", string_second: "\(mobileNumber)")
            self.lblPhone.attributedText = attributedMobileString
            
            let LocationAttribute = setAttributSting(str: "Location: \(dictRespnse["location"]["city"].stringValue), \(dictRespnse["location"]["state"].stringValue ), \(dictRespnse["location"]["zip"].stringValue )", string_first: "Location:", string_second: "\(dictRespnse["location"]["city"].stringValue), \(dictRespnse["location"]["state"].stringValue ), \(dictRespnse["location"]["zip"].stringValue )")
            self.lblAddress.attributedText = LocationAttribute
            
            
            if !dictRespnse["type"].stringValue.isEmpty {
                let attributedString = setAttributSting(str: "Type: \(dictRespnse["type"].stringValue)", string_first: "Type:", string_second: "\(dictRespnse["type"].stringValue)")
                self.lblCName.attributedText = attributedString
            }else{
                self.lblCarrierTopConstraints.constant = 0
            }
            
            if !dictRespnse["Gender"].stringValue.isEmpty {
                let attributedString = setAttributSting(str: "Gender: \(dictRespnse["gender"].stringValue)", string_first: "Gender:", string_second: "\(dictRespnse["gender"].stringValue)")
                self.lblGender.attributedText = attributedString
            } else {
                self.lblGenedarTopConstraints.constant = 0
            }
            
            if !dictRespnse["carrier"]["name"].stringValue.isEmpty {
                let attributedString = setAttributSting(str: "Carrier: \(dictRespnse["carrier"]["name"].stringValue)", string_first: "Carrier:", string_second: "\(dictRespnse["carrier"]["name"].stringValue)")
                self.lblCarrierName.attributedText = attributedString
            }
            
            if !dictRespnse["line_provider"]["mms_email"].stringValue.isEmpty {
                self.lblMMSEmail.text = "\(dictRespnse["line_provider"]["mms_email"].stringValue)"
            }
            
            if !dictRespnse["line_provider"]["mms_email"].stringValue.isEmpty {
                self.lblSMSEMail.text = "\(dictRespnse["line_provider"]["sms_email"].stringValue)"
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: Action
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
