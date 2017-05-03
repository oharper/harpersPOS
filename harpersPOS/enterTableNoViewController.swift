//
//  enterTableNoViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 08/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class enterTableNoViewController: UIViewController {
  
  let database = FIRDatabase.database().reference()
  var cashBool: Bool = false
  
  @IBOutlet weak var currentEventLabel: UILabel!
  @IBOutlet weak var tableField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    readEvent()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  //Segues to the billEvent view controller when the cash bill button is pressed
  @IBAction func cashPressed(_ sender: Any) {
    cashBool = true
    self.performSegue(withIdentifier: "enterTableToBill", sender: nil)
  }
  
  //Checks to see if the table exists and if it does, closes it, displays an alert if it doesnt exist or if the format entered is wrong.
  @IBAction func keyboardGoPressed(_ sender: Any) {
    
    if tableField.text?.characters.count == 2 {
      
      
      database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
        if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
          for child in result {
            if child.key == "Current Event" {
              
              let currentEvent = child.value as! String
              
              let itemArray = currentEvent.components(separatedBy: ", ")
              let eventDate = itemArray[0]
              let eventName = itemArray[1]
              
              
              self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Table " + self.tableField.text!).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                  
                  self.performSegue(withIdentifier: "enterTableToBill", sender: nil)
                  
                }
              })
            }
          }
        }
      })
    }
      
    else {
      
      let alert = UIAlertController(title: "Invalid Table", message: "Please enter table as a 2 digit number.. eg. For table 7 enter '07'", preferredStyle: .alert)
      
      let tryAgain = UIAlertAction(title: "Try Again", style: .default) { (alert: UIAlertAction!) -> Void in
        self.tableField.text = ""
      }
      
      alert.addAction(tryAgain)
      
      self.present(alert, animated: true, completion:nil)
      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if (segue.identifier == "enterTableToBill") {
      let view : billEventViewController = segue.destination as! billEventViewController;
      view.currentEvent = currentEventLabel.text!
      if tableField.text == "" {
      } else {
        view.currentTable = Int(tableField.text!)!
      }
      view.cashBool = cashBool
    }
  }
  
  //Reads the current event
  func readEvent() {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            self.currentEventLabel.text = "Current Event: " + currentEvent
            
          }
        }
      }
    })
  }
}
