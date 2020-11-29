//
//  TabBarController.swift
//  Plot
//
//  Created by Steve Sparks on 11/2/20.
//

import UIKit

class TabBarController: UITabBarController {
    enum ActivityKeys: String {
        case selectedTab = "tabBarController.selectedTab"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        report()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let act = userActivity {
            if let idx = act.userInfo?[ActivityKeys.selectedTab.rawValue] as? Int {
                report("read selected tab from saved state")
                selectedIndex = idx
            } else {
                report()
            }
        } else {
            report()
        }
    }
        
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //        super.tabBar(tabBar, didSelect: item)
        if let act = userActivity, let idx = tabBar.items?.firstIndex(of: item) {
            act.userInfo?[ActivityKeys.selectedTab.rawValue] = idx
        }
    }
}
