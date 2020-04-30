//
//  CameraController.swift
//  PhotoBank
//
//  Created by Hackr on 9/14/19.
//  Copyright © 2019 Sugar. All rights reserved.
//
//import UIKit
//import AVFoundation
//
//class CameraController: UIViewController, AVCaptureFileOutputRecordingDelegate {
//
//    var camPreview: UIView = UIView(frame: UIScreen.main.bounds)
//
//    lazy var cameraButton: UIButton = {
//        let safeAreaBottom = self.view.safeAreaInsets.bottom
//        let y = self.view.frame.height - 120 - safeAreaBottom
//        let frame = CGRect(x: self.view.center.x-50, y: self.view.frame.height-150, width: 100, height: 100)
//        var button = UIButton(frame: frame)
//        let capture = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate)
//        button.tintColor = .white
//        button.setImage(capture, for: .normal)
//        button.addTarget(self, action: #selector(startCapture), for: .touchUpInside)
//        return button
//    }()
//
//    let captureSession = AVCaptureSession()
//
//    let movieOutput = AVCaptureMovieFileOutput()
//
//    var previewLayer: AVCaptureVideoPreviewLayer!
//
//    var activeInput: AVCaptureDeviceInput!
//
//    var outputURL: URL!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if setupSession() {
//            setupPreview()
//            startSession()
//        }
//
//        view.addSubview(camPreview)
//        camPreview.addSubview(cameraButton)
//    }
//
//    func setupPreview() {
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = camPreview.bounds
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        camPreview.layer.addSublayer(previewLayer)
//    }
//
//    // MARK:- Setup Camera
//
//    func setupSession() -> Bool {
//
//        captureSession.sessionPreset = AVCaptureSession.Preset.high
//
//        guard let camera = AVCaptureDevice.default(for: AVMediaType.video) else { return false }
//
//        do {
//
//            let input = try AVCaptureDeviceInput(device: camera)
//
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//                activeInput = input
//            }
//        } catch {
//            print("Error setting device video input: \(error)")
//            return false
//        }
//
//        // Setup Microphone
////        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
////
////        do {
////            let micInput = try AVCaptureDeviceInput(device: microphone)
////            if captureSession.canAddInput(micInput) {
////                captureSession.addInput(micInput)
////            }
////        } catch {
////            print("Error setting device audio input: \(error)")
////            return false
////        }
//
//
//        // Movie output
//        if captureSession.canAddOutput(movieOutput) {
//            captureSession.addOutput(movieOutput)
//        }
//
//        return true
//    }
//
//    func setupCaptureMode(_ mode: Int) {
//        // Video Mode
//
//    }
//
//    //MARK:- Camera Session
//    func startSession() {
//
//        if !captureSession.isRunning {
//            videoQueue().async {
//                self.captureSession.startRunning()
//            }
//        }
//    }
//
//    func stopSession() {
//        if captureSession.isRunning {
//            videoQueue().async {
//                self.captureSession.stopRunning()
//            }
//        }
//    }
//
//    func videoQueue() -> DispatchQueue {
//        return DispatchQueue.main
//    }
//
//    func currentVideoOrientation() -> AVCaptureVideoOrientation {
//        var orientation: AVCaptureVideoOrientation
//
//        switch UIDevice.current.orientation {
//        case .portrait:
//            orientation = AVCaptureVideoOrientation.portrait
//        case .landscapeRight:
//            orientation = AVCaptureVideoOrientation.landscapeLeft
//        case .portraitUpsideDown:
//            orientation = AVCaptureVideoOrientation.portraitUpsideDown
//        default:
//            orientation = AVCaptureVideoOrientation.landscapeRight
//        }
//
//        return orientation
//    }
//
//
//    @objc func startCapture() {
//
//        startRecording()
//
//    }
//
//
//    func tempURL() -> URL? {
//        let directory = NSTemporaryDirectory() as NSString
//
//        if directory != "" {
//            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
//            return URL(fileURLWithPath: path)
//        }
//
//        return nil
//    }
//
//
//    func pushVideo(_ url: URL) {
//        let vc = AVController(url)
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func startRecording() {
//
//        print("RECORDING: \(movieOutput.isRecording)")
//        if movieOutput.isRecording == false {
//
//            let connection = movieOutput.connection(with: AVMediaType.video)
//
//            if (connection?.isVideoOrientationSupported)! {
//                connection?.videoOrientation = currentVideoOrientation()
//            }
//
//            if (connection?.isVideoStabilizationSupported)! {
//                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
//            }
//
//            let device = activeInput.device
//
//            if (device.isSmoothAutoFocusSupported) {
//
//                do {
//                    try device.lockForConfiguration()
//                    device.isSmoothAutoFocusEnabled = false
//                    device.unlockForConfiguration()
//                } catch {
//                    print("Error setting configuration: \(error)")
//                }
//
//            }
//
//            //EDIT2: And I forgot this
//            outputURL = tempURL()
//            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
//
//        }
//        else {
//            stopRecording()
//        }
//
//    }
//
//    func stopRecording() {
//
//        if movieOutput.isRecording == true {
//            movieOutput.stopRecording()
//        }
//    }
//
//    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
//
//    }
//
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//
//        if (error != nil) {
//
//            print("Error recording movie: \(error!.localizedDescription)")
//
//        } else {
//
//            let videoRecorded = outputURL! as URL
//            print("VIDEO URL \(videoRecorded.absoluteString)")
//            pushVideo(videoRecorded)
////            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
//
//        }
//
//    }
//
//}


import Foundation
import UIKit
import SwiftyCam

class CameraController: SwiftyCamViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGesture.isEnabled = false
        cameraButton.delegate = self
        cameraDelegate = self
    }
    
    
    lazy var cameraButton: SwiftyCamButton = {
        let safeAreaBottom = self.view.safeAreaInsets.bottom
        let y = self.view.frame.height - 100 - safeAreaBottom
        let frame = CGRect(x: self.view.center.x-50, y: self.view.frame.height-150, width: 100, height: 100)
        var button = SwiftyCamButton(frame: frame)
        let capture = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = .white
        button.setImage(capture, for: .normal)
        button.addTarget(self, action: #selector(startCapture), for: .touchUpInside)
        return button
    }()
    
    @objc func startCapture() {
        
        startVideoRecording()
    }
    
        
}


extension CameraController: SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Called when takePhoto() is called or if a SwiftyCamButton initiates a tap gesture
        // Returns a UIImage captured from the current session
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Called when a user initiates a tap gesture on the preview layer
        // Will only be called if tapToFocus = true
        // Returns a CGPoint of the tap location on the preview layer
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Called when a user initiates a pinch gesture on the preview layer
        // Will only be called if pinchToZoomn = true
        // Returns a CGFloat of the current zoom level
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // Called when user switches between cameras
        // Returns current camera selection
    }
}
