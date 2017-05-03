//
//  closeTabViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 16/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class closeTabViewController: UIViewController {
  
  let database = FIRDatabase.database().reference()
  
  @IBOutlet weak var tableField: UITextField!
  
  //Takes the entered table and writes the status of that table as closed on the database. Asks for confirmation and gives confirmation that the tab is closed.
  @IBAction func closeTabPressed(_ sender: Any) {
    
    let tableNumber = Int(tableField.text!)
    
    let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to close Table " + String(tableNumber!) + "s tab?", preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
    }
    
    let closeAction = UIAlertAction(title: "Close", style: .destructive) { (alert: UIAlertAction!) -> Void in
      
      
      self.database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
        if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
          for child in result {
            if child.key == "Current Event" {
              
              let currentEvent = child.value as! String
              
              let itemArray = currentEvent.components(separatedBy: ", ")
              let eventDate = itemArray[0]
              let eventName = itemArray[1]
              
              
              
              
              self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Table Status").child("Table " + String(format: "%02d", tableNumber!)).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.children.allObjects is [FIRDataSnapshot] {
                  if snapshot.exists() {
                    
                    
                    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Table Status").child("Table " + String(format: "%02d", tableNumber!)).setValue("Closed")
                    
                    let alert = UIAlertController(title: "Table " + String(describing: tableNumber!) + " Closed" , message: "Table Number " + String(tableNumber!) + "s tab has been closed.", preferredStyle: .alert)
                    
                    let clearAction = UIAlertAction(title: "Accept", style: .default) { (alert: UIAlertAction!) -> Void in
                      self.performSegue(withIdentifier: "closeTabBack", sender: nil)
                      
                    }
                    
                    alert.addAction(clearAction)
                    self.present(alert, animated: true, completion:nil)
                    
                    
                    
                  } else {
                    
                    let alert = UIAlertController(title: "Invalid" , message: "This is not a valid table, please try again", preferredStyle: .alert)
                    
                    let clearAction = UIAlertAction(title: "Try Again", style: .default) { (alert: UIAlertAction!) -> Void in
                      
                      self.tableField.text = ""
                      self.tableField.becomeFirstResponder()
                      
                    }
                    
                    alert.addAction(clearAction)
                    self.present(alert, animated: true, completion:nil)
                    
                  }
                }
              })
            }
          }
        }
      })
    }
    
    alert.addAction(cancelAction)
    alert.addAction(closeAction)
    
    present(alert, animated: true, completion:nil)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableField.becomeFirstResponder()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
}
