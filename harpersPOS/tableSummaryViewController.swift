//
//  tableSummaryViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 14/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class tableSummaryViewController: UIViewController {
  
  @IBOutlet weak var tabStatusButton: UIButton!
  let database = FIRDatabase.database().reference()
  var totalsArray: [String] = []
  var currentTableTotal: Double = 0
  var table: String = ""
  
  
  @IBOutlet weak var tableLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableLabel.text = table
    readTotals(table: table)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  func initialOpenButtonSet() {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.value as! String == "Open" {
            self.tabStatusButton.setTitle("Bar Open", for: .normal)
            self.tabStatusButton.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.50, alpha:1.0)
          } else {
            self.tabStatusButton.setTitle("Bar Closed", for: .normal)
            self.tabStatusButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
          }
        }
      }
    })
  }
  
  func readTotals(table: String) {
    
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
    
    
    print(table)
            
    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child(table).observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        if snapshot.exists() {
        for child in result {
          let currentOrder = child.key
          
          
          self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child(table).child(currentOrder).observeSingleEvent(of: .value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
              for child in result {
                
                if child.key == "Order Total" {
                  var currentOrderTotal = child.value as! String
                  currentOrderTotal.remove(at: currentOrderTotal.startIndex)
                  self.currentTableTotal += Double(currentOrderTotal)!
                  self.totalLabel.text = "Table Total: £" + String(format:"%.2f", self.currentTableTotal)
                }
              }
            }
          })
          
          
          
          
          }
        } else {
          
          print("does not exist")
          
        }
        
        
      }
    })
    
            
          }
        }
      }
    })
    
  }
  
  
  func getOrderDate() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd|MM|yy"
    let result = formatter.string(from: date)
    return result
  }
  func getTable(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let name = itemArray[0]
    return name
  }
  
  func getTotal(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let price = itemArray[1]
    return price
  }
  
  
  
  
  
}
