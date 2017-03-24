//
//  newEventViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 15/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class newEventViewController: UIViewController {
  
  @IBOutlet weak var eventNameField: UITextField!
  @IBOutlet weak var eventDateField: UITextField!
  @IBOutlet weak var eventIDField: UITextField!
  
  @IBOutlet weak var tableNumberField: UITextField!
  @IBOutlet weak var tableNameField: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()

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
