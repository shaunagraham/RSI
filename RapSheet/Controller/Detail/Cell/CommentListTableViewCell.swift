//
//  CommentListTableViewCell.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 10/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit

class CommentListTableViewCell: UITableViewCell {
    
    //MARK: Outlet
    
    @IBOutlet weak var lblCommentName: UILabel!
    @IBOutlet weak var lblsepraterView: UILabel!
    @IBOutlet weak var lblDateAndTime: UILabel!
    @IBOutlet var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
