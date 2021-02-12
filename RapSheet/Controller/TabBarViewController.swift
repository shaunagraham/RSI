//
//  TabBarViewController.swift
//  RapSheet
//
//  Created by DREAMWORLD on 02/11/20.
//  Copyright © 2020 Kalpesh Satasiya. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    func setUI() {
        //TAB_UNSELECTED_COLOR
        self.tabBar.backgroundColor = TAB_BACKGROUND_COLOR
        if let items = tabBar.items {
            // Setting the title text color of all tab bar items:
            for item in items {
                item.setTitleTextAttributes([.foregroundColor: TAB_SELECTED_COLOR, .font : UIFont(name: APP_MEDIUM_FONT, size: 11)!], for: .selected)
                item.setTitleTextAttributes([.foregroundColor: TAB_UNSELECTED_COLOR, .font : UIFont(name: APP_MEDIUM_FONT, size: 11)!], for: .normal)
            }
        }
    }
}

