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
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  //Function that compares the passcode entered in the text field when return is pressed to the passcode set on the firebase database
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
}
