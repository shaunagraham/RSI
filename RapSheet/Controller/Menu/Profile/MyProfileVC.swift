//
//  MyProfileVC.swift
//  RapSheet
//
//  Created by MACMINI on 07/11/20.
//  Copyright © 2020 Kalpesh Satasiya. All rights reserved.
//

import UIKit
//import SkyFloatingLabelTextField
import SVProgressHUD
import AFNetworking
import SwiftyJSON
import MBProgressHUD
import KeychainAccess

class MyProfileVC: UIViewController {

    //MARK:- OUTLET
    @IBOutlet weak var lblMyProfile: UILabel!

    @IBOutlet weak var txtFirstName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLastName: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPhoneNumber: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var imgMyProfile: UIImageView!
    
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    //MARK:- VARIABLE
    let keychain = Keychain(service: "com.adrapsheet.crawlapps")
    var isImageSelect:Bool = false
    var dataarray:[(parameter_name:String,data:Data,type:String)] = []
    var profilePicData:Data?
    var profileData : profile?
    var profile : JSON?
    
    
    func validation() -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if txtFirstName.text == "" {
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
        }
        return true
    }
    
    //MARK: Camera And Gallery Image Selection
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
    
    //MARK:- BUTTON ACTION
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCancleAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddAction(_ sender: Any) {
        Userupdate()
    }
    
    @IBAction func onSelectImage_Click(_ sender: UIButton) {
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
    
    //MARK:- LIFE CYCLE METHOD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupUI()
        // Do any additional setup after loading the view.
    }
  
    override func viewWillAppear(_ animated: Bool) {
        
        if let token = try? self.keychain.get("deviceId") {
            getContactDetail(Id: token)
        }
       
    }
    
    func SetupUI(){
        lblMyProfile.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
        lblMyProfile.tintColor = .white
        [btnCancle,btnAdd].forEach{(btn) in
            btn?.layer.cornerRadius = (btn?.frame.height)! / 2
        }
        [txtEmail,txtFirstName,txtLastName,txtPhoneNumber].forEach{ (txt) in
            txt?.delegate = self
        }
        
    }
}

//MARK:- UITextField Delegate Method

extension MyProfileVC : UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtLastName {
            print("TextField did begin editing method called")
            // Do your Validate for first text field
        } else {
            //Do Nothing
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtFirstName {
            txtFirstName.resignFirstResponder()
            txtLastName.becomeFirstResponder()
        }else if textField == txtLastName {
            txtLastName.resignFirstResponder()
            txtPhoneNumber.becomeFirstResponder()
        }else if textField == txtPhoneNumber {
            txtPhoneNumber.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        }else if textField == txtEmail{
            txtEmail.resignFirstResponder()
        }
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
            
        }else{
            return true
        }
 
        
       
    }
}

//MARK: - UIImagePickerView Delegate Method
extension MyProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            isImageSelect = true
            imgMyProfile.image = editedImg
            profilePicData = editedImg.jpegData(compressionQuality: 0.4)
            
        } else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            isImageSelect = true
            imgMyProfile.image = originalImg
            profilePicData = originalImg.jpegData(compressionQuality: 0.4)
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
}

//MARK:- API CALL

extension MyProfileVC {
    func Userupdate(){
        
        if !validation() {
            return
        }
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        
        var param = [String:Any]()
        param[kFirstName] = txtFirstName.text
        param[kLastName] = txtLastName.text
        param[kEmail] = txtEmail.text
        param[kPhone] = txtPhoneNumber.text
        
        if let token = try? self.keychain.get("deviceId") {
            param[kUUID] = token
        }
        
        
        if self.profilePicData != nil {
            let t1 = (parameter_name:"profile",data:self.profilePicData,type:"profile_pic")
            dataarray.append(t1 as! (parameter_name: String, data: Data, type: String))
        }
        
        print("param\(param)")
        print("profilePicData \(String(describing: profilePicData))")
        
        APICall.call_API_ImageUpload(url: API.USERUPDATE, param: param, doc: dataarray) { (responseObject, error)  in
            DispatchQueue.main.async {
                
                if let error = error {
                    self.showToast(message: error.localizedDescription)
                }else{
                    hud .hide(animated: true)

                    let dictData = JSON(responseObject as Any)
                    
                    if let message =  dictData["error"].string {
                        self.showToast(message: message)
                    }else{
                        let dictUserDetail = dictData["info"]
                        print("data \(dictUserDetail)")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func getContactDetail(Id:String)  {
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        
        
        APICall.call_API_Get_Mehotd(url: API.GETUSER + Id) { (object) in
            hud .hide(animated: true)
            
            self.profile = JSON(object)
            print("objectDetail:-\(String(describing: self.profile))")
            
            if self.profile?["success"] == false{
                DisplayAlert(title: oppsmsg , message: self.profile?["error"].stringValue ?? "", vc: self)
            }else{
                
                let strdetail = self.profile?["info"][0]
                if strdetail != ""{
                    self.txtFirstName.text = strdetail?["first_name"].stringValue
                    self.txtLastName.text = strdetail?["last_name"].stringValue
                    self.txtPhoneNumber.text = strdetail?["phone"].stringValue
                    self.txtEmail.text = strdetail?["email"].stringValue
                    if strdetail?["profile"].stringValue == ""{
                        self.imgMyProfile.image = UIImage(named: "ic_add_profile.png")
                    }else{
                        self.imgMyProfile.sd_setImage(with: URL(string: imageURLPath + "/\(strdetail?["profile"].stringValue ?? "ic_add_profile.png")"), completed: nil)
                    }
                }
                
                
            }
        }
        
        
    }
    
}

class profile {
    var success : String?
    var info : info?
}

class info {
    var id : String?
    var email : String?
    var first_name : String?
    var last_Name : String?
    var phone : String?
    var profile : String?
    var uuid : String?
    var password : String?
    var created_at : String?
    var updated_at : String?
    
    class func getPaymentInfo(dicPaymentInfo:NSDictionary) -> info {
        
        let objPaymentInfo = info()
        
        objPaymentInfo.id = String(format: "%@", dicPaymentInfo.object(forKey: "id") as? CVarArg ?? "0")
        objPaymentInfo.email = String(format: "%@", dicPaymentInfo.object(forKey: "email") as? CVarArg ?? "0")
        objPaymentInfo.first_name = String(format: "%@", dicPaymentInfo.object(forKey: "first_name") as? CVarArg ?? "0")
        objPaymentInfo.last_Name = String(format: "%@", dicPaymentInfo.object(forKey: "last_Name") as? CVarArg ?? "0")
        objPaymentInfo.phone = String(format: "%@", dicPaymentInfo.object(forKey: "phone") as? CVarArg ?? "0")
        objPaymentInfo.profile = String(format: "%@", dicPaymentInfo.object(forKey: "profile") as? CVarArg ?? "0")
        objPaymentInfo.uuid = String(format: "%@", dicPaymentInfo.object(forKey: "uuid") as? CVarArg ?? "0")
        
        objPaymentInfo.password = String(format: "%@", dicPaymentInfo.object(forKey: "password") as? CVarArg ?? "0")
        objPaymentInfo.created_at = String(format: "%@", dicPaymentInfo.object(forKey: "created_at") as? CVarArg ?? "0")
        objPaymentInfo.updated_at = String(format: "%@", dicPaymentInfo.object(forKey: "updated_at") as? CVarArg ?? "0")

        return objPaymentInfo
    }
    
}

