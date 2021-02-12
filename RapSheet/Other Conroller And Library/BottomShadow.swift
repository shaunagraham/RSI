//
//  BottomShadow.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 08/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit

class BottomShadow: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func draw(_ rect: CGRect) {
        updateLayerProperties()
    }
    
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 7.0
        self.layer.masksToBounds = false
    }
}
