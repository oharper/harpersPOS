//
//  managerPasswordViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 01/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class managerPasswordViewController: UIViewController {
    
    let database = FIRDatabase.database().reference()
    
    @IBOutlet weak var codeField: UITextField!

    @IBAction func enterButton(_ sender: Any) {
        
        passcodeEntered()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func passcodeEntered() {
        
        database.child("Manager").observeSingleEvent(of: .value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    if child.value as? String == self.codeField.text {
                        self.performSegue(withIdentifier: "passcodeToLiveStats", sender: nil)
                    } else {
                        
                    }
                }
            }
        })
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
