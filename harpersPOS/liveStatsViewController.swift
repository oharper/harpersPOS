//
//  liveStatsViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 01/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class liveStatsViewController: UIViewController {
  
  let database = FIRDatabase.database().reference()
  var numberOfTables: Int = 0
  
  @IBOutlet weak var openCloseButton: UIButton!
  
  //Function that opens a given number of tables tabs when the open/close button is pressed. Writes the bar status as closed if it is already open.
  @IBAction func openCloseBar(_ sender: Any) {
    
    if openCloseButton.currentTitle == "Bar Closed" {
      
      //Create alert controller.
      let alert = UIAlertController(title: "How many Tables?", message: "How many tables would you like to open?", preferredStyle: .alert)
      
      //Add text field
      alert.addTextField { (textField) in
        textField.keyboardType = UIKeyboardType.numberPad
        textField.text = ""
      }
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
      }))
      
      //Open Tab's action method
      alert.addAction(UIAlertAction(title: "Open Tab's", style: .default, handler: { [weak alert] (_) in
        let textField = alert?.textFields![0]
        var numberOfTables = Int(String(textField!.text!)!)!
        
        //Set button to open/write open
        self.openCloseButton.setTitle("Bar Open", for: .normal)
        self.openCloseButton.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.50, alpha:1.0)
        self.writeFirebase(child: "Bar", value: "Open", database: FIRDatabase.database().reference().child("Status"))
        
        //Get current event and write given number of tables as Open
        self.database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
          if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
            for child in result {
              if child.key == "Current Event" {
                
                let currentEvent = child.value as! String
                
                let itemArray = currentEvent.components(separatedBy: ", ")
                let eventDate = itemArray[0]
                let eventName = itemArray[1]
                
                
                while numberOfTables > 0 {
                  numberOfTables -= 1
                  self.writeFirebase(child: "Table " + String(format: "%02d", numberOfTables+1), value: "Open", database: FIRDatabase.database().reference().child("Events").child(String(eventDate + " | " + eventName)).child("Table Status"))
                }
                
              }
            }
          }
        })
      }))
      
      //Present alert
      self.present(alert, animated: true, completion: nil)
      
    } else {
      
      //Write closed and set button
      openCloseButton.setTitle("Bar Closed", for: .normal)
      openCloseButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
      writeFirebase(child: "Bar", value: "Closed", database: FIRDatabase.database().reference().child("Status"))
      
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initialOpenButtonSet()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  //Method to get the current status of bar and set the button accordingly
  func initialOpenButtonSet() {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Bar" {
            if child.value as! String == "Open" {
              self.openCloseButton.setTitle("Bar Open", for: .normal)
              self.openCloseButton.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.50, alpha:1.0)
            } else {
              self.openCloseButton.setTitle("Bar Closed", for: .normal)
              self.openCloseButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
            }
          }
        }
      }
    })
  }
  
  //Function used to write to firebase
  func writeFirebase(child: String, value: String, database: FIRDatabaseReference) {
    database.child(child).setValue(value)
  }
  
  //Method to set colours using RGB
  func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
}
