//
//  HomeScreenViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SWRevealViewController
import HCSStarRatingView
import AFNetworking
import SwiftyJSON
import DropDown
import MessageUI
import ContactsUI
import MBProgressHUD
import GoogleMobileAds


class HomeScreenViewController: UIViewController, SWRevealViewControllerDelegate  {
    
    //MARK:- VARIABLE
    //GADRewardedAdDelegate
    var arrSearchList:[JSON] = []
    var isManageSearch:Bool = true
    var arrSearchObjectList:NSMutableArray?
    var intCountTap:Int = 0
    var intTextSearchCount:Int = 0
    var arrRandomNumber = ["1","2","3","4","5"]
    var arrRandomNumber_Full_Ads = ["1","2","3","4","5","6","7","8","9","10"]
    var interstitial : GADInterstitial?
    var defaults = UserDefaults.standard
    let rightBarDropDown = DropDown()
    var rewardedAd : GADRewardedAd?
    
    //MARK:- Outlet
    
    @IBOutlet var btnAddContact: UIButton!
    @IBOutlet weak var viewAddContact: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var lblNoRecordFound: UILabel!
    @IBOutlet var viewBannerAds: GADBannerView!
    @IBOutlet weak var tblSearchResultList: UITableView! {
        didSet {
            tblSearchResultList.register(UINib(nibName: ContactListTableViewCell.className, bundle: Bundle.main), forCellReuseIdentifier: ContactListTableViewCell.className)
        }
    }
    @IBOutlet var viewSearching: UIView!
    
    
    //MARK:- METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpUI()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        let val = defaults.value(forKey: "isAppAlreadyLaunchedOnce")
        print("val \(String(describing: val))")
        
        if appDelegate.isAppAlreadyLaunchedOnce(){
            viewAddContact.isHidden = true
            btnAddContact.isHidden = true
            defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
        }else {
            self.lblNoRecordFound.isHidden = false
            self.lblNoRecordFound.text = "No Results Found"
            viewAddContact.isHidden = false
            btnAddContact.isHidden = false
        }
        
        if appDelegate.strval == "1"{
            let mobileNumber = formatNumber(phoneNumber: txtSearchNumber, shouldRemoveLastDigit: false)
            self.lblNoRecordFound.text = "No Results for \(mobileNumber)"
            self.btnAddContact.isHidden = false
            self.lblNoRecordFound.isHidden = false
            self.tblSearchResultList.isHidden = true
            self.btnAddContact.isHidden = false
            self.viewAddContact.isHidden = false
        }else if appDelegate.strval == "0"{
            txtSearch.text = ""
            ManageSaveSearchResult()
            self.lblNoRecordFound.isHidden = true
            self.btnAddContact.isHidden = true
            self.tblSearchResultList.isHidden = false
            self.btnAddContact.isHidden = true
            self.viewAddContact.isHidden = true
        }
        
        /*
         ManageSaveSearchResult()
         if self.arrSearchList.count == 0 {
         isManageSearch = true
         self.lblNoRecordFound.text = "No Results Found"
         self.btnAddContact.isHidden = false
         self.lblNoRecordFound.isHidden = false
         self.tblSearchResultList.isHidden = true
         self.btnAddContact.isHidden = false
         self.viewAddContact.isHidden = false
         }else{
         self.lblNoRecordFound.isHidden = true
         self.btnAddContact.isHidden = true
         self.tblSearchResultList.isHidden = false
         self.btnAddContact.isHidden = true
         self.viewAddContact.isHidden = true
         }
         */
        NotificationCenter.default.addObserver(self, selector: #selector(ContactDetailScreenViewController.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationToAddContact"), object: nil)
        self.navigationController?.isNavigationBarHidden = true
        //        interstitial = createAndLoadInterstitial()
    }
    
    //MARK: Set Silent Push Notification
    
    @objc func methodOfReceivedNotification(notification: Notification){
        
        if notification.name.rawValue == "NotificationToAddContact" {
           ManageSaveSearchResult()
        }
    }
    
    //MARK:- Get Search Result
    
    func ManageSaveSearchResult()  {
        if UserDefaults.standard.object(forKey: "SearchResult") != nil {
            
            if let data = UserDefaults.standard.object(forKey: "SearchResult") as? Data {
                if let arrSearchObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray
                {
                    print("arrSearchObject:\(arrSearchObject)")
                    
                    let dictData = JSON(arrSearchObject)
                    arrSearchList = dictData.arrayValue
                    arrSearchObjectList = arrSearchObject
//                    print(arrSearchList.count)
                    if self.arrSearchList.count == 0 {
                        isManageSearch = true
                        self.lblNoRecordFound.text = ""//"No Results Found"
                        self.btnAddContact.isHidden = false
                        self.lblNoRecordFound.isHidden = false
                        self.tblSearchResultList.isHidden = true
                        self.btnAddContact.isHidden = false
                        self.viewAddContact.isHidden = false
                    }else{
                        self.lblNoRecordFound.isHidden = true
                        self.btnAddContact.isHidden = true
                        self.tblSearchResultList.isHidden = false
                        self.btnAddContact.isHidden = true
                        self.viewAddContact.isHidden = true

                    }
                    self.tblSearchResultList.reloadData()
                }
            }
            
        }
    }

    func SetUpUI(){
        viewSearch.applyCornerRadius(radius: viewSearch.frame.size.height/2)
        viewAddContact.applyCornerRadius(radius: viewAddContact.frame.size.height/2)
        txtSearch.applyCornerRadius(radius: txtSearch.frame.size.height/2)
        txtSearch.attributedPlaceholder = NSAttributedString(string: "Search Number",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: APP_DISPLAY_THIN_FONT, size: 24)!])
        txtSearch.setLeftImage(imageName: "ic_search_white")
    }
   
    //MARK:- Load Full Screen ads
    /*
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

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    func 
    showAd() {
            if let ad = self.interstitial, ad.isReady {
               let root = UIApplication.shared.windows.first?.rootViewController
               ad.present(fromRootViewController: root!)
            }
        }
    
    //MARK:- Load Rewar Video ADs
    
    func loadRewarVideoAds()  {
//        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
//                                                    withAdUnitID: Reward_Ads)
        
        rewardedAd = GADRewardedAd(adUnitID: Reward_Ads)
          rewardedAd?.load(GADRequest()) { error in
            if let error = error {
              // Handle ad failed to load case.
                print(error)
            } else {
                print("Ad successfully loaded.")
              // Ad successfully loaded.
                self.rewardedAd?.present(fromRootViewController: self, delegate:self)
            }
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
    
 */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Serach Record
    
    func apiCallSearchResult()  {
        
//        SVProgressHUD.show(withStatus: "Searching...")
        
        let escapedString = txtSearch.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let strSearchURL = API.SEARCH + "\(escapedString!)"
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.get(strSearchURL, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            print("responseObject:-\(String(describing: responseObject))")
            
            if let jsonResponse = responseObject as? NSDictionary {
            
                self.lblNoRecordFound.isHidden = true
                self.viewAddContact.isHidden = true
                self.btnAddContact.isHidden = true
                self.txtSearch.text = ""
                
                let dictData = JSON(jsonResponse)
                
                self.isManageSearch = false
                DispatchQueue.main.async {
                    self.arrSearchList = dictData["data"].arrayValue
                    
                    if self.arrSearchList.count == 0 {
                        self.lblNoRecordFound.text = "No Results for \(txtSearchNumber)"
                        self.lblNoRecordFound.isHidden = false
                        self.btnAddContact.isHidden = false
                        self.viewAddContact.isHidden = false
                        self.tblSearchResultList.isHidden = true
                    
                    }else{
                        self.tblSearchResultList.reloadData()
                        self.lblNoRecordFound.isHidden = true
                        self.btnAddContact.isHidden = true
                        self.viewAddContact.isHidden = true
                        self.tblSearchResultList.isHidden = false
                    }
                    
//                    if let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as? ContactDetailScreenViewController {
//                        vcContactDetail.Contact_ID = dictData["id"].stringValue
//                        vcContactDetail.isHideSearch = true
////                        vcContactDetail.delegate = self
//                        self.navigationController?.pushViewController(vcContactDetail, animated: true)
//                    }
                    
                    self.viewSearching.isHidden = true
                }
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
            let responseCode = task?.response as! HTTPURLResponse
            if(responseCode.statusCode == 500) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: oppsmsg , message: CheckConnection , vc: self)
            } else {
                let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: oppsmsg, message: errResponse, vc: self)
            }
        }
    }
    
    //MARK:- SWRevealViewController Delegate Method
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        txtSearch .resignFirstResponder()
    }
    
    //MARK:- Action
    
    @IBAction func onSearchResult(_ sender: Any) {
       
    }
    
    @IBAction func onAddNewContact(_ sender: Any) {
        
        let vcAddContact = self.storyboard?.instantiateViewController(withIdentifier: "AddNewContactViewController") as! AddNewContactViewController
        self.navigationController?.pushViewController(vcAddContact, animated: true)
    }
    
    @objc func onHandleMoreOption(sender:UIButton)  {
        
        let dictSearchDetail = arrSearchList[sender.tag]

        rightBarDropDown.anchorView = sender
//        rightBarDropDown.bottomOffset = CGPoint (x: self.view.bounds.width - 20, y: sender.bounds.height)
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
            case 3:
                let vcAddComment = self.storyboard?.instantiateViewController(withIdentifier: "AddCommentScreenViewController") as! AddCommentScreenViewController
                vcAddComment.Contact_Id = dictSearchDetail["id"].stringValue
                vcAddComment.strWhichSscreen = "Detail"
                self.navigationController?.pushViewController(vcAddComment, animated: true)
                //self.presentReportContact(object: dictSearchDetail)
            default:
                break
            }
        }
        
    }
    
    @IBAction func onSearchDoneTap(_ sender: UITextField) {
    }
    
    @IBAction func btnSearchAction(_ sender: Any) {
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "textSearchVC") as? textSearchVC
        self.tabBarController?.selectedIndex = 1
//        viewController?.delegate = self
        
    }
    
    // MARK: - Present Report Contact
    private func presentReportContact(object:JSON) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddContactReportViewController") as? AddContactReportViewController {
            viewController.providesPresentationContextTransitionStyle = true
            viewController.definesPresentationContext = true
            viewController.dictContactInfo = object
            present(viewController, animated: true, completion: nil)
        }
    }
    
}

// ----------------------------------
//  MARK: - UITextField Delgate Method

extension HomeScreenViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "textSearchVC") as? textSearchVC
        self.tabBarController?.selectedIndex = 1
        viewController?.delegate = self
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        viewSearching.isHidden = true
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}




// ----------------------------------
//  MARK: - UITableViewDataSource

extension HomeScreenViewController : UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSearchList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.className, for: indexPath) as? ContactListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none

        let dictSearchDetail = arrSearchList[indexPath.section]
        
        let Rating_Value = dictSearchDetail["avg_rate"].stringValue
        let _ : Float = NSString(string: Rating_Value).floatValue
    
        cell.lblUserName.text = "\(dictSearchDetail["first_name"].stringValue.capitalized) " + "\(dictSearchDetail["last_name"].stringValue.capitalized)"
        
//        let mobileNumber = format(phoneNumber: dictSearchDetail["number"].stringValue)
        let mobileNumber = formatNumber(phoneNumber: dictSearchDetail["number"].stringValue, shouldRemoveLastDigit: false)
        cell.lblMobileNumber.text = mobileNumber

        return cell
    }
    
   
    
}

// ----------------------------------
//  MARK: - UITableViewDelegate

extension HomeScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictSearchDetail = arrSearchList[indexPath.section]
        
        let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as! ContactDetailScreenViewController
        vcContactDetail.Contact_ID = dictSearchDetail["id"].stringValue
        vcContactDetail.isComeScreen = .Logs
        self.navigationController?.pushViewController(vcContactDetail, animated: true)
        
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if isManageSearch {
            let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

                // Reset state
                let alertVC = Alertview(title: "Warring!", body: "Are you sure you want to delete contact?", cancelbutton: "Cancel", okbutton: "Yes", completion: {
                    self.arrSearchObjectList?.removeObject(at: indexPath.section)
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: self.arrSearchObjectList!)
                    UserDefaults.standard.set(data, forKey: "SearchResult")
                    UserDefaults.standard.synchronize()
                    self.ManageSaveSearchResult()
                })
                self.present(alertVC, animated: true, completion: nil)
                
                success(true)
            })
            deleteAction.image = UIImage(named: "ic_delete")
            deleteAction.backgroundColor = hexa("000000", alpha: 1)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        return UISwipeActionsConfiguration (actions: [])
    }
    
}

//MARK:- UIMessage Deleggate method

extension HomeScreenViewController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}

//MARK:- ContactUI Delegate Method

extension HomeScreenViewController : CNContactViewControllerDelegate {
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        print("dismiss contact")
        self.navigationController?.popViewController(animated: true)
    }
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}

//MARK:- DELEGATE METHOD
extension HomeScreenViewController:TextFieldValue{
    func textFieldEnterValue(text: String) {

        print(text)
//        txtSearch.text = text
        
//        arrSearchList.removeAll()
//        if txtSearch.text?.count == 0 {
//            txtSearch.text = ""
//            ManageSaveSearchResult()
//            tblSearchResultList.reloadData()
//        }else{
//            viewSearching.isHidden = false
//            
//            if (defaults.bool(forKey: "purchased")){
//                // Hide a view or show content depends on your requirement
//                interstitial = nil
//            } else if (!defaults.bool(forKey: "stonerPurchased")) {
//                print("false")
//                showAd()
//            }
//
//            DispatchQueue.main.async {
//                self.apiCallSearchResult()
//                self.tblSearchResultList.reloadData()
//            }
//        }
        
    }
}

extension HomeScreenViewController:GADInterstitialDelegate{
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
            print("Ad presented")
        }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("Interstitial ad failed to load with error: \(error.localizedDescription)")
      }
}
