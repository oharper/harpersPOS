//
//  ViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 07/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    let database = FIRDatabase.database().reference()
    let barStatus = ""
    
    @IBAction func newOrderPressed(_ sender: Any) {
        segueIfBarOpen()
//        if checkBarOpen() == "Open" {
//        self.performSegue(withIdentifier: "initialToOrder", sender: nil)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func segueIfBarOpen() {
        
        database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
            if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in result {
                    if child.value as! String == "Open" {
                        self.performSegue(withIdentifier: "initialToOrder", sender: nil)
                    } else {
                        
                        let alert = UIAlertController(title: "Bar Closed", message: "The Bar is currently Closed", preferredStyle: .alert)
                        let clearAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction!) -> Void in
                        }
                        
                        alert.addAction(clearAction)
                        
                        self.present(alert, animated: true, completion:nil)
                        
                    }
                }
            }
        })
    }
    
    func writeFirebase() {
        
        database.child("Status").child("Bar").setValue("Closed")
        
    }
    
    //Sets the status bar to white
    func setStatusBarColor() {
        let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
        let statusBar = statWindow.subviews[0] as UIView
        statusBar.backgroundColor = UIColor(red:0.00, green:0.21, blue:0.45, alpha:1.0)
        
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
}
