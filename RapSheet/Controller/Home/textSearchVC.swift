//
//  textSearchVC.swift
//  RapSheet
//
//  Created by MACMINI on 09/11/20.
//  Copyright © 2020 Kalpesh Satasiya. All rights reserved.
//

import UIKit
//import SkyFloatingLabelTextField
import IQKeyboardManager
import AFNetworking
import SwiftyJSON
import GoogleMobileAds
import MBProgressHUD
import Firebase
import Mixpanel

protocol TextFieldValue : class{
    func textFieldEnterValue(text:String)
}

class textSearchVC: UIViewController {

    //MARK:- VARIABLE
    weak var delegate: TextFieldValue?
    var textValue : String?
    var arrSearchList:[JSON] = []
    var window: UIWindow?
    var tabBarIndex: Int?
    var interstitial : GADInterstitial?
    let allowedCharacters = CharacterSet(charactersIn:"0123456789").inverted

    //MARK:- OUTLET
    
    @IBOutlet weak var txtNumber: SkyFloatingLabelTextField!
    @IBOutlet weak var btnSearch: UIButton!
    
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SetupUI()
        interstitial = createAndLoadInterstitial()
    }
    
    func SetupUI(){
//        IQKeyboardManager.shared().toolbarDoneBarButtonItemText = "Search"

        addDoneButtonOnKeyboard()
        txtNumber.delegate = self
        txtNumber.text = ""
        txtNumber.becomeFirstResponder()
//        txtNumber.text = textValue
        
        if txtNumber.text != "" {
            btnSearch.setTitle("Search", for: .normal)
        }
        else {
            btnSearch.setTitle("Paste", for: .normal)
        }
//        btnSearch.setTitle("Search Number", for: .normal)
        [btnSearch].forEach{(btn) in
            btn?.layer.cornerRadius = (btn?.frame.height)! / 2
            btn?.titleLabel?.font = UIFont(name: APP_DISPLAY_REGULER_FONT, size: 16)
            btn?.tintColor = .white
        }
    }

    
    
    //MARK:- ACTION
//    mixPanelId
    
    @IBAction func btnCancleAction(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func btnSearchAction(_ sender: Any) {
        
        if btnSearch.title(for: .normal) == "Search"{
            if txtNumber.text != ""{
                apiCallSearchResult()
                Analytics.logEvent("Search", parameters: [
                    "Number": txtNumber.text as Any
                ])
                Mixpanel.mainInstance().track(event: "Search",
                                              properties: ["Number" : "\(txtNumber.text ?? "")" ])
                
            }
        }else{
            
//            txtNumber.text = copy
//            var val : String = ""
//            if let copy = UIPasteboard.general.string{
//                if copy.count <= 10 {
//                    for u in copy.utf16 {
//                        print(u)
//                        val = val + "\(u)"
//                    }
//                }
//                print(copy)
//
//            }
//            txtNumber.text = val
            
            
//            var val : String = ""
            if let copy = UIPasteboard.general.string{
                if (copy.rangeOfCharacter(from: .decimalDigits) != nil) {
                    if copy.count <= 10 {
                        btnSearch.setTitle("Search", for: .normal)
                        txtNumber.text = copy
                    }else{
                        btnSearch.setTitle("Paste", for: .normal)
                        txtNumber.text = ""
                    }
                }else{
                    btnSearch.setTitle("Paste", for: .normal)
                    /*
                    for u in copy.utf16 {
                        print(u)
                        val = val + "\(u)"
                    }
                    
                    if val.count <= 10 {
                        btnSearch.setTitle("Search", for: .normal)
                        txtNumber.text = val
                    }else{
                        btnSearch.setTitle("Paste", for: .normal)
                        txtNumber.text = ""
                    }
                     */
                    
                }
            }
            
//            btnSearch.setTitle("Paste", for: .normal)
        }
    }
    
    @IBAction func btnResetAction(_ sender: Any) {
        txtNumber.text = ""
        btnSearch.setTitle("Paste", for: .normal)
    }
    
}

public extension String {
    func wordToInteger() -> Int? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .spellOut
        return  numberFormatter.number(from: self) as? Int
    }
}

//MARK:- Done button action

extension textSearchVC{
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.tintColor = .black
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonClicked))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.txtNumber.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonClicked(){
        print("search")
        
        if txtNumber.text != ""{
            apiCallSearchResult()
        }
    }
    
}
//MARK:- Load Full Screen ads

extension textSearchVC{
    
    func loadFullScreenAds()  {
        interstitial = GADInterstitial(adUnitID: API.FULLSCREEN_ADS)
        interstitial?.delegate = self
        let request = GADRequest()
        interstitial?.load(request)
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: API.FULLSCREEN_ADS)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//        interstitial = createAndLoadInterstitial()
//    }
    
    func
    showAd() {
        if ((interstitial?.isReady) != nil) {
//            let root = UIApplication.shared.windows.first?.rootViewController
            interstitial?.present(fromRootViewController: self)
        }
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad presented.")
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("Rewarded ad failed to present.")
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
 
}
 
//MARK:- GADInterstitialDelegate METHOD

extension textSearchVC :GADInterstitialDelegate{
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    internal func interstitialDidDismissScreen(_ ad: GADInterstitial) {
            // Send another GADRequest here
            print("Ad dismissed")
            interstitial = createAndLoadInterstitial()
            if let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as? ContactDetailScreenViewController {
            vcContactDetail.Contact_ID = self.arrSearchList[0]["id"].stringValue
            vcContactDetail.isComeScreen = .Search
            vcContactDetail.delegate = self

            self.navigationController?.pushViewController(vcContactDetail, animated: true)
            }
        }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
    
}


//  MARK:- UITextField Delgate Method

extension textSearchVC : UITextFieldDelegate {
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//            textField.text = ""
//        }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        txtNumber.keyboardType = .numberPad
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return txtNumber.resignFirstResponder()
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtNumber.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            
            let components = string.components(separatedBy: allowedCharacters)
            let filtered = components.joined(separator: "")
            
            if string == filtered && txtAfterUpdate.count <= 10{
                if txtAfterUpdate.count > 0 {
                    btnSearch.setTitle("Search", for: .normal)
                }else{
                    btnSearch.setTitle("Paste", for: .normal)
                }
                return true
            }
            return false
            
        }
        
        
        //        let textString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        //
        //        if textField == txtNumber  && string.count > 0{
        //            let numberOnly = NSCharacterSet.decimalDigits
        //            guard let val = UnicodeScalar("string") else {
        //                return false
        //            }
        //            let strValid = numberOnly.contains(val)
        //            return strValid && textString.count <= 10
        //        }
        //        return true
        
        //        if textField.text?.count == 0 && string == "0" && string.count > 10 {
        //                return false
        //            }
        //        return string == string.filter("0123456789".contains)
        //        let text = textField.text
        //        if text != nil && text != "" {
        //            if let text = textField.text,
        //                       let textRange = Range(range, in: text) {
        //                        let updatedText = text.replacingCharacters(in: textRange,
        //                                                                   with: string)
        //                if text.count == 0 || text.count <= 0{
        //                    btnSearch.setTitle("Search", for: .normal)
        //                }else{
        //                    btnSearch.setTitle("Paste", for: .normal)
        //                }
        //                return updatedText.count <= 10
        //            }
        //        }
        
        return true
        
    }
    
    func doStringContainsNumber( _string : String) -> Bool{
        
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        
        return containsNumber
    }
    
}

//MARK:- Serach Record

extension textSearchVC {
    
    func apiCallSearchResult()  {
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        
        let escapedString = txtNumber.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let strSearchURL = API.SEARCH + "\(escapedString!)"
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.get(strSearchURL, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print("responseObject:-\(String(describing: responseObject))")
            hud.hide(animated: true)
            
            if let jsonResponse = responseObject as? NSDictionary {
                
                let dictData = JSON(jsonResponse)
                self.arrSearchList = dictData["data"].arrayValue
                if self.arrSearchList.count == 0 {
                    appDelegate.strval = "1"
                    appDelegate.issearch = false
                    defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
                    txtSearchNumber = self.txtNumber.text ?? ""
                    self.tabBarController?.selectedIndex = 0
                    
                    print("no data")
                }else{
                    appDelegate.strval = "0"
                    appDelegate.issearch = true
                    //                    defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
                    if (defaults.bool(forKey: "purchased")){
                        self.interstitial = nil
                    } else if (!defaults.bool(forKey: "stonerPurchased")) {
                        print("false")
                        self.showAd()
                    }
                    
                    //                    if let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as? ContactDetailScreenViewController {
                    //                        vcContactDetail.Contact_ID = self.arrSearchList[0]["id"].stringValue
                    //                        vcContactDetail.isComeScreen = .Search
                    //                        vcContactDetail.delegate = self
                    //
                    //                        self.navigationController?.pushViewController(vcContactDetail, animated: true)
                    //                    }
                    
                }
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            guard let responseCode = task?.response else {
                DisplayAlertwithBack(title: oppsmsg , message: CheckConnection , vc: self)
                return
            }
            
            let statuscode = responseCode as! HTTPURLResponse
            if(statuscode.statusCode == 500) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: oppsmsg , message: CheckConnection , vc: self)
                
            } else  {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: oppsmsg , message: SomethingWrong , vc: self)
            }
            
        }
    }
}

//MARK:- DELEGATE

extension textSearchVC : BlockListReloadDelegateProtocol {
    func sendDataToFirstViewController(reloadStatus: Bool) {
        print(reloadStatus)
    }
    
    func navigatetoHome() {
        self.tabBarController?.selectedIndex = 0
    }
}

