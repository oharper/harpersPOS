//
//  billEventViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 17/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class billEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  
  let database = FIRDatabase.database().reference()
  var currentTableTotal: Double = 0
  var currentOrderTotal: Int = 0
  var currentTableDrinksArray: [String] = []
  var currentEvent: String = ""
  var currentTable: Int = 0
  var cashBool: Bool = false
  
  @IBOutlet weak var currentEventLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  @IBOutlet weak var quantityTable: UITableView!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var screenshotButton: UIButton!
  
  //Updates the table and total for the next table when next is pressed
  @IBAction func nextPressed(_ sender: Any) {
    
    currentTable += 1
    billEvent(currentTable: currentTable)
    readTableQuantities(currentTable: currentTable)
    
  }
  
  //Runs the screenshot method when the save button is pressed
  @IBAction func screenshotPressed(_ sender: Any) {
    takeScreenShot()
  }
  
  //Table Methods
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    
    let cell:UITableViewCell = quantityTable.dequeueReusableCell(withIdentifier: "quantityCell") as UITableViewCell!
    
    if (indexPath.row % 2 == 0) {
      cell.backgroundColor = .white;
    }
    else
    {
      cell.backgroundColor = .lightGray;
    }
    
    let item = currentTableDrinksArray[indexPath.row]
    var itemArray = item.components(separatedBy: ", ")
    cell.textLabel?.text = itemArray[0]
    cell.detailTextLabel?.text = itemArray[1]
    
    return cell
  }
  
  
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentTableDrinksArray.count
  }
  //End table methods
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Runs the method to update the table for either tabs or cards and resets total variables
    if cashBool == false {
      currentTableTotal = 0
      currentOrderTotal = 0
      billEvent(currentTable: currentTable)
      readTableQuantities(currentTable: currentTable)
    } else {
      currentTableTotal = 0
      currentOrderTotal = 0
      nextButton.isHidden = true
      billEventCash()
      readTableQuantitiesCash()
      titleLabel.text = "Cash or Card"
      
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //Updates the current event label and the title label, runs the method to read the totals for the current table.
  func billEvent(currentTable: Int) {
    
    let currentTable = "Table " + String(format: "%02d", currentTable)
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            self.currentEventLabel.text = "Event: " + eventName + " - " + eventDate
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Table 07").observeSingleEvent(of: .value, with: { snapshot in
              if snapshot.children.allObjects is [FIRDataSnapshot] {
                self.titleLabel.text = currentTable
                self.readTotals(table: currentTable)
              }
            })
            
          }
        }
      }
    })
    
  }
  
  func billEventCash() {
    
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            self.currentEventLabel.text = "Event: " + eventName + " - " + eventDate
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Table 07").observeSingleEvent(of: .value, with: { snapshot in
              if snapshot.children.allObjects is [FIRDataSnapshot] {
                self.readTotalsCash()
              }
            })
            
          }
        }
      }
    })
    
  }
  
  //Calculates and reads the total value of the tables tab inputted
  func readTotals(table: String) {
    
    self.currentOrderTotal = 0
    self.currentTableTotal = 0
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            
            
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
                  self.titleLabel.text = table + " is empty"
                  self.totalLabel.text = "Table Total: £00.00"
                }
                
                
              }
            })
            
            
          }
        }
      }
    })
    
    
  }
  
  //Reads the total for cash/card orders
  func readTotalsCash() {
    
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").observeSingleEvent(of: .value, with: { snapshot in
              if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                if snapshot.exists() {
                  for child in result {
                    let currentOrder = child.key
                    
                    
                    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child(currentOrder).observeSingleEvent(of: .value, with: { snapshot in
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
                  self.titleLabel.text = "Cash is empty"
                  self.totalLabel.text = "Table Total: £00.00"
                }
                
                
              }
            })
            
            
          }
        }
      }
    })
    
    
  }
  
  //Func to take a screenshot
  func takeScreenShot() {
    UIGraphicsBeginImageContext(view.frame.size)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let sourceImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    UIImageWriteToSavedPhotosAlbum(sourceImage!, nil, nil, nil)
    
  }
  
  //Reads the quantities for tab order for a given table
  func readTableQuantities(currentTable: Int) {
    
    let currentTable = "Table " + String(format: "%02d", currentTable)
    currentTableDrinksArray = []
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Totals").child(currentTable).observeSingleEvent(of: .value, with: { snapshot in
              if snapshot.exists() {
                if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                  for child in result {
                    
                    let drink = String(child.key)!
                    let quantity = String(describing: child.value!)
                    self.currentTableDrinksArray.append(String(drink) + ", " + String(describing: quantity))
                    self.quantityTable.reloadData()
                    
                  }
                }
              } else {
                
                self.currentTableDrinksArray.removeAll()
                self.quantityTable.reloadData()
                
              }
              
            })
          }
        }
      }
    })
  }
  
  //Reads the quantities for cash/card orders
  func readTableQuantitiesCash() {
    
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child("Totals").observeSingleEvent(of: .value, with: { snapshot in
              if snapshot.exists() {
                if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                  for child in result {
                    
                    let drink = String(child.key)!
                    let quantity = String(describing: child.value!)
                    self.currentTableDrinksArray.append(String(drink) + ", " + String(describing: quantity))
                    self.quantityTable.reloadData()
                    
                  }
                }
              } else {
                
                self.currentTableDrinksArray.removeAll()
                self.quantityTable.reloadData()
                
              }
              
            })
          }
        }
      }
    })
  }
  
}
