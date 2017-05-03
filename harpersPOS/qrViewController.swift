//
//  qrViewController.swift
//  harpersPOS
//
//  Created by Owen Harper on 24/02/2017.
//  Copyright © 2017 Owen Harper. All rights reserved.
//

import AVFoundation
import UIKit
import Firebase
import FirebaseDatabase

class qrViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  
  let database = FIRDatabase.database().reference()
  
  var currentOrder: [String] = []
  
  var code: String = ""
  var captureSession:AVCaptureSession?
  var videoPreviewLayer:AVCaptureVideoPreviewLayer?
  var qrCodeFrameView:UIView?
  var subTotal: Double = 0
  
  
  @IBOutlet weak var backButton: UIButton!
  
  @IBAction func backPressed(_ sender: Any) {
    captureSession?.stopRunning()
    performSegue(withIdentifier: "qrBack", sender: nil)
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    captureSession?.startRunning()
    qrCodeFrameView = UIView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    
    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous device object.
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Initialize the captureSession object.
      captureSession = AVCaptureSession()
      
      // Set the input device on the capture session.
      captureSession?.addInput(input)
      
      // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession?.addOutput(captureMetadataOutput)
      
      // Set delegate and use the default dispatch queue to execute the call back
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
      
      // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      view.layer.addSublayer(videoPreviewLayer!)
      
      // Start video capture.
      captureSession?.startRunning()
      
      // Initialize QR Code Frame to highlight the QR code
      qrCodeFrameView = UIView()
      
      if let qrCodeFrameView = qrCodeFrameView {
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        view.bringSubview(toFront: qrCodeFrameView)
      }
      
    } catch {
      print(error)
      return
    }
    self.view.bringSubview(toFront: backButton)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if metadataObjects == nil || metadataObjects.count == 0 {
      qrCodeFrameView?.frame = CGRect.zero
      code = "No QR code is detected"
      return
    }
    
    // Get the metadata object.
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
    if metadataObj.type == AVMetadataObjectTypeQRCode {
      // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds
      
      if metadataObj.stringValue != nil {
        code = metadataObj.stringValue
        
        self.captureSession?.stopRunning()
        segueIfValid(code: code)
        
      }
    }
  }
  
  ///Methods to Rotate Camera
  private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
    
    layer.videoOrientation = orientation
    
    videoPreviewLayer?.frame = self.view.bounds
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if let connection =  self.videoPreviewLayer?.connection  {
      
      let currentDevice: UIDevice = UIDevice.current
      
      //was = currentDevice.orientation, change to .landscapeLeft to force orientation
      let orientation: UIDeviceOrientation = currentDevice.orientation
      
      let previewLayerConnection : AVCaptureConnection = connection
      
      if previewLayerConnection.isVideoOrientationSupported {
        
        switch (orientation) {
        case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
        
          break
          
        case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
        
          break
          
        case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
        
          break
          
        case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
        
          break
          
        default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
        
          break
        }
      }
    }
  }
  //End of Methods to rotate camera
  
  
  //Checks to see if the code is a valid and segues if it is
  func segueIfValid(code: String) {
    
    let tableNumber = code.substring(from:code.index(code.endIndex, offsetBy: -2))
    
    database.child("Status").observeSingleEvent(of: .value, with: { snapshot in
      if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
        for child in result {
          if child.key == "Current Event" {
            
            let currentEvent = child.value as! String
            
            let itemArray = currentEvent.components(separatedBy: ", ")
            let eventDate = itemArray[0]
            let eventName = itemArray[1]
            let eventID = itemArray[2]
            
            let codeID = code.substring(to:code.index(code.startIndex, offsetBy: 8))
            
            if codeID == eventID {
              
              
              self.database.child("Events").child(String(eventDate + " | " + eventName)).child("Table Status").observeSingleEvent(of: .value, with: { snapshot in
                if let result = snapshot.children.allObjects as? [FIRDataSnapshot] {
                  for child in result {
                    if child.key == "Table " + tableNumber {
                      if String(describing: child.value!) == "Open" {
                        
                        print("Run")
                        self.performSegue(withIdentifier: "qrToSuccess", sender: nil)
                        
                      } else {
                        
                        let alert = UIAlertController(title: "Table " + tableNumber + " Closed", message: "The tab for this table has been closed.", preferredStyle: .alert)
                        
                        let clearAction = UIAlertAction(title: "Back", style: .default) { (alert: UIAlertAction!) -> Void in
                          self.performSegue(withIdentifier: "qrBack", sender: nil)
                        }
                        
                        alert.addAction(clearAction)
                        
                        self.present(alert, animated: true, completion:nil)
                        
                      }
                      
                    }
                  }
                }
              })
            } else {
              
              let alert = UIAlertController(title: "Invalid QR", message: "This code is either from another past event or is invalid", preferredStyle: .alert)
              
              let clearAction = UIAlertAction(title: "Back", style: .default) { (alert: UIAlertAction!) -> Void in
                self.performSegue(withIdentifier: "qrBack", sender: nil)
              }
              
              alert.addAction(clearAction)
              
              self.present(alert, animated: true, completion:nil)
              
            }
            
          }
          
        }
      }
    })
    
  }
  
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "qrToSuccess") {
      let view : tabSuccessViewController = segue.destination as! tabSuccessViewController
      view.tableNumber = code.substring(from:code.index(code.endIndex, offsetBy: -2))
      view.currentOrder = currentOrder
      view.subTotal = subTotal
    }
    if (segue.identifier == "qrBack") {
      let view: orderViewController = segue.destination as! orderViewController
      view.currentOrder = currentOrder
      view.subTotal = subTotal
    }
  }
  
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  
  override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscapeRight
  }
  
  
}
