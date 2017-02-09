//
//  addDrinksTabBarController.swift
//  harpersPOS
//
//  Created by Owen Harper on 08/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class addDrinksTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBarFont()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //Sets the tab bar font
    func tabBarFont() {
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "AppleSDGothicNeo-Bold", size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        appearance.setTitleTextAttributes(attributes, for: .normal)
    }
    
}
