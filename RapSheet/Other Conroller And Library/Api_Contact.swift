//
//  Api_Contact.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 08/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import Foundation


//let ServicePath = "http://rapsheet.crawlapps.com/api"  //Local
let ServicePath = "http://thealfam.com/rapsheet_api/api" //Live

let everyOneAPI = "https://api.everyoneapi.com/v1/phone/"
let imageURLPath = "http://thealfam.com/rapsheet_api/assets/profile"

//Local

//let Unit_Id = "ca-app-pub-3940256099942544~3347511713"
//
//let kBanneradURL = "ca-app-pub-3940256099942544/2934735716"
//let kFulladURL = "ca-app-pub-3940256099942544/4411468910"
//let Reward_Ads = "ca-app-pub-3940256099942544/1712485313"

//Live

let Unit_Id = "ca-app-pub-7827617590051418~4483273058"

let kBanneradURL = "ca-app-pub-7827617590051418/3441654124"
let kFulladURL = "ca-app-pub-7827617590051418/4399512571"
let Reward_Ads = "ca-app-pub-7827617590051418/7413799511"

let Auth_Token = "?account_sid=ACc397a3443ce34c1d9b415853b2ce8962&auth_token=AU8f4ffaee4ea446de88b462c02f09fbd7"
struct API
{
    //static var API_BASE_URL  = Live
    
    static var API_BASE_URL      = ServicePath
    static var UNIT_AD_ID        = Unit_Id
    static var BANNER_ADS        = kBanneradURL
    static var FULLSCREEN_ADS    = kFulladURL
    static var imageFullPath     = imageURLPath
    //    static var IMAGE_BASE_URL  = stagingimage
    
    //static var GET_REQUEST_TOKEN   = API_BASE_URL + "token/get_request_token"
    static var SEARCH                              = API_BASE_URL + "/contact/search?search="
    static var ADD_CONTACT                         = API_BASE_URL + "/contact/add"
    static var CONTACT_DETAIL                      = API_BASE_URL + "/contact/?id="
    static var ADD_COMMENT                         = API_BASE_URL + "/comments/add"
    static var MY_CONTACT                          = API_BASE_URL + "/contact/my/?id="
    static var DELETE_CONTACT                      = API_BASE_URL + "/contact/remove/"
    static var COMMENT_LIST                        = API_BASE_URL + "/comments?contact_id="
    static var ADD_USER                            = API_BASE_URL + "/user"
    static var DELETE_COMMENT                      = API_BASE_URL + "/comments/deletecomment?comment_id="
    static var ADD_COTACT_REPORT                   = API_BASE_URL + "/reports/add"
    static var BROWSE_CONTACT                      = API_BASE_URL + "/contact/browse"
    static var RECENT_CONTACT                      = API_BASE_URL + "/reports/get"
    static var EDIT_COMMENT                        = API_BASE_URL + "/comments/edit"
    static var FEEDBACK                            = API_BASE_URL + "/feedback/send"
    static var USERUPDATE                          = API_BASE_URL + "/user/update"
    static var GETUSER                             = API_BASE_URL + "/user/get?uuid="
}

func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool, strDate:String) -> String {
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return convertDataSubscription(date: strDate)
    } else if (components.year! >= 1){
        if (numericDates){
            return convertDataSubscription(date: strDate)
        } else {
            return convertDataSubscription(date: strDate)
        }
    } else if (components.month! >= 2) {
        return convertDataSubscription(date: strDate)
    } else if (components.month! >= 1) {
        if (numericDates){
            return convertDataSubscription(date: strDate)
        } else {
            return convertDataSubscription(date: strDate)
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return convertDataSubscription(date: strDate)
        } else {
            return convertDataSubscription(date: strDate)
        }
    } else if (components.day! >= 2) {
        return convertDataSubscription(date: strDate)
    } else if (components.day! >= 1){
        if (numericDates){
            return convertDataSubscription(date: strDate)
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
    
}

func formatNumber(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
    guard !phoneNumber.isEmpty else { return "" }
    guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
    let r = NSString(string: phoneNumber).range(of: phoneNumber)
    var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
    
    if number.count > 10 {
        let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
        number = String(number[number.startIndex..<tenthDigitIndex])
    }
    
    if shouldRemoveLastDigit {
        let end = number.index(number.startIndex, offsetBy: number.count-1)
        number = String(number[number.startIndex..<end])
    }
    
    if number.count < 7 {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "$1-$2", options: .regularExpression, range: range)
        
    } else {
        let end = number.index(number.startIndex, offsetBy: number.count)
        let range = number.startIndex..<end
        number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: range)
    }
    
    return number
}

/*
func format(phoneNumber sourcePhoneNumber: String) -> String? {
    
    // Remove any character that is not a number
    let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() 
    let length = numbersOnly.count
    let hasLeadingOne = numbersOnly.hasPrefix("1")
    
    // Check for supported phone number length
    guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
        return nil
    }
    
    let hasAreaCode = (length >= 10)
    var sourceIndex = 0
    
    // Leading 1
    var leadingOne = ""
    if hasLeadingOne {
        leadingOne = ""
        sourceIndex += 0
    }
    
    // Area code
    var areaCode = ""
    if hasAreaCode {
        let areaCodeLength = 3
        guard let areaCodeSubstring = numbersOnly.characters.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
            return nil
        }
        areaCode = String(format: "%@-", areaCodeSubstring)
        sourceIndex += areaCodeLength
    }
    
    // Prefix, 3 characters
    let prefixLength = 3
    guard let prefix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: prefixLength) else {
        return nil
    }
    sourceIndex += prefixLength
    
    // Suffix, 4 characters
    let suffixLength = 4
    guard let suffix = numbersOnly.characters.substring(start: sourceIndex, offsetBy: suffixLength) else {
        return nil
    }
    
    return leadingOne + areaCode + prefix + "-" + suffix
}

extension String.CharacterView {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}*/

extension String{
    func toDictionary() -> NSDictionary {
        let blankDict : NSDictionary = [:]
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return blankDict
    }
}
