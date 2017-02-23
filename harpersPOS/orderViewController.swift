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

// Dont think these two are needed??
//    var ref:FIRDatabaseReference?
//    var databaseHandle:FIRDatabaseHandle?
    
    let database = FIRDatabase.database().reference()
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var drinksTable: UITableView!
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var subTotalLabel: UILabel!
    
    //Action method for when the void button is pressed
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
    
    //Action method for when save button is pressed
    @IBAction func savePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Cash/Card or Tab?", message: "Do you want to charge by cash/card or put it on a tab?", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Cash/Card", style: .default) { (alert: UIAlertAction!) -> Void in
            //code here if by cash/card
        }
        let cancelAction = UIAlertAction(title: "Tab", style: .default) { (alert: UIAlertAction!) -> Void in
            //code here if on tab
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
        
    }
    
    
    var leftTableCount: Int = 0
    var rightTableCount: Int = 0
    var orderValue: String = ""
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
        
        writeFirebase(child: "Carling", value: "2.40", database: database.child("Drinks").child("Beer"))
        writeFirebase(child: "Coke", value: "1.50", database: database.child("Drinks").child("Soft"))
        
        //Populates drinks arrays from firebase
        readFirebase()
        
        //Automatically selects the first item in the tab bar
        tabBar.selectedItem = (tabBar.items?[0])! as UITabBarItem;
        
        //Loads the table with the default beer array
        currentCategoryArray = beerArray
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to write to firebase when given a child, value and database reference
    func writeFirebase(child: String, value: String, database: FIRDatabaseReference) {
        
        database.child(child).setValue(value)
        
    }
    
    func readFirebase() {
        
        database.child("Drinks").child("Beer").observeSingleEvent(of: .value, with: { snapshot in
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
        
        database.child("Drinks").child("Wine").observeSingleEvent(of: .value, with: { snapshot in
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
        
        database.child("Drinks").child("Spirits").observeSingleEvent(of: .value, with: { snapshot in
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
        
        database.child("Drinks").child("Soft").observeSingleEvent(of: .value, with: { snapshot in
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
        
        database.child("Drinks").child("Other").observeSingleEvent(of: .value, with: { snapshot in
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
    
    
    //Function that counts the number of items in the table arrays
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
    
    //Method to put the data from the arrays into the tables
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (tableView.tag == 0) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! selectionTableViewCell
            
            cell.selectionNameLabel.text = getName(item: currentCategoryArray[indexPath.row])
            cell.selectionPriceLabel.text = "£" + getPrice(item: currentCategoryArray[indexPath.row])
            return cell
        }
        else {
            //Custom cell label update here!
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! orderTableViewCell
            
            cell.nameLabel.text = getName(item: currentOrder[indexPath.row]) + " x " + getQuantityDigit(item: currentOrder[indexPath.row])
            
            cell.singlePriceLabel.text = "£" + getPrice(item: currentOrder[indexPath.row])
            
            let quantityPrice = Double(getQuantityDigit(item: currentOrder[indexPath.row]))! * Double(getPrice(item: currentOrder[indexPath.row]))!
            cell.quantityPriceLabel.text = "£" + String(format:"%.2f", quantityPrice)
            
            return cell
        }
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
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let toBeMoved = currentCategoryArray[indexPath.row]
        
        if (tableView.tag == 0) {
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
    
    
    //Function to get the value of the drink that is already in the order
    func getAlreadyInOrder(toBeMoved: String) -> String {
        for object in currentOrder {
            if object.range(of:toBeMoved) != nil {
                let orderValue = object
                return orderValue
            }
        }
        return orderValue
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
    
    
    
    
    
    
    //Method to change currentArray depending on which category is selected
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
            currentCategoryArray = otherArray
        default:
            break
        }
        self.drinksTable.reloadData()
    }
    
    //Changes the font of the tab bar
    func tabBarFont() {
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "AppleSDGothicNeo-Bold", size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        appearance.setTitleTextAttributes(attributes, for: .normal)
    }
    
    
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */
