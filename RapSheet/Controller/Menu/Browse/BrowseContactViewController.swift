//
//  BrowseContactViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 17/07/19.
//  Copyright © 2019 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import SVProgressHUD
import MBProgressHUD

class BrowseContactViewController: UIViewController{
    
    
    //MARK:- IBOutlet
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var lblblacklist: UILabel!
    @IBOutlet weak var viewaddcontact: UIView!
    @IBOutlet weak var btnaddcontact: UIButton!
    @IBOutlet var tblBrowseContact: UITableView! {
        didSet {
            tblBrowseContact.dataSource = self
            tblBrowseContact.delegate = self
            
            tblBrowseContact.register(UINib(nibName: ContactListTableViewCell.className, bundle: Bundle.main), forCellReuseIdentifier: ContactListTableViewCell.className)
            
        }
    }
    @IBOutlet var viewSearching: UIView!

    //MARK:- Variables
    var arrBrowseContactList:[JSON] = []
    var arrSearchContactList:[JSON] = []
    var dictContactSend:JSON?
    var isBrowseContact:Bool = true
    
    var isManageSearch:Bool = true
    var arrSearchObjectList:NSMutableArray?
    var intCountTap:Int = 0
    var intTextSearchCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblblacklist.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
        lblblacklist.tintColor = .white
        
        viewaddcontact.applyCornerRadius(radius: viewaddcontact.frame.size.height/2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tblBrowseContact.rowHeight = UITableView.automaticDimension
        tblBrowseContact.estimatedRowHeight = 50
        viewaddcontact.isHidden = true
        btnaddcontact.isHidden = true
        setupUI()
    }
    
    func setupUI(){
       // leftSilder()
        
        viewSearch.applyCornerRadius(radius: viewSearch.frame.size.height/2)
        txtSearch.applyCornerRadius(radius: txtSearch.frame.size.height/2)
        txtSearch.attributedPlaceholder = NSAttributedString(string: "Search Number",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: APP_DISPLAY_THIN_FONT, size: 24)!])
        txtSearch.setLeftImage(imageName: "ic_search_white")
        txtSearch.text = ""
        fetchBrowseContactList()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- ACTIONS
    
    @IBAction func btnaddContactAction(_ sender: Any) {
        print("clicked")
        let vcHomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "AddNewContactViewController") as! AddNewContactViewController
        self.navigationController?.pushViewController(vcHomeScreen, animated: true)
    }
    @IBAction func btnLogo_Click(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    //MARK:- Fetch Browse Contact List
    
    func fetchBrowseContactList()  {
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        
        APICall.call_API_Get_Mehotd(url: isBrowseContact ? (API.BROWSE_CONTACT) : (API.RECENT_CONTACT)) { (object) in
            hud .hide(animated: true)
         
            let objectDetail = JSON(object)
            print("objectDetail:-\(objectDetail)")
            
            if objectDetail["success"] == false{
                DisplayAlert(title: oppsmsg , message: objectDetail["error"].stringValue, vc: self)
            }else{
                self.arrBrowseContactList = objectDetail["Contacts"].arrayValue
                self.arrSearchContactList = objectDetail["Contacts"].arrayValue
                self.tblBrowseContact.reloadData()
            }
        }
    }
    
    func ManageSaveSearchResult()  {
        if UserDefaults.standard.object(forKey: "SearchResult") != nil {
            if let data = UserDefaults.standard.object(forKey: "SearchResult") as? Data {
                if let arrSearchObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray
                {
                    let dictData = JSON(arrSearchObject)
                    arrSearchContactList = dictData.arrayValue
                    arrSearchObjectList = arrSearchObject
                    if self.arrSearchContactList.count == 0 {
                        isManageSearch = true
                        self.tblBrowseContact.setEmptyMessage(message:  "No Results Found")
                        self.tblBrowseContact.isHidden = true
                    }else{
                        self.tblBrowseContact.isHidden = false
                    }
                    self.tblBrowseContact.reloadData()
                }
            }

        }
    }
    
    func filterContentForSearchText(searchText: String) {
        arrSearchContactList = self.arrBrowseContactList.filter { item in
            return item["first_name"].stringValue.lowercased().contains(searchText.lowercased()) || item["last_name"].stringValue.lowercased().contains(searchText.lowercased()) || item["number"].stringValue.contains(searchText)
        }
    }
}


//MARK:- UITableView Data Source And Delegate Method

extension BrowseContactViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearchContactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactListTableViewCell.className, for: indexPath) as? ContactListTableViewCell else {
            return UITableViewCell()
        }
        
        ConfigureBrowseContactList(cell, indexPath: indexPath)
        
        return cell
    }
    
    //MARK: Configure Cell
    
    func ConfigureBrowseContactList(_ cell: ContactListTableViewCell, indexPath: IndexPath)  {
        
        cell.selectionStyle = .none
        let dictContactDetail = arrSearchContactList[indexPath.row]
        
        cell.lblUserName.text = "\(dictContactDetail["first_name"].stringValue.capitalized) \(dictContactDetail["last_name"].stringValue.capitalized)"
        let mobileNumber = formatNumber(phoneNumber: dictContactDetail["number"].stringValue, shouldRemoveLastDigit: false)

        if mobileNumber != nil {
            cell.lblMobileNumber.text = mobileNumber
        }else{
            cell.lblMobileNumber.text = dictContactDetail["number"].stringValue
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictContactDetail = arrSearchContactList[indexPath.row]
        
        if let vcContactDetail = self.storyboard?.instantiateViewController(withIdentifier: "ContactDetailScreenViewController") as? ContactDetailScreenViewController {
            vcContactDetail.Contact_ID = dictContactDetail["id"].stringValue
            vcContactDetail.isHideSearch = true
            vcContactDetail.delegate = self
            vcContactDetail.isComeScreen = .Logs
            self.navigationController?.pushViewController(vcContactDetail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


// ----------------------------------
//  MARK: - UITextField Delgate Methos -

extension BrowseContactViewController : BlockListReloadDelegateProtocol {
    func navigatetoHome() {
        print("")
    }
    
    func sendDataToFirstViewController(reloadStatus: Bool) {
        if reloadStatus == true {
            arrSearchContactList.removeAll()
            setupUI()
        }
    }
}

//MARK:- DELEGATE METHOD
extension BrowseContactViewController : TextFieldValue{
    func textFieldEnterValue(text: String) {

        print(text)
        
    }
}

//MARK:- UITextFieldDelegate METHOD

extension BrowseContactViewController : UITextFieldDelegate {
    
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

