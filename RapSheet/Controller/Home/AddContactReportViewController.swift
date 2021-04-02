//
//  AddContactReportViewController.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 16/07/19.
//  Copyright © 2019 Kalpesh Satasiya. All rights reserved.
//

import UIKit
//import SkyFloatingLabelTextField
import SwiftyJSON
import MBProgressHUD

class AddContactReportViewController: UIViewController {
    
    
    //MARK: Variables
    
    var dictContactInfo:JSON?
    var dictUserDetail:NSDictionary = UserDefaults.standard.object(forKey: "isUserLogin") as? NSDictionary ?? NSDictionary()

    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    //MARK: IBOutlet
    
    @IBOutlet var txtTitle: SkyFloatingLabelTextField!
    
    @IBOutlet var txtComment: UITextView! {
        didSet {
            txtComment.delegate = self
            txtComment.text = "Comment"
            txtComment.textColor = UIColor.lightGray
            txtComment.textContainerInset = UIEdgeInsets(top: 10, left: -5, bottom: 0, right: 10)


        }
    }
    
    //MARK:- METHODS

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //        print(dictContactInfo)
    }

    //MARK:- Action
    @IBAction func onTapHandleReports(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.dismiss(animated: true, completion: nil)
        default:
            submitContactReport()
        }
        
        
    }
    
    // MARK:- Validation
    
    func validation() -> Bool {
        
        if txtTitle.text == "" {
            showToast(message: "Title is empty")
            return false
        }else if txtComment.text == "" || txtComment.text == "Comment" {
            showToast(message: "Comment is empty")

            return false
        }
        
        return true
        
    }
    
    //MARK:- Send Report
    
    func submitContactReport()  {
        
        if !validation() {
            return
        }
        
        let hud:MBProgressHUD = MBProgressHUD .showAdded(to: self.view, animated: true)
        
        let param:[String:Any] = [kUserid :dictUserDetail.value(forKey: "id") ?? "", Contactid :dictContactInfo?["id"].stringValue ?? "", Title : txtTitle.text ?? "",message : txtComment.text ?? ""]
        
        
        APICall.call_API_ALL(url: API.ADD_COTACT_REPORT, param: param) { (object, error) in
            hud .hide(animated: true)
            
            if let error = error {
                self.showToast(message: error.localizedDescription)
            }else{
                let object = JSON(object!)
                print(object)
                
                self.showToast(message: object["data"]["message"].stringValue )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
}

// MARK: - Transition Delegate

extension AddContactReportViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            let modal = ModalPresentationController(presentedViewController: presented, presenting: presenting)
            modal.height = 320.0
            return modal
        }
        
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented == self {
            return ModalAnimationPresentationController(isPresenting: true)
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self {
            return ModalAnimationPresentationController(isPresenting: false)
        } else {
            return nil
        }
    }
}

//MARK:- UITextView Delegate Method

extension AddContactReportViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment"
            textView.textColor = UIColor.lightGray
        }
    }
}
