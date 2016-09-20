//
//  CameraVC.swift
//  Slothie
//
//  Created by Max Peiros on 7/9/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var backButton: SlothieButton!
    @IBOutlet weak var approveButton: SlothieButton!
    @IBOutlet weak var declineButton: SlothieButton!
    @IBOutlet weak var takePhotoButton: SlothieButton!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var slothCALayer: CALayer!
    var metadataOutput: AVCaptureMetadataOutput?
    var sessionQueue: dispatch_queue_t = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL)
    
    var flashView: UIView!
    var slothieImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.hidden = true
        
        approveButton.hidden = true
        declineButton.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetHigh
        
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
                
                setUpFlashView()
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.hidden = false
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
    
    func setUpFlashView() {
        flashView = UIView(frame: previewView.bounds)
        flashView.alpha = 0
        flashView.backgroundColor = UIColor.whiteColor()
        flashView.layer.zPosition = 3
        previewView.addSubview(flashView)
    }
    
    func flashAnimation() {
        UIView.animateWithDuration(0.1, animations: {
            self.flashView.alpha = 1
        }) { _ in
            self.flashView.alpha = 0
        }
    }
    
    func setupSlothFace() {
        slothCALayer = CALayer()
        slothCALayer.zPosition = 1
        slothCALayer.contents = UIImage(named: "slothFace")!.CGImage
        slothCALayer.hidden = true
        previewLayer!.addSublayer(slothCALayer)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            
            if metadataObject.type == AVMetadataObjectTypeFace {
                
                dispatch_async(dispatch_get_main_queue(), {
                    let transformedMetadataObject = self.previewLayer!.transformedMetadataObjectForMetadataObject(metadataObject)
                    let face = transformedMetadataObject!.bounds
                    self.slothCALayer.frame = face
                    self.slothCALayer.hidden = false
                })
            }
        }
    }
    
    @IBAction func didPressTakePhoto(sender: UIButton) {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                if (sampleBuffer != nil) {
                    
                    self.flashAnimation()
                    
                    self.takePhotoButton.hidden = true
                    self.backButton.hidden = true
                    self.approveButton.hidden = false
                    self.declineButton.hidden = false
                    
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
                    self.slothieImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    self.captureSession!.stopRunning()
                }
            })
        }
    }
    
    @IBAction func approveButtonPressed(sender: AnyObject) {
        let imgPath = DataService.instance.saveImageAndCreatePath(slothieImage)
        
        let slothieJustTaken = Slothie(imagePath: imgPath)
        DataService.instance.addSlothie(slothieJustTaken)
        
        resetView()
    }
    
    @IBAction func declineButtonPressed(sender: AnyObject) {
        resetView()
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        captureSession!.stopRunning()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func resetView() {
        captureSession!.startRunning()
        
        slothCALayer.hidden = true
        
        takePhotoButton.hidden = false
        backButton.hidden = false
        approveButton.hidden = true
        declineButton.hidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}
