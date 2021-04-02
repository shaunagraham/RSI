//
//  AddNewContactViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 09/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
//import SkyFloatingLabelTextField
import SVProgressHUD
import AFNetworking
import SwiftyJSON
import MBProgressHUD

enum comeScreen {
    case contactDetail,Home
}

class AddNewContactViewController: UIViewController {
    
    var dictUserDetail:NSDictionary = UserDefaults.standard.object(forKey: "isUserLogin") as? NSDictionary ?? NSDictionary()
    var defaults = UserDefaults.standard
    var dataarray:[(parameter_name:String,data:Data,type:String)] = []
    var isImageSelect:Bool = false
    var profilePicData:Data!
    var dictContactDetail = JSON()
    var isComeAddNewContact :comeScreen = .contactDetail
    
    //MARK:- Outlet
    
    @IBOutlet var viewImage: UIView!
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet weak var txtFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLastName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPhoneNumber: SkyFloatingLabelTextField!
//    @IBOutlet weak var txtExtraInfo: SkyFloatingLabelTextField!
//    @IBOutlet var txtInstgramLink: SkyFloatingLabelTextField!
//    @IBOutlet var txtFacebookLink: SkyFloatingLabelTextField!
//    @IBOutlet var txtLinkdinLink: SkyFloatingLabelTextField!
////    @IBOutlet var viewBannerAd: GADBannerView!
//    @IBOutlet var viewBannerHeightConstraints: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var lblAddcontact: UILabel!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnadd: UIButton!
    
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        print(dictUserDetail)
        /*
        if (defaults.bool(forKey: "purchased")){
            // Hide a view or show content depends on your requirement
            //            overlayView.hidden = true
            viewBannerHeightConstraints.constant = 0
            
        } else if (!defaults.bool(forKey: "stonerPurchased")) {
            viewBannerAd.adUnitID = API.BANNER_ADS
            viewBannerAd.rootViewController = self
            viewBannerAd.load(GADRequest())
            
        }
        */
        
        lblAddcontact.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
        lblAddcontact.tintColor = .white
        [btnCancle,btnadd].forEach{(btn) in
            btn?.layer.cornerRadius = (btn?.frame.height)! / 2
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isComeAddNewContact == .contactDetail {
            if "\(dictContactDetail["details"]["profile"])" != "" && "\(dictContactDetail["details"]["profile"])" != "null"{
                self.imgUser.sd_setImage(with: URL(string: imageURLPath + "/\(dictContactDetail["details"]["profile"])"), completed: nil)
            }else{
                self.imgUser.image = UIImage(named: "ic_add_profile")
            }
            txtFirstName.text = "\(dictContactDetail["details"]["first_name"].stringValue.capitalized)"
            txtLastName.text = "\(dictContactDetail["details"]["last_name"].stringValue.capitalized)"
            let mobileNumber = formatNumber(phoneNumber: dictContactDetail["details"]["number"].stringValue, shouldRemoveLastDigit: false)
            txtPhoneNumber.text = mobileNumber
            txtPhoneNumber.isUserInteractionEnabled = false
            txtEmail.text = dictContactDetail["details"]["email"].stringValue
        }else{
            txtPhoneNumber.isUserInteractionEnabled = true
            txtFirstName.text = ""
            txtLastName.text = ""
            txtPhoneNumber.text = ""
            txtEmail.text = ""
        }
    }
    
    // MARK:- Validation
    
    func validation() -> Bool {
        
        
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        
        if txtFirstName.text == "" {
            DisplayAlert(title: "Oops!", message: "First Name is required!", vc: self)
            return false
        }
//        else if txtLastName.text == ""{
//            DisplayAlert(title: "Oops!", message: "Last Name is required!", vc: self)
//            return false
//        }
        else if txtPhoneNumber.text == ""{
            DisplayAlert(title: "Oops!", message: "Phone Number is required!", vc: self)
            return false
        }
//        else if txtEmail.text == ""{
//            DisplayAlert(title: "Oops!", message: "Email is required!", vc: self)
//            return false
//        }
        
        return true
        
    }
    
    //MARK:- Action
        
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSelectImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Camera And Gallery Image Selection
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            let imagePicker = UIImagePickerController()
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onAdd(_ sender: Any) {
        if !validation(){
            return
        }
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let param = [String :Any]()
            
//            [kFirstName : txtFirstName.text ?? "", kLastName :txtLastName.text ?? "", kEmail :txtEmail.text ?? "", kNumber :txtPhoneNumber.text ?? "", kWeblink : txtExtraInfo.text ?? "", kInstagram : txtInstgramLink.text ?? "", kFacebook : txtFacebookLink.text ?? "", kLinkedin : txtLinkdinLink.text ?? "", kUserid : dictUserDetail .value(forKey: "id")!] as [String : Any]
        
        
        if self.profilePicData != nil {
            let t1 = (parameter_name:"profile",data:self.profilePicData,type:"profile_pic")
            dataarray.append(t1 as! (parameter_name: String, data: Data, type: String))
        }
        
        APICall.call_API_ImageUpload(url: API.ADD_CONTACT, param: param, doc: dataarray) { (responseObject, error)  in
            DispatchQueue.main.async {
                hud .hide(animated: true)
                
                
                if let error = error {
                    self.showToast(message: error.localizedDescription)
                }else{
                    let dictData = JSON(responseObject!)

                    if let message =  dictData["error"].string {
                        self.showToast(message: message)
                    }else{
                        let dictUserDetail = dictData["info"]
                        /*
                        let vcAddComment = self.storyboard?.instantiateViewController(withIdentifier: "AddCommentScreenViewController") as! AddCommentScreenViewController
                        vcAddComment.Contact_Id = dictUserDetail["id"].stringValue
                        vcAddComment.strWhichSscreen = "Add Contact"
                        
                        self.navigationController?.pushViewController(vcAddComment, animated: true)*/
                        
                        let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as! ContactDetailScreenViewController
                        vcContactDetail.Contact_ID = dictUserDetail["id"].stringValue
                        vcContactDetail.strWhichScreen = "Add Contact"
                        vcContactDetail.isComeScreen = .addnewContact
                        vcContactDetail.delegate = self
                        self.navigationController?.pushViewController(vcContactDetail, animated: true)
                    }
                }
            }
        }
        /*
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
        manager.post(API.ADD_CONTACT, parameters: param, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            
            hud.hide(animated: true)
            if let jsonResponse = responseObject as? NSDictionary {
                // here read response
                
                
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            hud.hide(animated: true)

            guard let responseCode = task?.response else {
                DisplayAlertwithBack(title: "Oops!", message: "Please check your internet connection.", vc: self)
                return
            }
            
            //            let responseCode = task?.response as! HTTPURLResponse
            let statuscode = responseCode as! HTTPURLResponse
            if(statuscode.statusCode == 500) {
                let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
//                print(errResponse)
                
                DisplayAlert(title: "Oops!", message: "Please check your internet connection", vc: self)
                
                
            } else {
                let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: "Oops!", message: "Something went wrong.", vc: self)
                //DisplayAlert(title: "Oops!", message: errResponse, vc: self)
            }
            
        }*/
    }

}

//MARK:- DELEGATE

extension AddNewContactViewController : BlockListReloadDelegateProtocol {
    func sendDataToFirstViewController(reloadStatus: Bool) {
        print(reloadStatus)
    }
    
    func navigatetoHome() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- UITextField Delegate Method

extension AddNewContactViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtFirstName {
            txtFirstName.resignFirstResponder()
            txtLastName.becomeFirstResponder()
        }else if textField == txtLastName {
            txtLastName.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        }else if textField == txtPhoneNumber {
            txtPhoneNumber.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        }else if textField == txtEmail{
            txtEmail.resignFirstResponder()
            //txtExtraInfo.becomeFirstResponder()
        }
        /*
        else if textField == txtExtraInfo{
            txtExtraInfo.resignFirstResponder()
            txtInstgramLink.becomeFirstResponder()
        }else if textField == txtInstgramLink{
            txtInstgramLink.resignFirstResponder()
            txtFacebookLink.becomeFirstResponder()
        }else if textField == txtFacebookLink {
            txtFacebookLink.resignFirstResponder()
            txtLinkdinLink.becomeFirstResponder()
        }else {
            txtLinkdinLink.resignFirstResponder()
        }
 */
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPhoneNumber {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 16 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 16) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
            
        }
//        else if textField == txtExtraInfo {
//            let maxLength = 20
//            let currentString: NSString = textField.text! as NSString
//            let newString: NSString =
//                currentString.replacingCharacters(in: range, with: string) as NSString
//            return newString.length <= maxLength
//        }
        else{
            return true
        }
    }
}

//MARK:- UIImagePickerView Delegate Method

extension AddNewContactViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            isImageSelect = true
            imgUser.image = editedImg
            profilePicData = editedImg.jpegData(compressionQuality: 0.4)
            
        } else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            isImageSelect = true
            imgUser.image = originalImg
            profilePicData = originalImg.jpegData(compressionQuality: 0.4)
        }
        
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            // imageViewPic.contentMode = .scaleToFill
//
//
//        }
        picker.dismiss(animated: true, completion: nil)
        
    }
}
