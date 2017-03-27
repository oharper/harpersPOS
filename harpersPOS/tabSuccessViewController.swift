//
//  tabSuccessViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 27/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class tabSuccessViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  let database = FIRDatabase.database().reference()
  var tableNumber: String = ""
  var currentOrder: [String] = []
  var subTotal: Double = 0
  
  @IBAction func saveButton(_ sender: Any) {
    confirmButton.isHidden = false
  }
  
  @IBAction func confirmPressed(_ sender: Any) {
    
    takeScreenShot()
    
    let uniqueID = UUID().uuidString
    
//    readCurrentEvent()
    
    postTimeTotal(total: subTotal, uniqueID: uniqueID)
    
    for item in currentOrder {
      post(drink: getName(item: item), quantity: getQuantityDigit(item: item), tableNumber: tableNumber, uniqueID: uniqueID, itemPrice: getPrice(item: item))
      postTotals(drink: getName(item: item), quantity: getQuantityDigit(item: item), price: Double(getPrice(item: item))!, tableNumber: tableNumber)
    }
    
    self.performSegue(withIdentifier: "qrToInitial", sender: nil)
  }
  
  
  @IBAction func backPressed(_ sender: Any) {
    confirmButton.isHidden = true
    self.performSegue(withIdentifier: "tabSuccessBack", sender: nil)
  }
  
  @IBOutlet weak var finalOrderTable: UITableView!
  
  @IBOutlet weak var subTotalLabel: UILabel!
  
  @IBOutlet weak var tableLabel: UILabel!
  
  @IBOutlet weak var confirmButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableLabel.text = "Table " + tableNumber + "?"
    subTotalLabel.text = "Sub Total: £" + String(format:"%.2f", subTotal)
    finalOrderTable.reloadData()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func takeScreenShot() {
    UIGraphicsBeginImageContext(view.frame.size)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let sourceImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    UIImageWriteToSavedPhotosAlbum(sourceImage!, nil, nil, nil)
    
  }
  
//  func readCurrentEvent() {
//    
//    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
//      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
//        for child in result {
//          if child.key == "Current Event" {
//            
//            let currentEvent = child.value as! String
//            
//            let itemArray = currentEvent.components(separatedBy: ", ")
//            print(itemArray)
//            let eventDate = itemArray[0]
//            let eventName = itemArray[1]
//            let eventID = itemArray[2]
//            
//          }
//        }
//      }
//    })
//    
//  }
  
  func post(drink: String, quantity: String, tableNumber: String, uniqueID: String, itemPrice: String){
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Table " + tableNumber).child(self.getTime() + " | " + uniqueID).child(drink + " x " + quantity).setValue("£" + String(format:"%.2f", Double(itemPrice)!*Double(quantity)!))
            
//            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Table " + tableNumber).child(self.getTime() + " | " + uniqueID).setValue("£" + String(format:"%.2f", Double(self.subTotal)))
            
            
            
            
            
            
            
          }
        }
      }
    })
    
    
    
  }
  
  func postTimeTotal(total: Double, uniqueID: String) {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
    
    let order : [String : String] = ["Order Total" : "£" + String(format:"%.2f", total)]
    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Table " + self.tableNumber).child(self.getTime() + " | " + uniqueID).setValue(order)
            
          }
        }
      }
    })
    
  }
  
  func postTotals(drink: String, quantity: String, price: Double, tableNumber:String) {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
    
    
    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Totals").child("Table " + tableNumber).child(drink).observeSingleEvent(of: .value, with: { snapshot in
      
      if snapshot.exists() {
        if snapshot.key == drink {
          let existingQuantity = String(describing: snapshot.value!)
          let quantityToAdd = Int(quantity)!
          let newQuantity = quantityToAdd + Int(existingQuantity)!
          self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Totals").child("Table " + tableNumber).child(drink).setValue(newQuantity)
        }
      }
      else {
        self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Tab").child("Totals").child("Table " + tableNumber).child(drink).setValue(Int(quantity))
      }
    })
           
          }
        }
      }
    })
    
    
    
    
    
    
            
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentOrder.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! orderTableViewCell
    
    cell.nameLabel.text = getName(item: currentOrder[indexPath.row])
    
    cell.singlePriceLabel.text = "£" + getPrice(item: currentOrder[indexPath.row]) + " x " + getQuantityDigit(item: currentOrder[indexPath.row])
    
    let quantityPrice = Double(getQuantityDigit(item: currentOrder[indexPath.row]))! * Double(getPrice(item: currentOrder[indexPath.row]))!
    cell.quantityPriceLabel.text = "£" + String(format:"%.2f", quantityPrice)
    
    return cell
    
  }
  
  func getName(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let name = itemArray[0]
    return name
  }
  
  func getPrice(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let price = itemArray[1]
    return price
  }
  
  func getQuantityDigit(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let quantity = itemArray[2]
    return quantity
  }
  
  func getTime() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    let result = formatter.string(from: date)
    return result
  }
  
  func getOrderDate() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd|MM|yy"
    let result = formatter.string(from: date)
    return result
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "tabSuccessBack") {
      let view : qrViewController = segue.destination as! qrViewController;
      view.currentOrder = currentOrder
      view.subTotal = subTotal
    }
  }
  
  
}
