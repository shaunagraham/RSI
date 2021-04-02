//
//  AddCommentScreenViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 10/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import SVProgressHUD
//import SkyFloatingLabelTextField
import HCSStarRatingView
import SWRevealViewController
import MBProgressHUD

enum isComeComment {
    case add
    case edit
}

class AddCommentScreenViewController: UIViewController {
    
    //MARK:- VARIABLE

    var dictUserDetail:NSDictionary = UserDefaults.standard.object(forKey: "isUserLogin") as? NSDictionary ?? NSDictionary()
    var Contact_Id:String?
    var arrCommentList:[JSON] = []
    var Rating:CGFloat = 0.0
    var strWhichSscreen:String?
    var isComeFrom = isComeComment.add
    var comment : String?
    var id = String()

    var txtColor = UIColor(red: 29/255, green: 173/255, blue: 169/255, alpha: 1)
    
    var arrComments = ["Telemarketer","Robocaller","Fraud","Spoof","Spam","Survey","IRS","Debt Collector","Charity","Political"]
    var arrName : [String] = []
    
    //MARK:- Outlet
    
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var tblCommentList: UITableView!
    @IBOutlet weak var tblCommentHeightConstraints: NSLayoutConstraint!
//    @IBOutlet weak var viewRatingStar: HCSStarRatingView!
    
    
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var txtcomment: SkyFloatingLabelTextField!

    @IBOutlet weak var collectionComment: UICollectionView!
    
    @IBOutlet weak var collectionCommentHeight: NSLayoutConstraint!
    
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionComment.delegate = self
        collectionComment.dataSource = self
        collectionComment.register(UINib(nibName: CommentCell.className , bundle: nil), forCellWithReuseIdentifier: CommentCell.className)

        let layout = TagFlowLayout()
        layout.estimatedItemSize = CGSize(width: 140, height: 40)
        collectionComment.collectionViewLayout = layout
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isComeFrom == .edit{
            txtComment.text = comment
            btnAdd.setTitle("Edit", for: .normal)
        }else{
            setScreenLayOut()
        }
        
        getCommentList()
        [btnCancle,btnAdd].forEach{(btn) in
            btn?.layer.cornerRadius = (btn?.frame.height)! / 2
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Set Screen LayOut
    
    func setScreenLayOut()  {
        txtComment.text = "Comment"
        txtComment.textColor = txtColor
        btnAdd.setTitle("Add", for: .normal)
        
//        txtComment.layer.borderWidth = 1
//        txtComment.layer.borderColor = UIColor.lightGray.cgColor
//        txtComment.layer.cornerRadius = 6

//
//        viewRatingStar.maximumValue = 5
//        viewRatingStar.allowsHalfStars = true
//        viewRatingStar.tintColor = hexa("b25524", alpha: 1)
//        viewRatingStar .addTarget(self, action: #selector(AddCommentScreenViewController.onHandleRatingCount(sender:)), for: .valueChanged)

    }
    
    @objc func onHandleRatingCount(sender: HCSStarRatingView){
        Rating = sender.value
    }

    
    
    //MARK:- Get Comment List
    
    func getCommentList()  {
        
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)

        let strCommentList = API.COMMENT_LIST + "\(Contact_Id ?? "")"
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer .setValue("application/json", forHTTPHeaderField: "Accept")
        manager.get(strCommentList, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {
                // here read response
                hud.hide(animated: true)

                
                let dictData = JSON(jsonResponse)
                
                
                self.arrCommentList = dictData["data"].arrayValue

                self.tblCommentList.reloadData()
                self.tblCommentHeightConstraints.constant = self.tblCommentList.contentSize.height
            }

        }) { (task: URLSessionDataTask?, error: Error) in
            hud.hide(animated: true)

            //            let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
            
            guard let responseCode = task?.response else {
                DisplayAlertwithBack(title: oppsmsg , message: CheckConnection , vc: self)
                return
            }
            
            //            let responseCode = task?.response as! HTTPURLResponse
            let statuscode = responseCode as! HTTPURLResponse
            if(statuscode.statusCode == 500) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
//                print(errResponse)
                DisplayAlert(title: oppsmsg , message: CheckConnection , vc: self)
                
            } else if (statuscode.statusCode == 404) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: oppsmsg, message: SomethingWrong, vc: self)

            }
        }
        
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Validation
    
    func validation() -> Bool {
      /*
        if txtComment.text == "" || txtComment.text == "Comment" {
            DisplayAlert(title: "Oops!", message: "Please a write comment!", vc: self)
            return false
        }
        */

        if arrName.count == 0 {
            DisplayAlert(title: "Oops!", message: "Please select comment!", vc: self)
            return false
        }
        
        return true
    }
    
    //MARK:- Action
    
    @IBAction func onCancel(_ sender: Any) {
        
        if self.strWhichSscreen == "Add Contact" {
            let vcHomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
            let navigationController = MainNavigationViewController(rootViewController: vcHomeScreen)
            navigationController.isNavigationBarHidden = true
            let vcReveal:SWRevealViewController = self.revealViewController() as SWRevealViewController
            vcReveal.pushFrontViewController(navigationController, animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)

        }
    }
    
    @IBAction func onAdd(_ sender: Any) {
        
        if isComeFrom == .edit{
            print("")
            deleteCommentApi()
        }else{
            addCommentapiCall()
        }
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addCommentapiCall(){
        if !validation() {
            return
        }
        
        let hud:MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let val = arrName.joined(separator: ", ")
        var param = [String:Any]()
        param[message] = val.trimmingCharacters(in: .whitespacesAndNewlines)
        //txtComment.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        param[Contactid] = Contact_Id
        param[kRate] = "\(Rating)"
        param[kUserid] = dictUserDetail.value(forKey: "id")
        
        // let param = ["message":txtComment.text!.trimmingCharacters(in: .whitespacesAndNewlines),"contact_id":Contact_Id!,"rate":"\(Rating)","user_id":dictUserDetail.value(forKey: "id")!]
        debugPrint("add comment: \(param)")
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.post(API.ADD_COMMENT, parameters: param, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {
                // here read response
                hud.hide(animated: true)
                
                let dictData = JSON(jsonResponse)
                print(dictData)
                
                if self.strWhichSscreen == "Detail" {
                    NotificationCenter.default.post(name: Notification.Name("NotificationToAddComment"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                    
                }else if self.strWhichSscreen == "Add Contact" {
                    
                    let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as! ContactDetailScreenViewController
                    vcContactDetail.Contact_ID = self.Contact_Id
                    vcContactDetail.strWhichScreen = "Add Contact"
                    self.navigationController?.pushViewController(vcContactDetail, animated: true)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            hud.hide(animated: true)
            
            let responseCode = task?.response as! HTTPURLResponse
            if(responseCode.statusCode == 500) {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                
                DisplayAlert(title: oppsmsg , message: CheckConnection , vc: self)
                
            } else  {
                let _: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
                DisplayAlert(title: oppsmsg , message: SomethingWrong , vc: self)
            }
        }
        
        
    }
    
    func deleteCommentApi(){
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)

        var parm = [String:Any]()
        parm[message] = txtComment.text.trimmingCharacters(in: .whitespacesAndNewlines)
        parm[kRate] = "\(Rating)"
        parm[kCommentid] = id
        
        APICall.call_API_PUT(url: API.EDIT_COMMENT, param: parm) { (object, error) in
            hud .hide(animated: true)
            
            if let error = error {
                self.showToast(message: error.localizedDescription)
            }else{
                let object = JSON(object as Any)
                print(object)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}

// -----------------------------------
//  MARK: - UITextView Delegate Method -
//

extension AddCommentScreenViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == txtColor {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment"
            textView.textColor = txtColor
        }
    }
    

    
}

// ----------------------------------
//  MARK: - UITableViewDataSource -
//
extension AddCommentScreenViewController : UITableViewDataSource {

    
    func numberOfSections(in tableView: UITableView) -> Int {
        
//        if arrCommentList.count == 0 {
//            lblNoComment.isHidden = false
//        }else{
//            lblNoComment.isHidden = true
//        }
        return arrCommentList.count
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentListTableViewCell
        
        cell.selectionStyle = .none
        
        let dictCommentDetail = arrCommentList[indexPath.section]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: dictCommentDetail["created_at"].stringValue)
        let timeAgo:String = timeAgoSinceDate(date!, currentDate: Date(), numericDates: true, strDate: dictCommentDetail["created_at"].stringValue)
        
        
        cell.lblDateAndTime.text = timeAgo
        cell.lblCommentName.text = dictCommentDetail["message"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cell
        
    }
    
    
}

// ----------------------------------
//  MARK: - UITableViewDelegate -

extension AddCommentScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
