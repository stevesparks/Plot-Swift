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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let act = userActivity {
            
            if let idx = act.userInfo?[ActivityKeys.selectedTab.rawValue] as? Int {
                report(String(describing: act.userInfo))
                selectedIndex = idx
            }
        }
    }
        
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //        super.tabBar(tabBar, didSelect: item)
        if let act = userActivity, let idx = tabBar.items?.firstIndex(of: item) {
            act.userInfo?[ActivityKeys.selectedTab.rawValue] = idx
        }
    }
}
