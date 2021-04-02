//
//  ContactDetailScreenViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 09/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import AFNetworking
import SVProgressHUD
import SwiftyJSON
import SWRevealViewController
import DropDown
import MessageUI
import ContactsUI
import MBProgressHUD
import SafariServices
import GoogleMobileAds

enum ComeScreen{
    case Search,Logs,addnewContact
}

protocol BlockListReloadDelegateProtocol {
    func sendDataToFirstViewController(reloadStatus: Bool)
    func navigatetoHome()
}

class ContactDetailScreenViewController: UIViewController {
    
    //MARK:- VARIABLE
    
    var Contact_ID:String?
    var arrCommentList:[JSON] = []
    var arrSearchList:[JSON] = []

    var dictUserDetail = JSON(UserDefaults.standard.object(forKey: "isUserLogin") as! NSDictionary)
    var dictContactDetail:JSON?
    var isHideSearch:Bool = false
    var isAddContact:Bool = false

    var strContactName:String?
    var strCotactNumber:String?
    var strUserEmail:String?
    var intCountTap:Int = 0
    var defaults = UserDefaults.standard
    var interstitial: GADInterstitial?
    var intTextSearchCount:Int = 0

    var arrRandomNumber = ["1","2","3","4","5"]
    var arrRandomNumber_Full_Ads = ["1","2","3","4","5","6","7","8","9","10"]
    
    var strWhichScreen:String?
    var delegate: BlockListReloadDelegateProtocol? = nil
    var isComeScreen = ComeScreen.Logs
//    var BackHandler: (Bool)->Void = {_ in }
    var window: UIWindow?
    let rightBarDropDown = DropDown()
    
    //MARK:- Outlet
    
    @IBOutlet weak var viewCommentList: UIView!
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var lblContactName: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var lblExtraInfo: UILabel!
    @IBOutlet weak var lblNoComment: UILabel!
   // @IBOutlet weak var lblTopAddComment: UILabel!
    @IBOutlet weak var btnAddComment: UIButton!
//    @IBOutlet weak var lblBottomAddComment: UILabel!
//    @IBOutlet weak var btnBottomAddComment: UIButton!

    @IBOutlet weak var tblCommentList: UITableView!
    @IBOutlet weak var constraintContactImageWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var btnReport: UIButton!{
        didSet {
            btnReport.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
            btnReport.backgroundColor = TAB_BACKGROUND_COLOR
            btnReport.layer.cornerRadius = btnReport.frame.height / 2
        }
    }
    
    @IBOutlet weak var btnUpdate: UIButton! {
        didSet {
            btnUpdate.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
            btnUpdate.backgroundColor = TAB_BACKGROUND_COLOR
            btnUpdate.layer.cornerRadius = btnUpdate.frame.height / 2
        }
    }
    
    @IBOutlet weak var btnBlock: UIButton! {
        didSet {
            btnBlock.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
            btnBlock.backgroundColor = TAB_BACKGROUND_COLOR
            btnBlock.layer.cornerRadius = btnBlock.frame.height / 2
        }
    }
    
    @IBOutlet weak var viewMainBlock: UIView! {
        didSet {
            viewMainBlock.layer.cornerRadius = 8.0
            viewMainBlock.layer.shadowColor = UIColor.gray.cgColor
            viewMainBlock.layer.shadowOpacity = 0.2
            viewMainBlock.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            viewMainBlock.layer.shadowRadius = 3.0
            viewMainBlock.layer.masksToBounds =  false
        }
    }
    
    //MARK:- override method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblCommentList.isEditing = false
        // Do any additional setup after loading the view.

//        rightBarDropDown.textFont = UIFont(name: "futura", size: 14)!
//        rightBarDropDown.backgroundColor = UIColor.white
//        rightBarDropDown.cellHeight = 38
//        rightBarDropDown.width = 115
//        rightBarDropDown.separatorColor = UIColor.black .withAlphaComponent(0.20)
//        rightBarDropDown.cornerRadius = 10
        
        imgContact.layer.cornerRadius = imgContact.frame.size.height/2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        interstitial = createAndLoadInterstitial()
        arrCommentList.removeAll()
        getContactDetail(Id: Contact_ID ?? "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactDetailScreenViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationToAddComment"), object: nil)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    //MARK:- Set Silent Push Notification
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        if notification.name.rawValue == "NotificationToAddComment" {
            arrCommentList.removeAll()
            getContactDetail(Id: Contact_ID ?? "")
        }
    }
    
//    //MARK: Load Full Screen ads
//
//    func loadFullScreenAds()  {
//        interstitial = GADInterstitial(adUnitID: API.FULLSCREEN_ADS)
//        let request = GADRequest()
//        interstitial?.load(request)
//    }
//
//    //MARK: Load Rewar Video ADs
//
//    func loadRewarVideoAds() {
//        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
//                                                    withAdUnitID: Reward_Ads)
//    }
    
    
    //MARK:- Get Contact Detail
    
    func getContactDetail(Id:String)  {
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)

        let strContactDetail = API.CONTACT_DETAIL + "\(Id)"
        
        print("strContactDetail \(strContactDetail)")
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
        manager.get(strContactDetail, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {
                // here read response
                hud.hide(animated: true)
                
                let dictData = JSON(jsonResponse)
                print(dictData)
                self.dictContactDetail = JSON(jsonResponse)
    
                let strUserId = dictData["details"]["id"]
                
                if "\(dictData["details"]["profile"])" != "" && "\(dictData["details"]["profile"])" != "null"{
                    self.imgContact.sd_setImage(with: URL(string: imageURLPath + "/\(dictData["details"]["profile"])"), completed: nil)
                    self.constraintContactImageWidth.constant = 80
                    self.imgContact.isHidden = false
                }else{
                    self.constraintContactImageWidth.constant = 0
                    self.imgContact.isHidden = true
                }

                self.lblContactName.text = "\(dictData["details"]["first_name"].stringValue.capitalized) " + "\(dictData["details"]["last_name"].stringValue.capitalized)"
                self.strContactName = "\(dictData["details"]["first_name"]) " + "\(dictData["details"]["last_name"])"
                
                let mobileNumber = formatNumber(phoneNumber: dictData["details"]["number"].stringValue, shouldRemoveLastDigit: false)
                
                self.strCotactNumber =  mobileNumber
                self.lblContactNumber.text = mobileNumber
                
                self.lblUserEmail.text = dictData["details"]["email"].stringValue
                
                if dictData["details"]["nick_name"].stringValue != "" {
                    self.lblExtraInfo.text = dictData["details"]["nick_name"].stringValue
                }
                
                if dictData["details"]["email"].stringValue != "" {
                    self.strUserEmail = "Email: " + "\(dictData["details"]["email"].stringValue)"
                }

                self.arrCommentList = dictData["comments"].arrayValue
                self.tblCommentList.reloadData()
                
                if self.isComeScreen == .Search{
                    if UserDefaults.standard.object(forKey: "SearchResult") != nil {
                        if let data = UserDefaults.standard.object(forKey: "SearchResult") as? Data {
                            
                            if let arrSearchObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray {
                                let dictData = JSON(arrSearchObject)
                                
                                self.arrSearchList = dictData.arrayValue
                                var isFound:Bool = false
                                for (index, element) in self.arrSearchList.enumerated() {
                                    
                                    if element["id"] == strUserId {
                                        arrSearchObject .removeObject(at: index)
                                        arrSearchObject.insert(jsonResponse .value(forKey: "details") as Any, at: 0)
                                        let data = NSKeyedArchiver.archivedData(withRootObject: arrSearchObject)
                                        UserDefaults .standard .set(data, forKey: "SearchResult")
                                        UserDefaults.standard .synchronize()
                                        
                                        NotificationCenter.default.post(name: Notification.Name("NotificationToAddContact"), object: nil)
                                        isFound = true

                                        break
                                    }
                                }
                                
                                if !isFound {
                                    arrSearchObject.insert(jsonResponse .value(forKey: "details") as Any, at: 0)
                                    let data = NSKeyedArchiver.archivedData(withRootObject: arrSearchObject)
                                    UserDefaults .standard .set(data, forKey: "SearchResult")
                                    UserDefaults.standard .synchronize()
                                    
                                    NotificationCenter.default.post(name: Notification.Name("NotificationToAddContact"), object: nil)
                                }
                            }
                        }
                        
                    }else{
                        
                        let arrSearchObject:NSMutableArray = []
                        
                        arrSearchObject.add(jsonResponse.value(forKey: "details")!)
                        let data = NSKeyedArchiver.archivedData(withRootObject: arrSearchObject)

                        UserDefaults.standard.set(data, forKey: "SearchResult")
                        UserDefaults.standard.synchronize()
                    }
                }
                
                
                
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            hud.hide(animated: true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "details" {
            let EvryAPIVC = segue.destination as? EvryAPIContactDetailViewController
            EvryAPIVC?.dictContactDetail = dictContactDetail
            
        }
    }
    
    //MARK:- Action

    @IBAction func btnReportAction(_ sender: UIButton) {
        btnReport.setTitleColor(APP_WHITE_COLOR, for: .normal)
        btnReport.backgroundColor = .systemRed
        btnUpdate.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
        btnUpdate.backgroundColor = TAB_BACKGROUND_COLOR
        btnBlock.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
        btnBlock.backgroundColor = TAB_BACKGROUND_COLOR
        
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton) {
        btnUpdate.setTitleColor(APP_WHITE_COLOR, for: .normal)
        btnUpdate.backgroundColor = .systemRed
        btnReport.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
        btnReport.backgroundColor = TAB_BACKGROUND_COLOR
        btnBlock.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
        btnBlock.backgroundColor = TAB_BACKGROUND_COLOR
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewContactViewController") as! AddNewContactViewController
        vc.isComeAddNewContact = .contactDetail
        vc.dictContactDetail = self.dictContactDetail ?? JSON()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func btnBlockAction(_ sender: UIButton) {
        btnBlock.setTitleColor(APP_WHITE_COLOR, for: .normal)
        btnBlock.backgroundColor = .systemRed
        btnUpdate.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
        btnUpdate.backgroundColor = TAB_BACKGROUND_COLOR
        btnReport.titleLabel?.textColor = APP_DETAILSCREEN_COLOR
        btnReport.backgroundColor = TAB_BACKGROUND_COLOR
        showAlert(withTitle:"", withMessage: "Do you want to unblock \(lblContactName.text ?? "") and \(lblContactNumber.text ?? "")")

//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BrowseContactViewController") as! BrowseContactViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBackAction(_ sender: Any) {
        
        if isComeScreen == .Logs{
            self.navigationController?.popViewController(animated: true)
        }else if isComeScreen == .Search || isComeScreen == .addnewContact{
            self.delegate?.navigatetoHome()
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func onBack(_ sender: Any) {
        
        if strWhichScreen == "Add Contact" {
            let vcHomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            let navigationController = MainNavigationViewController(rootViewController: vcHomeScreen)
            navigationController.isNavigationBarHidden = true
            let vcReveal:SWRevealViewController = self.revealViewController() as SWRevealViewController
            vcReveal.pushFrontViewController(navigationController, animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onSearchBack(_ sender: Any) {
//        self.navigationController?.popViewController(animated: false)
        let vcHomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        let navigationController = MainNavigationViewController(rootViewController: vcHomeScreen)
        navigationController.isNavigationBarHidden = true
//        let vcReveal:SWRevealViewController = self.revealViewController() as SWRevealViewController
//        vcReveal.pushFrontViewController(navigationController, animated: false)

    }
    
    
    @IBAction func onSearchResult(_ sender: Any) {
//        arrSearchList.removeAll()
//        if txtSearch.text?.count ==  0 {
//            tblSearchResultList.reloadData()
//            viewCommentList.isHidden = false
//            viewSearchList.isHidden = true
//        }else{
//            viewSearching.isHidden = false
//            DispatchQueue.main.async {
//                self.apiCallSearchResult()
//            }
//        }
    }
    
    @IBAction func onComment(_ sender: Any) {
        let vcAddComment = self.storyboard?.instantiateViewController(withIdentifier: "AddCommentScreenViewController") as! AddCommentScreenViewController
        vcAddComment.Contact_Id = Contact_ID
        vcAddComment.strWhichSscreen = "Detail"
        self.navigationController?.pushViewController(vcAddComment, animated: true)
    }
    
    @IBAction func onShare(_ sender: Any) {
        
        let APPUrl:URL = URL(string: "https://itunes.apple.com/us/app/rap-sheet/id1439929100?ls=1&mt=8")!
        let strName = "Contact name: " + "\(strContactName ?? "")"
        let strNumber = "Contact Number: " + "\(strCotactNumber ?? "")"
        let strEmail = strUserEmail == nil ? "" : strUserEmail
        
        let vc = UIActivityViewController(activityItems: [APPUrl, strName, strNumber, strEmail!], applicationActivities: [])
            
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            vc.popoverPresentationController?.sourceView = sender as? UIView
            self.present(vc, animated: true, completion: nil)
        }else{
            present(vc, animated: true)
        }
    }
    
    @objc func onDeleteComment(sender: UIButton){
        /*
        let alertVC = Alertview(title: "Warring!", body: "Are you sure you want to delete comment?", cancelbutton:  "Cancel", okbutton: "Yes", completion: {
            
            let dictCommentDetail = self.arrCommentList[sender.tag]
            let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
            
            let strDelete = API.DELETE_COMMENT + dictCommentDetail["id"].stringValue
            
            let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
            manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
            manager.get(strDelete, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                if (responseObject as? NSDictionary) != nil {
                    // here read response
                    self.arrCommentList.remove(at: sender.tag)
                    self.tblCommentList.reloadData()
                    if self.arrCommentList.count == 0 {
                        self.delegate?.sendDataToFirstViewController(reloadStatus: true)
                    }
                    hud .hide(animated: true)
                }
                
            }) { (task: URLSessionDataTask?, error: Error) in
                hud .hide(animated: true)

            }
        })
        
        self.present(alertVC, animated: true, completion: nil)
        */
        let dictCommentDetail = arrCommentList[sender.tag]
        print("seleted :\(dictCommentDetail["id"])")
        
        let vcAddComment = self.storyboard?.instantiateViewController(withIdentifier: "AddCommentScreenViewController") as! AddCommentScreenViewController
        vcAddComment.Contact_Id = Contact_ID
        vcAddComment.isComeFrom = .edit
        vcAddComment.id = dictCommentDetail["id"].stringValue
        vcAddComment.comment = dictCommentDetail["message"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.navigationController?.pushViewController(vcAddComment, animated: true)
        
    }
    
    @objc func onHandleMoreOption(sender:UIButton)  {
        
        let dictSearchDetail = arrSearchList[sender.tag]

        
        rightBarDropDown.anchorView = sender
//        rightBarDropDown.bottomOffset = CGPoint (x: +20, y: sender.bounds.height)
        rightBarDropDown.dataSource = ["Call","Message","Save","Report"]
        rightBarDropDown.show()
        rightBarDropDown.selectionAction = { (index,title) in
            
            switch index {
            case 0:
                if let url = URL(string: "tel://\(dictSearchDetail["number"].stringValue)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                break
            case 1:
                let messageVC = MFMessageComposeViewController()
                messageVC.recipients = [dictSearchDetail["number"].stringValue]
                messageVC.messageComposeDelegate = self
                self.present(messageVC, animated: true, completion: nil)
                break
            case 2:
                
                if #available(iOS 9.0, *) {
                    let store = CNContactStore()
                    let contact = CNMutableContact()
                    let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :"\(dictSearchDetail["number"].stringValue)"))
                    contact.phoneNumbers = [homePhone]
                    let controller = CNContactViewController(forUnknownContact : contact)
                    controller.contactStore = store
                    controller.delegate = self
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    self.navigationController!.pushViewController(controller, animated: true)
                }
                break
            default:
                break
            }
        }
    }
    
    
    @IBAction func onHandleMoreInfo(_ sender: Any) {
        self.performSegue(withIdentifier: "details", sender: self)
    }
    
    
    @IBAction func onHandleForContact(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if let url = URL(string: "tel://\(strCotactNumber ?? "")"){
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            break
        case 1:
            
            if MFMessageComposeViewController.canSendText() {
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self
                composeVC.recipients = ([strCotactNumber] as! [String])
                self.present(composeVC, animated: true, completion: nil)
            }else {
                print("Can't send messages.")
            }
            
            break
        case 2:
            
            if #available(iOS 9.0, *) {
                let store = CNContactStore()
                let contact = CNMutableContact()
                let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue :"\(strCotactNumber ?? ""   ))"))
                contact.phoneNumbers = [homePhone]
                let controller = CNContactViewController(forUnknownContact : contact)
                controller.contactStore = store
                controller.delegate = self
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationController!.pushViewController(controller, animated: true)
            }
            break
        default:
            break
        }
    }
    
    @IBAction func onSocialMedia(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            
            guard var url = NSURL(string: self.dictContactDetail?["details"]["weblink"].stringValue ?? "") else {
                return
            }
            
            
            if !(["http", "https"].contains(url.scheme?.lowercased())) {
                
                let appendedLink = "http://\(self.dictContactDetail?["details"]["weblink"].stringValue ?? "")"

                url = NSURL(string: appendedLink)!
            }
            
            openSafariFor(webURL: url as URL)
        case 1:
            openInstagramApplication(userName: self.dictContactDetail?["details"]["instagram"].stringValue ?? "")
        case 2:
            guard var url = NSURL(string: self.dictContactDetail?["details"]["facebook"].stringValue ?? "") else {
                return
            }
            
            if !(["http", "https"].contains(url.scheme?.lowercased())) {
                
                let appendedLink = "http://\(self.dictContactDetail?["details"]["facebook"].stringValue ?? "")"
                url = NSURL(string: appendedLink)!
            }
            
            openSafariFor(webURL: url as URL)
        default:
            guard var url = NSURL(string: self.dictContactDetail?["details"]["linkedin"].stringValue ?? "") else {
                return
            }
            
            if !(["http", "https"].contains(url.scheme?.lowercased())) {
                
                let appendedLink = "http://\(self.dictContactDetail?["details"]["linkedin"].stringValue ?? "")"
                url = NSURL(string: appendedLink)!
            }
            
            openSafariFor(webURL: url as URL)
        }
        
    }
    
    //MARK: Open Safari Browser
    
    func openSafariFor(webURL:URL) {
        let safari  = SFSafariViewController(url: webURL)
        self.present(safari, animated: true, completion: nil)
        safari.delegate = self
    }
    
    //MARK: Open Instagram
    
    func openInstagramApplication(userName:String)  {
        if let appURL = URL(string: "instagram://user?username=\(userName)") {
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                if let webURL = URL(string: "https://instagram.com/\(userName)") {
                    application.open(webURL)
                }
            }
        }
    }
}

//MARK:- Safari Service Delegate methods

extension ContactDetailScreenViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController){
        controller.dismiss(animated: true, completion: nil)
    }
}

// ----------------------------------
//  MARK: - UITextField Delgate Methos -

extension ContactDetailScreenViewController : UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        txtSearch .resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        txtSearch .resignFirstResponder()
        
        return true
    }
}

// ----------------------------------
//  MARK: - UITableViewDataSource -

extension ContactDetailScreenViewController : UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        /*
        if arrCommentList.count == 0 {
            lblNoComment.isHidden = false
            btnAddComment.isHidden = false
//            lblBottomAddComment.isHidden = true
//            btnBottomAddComment.isHidden = true
        }else{
            lblNoComment.isHidden = true
            btnAddComment.isHidden = true
//            lblBottomAddComment.isHidden = false
//            btnBottomAddComment.isHidden = false
        }
        */
        return arrCommentList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentListTableViewCell
        
        cell.selectionStyle = .none
        
        if indexPath.row == 0{
            cell.lblsepraterView.isHidden = false
        }else{
            cell.lblsepraterView.isHidden = true
        }
        
        let dictCommentDetail = arrCommentList[indexPath.section]
        print(dictCommentDetail)
        let strUserID:NSNumber = dictUserDetail["id"].numberValue
        let strCommentID:NSNumber = dictCommentDetail["user_id"].numberValue
        print(strUserID)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: dictCommentDetail["created_at"].stringValue)
        let timeAgo:String = timeAgoSinceDate(date!, currentDate: Date(), numericDates: true, strDate: dictCommentDetail["created_at"].stringValue)
        
        
        cell.lblDateAndTime.text = timeAgo
        cell.lblCommentName.text = dictCommentDetail["message"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if strUserID == strCommentID {
            cell.btnDelete.isHidden = false
        }else {
            cell.btnDelete.isHidden = true
        }
        
        cell.btnDelete.tag = indexPath.section
        cell.btnDelete.addTarget(self, action: #selector(ContactDetailScreenViewController.onDeleteComment(sender:)), for: .touchUpInside)
        
        return cell

    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let dictCommentDetail = arrCommentList[indexPath.section]
        print(dictCommentDetail)
        let strUserID:NSNumber = dictUserDetail["id"].numberValue
        let strCommentID:NSNumber = dictCommentDetail["user_id"].numberValue
        print(strUserID)
        
        if strUserID == strCommentID {
            let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
              
                let alertVC = Alertview(title: "Warring!", body: "Are you sure you want to delete comment?", cancelbutton:  "Cancel", okbutton: "Yes", completion: {
                    
                    let dictCommentDetail = self.arrCommentList[indexPath.section]
                    let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
                    
                    let strDelete = API.DELETE_COMMENT + dictCommentDetail["id"].stringValue
                    
                    let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
                    manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
                    manager.get(strDelete, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                        if (responseObject as? NSDictionary) != nil {
                            // here read response
                            self.arrCommentList.remove(at: indexPath.section)
                            self.tblCommentList.reloadData()
                            if self.arrCommentList.count == 0 {
                                self.delegate?.sendDataToFirstViewController(reloadStatus: true)
                            }
                            hud .hide(animated: true)
                        }
                        
                    }) { (task: URLSessionDataTask?, error: Error) in
                        hud .hide(animated: true)
                    }
                    
                })
                
                self.present(alertVC, animated: true, completion: nil)
                success(true)
            })
            deleteAction.image = UIImage(named: "ic_delete")
            deleteAction.backgroundColor = hexa("000000", alpha: 1)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        else{
            return UISwipeActionsConfiguration(actions: [])
        }
        /*
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            // Call edit action
            
//            let dictContactDetail = self.arrCommentList[indexPath.section]
            
            let alertVC = Alertview(title: "Warring!", body: "Are you sure you want to delete comment?", cancelbutton:  "Cancel", okbutton: "Yes", completion: {
                
                let dictCommentDetail = self.arrCommentList[indexPath.section]
                let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
                
                let strDelete = API.DELETE_COMMENT + dictCommentDetail["id"].stringValue
                
                let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
                manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
                manager.get(strDelete, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
                    if (responseObject as? NSDictionary) != nil {
                        // here read response
                        self.arrCommentList.remove(at: indexPath.section)
                        self.tblCommentList.reloadData()
                        if self.arrCommentList.count == 0 {
                            self.delegate?.sendDataToFirstViewController(reloadStatus: true)
                        }
                        hud .hide(animated: true)
                    }
                    
                }) { (task: URLSessionDataTask?, error: Error) in
                    hud .hide(animated: true)
                }
                
            })
            
            self.present(alertVC, animated: true, completion: nil)
            success(true)
        })
        deleteAction.image = UIImage(named: "ic_delete")
        deleteAction.backgroundColor = hexa("000000", alpha: 1)
        return UISwipeActionsConfiguration(actions: [deleteAction])
        */
    }
    
}




//MARK:- UIMessage Deleget method

extension ContactDetailScreenViewController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
//            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
//            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
           
        default:
//            break
            return
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- ContactUI Delegate Method

extension ContactDetailScreenViewController : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        print("dismiss contact")
        self.navigationController?.popViewController(animated: true)
    }
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}

//MARK:- Load Full Screen ads
/*
extension ContactDetailScreenViewController {
    
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
    
    func showAd() {
        if let ad = self.interstitial, ad.isReady {
            let root = UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
            ad.present(fromRootViewController: root)
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

extension ContactDetailScreenViewController :GADInterstitialDelegate{
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
        }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
}
*/
