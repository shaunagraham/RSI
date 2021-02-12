//
//  HelpScreenViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 09/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import SWRevealViewController
import SVProgressHUD
import MBProgressHUD
import WebKit

enum iscomeFrom {
    case Help,PrivacePolicy,Terms
}

class HelpScreenViewController: UIViewController, SWRevealViewControllerDelegate {
    
    
    //MARK:- VARIABLE
    
    var web_url:String = "http://rapsheetapp.com/faq/?device=mobile"
        //UserDefaults.standard.object(forKey: "Web_url") as! String
    var defaults = UserDefaults.standard
    var hud:MBProgressHUD?
    var isCome = iscomeFrom.Help
    var web_url_Privacy :String = "http://rapsheetapp.com/privacy-policy/?device=mobile"
    var web_url_term :String = "https://rapsheetapp.com/terms-of-use/"
    //MARK:- Outlet
    
//    @IBOutlet weak var btnMenu: UIButton!
//    @IBOutlet var viewBannerAds: GADBannerView!
//    @IBOutlet var viewBannerHeightConstraints: NSLayoutConstraint!
//    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var webViewHelp: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        SVProgressHUD.show(withStatus: "Loading...")
//        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        
//        loadUrlInWebView()
//        leftSilder()
        
        /*
        if (defaults.bool(forKey: "purchased")){
            // Hide a view or show content depends on your requirement
            //            overlayView.hidden = true
            viewBannerHeightConstraints.constant = 0
            
        } else if (!defaults.bool(forKey: "stonerPurchased")) {
            print("false")
            print(API.BANNER_ADS)
            viewBannerAds.adUnitID = API.BANNER_ADS
            viewBannerAds.rootViewController = self
            viewBannerAds.load(GADRequest())
            
        }
        */
        
        lblHelp.font = UIFont(name: APP_SEMIBOLD_FONT, size: 18)
        lblHelp.tintColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isCome == .Help{
            lblHelp.text = "Help"
            loadUrlInWebViewofHelp()
        }else if isCome == .PrivacePolicy{
            lblHelp.text = "Privacy Policy"
            loadUrlInWebViewofPrivacyPolicy()
        }else{
            lblHelp.text = "Terms Of Use"
            loadUrlInWebViewofTerms()
        }
    }
    //MARK:- Load Url In WebView
    
    func loadUrlInWebViewofHelp()  {
        
        if let url = URL(string: web_url) {
            let request = URLRequest(url: url)
            self.webViewHelp.load(request)
        }
    }

    func loadUrlInWebViewofPrivacyPolicy()  {
        
        if let url = URL(string: web_url_Privacy) {
            let request = URLRequest(url: url)
            self.webViewHelp.load(request)
        }
    }
    
    func loadUrlInWebViewofTerms()  {
        
        if let url = URL(string: web_url_term) {
            let request = URLRequest(url: url)
            self.webViewHelp.load(request)
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func leftSilder() {
        
        
        if self.revealViewController() != nil {
            
            self.revealViewController().delegate = self
            self.revealViewController() .panGestureRecognizer().isEnabled = true
//            btnMenu.addTarget(self.revealViewController(), action:#selector(SWRevealViewController.revealToggle(_:)) , for:.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- ACTION
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnHome(_ sender: Any) {
        let vcHomeScreen = self.storyboard?.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        let navigationController = MainNavigationViewController(rootViewController: vcHomeScreen)
        navigationController.isNavigationBarHidden = true
        let vcReveal:SWRevealViewController = self.revealViewController() as SWRevealViewController
        vcReveal.pushFrontViewController(navigationController, animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: UIWebView Delegate Method

extension HelpScreenViewController : UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.hud?.hide(animated: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hud?.hide(animated: true)
    }
    
}
