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

class liveStatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let database = FIRDatabase.database().reference()
    var orderCount: Int = 0
    var totalsArray: [String] = []
  var currentTableTotal: Double = 0
  var numberOfTables: Int = 0
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var openCloseButton: UIButton!
    
    @IBAction func openCloseBar(_ sender: Any) {
        if openCloseButton.currentTitle == "Bar Closed" {
          
          //1. Create the alert controller.
          let alert = UIAlertController(title: "How many Tables?", message: "How many tables would you like to open?", preferredStyle: .alert)
          
          //2. Add the text field. You can configure it however you need.
          alert.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.numberPad
            textField.text = ""
          }
          
          alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
          }))
          
          // 3. Grab the value from the text field, and print it when the user clicks OK.
          alert.addAction(UIAlertAction(title: "Open Tab's", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            var numberOfTables = Int(String(textField!.text!)!)!
            
            self.openCloseButton.setTitle("Bar Open", for: .normal)
            self.openCloseButton.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.50, alpha:1.0)
            self.writeFirebase(child: "Bar", value: "Open", database: FIRDatabase.database().reference().child("Status"))
            
            
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
          
          // 4. Present the alert.
          self.present(alert, animated: true, completion: nil)
            
        } else {
          
          openCloseButton.setTitle("Bar Closed", for: .normal)
          openCloseButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
          writeFirebase(child: "Bar", value: "Closed", database: FIRDatabase.database().reference().child("Status"))
          
//          database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
//            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
//              for child in result {
//                if child.key == "Current Event" {
//                  
//                  let currentEvent = child.value as! String
//                  
//                  
//                  
//                  let itemArray = currentEvent.components(separatedBy: ", ")
//                  let eventDate = itemArray[0]
//                  let eventName = itemArray[1]
//          
//        
//        self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Table Status").observeSingleEvent(of: .value, with: { snapshot in
//          if snapshot.exists() {
//            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
//              for child in result {
//                self.writeFirebase(child: child.key, value: "Closed", database: FIRDatabase.database().reference().child("Events").child("25|03|17 | Rugby").child("Table Status"))
//        
//              }
//            }
//          }
//          })
//      }
//      
//    }
//            }
//          })
          
          
          
      }
  }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialOpenButtonSet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getOrderDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd|MM|yy"
        let result = formatter.string(from: date)
        return result
    }
    
    
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
    
    func writeFirebase(child: String, value: String, database: FIRDatabaseReference) {
        
        database.child(child).setValue(value)
        
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalsArray.count
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
            
            cell.textLabel?.text = getTable(item: totalsArray[indexPath.row])
            cell.detailTextLabel?.text = getTotal(item: totalsArray[indexPath.row])
            return cell
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
