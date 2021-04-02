//
//  MenuScreenViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD
import MBProgressHUD
import GoogleMobileAds

class MenuScreenViewController: UIViewController {
    
    //MARK:- variable
    
    var arrMenuList:[String] = ["My Profile","Blocked Calls","Rate App","Share App","Feedback","Help","Privacy Policy","Terms","Remove ads"]
    //"Remove Results",
    var indexPathValue:Int = 1
    var bottomPathValue:Int?
    
    var defaults = UserDefaults.standard
    var hud:MBProgressHUD?
    var isBrowseContact:Bool = true
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblMenuListHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var tblMenuList: UITableView!{
        didSet{
            self.tblMenuList.register(UINib(nibName: MenuListTableViewCell.className, bundle: nil), forCellReuseIdentifier: MenuListTableViewCell.className)
        }
    }
    
    @IBOutlet weak var HeightStackViewButton: UIStackView!
    @IBOutlet var btnRemoveAds: UIButton!
    @IBOutlet var btnRestoreApp: UIButton!
    @IBOutlet weak var lblSetting: UILabel!
    
    @IBOutlet weak var btnRestoreHeight: NSLayoutConstraint!
    @IBOutlet weak var stackviewHeight: NSLayoutConstraint!
    
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        SKPaymentQueue.default().add(self)
        
       // btnRemoveAds.isHidden = true
       // btnRestoreApp.isHidden = true
        
        
        
        //        setScreenLayOut()
        lblSetting.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
        lblSetting.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (defaults.bool(forKey: "purchased")){

            print("true")
            stackviewHeight.constant = 0
            btnRestoreHeight.constant = 0
            btnRemoveAds.isHidden = true
            btnRestoreApp.isHidden = true

        } else if (!defaults.bool(forKey: "stonerPurchased")) {
            print("false")
            stackviewHeight.constant = 0
            btnRestoreHeight.constant = 40
            btnRemoveAds.isHidden = true
            btnRestoreApp.isHidden = false
        }
    }
    
    //MARK:- Set Screen LayOut
    
    func setScreenLayOut() {
        tblMenuListHeightConstraints.constant = CGFloat(arrMenuList.count * 60)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- In-app Puychase Alert View
    
     func buyProduct(product: SKProduct) {
             print("Sending the Payment Request to Apple")
             let payment = SKPayment(product: product)
             SKPaymentQueue.default().add(payment)
                
     }
    
    //MARK:- Action
    
    @IBAction func onRemoveAds(_ sender: Any) {
        
         let alertVC = Alertview(title: "Remove Ads", body: "Remove ads charge is USD $1.99.", cancelbutton: "No", okbutton: "Yes") {
         
         self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
         
            if (SKPaymentQueue.canMakePayments()) {
                self.hud?.hide(animated: true)
                let productID:NSSet = NSSet(object: "com.adrapsheet.crawlapps");
                let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
                productsRequest.delegate = self;
                productsRequest.start();
                print("Fetching Products");
            } else {
                self.hud?.hide(animated: true)
                print("can't make purchases");
            }
         }
         
         self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func onRestore(_ sender: Any) {
        
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }else{
            print("error")
        }
        
//         self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
         
        
    }
}

// ----------------------------------
//  MARK: - UITableViewDataSource

extension MenuScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MenuListTableViewCell
        
        cell.lblName.text = arrMenuList[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_profile")
            break
        case 1:
            cell.imgMenu.image = #imageLiteral(resourceName: "ic_block-user")
        case 2:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_rate")
            break
        case 3:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_share.png")
            break
        case 4:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_feedback")
            break
        case 5:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_help")
            break
//        case 5:
////            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_remove")
//            break
        case 6:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_privacy")
            break
        case 7:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_terms")
            break
        case 8:
            cell.imgMenu?.image = #imageLiteral(resourceName: "ic_disclaimer.png")
            break
        case 9:
            cell.imgMenu.image = #imageLiteral(resourceName: "ic_disclaimer.png")
        default:
            break
        }

        return cell
    }

}

// ----------------------------------
//  MARK: - UITableViewDelegate

extension MenuScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            print("open block")
            let vc = storyboard?.instantiateViewController(withIdentifier: "BrowseContactViewController") as! BrowseContactViewController
            vc.isComeFromProfile = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:

            print("rate app")
            if let reviewURL = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1439929100?mt=8"), UIApplication.shared.canOpenURL(reviewURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(reviewURL)
                }
            }
        case 3:

            let APPUrl:URL = URL(string: "https://itunes.apple.com/us/app/rap-sheet/id1439929100?ls=1&mt=8")!
            let vc = UIActivityViewController(activityItems: [APPUrl], applicationActivities: [])
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                vc.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                
                vc.popoverPresentationController?.sourceView = self.view
                self.present(vc, animated: true, completion: nil)
            }else{
                present(vc, animated: true)
            }
        case 4:

            let vc = storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 5:
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "HelpScreenViewController") as! HelpScreenViewController
            vc.isCome = .Help
            self.navigationController?.pushViewController(vc, animated: true)
            
//        case 5:
//
////            let vc = storyboard?.instantiateViewController(withIdentifier: "RemoveResultVC") as! RemoveResultVC
////            self.navigationController?.pushViewController(vc, animated: true)
//            print("remove ")
        case 6:

            let vc = storyboard?.instantiateViewController(withIdentifier: "HelpScreenViewController") as! HelpScreenViewController
            vc.isCome = .PrivacePolicy
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 7:

            let vc = storyboard?.instantiateViewController(withIdentifier: "HelpScreenViewController") as! HelpScreenViewController
            vc.isCome = .Terms
            self.navigationController?.pushViewController(vc, animated: true)
            
        case 8:
        print("ok")
               if (SKPaymentQueue.canMakePayments()) {
                   let productID:NSSet = NSSet(object: "com.adrapsheet.crawlapps");
                   let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
                   productsRequest.delegate = self;
                   productsRequest.start();
                   print("Fetching Products");
               } else {
                   
                   print("can't make purchases");
               }
        default: break
        }
        tblMenuList.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

//MARK:- SKPaymentTransactionObserver method

extension MenuScreenViewController : SKProductsRequestDelegate, SKPaymentTransactionObserver  {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let count : Int = response.products.count
        print(count)
        if (count>0) {

            self.hud?.hide(animated: true)

            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == "com.adrapsheet.crawlapps") {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                buyProduct(product: validProduct);
                
            } else {
                print(validProduct.productIdentifier)
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        } else {
            print("nothing")
            self.hud?.hide(animated: true)

        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error Fetching product information");
//        SVProgressHUD .dismiss()
        self.hud?.hide(animated: true)

    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("transactions restored")
        
        for transact:SKPaymentTransaction in queue.transactions
        {
            if transact.transactionState == SKPaymentTransactionState.restored
            {
                let t: SKPaymentTransaction = transact as SKPaymentTransaction
                let prodID = t.payment.productIdentifier as String
                
                switch prodID {
                case "com.adrapsheet.crawlapps":
                    stackviewHeight.constant = 0
                    btnRestoreHeight.constant = 0
                    btnRemoveAds.isHidden = true
                  //  btnRemoveAdsHitghtConstrints.constant = 0
                    btnRestoreApp.isHidden = false
                  //  btnRestoreAppHeightConstraints.constant = 0
                
                default:
                    print("IAP not found")
                }
                SKPaymentQueue .default().finishTransaction(transact)
                defaults.set(true , forKey: "purchased")
//                SVProgressHUD .dismiss()
                self.hud?.hide(animated: true)

            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
        for transaction:SKPaymentTransaction  in queue.transactions
        {
            if transaction.transactionState == SKPaymentTransactionState.restored
            {
                SKPaymentQueue.default().finishTransaction(transaction)
                defaults.set(true , forKey: "purchased")
                
//                SVProgressHUD.dismiss()
                self.hud?.hide(animated: true)

                break
            }
        }
        self.hud?.hide(animated: true)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    defaults.set(true , forKey: "purchased")
                    stackviewHeight.constant = 0
                    btnRemoveAds.isHidden = true
                    btnRestoreApp.isHidden = true
//                    btnRestoreAppHeightConstraints.constant = 0
                    SVProgressHUD .dismiss()
                    self.hud?.hide(animated: true)
                    break;
                case .failed:
                    print("Purchased Failed");
//                    SVProgressHUD .dismiss()
                    self.hud?.hide(animated: true)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
//                    SVProgressHUD .dismiss()
                    self.hud?.hide(animated: true)
                    stackviewHeight.constant = 0
                    btnRestoreHeight.constant = 0
                    btnRestoreApp.tintColor = .clear
                    btnRemoveAds.isHidden = true
//                    btnRemoveAdsHitghtConstrints.constant = 0
                    btnRestoreApp.isHidden = true
//                    btnRestoreAppHeightConstraints.constant = 0

                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }
}

