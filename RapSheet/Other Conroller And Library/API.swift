//
//  API.swift
//  Connectto
//
//  Created by Kalpesh Satasiya on 27/11/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON




let mainkey = "fa7cb170bfdfda8e6a4436553af374f5"
let mixPanelId = "45b9c7613d1e2cd6255b06e2cf061a00"

let headers: HTTPHeaders = [
    "key":mainkey
]

var dictUserObject:JSON {
    return JSON(UserDefaults.standard.object(forKey: "isUserLogin") as? NSDictionary ?? NSDictionary())
}

let headerToken:HTTPHeaders = [
    "key":mainkey,
    "token":dictUserObject["token"].stringValue
]

let NOInterNetAvailabel = "No internet available."

class APICall: NSObject
{
    
    
    class func call_API_Get_Mehotd(url:String,handlerCompletion:@escaping (_ resDict:NSDictionary) -> Void) {
        
        print("Send URL:---->\(url)");
        
        if isConnectedToNetwork() == false
        {
            let dict = [kSuccess:false, kmessage: NOInterNetAvailabel ] as [String : Any]
            handlerCompletion(dict as NSDictionary)
        }
        
        Alamofire.request(url, method: .get).responseJSON { response in
            let finalJSON = try? JSON(data: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
            if let dict = finalJSON?.dictionaryObject as NSDictionary?
            {
                //                print("Receive Dict:((\(url))---->\(dict)");
                handlerCompletion(dict);
            }
            else
            {
                let dict = [kSuccess :false]
                print("FAIL-------------")
                //                showToastMessage(msg: (response.error?.localizedDescription)!)
                //                DisplayAlert(title: "Oops!", message: (response.error?.localizedDescription)!, vc: self)
                handlerCompletion(dict as NSDictionary)
            }
        }
    }
    
    class func call_API_ALL(url:String,param:[String:Any],handlerCompletion:@escaping (_ resDict:NSDictionary?,_ error:Error?) -> Void) {
        
        print("Send URL:---->\(url)");
        print("Send Dict:---->\(param)");
        
        if isConnectedToNetwork() == false
        {
            let dict = [kStatusCode : StatuscodeValue , kmessage :NOInterNetAvailabel] as [String : Any]
            handlerCompletion(dict as NSDictionary,nil);
        }
        
        Alamofire.request(url, method: .post, parameters: param).responseJSON { response in
            
            // print(response.error)
            let finalJSON = try? JSON(data: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
            if let dict = finalJSON?.dictionaryObject as NSDictionary?
            {
                handlerCompletion(dict,nil);
                print("Receive Dict:((\(url))---->\(dict)");
            }
            else
            {
                handlerCompletion(nil,response.error);
            }
        }
    }
    
    class func call_API_PUT(url:String,param:[String:Any],handlerCompletion:@escaping (_ resDict:NSDictionary?,_ error:Error?) -> Void) {
        
        print("Send URL:---->\(url)");
        print("Send Dict:---->\(param)");
        
        if isConnectedToNetwork() == false
        {
            let dict = [kStatusCode : StatuscodeValue , kmessage :NOInterNetAvailabel] as [String : Any]
            handlerCompletion(dict as NSDictionary,nil);
            
        }
        
        Alamofire.request(url, method: .put, parameters: param).responseJSON { response in
            // print(response.error)
            let finalJSON = try? JSON(data: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
            if let dict = finalJSON?.dictionaryObject as NSDictionary?
            {
                handlerCompletion(dict,nil);
                print("Receive Dict:((\(url))---->\(dict)");
            }
            else
            {
                handlerCompletion(nil,response.error);
            }
        }
    }
    
    class func call_API_ImageUpload(url:String,param:[String:Any],doc:[(parameter_name:String,data:Data,type:String)],handlerCompletion:@escaping (_ resDict:NSDictionary?,_ error:Error?) -> Void)
    {
        
        print("Send URL:---->\(url)");
        
        print("Send Dict:---->\(param)");
        
        if isConnectedToNetwork() == false
        {
            let dict = [Responsecode : StatuscodeValue , kmessage :NOInterNetAvailabel] as [String : Any]
            handlerCompletion(dict as NSDictionary,nil)
        }
        
        
        let urlUpload = try! URLRequest (url: url, method: .post)
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for(key,value) in param
            {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            
            for media in doc
            {
                print(media.type)
                if media.type == "profile_pic"{
                    multipartFormData.append(media.data, withName: media.parameter_name, fileName: "profile.png", mimeType: "image/png");
                }else if media.type == "image"{
                    multipartFormData.append(media.data, withName: media.parameter_name, fileName: "1.png", mimeType: "image/png");
                }else if media.type == "pdf"{
                    multipartFormData.append(media.data, withName: media.parameter_name, fileName: "1.pdf", mimeType: "application/pdf");
                }else if media.type == "doc"{
                    multipartFormData.append(media.data, withName: media.parameter_name, fileName: "1.doc", mimeType: "application/msword");
                }else if media.type == "docx"{
                    multipartFormData.append(media.data, withName: media.parameter_name, fileName: "1.docx", mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
                }
            }
            
        }, with: urlUpload) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //                    print(progress)
                })
                
                upload.responseJSON { response in
                    
                    let finalJSON = try? JSON(data: response.data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let dict = finalJSON?.dictionaryObject! as NSDictionary?
                    {
                        if response.response?.statusCode == 200 || response.response?.statusCode == 201 {
                            print("Receive Dict:---->\(dict)");
                            handlerCompletion(dict,nil);

                        }else{
                            let dict = [kStatusCode : response.response?.statusCode ?? 0, Error : finalJSON?["error"].string ?? ""] as [String : Any]
                            handlerCompletion(dict as NSDictionary,nil);
                        }
                    }
                    else
                    {
                        handlerCompletion(nil,response.error);
                        
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError.localizedDescription);
                break
            }
            
        }
    }
    
    class func isConnectedToNetwork()->Bool{
     
         return NetworkReachabilityManager()!.isReachable
        
        
    }
    
    
}




