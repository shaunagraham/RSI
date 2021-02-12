//
//  ContactListTableViewCell.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import HCSStarRatingView

class ContactListTableViewCell: UITableViewCell {
    
    //MARK: Outlet
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var viewRatingStar: HCSStarRatingView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblUserName.font = UIFont(name: APP_DISPLAY_BOLD_FONT, size: 16)
        lblMobileNumber.font = UIFont(name: APP_DISPLAY_THIN_FONT, size: 20)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
	    }
    
    

}
