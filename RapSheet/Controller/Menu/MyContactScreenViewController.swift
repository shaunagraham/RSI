//
//  MyContactScreenViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import SVProgressHUD
import MBProgressHUD
import GoogleMobileAds

class MyContactScreenViewController: UIViewController {
    
    
    
    //MARK:- Outlet
    
    @IBOutlet var viewBannerAds: GADBannerView!
    @IBOutlet weak var lblNoRecordYet: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var btnAddcontact: UIButton!
    @IBOutlet weak var tblMyContactList: UITableView! {
        didSet {
            tblMyContactList.register(UINib(nibName: ContactListTableViewCell.className, bundle: Bundle.main), forCellReuseIdentifier: ContactListTableViewCell.className)
            tblMyContactList.tableFooterView = UIView()
        }
    }
    @IBOutlet var viewSearching: UIView!
    
    //MARK: - Variables
    var dictUserDetail:NSDictionary? = (UserDefaults.standard.object(forKey: "isUserLogin") as? NSDictionary ?? NSDictionary())
    var arrMyContact:[JSON] = []
    var isManageSearch:Bool = true
    var arrSearchObjectList:NSMutableArray?
    var intCountTap:Int = 0
    var intTextSearchCount:Int = 0
    var interstitial: GADInterstitial?
    
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       // leftSilder()
        /*
        if (defaults.bool(forKey: "purchased")){
            // Hide a view or show content depends on your requirement
            //            overlayView.hidden = true
            viewBannerHeightConstraints.constant = 0
            
        } else if (!defaults.bool(forKey: "stonerPurchased")) {
            viewBannerAds.adUnitID = API.BANNER_ADS
            viewBannerAds.rootViewController = self
            viewBannerAds.load(GADRequest())
        }
      */
        
//        lblmylist.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
//        lblmylist.tintColor = .white
        
        viewButton.applyCornerRadius(radius: viewButton.frame.size.height/2)
        
        viewSearch.applyCornerRadius(radius: viewSearch.frame.size.height/2)
        txtSearch.applyCornerRadius(radius: txtSearch.frame.size.height/2)
        txtSearch.attributedPlaceholder = NSAttributedString(string: "Search Number",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: APP_DISPLAY_THIN_FONT, size: 24)!])
        txtSearch.setLeftImage(imageName: "ic_search_white")
        txtSearch.text = ""
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMyContactList()
//        ManageSaveSearchResult()
    }
    
    @IBAction func btnAddcontactAction(_ sender: Any) {
        let vcHomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "AddNewContactViewController") as! AddNewContactViewController
        self.navigationController?.pushViewController(vcHomeScreen, animated: true)
    }
    
    @IBAction func btnLogo_Click(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    //MARK:- Get My Contact List
    
    func getMyContactList()  {
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        let strMyContactUrl = API.MY_CONTACT + "\(dictUserDetail! .value(forKey: "id") ?? "")"
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
        manager.get(strMyContactUrl, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {

                hud.hide(animated: true)
                print("jsonResponse: \(jsonResponse)")
                
                self.lblNoRecordYet.isHidden = true
                let dictData = JSON(jsonResponse)
                self.arrMyContact = dictData["Contacts"].arrayValue
                
                if self.arrMyContact.count == 0 {
                    self.lblNoRecordYet.text = "No Results Found"
                    self.viewButton.isHidden = false
                    self.btnAddcontact.isHidden = false
                    self.lblNoRecordYet.isHidden = false
                }else{
                    self.lblNoRecordYet.isHidden = true
                    self.viewButton.isHidden = true
                    self.btnAddcontact.isHidden = true
                }
                self.tblMyContactList.reloadData()
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            hud.hide(animated: true)

            guard let responseCode = task?.response else {
                DisplayAlertwithBack(title: "Oops!", message: "Please check your internet connection.", vc: self)
                return
            }
            let statuscode = responseCode as! HTTPURLResponse
            if(statuscode.statusCode == 500) {
                let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                print(errResponse)
                
                DisplayAlert(title: "Oops!", message: "Please check your internet connection", vc: self)
                
                
            } else if (statuscode.statusCode == 404) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: "Oops!", message: "Something went wrong.", vc: self)
                //DisplayAlert(title: "Oops!", message: errResponse, vc: self)
            }
        }
        
    }
    
    //MARK: Delete Billing Address
    
    func deleteBillingAddress(id:String, indexID:Int)  {
        
//        SVProgressHUD.show(withStatus: "Loading...")
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let strMyContactDeleteUrl = API.DELETE_CONTACT + "/\(id)/" + "\(dictUserDetail! .value(forKey: "id")!)"
        print(strMyContactDeleteUrl)
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
        manager.delete(strMyContactDeleteUrl, parameters: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if (responseObject as? NSDictionary) != nil {
                // here re(         hud.hide(animated: tru) != nile)
                
                self.arrMyContact .remove(at: indexID)
                self.tblMyContactList.reloadData()
                
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            hud.hide(animated: true)

            //            let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
            
            guard let responseCode = task?.response else {
                DisplayAlertwithBack(title: "Oops!", message: "Please check your internet connection.", vc: self)
                return
            }
            
            //            let responseCode = task?.response as! HTTPURLResponse
            let statuscode = responseCode as! HTTPURLResponse
            if(statuscode.statusCode == 500) {
                let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                print(errResponse)
                
                DisplayAlert(title: "Oops!", message: "Please check your internet connection", vc: self)
                
                
            } else {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: "Oops!", message: "Something went wrong.", vc: self)
                //DisplayAlert(title: "Oops!", message: errResponse, vc: self)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func apiCallSearchResult()  {
        
//        SVProgressHUD.show(withStatus: "Searching...")
        let escapedString = txtSearch.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let strSearchURL = API.SEARCH + "\(escapedString!)"
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
        manager.get(strSearchURL, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {
                 // here read response
//                SVProgressHUD.dismiss()
                self.txtSearch.text = ""
                self.lblNoRecordYet.isHidden = true
                
                let dictData = JSON(jsonResponse)
                print("dictData :-\(dictData)")
                
                self.isManageSearch = false
                DispatchQueue.main.async {
                    self.arrMyContact = dictData["data"].arrayValue
                    
                    if self.arrMyContact.count == 0 {
                        self.lblNoRecordYet.text = "No Results Found"
                        self.viewButton.isHidden = false
                        self.btnAddcontact.isHidden = false
                        self.lblNoRecordYet.isHidden = false
                        self.tblMyContactList.isHidden = true
                    }else{
                        self.tblMyContactList.reloadData()
                        self.lblNoRecordYet.isHidden = true
                        self.btnAddcontact.isHidden = true
                        self.viewButton.isHidden = true
                        self.tblMyContactList.setEmptyMessage(message:  "")
                        self.tblMyContactList.isHidden = false


                    }
                    self.viewSearching.isHidden = true
                }
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            SVProgressHUD.dismiss()

            let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
            
            let responseCode = task?.response as! HTTPURLResponse
            if(responseCode.statusCode == 500) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
//                print(errResponse)

                DisplayAlert(title: "Oops!", message: "Please check your internet connection", vc: self)


            } else {
                let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: "Oops!", message: errResponse, vc: self)
            }
        }
        
    }
    
    func ManageSaveSearchResult()  {
        if UserDefaults.standard.object(forKey: "SearchResult") != nil {
            if let data = UserDefaults.standard.object(forKey: "SearchResult") as? Data {
                if let arrSearchObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray
                {
                    print("arrSearchObject:\(arrSearchObject)")
                    
                    let dictData = JSON(arrSearchObject)
                    arrMyContact = dictData.arrayValue
                    arrSearchObjectList = arrSearchObject
                    if self.arrMyContact.count == 0 {
                        isManageSearch = true
                        self.lblNoRecordYet.text = "No Results Found"
                        self.viewButton.isHidden = false
                        self.btnAddcontact.isHidden = false
                        self.lblNoRecordYet.isHidden = false
                    }else{
                        self.tblMyContactList.isHidden = false
                        self.lblNoRecordYet.isHidden = true
                        self.btnAddcontact.isHidden = true
                        self.viewButton.isHidden = true

                    }
                    self.tblMyContactList.reloadData()
                }
            }

        }
    }

    func loadAds(){
        if (defaults.bool(forKey: "purchased")){
            // Hide a view or show content depends on your requirement
            viewBannerAds.isHidden = true
        } else if (!defaults.bool(forKey: "stonerPurchased")) {
            print("false")
            viewBannerAds.isHidden = false
            viewBannerAds.adUnitID = API.BANNER_ADS
            viewBannerAds.rootViewController = self
            viewBannerAds.load(GADRequest())
//            loadFullScreenAds()
//            loadRewarVideoAds()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("done")
                self.viewBannerAds.isHidden = true
            }
        }
    }

    
    //MARK: Action
    
   
    //MARK: Delete Savaed Contact
    func deleteSavedConatactForLocalDatabase(strUserId:String)  {
        if let data = UserDefaults.standard.object(forKey: "SearchResult") as? Data {
            
            if let arrSearchObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray {
                let dictData = JSON(arrSearchObject)
                
                let arrSearchList:[JSON] = dictData.arrayValue
                
                for (index, element) in arrSearchList.enumerated() {
                    
                    if element["id"].stringValue == strUserId {
                        arrSearchObject .removeObject(at: index)
                        let data = NSKeyedArchiver.archivedData(withRootObject: arrSearchObject)
                        UserDefaults.standard.set(data, forKey: "SearchResult")
                        UserDefaults.standard.synchronize()
                        
                        NotificationCenter.default.post(name: Notification.Name("NotificationToAddContact"), object: nil)
                        break
                    }
                }
            }
        }
    }
}

// ----------------------------------
//  MARK: - UITableViewDataSource -
//
extension MyContactScreenViewController : UITableViewDataSource {
    
    // ----------------------------------
    //  MARK: - Data -
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMyContact.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.className, for: indexPath) as? ContactListTableViewCell else {
            return UITableViewCell()
        }
        
        let dictContactDetail = arrMyContact[indexPath.section]
        cell.selectionStyle = .none

        cell.lblUserName.text = "\(dictContactDetail["first_name"].stringValue.capitalized) \(dictContactDetail["last_name"].stringValue.capitalized)"
        
//        let mobileNumber = format(phoneNumber: dictContactDetail["number"].stringValue)
        let mobileNumber = formatNumber(phoneNumber: dictContactDetail["number"].stringValue, shouldRemoveLastDigit: false)

//        if mobileNumber != nil {
            cell.lblMobileNumber.text = mobileNumber
//        }else{
//            cell.lblMobileNumber.text = dictContactDetail["number"].stringValue
//        }
        
        let Rating_Value = dictContactDetail["avg_rate"].stringValue
        let floatValue : Float = NSString(string: Rating_Value).floatValue
        
//        cell.viewRatingStar.maximumValue = 5
//        cell.viewRatingStar.allowsHalfStars = true
//        cell.viewRatingStar.value = CGFloat(floatValue)
//        cell.viewRatingStar.isEnabled = false
//        cell.viewRatingStar.tintColor = hexa("b25524", alpha: 1)
        
        return cell
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // Call edit action
            
            let dictContactDetail = self.arrMyContact[indexPath.section]

            
            // Reset state
            let alertVC = Alertview(title: "Warring!", body: "Are you sure you want to delete contact?", cancelbutton: "Cancel", okbutton: "Yes", completion: {
                self.deleteBillingAddress(id: dictContactDetail["id"].stringValue, indexID: indexPath.section)
                self.deleteSavedConatactForLocalDatabase(strUserId: dictContactDetail["id"].stringValue)
                
            })
            
            self.present(alertVC, animated: true, completion: nil)
            success(true)
        })
        deleteAction.image = UIImage(named: "ic_delete")
        deleteAction.backgroundColor = hexa("d95900", alpha: 1)
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
}

// ----------------------------------
//  MARK: - UITableViewDelegate -
//
extension MyContactScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictContactDetail = arrMyContact[indexPath.section]

        /*
        let vcAddComment = self.storyboard?.instantiateViewController(withIdentifier: "AddCommentScreenViewController") as! AddCommentScreenViewController
        vcAddComment.Contact_Id =  dictContactDetail["id"].stringValue
        vcAddComment.strWhichSscreen = "Add Contact"
        self.navigationController?.pushViewController(vcAddComment, animated: true)*/
        let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as! ContactDetailScreenViewController
        vcContactDetail.Contact_ID = dictContactDetail["id"].stringValue
        self.navigationController?.pushViewController(vcContactDetail, animated: true)
    }
}

//MARK:- DELEGATE METHOD
extension MyContactScreenViewController : TextFieldValue{
    func textFieldEnterValue(text: String) {

        print(text)
//        txtSearch.text = text
//        arrMyContact.removeAll()
//        if txtSearch.text?.count == 0 {
//            ManageSaveSearchResult()
//            tblMyContactList.reloadData()
//        }else{
//            viewSearching.isHidden = false
//            DispatchQueue.main.async {
//                self.apiCallSearchResult()
//                self.tblMyContactList.reloadData()
//            }
//
//        }
    }
    
    
}


extension MyContactScreenViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "textSearchVC") as! textSearchVC
        viewController.delegate = self
        viewController.textValue = txtSearch.text
        self.navigationController?.pushViewController(viewController, animated: true)
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        viewSearching.isHidden = true
        txtSearch.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        intTextSearchCount += 1
        
        if intTextSearchCount == 4 {
            intTextSearchCount = 0
        }
        
        return true
    }
}
