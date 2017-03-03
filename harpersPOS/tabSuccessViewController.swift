//
//  tabSuccessViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 27/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class tabSuccessViewController: UIViewController {

    var tableNumber: String = ""
    
    @IBOutlet weak var tableLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableLabel.text = "Table " + tableNumber

        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "qrToInitial", sender: nil)
        }
        
        // Do any additional setup after loading the view.
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

}
