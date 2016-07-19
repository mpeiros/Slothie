//
//  CameraVC.swift
//  Slothie
//
//  Created by Max Peiros on 7/9/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var slothCALayer: CALayer!
    var metadataOutput: AVCaptureMetadataOutput?
    var sessionQueue: dispatch_queue_t = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Take a Slothie"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let frontCamera = cameraWithPosition(.Front)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        
        do {
            input = try AVCaptureDeviceInput(device: frontCamera)
        } catch let err as NSError {
            error = err
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession!.canAddOutput(stillImageOutput) && captureSession!.canAddOutput(metadataOutput) {
                captureSession!.addOutput(stillImageOutput)
                captureSession!.addOutput(metadataOutput)
                
                metadataOutput!.setMetadataObjectsDelegate(self, queue: sessionQueue)
                metadataOutput!.metadataObjectTypes = [AVMetadataObjectTypeFace]
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                setupSlothFace()
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.position == position {
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    func setupSlothFace() {
        slothCALayer = CALayer()
        slothCALayer.zPosition = 1
        slothCALayer.contents = UIImage(named: "sloth")!.CGImage
        slothCALayer.hidden = true
        previewLayer!.addSublayer(slothCALayer)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            if metadataObject.type == AVMetadataObjectTypeFace {
                let transformedMetadataObject = previewLayer!.transformedMetadataObjectForMetadataObject(metadataObject)
                let face = transformedMetadataObject!.bounds
                slothCALayer.frame = face
                slothCALayer.hidden = false
            }
        }
    }
    
    @IBAction func didPressTakePhoto(sender: UIButton) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                if (sampleBuffer != nil) {
                    
                    UIGraphicsBeginImageContext(self.slothCALayer.bounds.size)
                    self.slothCALayer.renderInContext(UIGraphicsGetCurrentContext()!)
                    let slothImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let photoImage = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    UIGraphicsBeginImageContext(self.previewView.bounds.size)
                    photoImage.drawInRect(CGRect(origin: CGPointZero, size: self.previewView.bounds.size))
                    slothImage.drawInRect(CGRectMake(self.slothCALayer.frame.minX, self.slothCALayer.frame.minY, self.slothCALayer.bounds.width, self.slothCALayer.bounds.height))
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let imgPath = DataService.instance.saveImageAndCreatePath(image)
                    
                    let slothie = Slothie(imagePath: imgPath)
                    DataService.instance.addSlothie(slothie)
                    
                    self.captureSession!.stopRunning()
                }
            })
        }
    }
    
}
