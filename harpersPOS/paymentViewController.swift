//
//  paymentViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 03/03/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class paymentViewController: UIViewController {
  
  let database = FIRDatabase.database().reference()
  var currentOrder: [String] = []
  var subTotal: Double = 0
  var cashOrCard: String = ""
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  @IBOutlet weak var calculateButton: UIButton!
  @IBOutlet weak var screenBackButton: UIButton!
  @IBOutlet weak var cashBackButton: UIButton!
  @IBOutlet weak var cashConfirmButton: UIButton!
  @IBOutlet weak var cashSubmitButton: UIButton!
  @IBOutlet weak var subTotalLabel: UILabel!
  @IBOutlet var paymentButtons: [UIButton]!
  @IBOutlet weak var changeGivenField: UITextField!
  @IBOutlet weak var changeDueLabel: UILabel!
  @IBOutlet var paymentLabels: [UILabel]!
  
  
  @IBAction func dismissPressed(_ sender: Any) {
    cashConfirmButton.isHidden = true
    performSegue(withIdentifier: "paymentBack", sender: nil)
  }
  
  
  @IBAction func cashButtonPressed(_ sender: Any) {
    cashOrCard = "Cash"
    subTotalLabel.text = "£" + String(format:"%.2f", subTotal)
    subTotalLabel.isHidden = false
    cashSubmitButton.isHidden = false
    cashBackButton.isHidden = false
    changeGivenField.isHidden = false
    changeDueLabel.isHidden = false
    calculateButton.isHidden = false
    changeGivenField.becomeFirstResponder()
    screenBackButton.isHidden = true
    self.view.backgroundColor = UIColor(red:0.00, green:0.25, blue:0.50, alpha:1.0)
    for item in paymentButtons {
      item.isHidden = true
    }
    for item in paymentLabels {
      item.isHidden = true
    }
  }
  
  @IBAction func calculatePressed(_ sender: Any) {
    
    self.view.endEditing(true)
    if Double(changeGivenField.text!)! - subTotal >= 0 {
      
      changeDueLabel.text = "Change Due: £" + String(format:"%.2f", (Double(changeGivenField.text!)! - subTotal))
      
    } else {
      
      let changeDue = Double(changeGivenField.text!)! - subTotal
      
      let alert = UIAlertController(title: "£" + String(format:"%.2f", abs(changeDue)) + " Short", message: "Not enough money was given", preferredStyle: UIAlertControllerStyle.alert)
      
      alert.addAction(UIAlertAction(title: "Try Again", style: .default) { (alert: UIAlertAction!) -> Void in
        self.changeGivenField.becomeFirstResponder()
        self.changeGivenField.text = ""
      })
      
      self.present(alert, animated: true, completion: nil)
      
    }
    
  }
  
  
  @IBAction func cardButtonPressed(_ sender: Any) {
    cashOrCard = "Card"
    subTotalLabel.text = "£" + String(format:"%.2f", subTotal)
    subTotalLabel.isHidden = false
    cashSubmitButton.isHidden = false
    cashBackButton.isHidden = false
    self.view.backgroundColor = UIColor(red:0.00, green:0.25, blue:0.50, alpha:1.0)
    for item in paymentButtons {
      item.isHidden = true
    }
    for item in paymentLabels {
      item.isHidden = true
    }
  }
  
  
  @IBAction func tabButtonPressed(_ sender: Any) {
    performSegue(withIdentifier: "paymentToQR", sender: nil)
  }
  
  
  @IBAction func cashSubmitPressed(_ sender: Any) {
    cashConfirmButton.isHidden = false
  }
  
  
  @IBAction func cashConfirmPressed(_ sender: Any) {
    
    let uniqueID = UUID().uuidString
    
    postTimeTotal(total: subTotal, uniqueID: uniqueID)
    
    for item in currentOrder {
      post(drink: getName(item: item), quantity: getQuantityDigit(item: item), uniqueID: uniqueID, itemPrice: getPrice(item: item), cashOrCard: cashOrCard)
      postTotals(drink: getName(item: item), quantity: getQuantityDigit(item: item), price: Double(getPrice(item: item))!)
    }
    
    performSegue(withIdentifier: "cashToInitial", sender: nil)
  }
  
  
  @IBAction func backPressed(_ sender: Any) {
    performSegue(withIdentifier: "paymentBack", sender: nil)
  }
  
  
  func post(drink: String, quantity: String, uniqueID: String, itemPrice: String, cashOrCard: String){
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
    
    
    
    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child(self.getTime() + " | " + uniqueID).child(drink + " x " + quantity).setValue("£" + String(format:"%.2f", Double(itemPrice)!*Double(quantity)!))
    
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
            
    
    let order : [String : String] = ["Order Total" : "£" + String(format:"%.2f", total), "Paid By" : self.cashOrCard]
    self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child(self.getTime() + " | " + uniqueID).setValue(order)
    
            
          }
        }
      }
    })
  }
  
  
  
  
  func postTotals(drink: String, quantity: String, price: Double) {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child("Totals").child(drink).observeSingleEvent(of: .value, with: { snapshot in
              
              if snapshot.exists() {
                if snapshot.key == drink {
                  let existingQuantity = String(describing: snapshot.value!)
                  let quantityToAdd = Int(quantity)!
                  let newQuantity = quantityToAdd + Int(existingQuantity)!
                  self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child("Totals").child(drink).setValue(newQuantity)
                }
              }
              else {
                self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Orders").child("Cash|Card").child("Totals").child(drink).setValue(Int(quantity))
              }
            })
            
          }
        }
      }
    })
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
  
  
  func getName(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let name = itemArray[0]
    return name
  }
  
  
  func getQuantityDigit(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let quantity = itemArray[2]
    return quantity
  }
  
  
  func getPrice(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let price = itemArray[1]
    return price
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if (segue.identifier == "paymentToQR") {
      let view : qrViewController = segue.destination as! qrViewController;
      view.currentOrder = currentOrder
      view.subTotal = subTotal
    }
    if (segue.identifier == "paymentBack") {
      let view: orderViewController = segue.destination as! orderViewController
      view.currentOrder = currentOrder
      view.subTotal = subTotal
      
    }
  }
  
  
}
