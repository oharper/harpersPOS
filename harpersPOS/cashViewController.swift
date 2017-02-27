//
//  cashViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 24/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import UIKit

class cashViewController: UIViewController {
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func donePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Done?", message: "Are you sure you have finished charging this order", preferredStyle: .alert)
        let clearAction = UIAlertAction(title: "DONE", style: .destructive) { (alert: UIAlertAction!) -> Void in
            //code here if done
            self.performSegue(withIdentifier: "cashToInitial", sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Check Total", style: .default) { (alert: UIAlertAction!) -> Void in
            //code here if on tab
        }
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
        
        
    }
    
    
    
    var subTotal: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.priceLabel.text = "£" + String(format:"%.2f", subTotal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
}
