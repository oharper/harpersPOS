//
//  orderViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 09/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class orderViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {
  
  let database = FIRDatabase.database().reference()
  var leftTableCount: Int = 0
  var rightTableCount: Int = 0
  var isInOrder: Bool = false
  var alreadyInOrderIndex: Int = 0
  var subTotal: Double = 0
  
  var currentCategoryArray: [String] = []
  var currentOrder: [String] = []
  
  var beerArray: [String] = []
  var wineArray: [String] = []
  var spiritsArray: [String] = []
  var softArray: [String] = []
  var otherArray: [String] = []
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Runs the method to set the font of the tab bar
    tabBarFont()
    
    //Populates drinks arrays from firebase
    readFirebase()
    
    //Sets the initial subTotal label
    subTotalLabel.text = "Sub Total: £" + String(format:"%.2f", subTotal)
    
    //Automatically selects the first item in the tab bar
    tabBar.selectedItem = (tabBar.items?[0])! as UITabBarItem;
    
    //Loads the table with the default beer array
    currentCategoryArray = wineArray
    
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  @IBOutlet weak var tabBar: UITabBar!
  @IBOutlet weak var drinksTable: UITableView!
  @IBOutlet weak var orderTable: UITableView!
  @IBOutlet weak var subTotalLabel: UILabel!
  
  
  //Action method that, when the void button is pressed, asks the user to confirm and then segues back to the initial screen if they do
  @IBAction func voidPressed(_ sender: Any) {
    
    let alert = UIAlertController(title: "Void Order", message: "Are you sure you want to void this order?", preferredStyle: .alert)
    
    let clearAction = UIAlertAction(title: "Continue Order", style: .default) { (alert: UIAlertAction!) -> Void in
    }
    
    let cancelAction = UIAlertAction(title: "Void Order", style: .destructive) { (alert: UIAlertAction!) -> Void in
      self.currentOrder = []
      self.performSegue(withIdentifier: "orderToInitial", sender: nil)
    }
    
    alert.addAction(clearAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion:nil)
  }
  
  
  //Action method that, when the save button is pressed, providing the current order is not empty, will segue to the payment selection screen
  @IBAction func savePressed(_ sender: Any) {
    
    if currentOrder.isEmpty == false {
      performSegue(withIdentifier: "orderToPayment", sender: nil)
    }
    
  }
  
  
  //Gets from firebase database all the drinks and prices of each category and puts them into an array that is stored locally. The name and price of each drink in this array are seperated with a ", "
  
  func readFirebase() {
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Drinks").child("Beer").observeSingleEvent(of: .value, with: { snapshot in
              if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                  let orderName = child.key
                  let orderPrice = child.value as! String
                  
                  
                  self.beerArray.append(orderName + ", " + orderPrice)
                  self.currentCategoryArray = self.beerArray
                  self.drinksTable.reloadData()
                  
                }
              }
            })
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Drinks").child("Wine").observeSingleEvent(of: .value, with: { snapshot in
              if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                  let orderName = child.key
                  let orderPrice = child.value as! String
                  
                  
                  self.wineArray.append(orderName + ", " + orderPrice)
                  self.currentCategoryArray = self.beerArray
                  self.drinksTable.reloadData()
                  
                }
              }
            })
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Drinks").child("Spirits").observeSingleEvent(of: .value, with: { snapshot in
              if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                  let orderName = child.key
                  let orderPrice = child.value as! String
                  
                  self.spiritsArray.append(orderName + ", " + orderPrice)
                  self.currentCategoryArray = self.beerArray
                  self.drinksTable.reloadData()
                  
                }
              }
            })
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Drinks").child("Soft").observeSingleEvent(of: .value, with: { snapshot in
              if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                  let orderName = child.key
                  let orderPrice = child.value as! String
                  
                  
                  self.softArray.append(orderName + ", " + orderPrice)
                  self.currentCategoryArray = self.beerArray
                  self.drinksTable.reloadData()
                  
                }
              }
            })
            
            self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Drinks").child("Other").observeSingleEvent(of: .value, with: { snapshot in
              if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                  let orderName = child.key
                  
                  let orderPrice = child.value as! String
                  
                  
                  self.otherArray.append(orderName + ", " + orderPrice)
                  self.currentCategoryArray = self.beerArray
                  self.drinksTable.reloadData()
                  
                }
              }
            })
          }
        }
      }
    })
  }
  
  
  //Function to get the name of an array item, or otherwise the string before the first comma
  
  func getName(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let name = itemArray[0]
    return name
    
  }
  
  //Function to get the price of an array item, or otherwise the string after the first comma
  
  func getPrice(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let price = Double(itemArray[1])
    return String(format:"%.2f", price!)
    
  }
  
  
  //Function to get the quantity of an array item, or otherwise the string after the second comma
  
  func getQuantityDigit(item: String) -> String {
    
    let itemArray = item.components(separatedBy: ", ")
    let quantity = itemArray[2]
    return quantity
    
  }
  
  
  //Function that counts the number of items in the current order
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (tableView.tag == 0) {
      leftTableCount = currentCategoryArray.count
      return leftTableCount
    }
    else if (tableView.tag == 1) {
      rightTableCount = currentOrder.count
      return rightTableCount
    }
    else {
      return 0
    }
  }
  
  
  //Function to put the data from the arrays into the two tables
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if (tableView.tag == 0) {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! selectionTableViewCell
      
      cell.selectionNameLabel.text = getName(item: currentCategoryArray[indexPath.row])
      
      cell.selectionPriceLabel.text = "£" + getPrice(item: currentCategoryArray[indexPath.row])
      
      return cell
      
    }
    else {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! orderTableViewCell
      
      cell.nameLabel.text = getName(item: currentOrder[indexPath.row])
      
      cell.singlePriceLabel.text = "£" + getPrice(item: currentOrder[indexPath.row]) + " x " + getQuantityDigit(item: currentOrder[indexPath.row])
      
      let quantityPrice = Double(getQuantityDigit(item: currentOrder[indexPath.row]))! * Double(getPrice(item: currentOrder[indexPath.row]))!
      cell.quantityPriceLabel.text = "£" + String(format:"%.2f", quantityPrice)
      
      return cell
      
    }
  }
  
  
  //Methods for when a table item is tapped on, different method depending on if a cell from the left table is tapped on or a cell from the right. For the left it adds the item to the current order array, for the right it removes a single unit of that item, or the whole item if only one. Also calculates the total price with quantity for each drink, and the main subtotal label.
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    if (tableView.tag == 0) {
      let toBeMoved = currentCategoryArray[indexPath.row]
      if checkAlreadyInOrder(toBeMoved: toBeMoved) {
        //code here if left table tapped and already in order
        let toBeMovedName = getName(item: toBeMoved)
        let toBeMovedIndex = getAlreadyInOrderIndex(itemToGet: toBeMovedName)
        var toBeMovedQuantity = Int(getQuantityDigit(item:currentOrder[toBeMovedIndex]))!
        let toBeMovedPrice = getPrice(item: currentOrder[toBeMovedIndex])
        
        toBeMovedQuantity += 1
        subTotal = subTotal + Double(toBeMovedPrice)!
        subTotalLabel.text = "Sub Total: £" + String(format:"%.2f", subTotal)
        currentOrder[toBeMovedIndex] = toBeMovedName + ", " + toBeMovedPrice + ", "  + String(toBeMovedQuantity)
        self.orderTable.reloadData()
      }
        
      else {
        //code here if left table tapped and not already in order
        currentOrder.append(toBeMoved + ", " + "1")
        let toBeMovedName = getName(item: toBeMoved)
        let toBeMovedIndex = getAlreadyInOrderIndex(itemToGet: toBeMovedName)
        let toBeMovedPrice = getPrice(item: currentOrder[toBeMovedIndex])
        subTotal = subTotal + Double(toBeMovedPrice)!
        subTotalLabel.text = "Sub Total: £" + String(format:"%.2f", subTotal)
        self.orderTable.reloadData()
      }
    }
      
    else if (tableView.tag == 1) {
      let toBeMoved = currentOrder[indexPath.row]
      let toBeMovedName = getName(item: toBeMoved)
      let toBeMovedIndex = getAlreadyInOrderIndex(itemToGet: toBeMovedName)
      var toBeMovedQuantity = Int(getQuantityDigit(item:currentOrder[toBeMovedIndex]))!
      let toBeMovedPrice = getPrice(item: currentOrder[toBeMovedIndex])
      subTotal = subTotal - Double(toBeMovedPrice)!
      subTotalLabel.text = "Sub Total: £" + String(format:"%.2f", subTotal)
      if toBeMovedQuantity > 1 {
        toBeMovedQuantity -= 1
        currentOrder[toBeMovedIndex] = toBeMovedName + ", " + toBeMovedPrice + ", "  + String(toBeMovedQuantity)
        self.orderTable.reloadData()
      }
      else {
        currentOrder.remove(at: toBeMovedIndex)
        self.orderTable.reloadData()
      }
    }
    
    if currentOrder.isEmpty {
      subTotalLabel.text = "Sub Total: £0.00"
    }
    
  }
  
  
  //Function to check to see if a drink is already in the order
  
  func checkAlreadyInOrder(toBeMoved: String) -> Bool {
    for object in currentOrder {
      if object.range(of:toBeMoved) != nil {
        let isInOrder = true
        return isInOrder
      }
    }
    return isInOrder
  }
  
  
  //Function to get the index in the array of the item that is already in the order
  
  func getAlreadyInOrderIndex(itemToGet: String) -> Int {
    for item in currentOrder {
      if getName(item: item) == itemToGet {
        let alreadyInOrderIndex = currentOrder.index(of: item)
        return alreadyInOrderIndex!
      }
    }
    return alreadyInOrderIndex
  }
  
  
  //Method to change currentArray and hence the table depending on which category is selected
  
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    
    switch item.tag  {
    case 0:
      currentCategoryArray = beerArray
      break
    case 1:
      currentCategoryArray = wineArray
      break
    case 2:
      currentCategoryArray = spiritsArray
      break
    case 3:
      currentCategoryArray = softArray
    case 4:
      addOther()
      tabBar.selectedItem = (tabBar.items?[0])! as UITabBarItem;
    default:
      break
    }
    self.drinksTable.reloadData()
  }
  
  func addOther() {
    
    //1. Create the alert controller.
    let alert = UIAlertController(title: "Other Item", message: "Please enter the name and price of the misc item.", preferredStyle: .alert)
    
    //2. Add the text field. You can configure it however you need.
    alert.addTextField { (textField) in
      textField.keyboardType = UIKeyboardType.default
      textField.autocapitalizationType = .words
      textField.placeholder = "Name"
      textField.text = ""
    }
    
    alert.addTextField { (priceField) in
      priceField.keyboardType = UIKeyboardType.numberPad
      priceField.placeholder = "Price"
      priceField.text = ""
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
    }))
    
    // 3. Grab the value from the text field, and print it when the user clicks OK.
    alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
      let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
      let priceField = alert?.textFields![1]
      let price = String(priceField!.text!)!
      let name = String(textField!.text!)!
      self.currentOrder.append(name + ", " + price + ", 1")
      self.subTotal = self.subTotal + Double(price)!
      self.subTotalLabel.text = "Sub Total: £" + String(format:"%.2f", self.subTotal)
      self.orderTable.reloadData()
    }))
    
    
    
    // 4. Present the alert.
    self.present(alert, animated: true, completion: nil)
    
    
  }
  
  
  //Changes the font of the tab bar
  
  func tabBarFont() {
    let appearance = UITabBarItem.appearance()
    let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "AppleSDGothicNeo-Bold", size: 18)!, NSForegroundColorAttributeName: UIColor.black]
    appearance.setTitleTextAttributes(attributes, for: .normal)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "orderToPayment") {
      let view : paymentViewController = segue.destination as! paymentViewController;
      view.currentOrder = currentOrder
      view.subTotal = subTotal
    }
  }
  
  //Overwriting two default variables in order to force Landscape right orientation
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscapeRight
  }
  
  
}
