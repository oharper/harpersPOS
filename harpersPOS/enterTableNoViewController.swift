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
  var numberOfTables = 0

  @IBOutlet weak var currentEventLabel: UILabel!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      readEvent()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var tableField: UITextField!

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
          if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
            if snapshot.exists() {
        
      self.performSegue(withIdentifier: "enterTableToBill", sender: nil)
            }
            else {
              
              let alert = UIAlertController(title: "No Data for Table", message: "This table either does not exist or has not put anything on there tab.", preferredStyle: .alert)
              
              let tryAgain = UIAlertAction(title: "OK", style: .default) { (alert: UIAlertAction!) -> Void in
                self.tableField.text = ""
              }
              
              alert.addAction(tryAgain)
              
              self.present(alert, animated: true, completion:nil)
              
              
            }
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
    if (segue.identifier == "tableEntered") {
      let view : tableSummaryViewController = segue.destination as! tableSummaryViewController;
      view.table = "Table " + tableField.text!
    }
    
    if (segue.identifier == "enterTableToBill") {
      let view : billEventViewController = segue.destination as! billEventViewController;
      view.currentEvent = currentEventLabel.text!
      view.currentTable = Int(tableField.text!)!
    }
  }

        func getOrderDate() -> String {
          let date = Date()
          let formatter = DateFormatter()
          formatter.dateFormat = "dd|MM|yy"
          let result = formatter.string(from: date)
          return result
        }
  
  
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
