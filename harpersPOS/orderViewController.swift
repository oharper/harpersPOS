//
//  orderViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 09/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class orderViewController: UIViewController, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var drinksTable: UITableView!
    @IBOutlet weak var orderTable: UITableView!
    
    
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
        
        let alert = UIAlertController(title: "Cash/Card or Tab?", message: "Do you want to charge BY cash/card or put it on a tab?", preferredStyle: .alert)
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
    var itemToRemoveIndex: Int = 0
    
    var currentCategoryArray: [String] = []
    var currentOrder: [String] = []
    var beerArray: [String] = ["Fosters, 2.40", "Carling, 2.50", "Carling, 2.50"]
    var wineArray: [String] = ["Chardony, 6.50", "Sauvignon Blanc, 7.20"]
    var spiritsArray: [String] = ["Shot, 3.20", "Mixer, 4.50"]
    var softArray: [String] = ["Red Bull, 2.00", "Can, 1.50", "Orange Juice, 2.00"]
    var otherArray: [String] = ["Water, 2.00", "Sparkling Water, 2.50"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarFont()
        
        //Automatically selects the first item in the tab bar
        tabBar.selectedItem = (tabBar.items?[0])! as UITabBarItem;
        //Loads the table with the default beer array
        currentCategoryArray = beerArray
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24)
        
        if (tableView.tag == 0) {
            cell.textLabel?.text = getName(item: currentCategoryArray[indexPath.row])
            cell.detailTextLabel?.text = "£" + getPrice(item: currentCategoryArray[indexPath.row])
        }
        else if (tableView.tag == 1) {
            cell.textLabel?.text = currentOrder[indexPath.row]
        }
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
    
    
    
    
    //Method to add/remove drinks when tapped on
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        if (tableView.tag == 0) {
//            let toBeMoved = currentCategoryArray[indexPath.row]
//            
//            if checkAlreadyInOrder(toBeMoved: toBeMoved) {
//                //code here for if it is already in order
//                let orderValue = getAlreadyInOrder(toBeMoved: toBeMoved)
////                let index = orderValue.index(orderValue.endIndex, offsetBy: -2)
////                let quantity = orderValue[index]
//                let quantity = getQuantityDigit(item: orderValue)
//                let newQuantity = Int(String(quantity))! + 1
//                
//                let itemToRemoveIndex = getAlreadyInOrderIndex(itemToRemove: orderValue)
//                currentOrder[itemToRemoveIndex] = toBeMoved + ", - " + String(newQuantity)
//                
//                self.orderTable.reloadData()
//            }
//            else {
//                //code here for if it is not already in order
//                currentOrder.append(toBeMoved+", - 1")
//                self.orderTable.reloadData()
//            }
//        }
//        else if (tableView.tag == 1) {
//            
//            let indexToBeMoved = currentOrder[indexPath.row].index(currentOrder[indexPath.row].endIndex, offsetBy: -3)
//            let toBeMoved: String = currentOrder[indexPath.row].substring(to: indexToBeMoved)
//            let orderValue = getAlreadyInOrder(toBeMoved: toBeMoved)
//            let index = orderValue.index(orderValue.endIndex, offsetBy: -2)
//            let quantity = orderValue[index]
//            let newQuantity = Int(String(quantity))! - 1
//            
//            let itemToRemoveIndex = getAlreadyInOrderIndex(itemToRemove: orderValue)
//            
//            
//            if newQuantity > 0 {
//                currentOrder[itemToRemoveIndex] = toBeMoved + ", - " + String(newQuantity)
//            } else {
//                currentOrder.remove(at: indexPath.row)
//            }
//            self.orderTable.reloadData()
//            
//            
//        }
//    }
    
    
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
    func getAlreadyInOrderIndex(itemToRemove: String) -> Int {
        while currentOrder.contains(itemToRemove) {
            if let itemToRemoveIndex = currentOrder.index(of: itemToRemove) {
                
                return itemToRemoveIndex
            }
        }
        return itemToRemoveIndex
    }
    
    
    
    
    
    
    //Method to change currentArray depending on which category is selected
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var category: String = ""
        
        switch item.tag  {
        case 0:
            currentCategoryArray = beerArray
            category = "beer"
            print(category)
            break
        case 1:
            currentCategoryArray = wineArray
            category = "wine"
            print(category)
            break
        case 2:
            currentCategoryArray = spiritsArray
            category = "spirits"
            print(category)
            break
        case 3:
            currentCategoryArray = softArray
            category = "soft"
            print(category)
        case 4:
            currentCategoryArray = otherArray
            category = "other"
            print(category)
        default:
            category = "beer"
            print(category)
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
