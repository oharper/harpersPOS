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
            
            //here
            
            
            
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
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
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
                captureSession?.stopRunning()
                if checkCodeDate(code: code) {
                    let table = code.substring(from:code.index(code.endIndex, offsetBy: -2))
                    for item in currentOrder {
                        post(drink: getName(item: item), quantity: getQuantityDigit(item: item), tableNumber: table)
                    }
                    performSegue(withIdentifier: "qrToInitial", sender: nil)
                    
                }
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
            let orientation: UIDeviceOrientation = .landscapeLeft
            
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
    
    func checkCodeDate(code: String) -> Bool {
        
        let QRDate = code.substring(to:code.index(code.startIndex, offsetBy: 8))
        print(QRDate)
        
        if getDate() == QRDate {
            return true
        } else {
            return false
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
    
    
    func post(drink: String, quantity: String, tableNumber: String){
        
        let time = getTime()
        let table = tableNumber
        let drink = drink
        let quantity = quantity
        
        let order : [String : String] = ["Time" : time, "Table" : table, "Drink" : drink, "Quantity" : quantity]
        
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child(getOrderDate()).child("Orders").childByAutoId().setValue(order)
        
    }
    
    func writeFirebase(child: String, value: String, database: FIRDatabaseReference) {
        
        database.child(child).setValue(value)
        
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let result = formatter.string(from: date)
        return result
    }
    
    func getTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let result = formatter.string(from: date)
        return result
    }
    
    func getOrderDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let result = formatter.string(from: date)
        return result
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
}

