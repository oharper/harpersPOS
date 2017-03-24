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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  //When the new order button is pressed, this runs the segueIfBarOpen function
  
  @IBAction func newOrderPressed(_ sender: Any) {
    segueIfBarOpen()
  }
  
  
  //Function that checks with the firebase database the status of the bar (open or closed), If open, segues to the new order screen, if closed; displays an alert. Also tests for connection to firebase and displays an alert if no connection.
  func segueIfBarOpen() {
    
    let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
    connectedRef.observe(.value, with: { snapshot in
      if let connected = snapshot.value as? Bool, connected {
        
        
        self.database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
          if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
            for child in result {
              if child.value as! String == "Open" {
                
                self.performSegue(withIdentifier: "initialToOrder", sender: nil)
                
              } else if child.value as! String == "Closed" {
                
                let alert = UIAlertController(title: "Bar Closed", message: "The Bar is currently Closed", preferredStyle: .alert)
                let clearAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction!) -> Void in
                }
                
                alert.addAction(clearAction)
                
                self.present(alert, animated: true, completion:nil)
              }
              
            }
          }
        })
        
        
      } else {
        
        let alert = UIAlertController(title: "No Connection", message: "Please check internet connection and try again.", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction!) -> Void in
        }
        
        alert.addAction(clearAction)
        
        self.present(alert, animated: true, completion:nil)
        
      }
    })
    
    
  }
  
  
  //Sets the status bar colour
  
  func setStatusBarColor() {
    let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
    let statusBar = statWindow.subviews[0] as UIView
    statusBar.backgroundColor = UIColor(red:0.00, green:0.21, blue:0.45, alpha:1.0)
    
  }
  
  //Overwriting two default variables in order to force Landscape right orientation
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscapeRight
  }
  
  
}
