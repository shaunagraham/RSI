//
//  MenuListTableViewCell.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit

class MenuListTableViewCell: UITableViewCell {
    
    //MARK: Outlet
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewDetail: UIView!
    
    @IBOutlet var imgMenu: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblName.font = UIFont(name: APP_DISPLAY_REGULER_FONT, size: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
