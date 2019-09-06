//
//  ScanController.swift
//  Sparrow
//
//  Created by Hackr on 8/6/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import AVFoundation
import UIKit

protocol QRScanDelegate {
    func handleQRScan(_ code: String)
}

class ScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private var scans: Int = 0
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")

    var scanDelegate: QRScanDelegate?
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var videoDeviceInput: AVCaptureDeviceInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = .black
        let closeIcon = UIBarButtonItem(image: UIImage(named: "close"), style: .done, target: self, action: #selector(handleCancel))
        closeIcon.tintColor = .white
        self.navigationItem.leftBarButtonItem = closeIcon
        view.backgroundColor = .black
        sessionQueue.async {
            self.setupCamera()
        }
    }
    

    func setupCamera() {

        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("Failed to get the camera device")
            return
        }


        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (session.canAddInput(videoDeviceInput)) {
            session.addInput(videoDeviceInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
        } else {
            failed()
            return
        }

        DispatchQueue.main.async {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            self.previewLayer?.frame = self.view.layer.bounds
            self.previewLayer?.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.previewLayer!)
        }

    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false

        scans = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startCamera()
        self.addCameraLayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scans = 0
        self.stopCamera()
        self.removeCameraLayer()
    }
    
    func closeDrawer() {
//        if let pulley = self.parent as? PulleyViewController {
//            pulley.setDrawerPosition(position: .open, animated: true)
//        }
    }

    
    func startCamera() {
        sessionQueue.async {
            if let connection = self.previewLayer?.connection {
                connection.isEnabled = true
                self.session.startRunning()
            }
        }
    }
    
    func stopCamera() {
        sessionQueue.async {
            if let connection = self.previewLayer?.connection {
                connection.isEnabled = false
                self.session.stopRunning()
            }
        }
    }
    
    func removeCameraLayer() {
        DispatchQueue.main.async {
            self.previewLayer?.removeFromSuperlayer()
        }
    }
    
    
    func addCameraLayer() {
        DispatchQueue.main.async {
            if self.previewLayer != nil {
                self.view.layer.addSublayer(self.previewLayer!)
            }
        }
    }
    

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session.stopRunning()

        let metadataObject = metadataObjects.first
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            let stringValue = readableObject.stringValue!
            found(code: stringValue)
    }


    func found(code: String) {
        UIDevice.vibrate()
        self.dismiss(animated: true) {
            self.scanDelegate?.handleQRScan(code)
        }
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }

    
}


