//
//  CameraVC.swift
//  Slothie
//
//  Created by Max Peiros on 7/9/16.
//  Copyright © 2016 Max Peiros. All rights reserved.
//

import UIKit
import AVFoundation
import JSSAlertView

class CameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var backButton: SlothieButton!
    @IBOutlet weak var approveButton: SlothieButton!
    @IBOutlet weak var declineButton: SlothieButton!
    @IBOutlet weak var takePhotoButton: SlothieButton!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var metadataOutput: AVCaptureMetadataOutput?
    var sessionQueue: DispatchQueue = DispatchQueue(label: "videoQueue", attributes: [])
    
    var slothCALayer: CALayer!
    var flashView: UIView!
    var slothieImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        approveButton.isHidden = true
        declineButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        setUpCaptureSession()
        setUpFlashView()
        setupSlothFace()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func setUpCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetHigh
        
        let frontCamera = cameraWithPosition(.front)
        
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
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer!.frame = UIScreen.main.bounds
                
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
    }
    
    func setUpFlashView() {
        flashView = UIView(frame: previewView.bounds)
        flashView.alpha = 0
        flashView.backgroundColor = UIColor.white
        flashView.layer.zPosition = 3
        previewView.addSubview(flashView)
    }

    func flashAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.flashView.alpha = 1
        }, completion: { _ in
            self.flashView.alpha = 0
        }) 
    }

    func setupSlothFace() {
        slothCALayer = CALayer()
        slothCALayer.zPosition = 1
        slothCALayer.contents = UIImage(named: "slothFace")!.cgImage
        slothCALayer.isHidden = true
        previewLayer!.addSublayer(slothCALayer)
    }
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices! {
            if (device as AnyObject).position == position {
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            
            if metadataObject.type == AVMetadataObjectTypeFace {
                
                DispatchQueue.main.async(execute: {
                    let transformedMetadataObject = self.previewLayer!.transformedMetadataObject(for: metadataObject)
                    let face = transformedMetadataObject!.bounds
                    self.slothCALayer.frame = face
                    self.slothCALayer.isHidden = false
                })
            }
        }
    }
    
    @IBAction func didPressTakePhoto(_ sender: UIButton) {
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                
                if (sampleBuffer != nil) && (self.slothCALayer.isHidden == false) {
                    
                    self.flashAnimation()
                    
                    self.takePhotoButton.isHidden = true
                    self.backButton.isHidden = true
                    self.approveButton.isHidden = false
                    self.declineButton.isHidden = false
                    
                    UIGraphicsBeginImageContext(self.slothCALayer.bounds.size)
                    self.slothCALayer.render(in: UIGraphicsGetCurrentContext()!)
                    let slothImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let photoImage = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
                    
                    UIGraphicsBeginImageContext(self.previewView.bounds.size)
                    photoImage.draw(in: CGRect(origin: CGPoint.zero, size: self.previewView.bounds.size))
                    slothImage!.draw(in: CGRect(x: self.slothCALayer.frame.minX, y: self.slothCALayer.frame.minY, width: self.slothCALayer.bounds.width, height: self.slothCALayer.bounds.height))
                    self.slothieImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    self.captureSession!.stopRunning()
                }
            })
        }
    }
    
    @IBAction func approveButtonPressed(_ sender: AnyObject) {
        let imgPath = DataService.instance.saveImageAndCreatePath(slothieImage)
        
        let slothieJustTaken = Slothie(imagePath: imgPath)
        DataService.instance.addSlothie(slothieJustTaken)
        
        let alert = JSSAlertView().success(self, title: "Slothie saved!")
        alert.addAction(resetView)
    }
    
    @IBAction func declineButtonPressed(_ sender: AnyObject) {
        let alert = JSSAlertView().danger(self, title: "Slothie not saved!")
        alert.addAction(resetView)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        captureSession!.stopRunning()
        
        navigationController!.popToRootViewController(animated: true)
    }
    
    func resetView() {
        captureSession!.startRunning()
        
        slothCALayer.isHidden = true
        
        takePhotoButton.isHidden = false
        backButton.isHidden = false
        approveButton.isHidden = true
        declineButton.isHidden = true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}
