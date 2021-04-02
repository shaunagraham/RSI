//
//  CommentCell.swift
//  RapSheet
//
//  Created by DREAMWORLD on 27/02/21.
//  Copyright © 2021 Kalpesh Satasiya. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {

    @IBOutlet weak var viewName: UIView! {
        didSet {
            viewName.layer.borderColor = UIColor.gray.cgColor
            viewName.layer.borderWidth = 1
            viewName.layer.cornerRadius = viewName.frame.height / 2.0
        }
    }
    
    @IBOutlet weak var lblCommentName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
