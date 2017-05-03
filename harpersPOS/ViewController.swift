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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Rotates to landscape left
    let value = UIInterfaceOrientation.landscapeLeft.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
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
    
    //Reading firebase
    let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
    connectedRef.observe(.value, with: { snapshot in
      
      //Checking to see if connection can be made to firebase
      if let connected = snapshot.value as? Bool, connected {
        
        self.database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
          
          if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
            
            for child in result {
              
              if child.value as! String == "Open" {
                
                //Segueing to new order screen if the bar is Open
                self.performSegue(withIdentifier: "initialToOrder", sender: nil)
                
              } else if child.value as! String == "Closed" {
                
                //Showing an alert if the bar is closed
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
        
        //Showing an error message if connection cannot be made
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
  
  private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscapeLeft
  }
  private func shouldAutorotate() -> Bool {
    return true
  }
  
}
