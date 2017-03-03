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
    var orderCount: Int = 0
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var openCloseButton: UIButton!
    
    @IBAction func openCloseBar(_ sender: Any) {
        if openCloseButton.currentTitle == "Bar Closed" {
            openCloseButton.setTitle("Bar Open", for: .normal)
            openCloseButton.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.50, alpha:1.0)
            writeFirebase(child: "Bar", value: "Open", database: FIRDatabase.database().reference().child("Status"))
            
        } else {
            openCloseButton.setTitle("Bar Closed", for: .normal)
            openCloseButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
            writeFirebase(child: "Bar", value: "Closed", database: FIRDatabase.database().reference().child("Status"))
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialOpenButtonSet()
        // Do any additional setup after loading the view.
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
                    if child.value as! String == "Open" {
                        self.openCloseButton.setTitle("Bar Open", for: .normal)
                        self.openCloseButton.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.50, alpha:1.0)
                    } else {
                        self.openCloseButton.setTitle("Bar Closed", for: .normal)
                        self.openCloseButton.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
