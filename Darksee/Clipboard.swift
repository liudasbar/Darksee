//
//  Clipboard.swift
//  Darksee
//
//  Created by LiudasBar on 2021-03-21.
//

//CAMERA SETUP

//var captureSession: AVCaptureSession!
//var previewLayer: AVCaptureVideoPreviewLayer!
//
//NotificationCenter.default.addObserver(self, selector: #selector(error), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: nil)
//
///// Setup capture session
//func captureSessionSetup() {
//    captureSession = AVCaptureSession()
//    captureSession.sessionPreset = .high
//
//    captureSession.beginConfiguration()
//
//    DispatchQueue.global(qos: .userInitiated).sync {
//        self.captureSession = AVCaptureSession()
//        self.captureSession.beginConfiguration()
//
//        if self.captureSession.canSetSessionPreset(.high) {
//            self.captureSession.sessionPreset = .high
//        } else {
//            self.captureSession.sessionPreset = .vga640x480
//        }
//
//
//        captureSession.addOutput(depthDataOutput)
//        depthDataOutput.isFilteringEnabled = false
//        if let connection = depthDataOutput.connection(with: .depthData) {
//            connection.isEnabled = true
//        } else {
//            print("No AVCaptureConnection")
//        }
//
//
//        self.setupInput()
//
//        DispatchQueue.main.async {
//            self.setupPreviewLayer()
//        }
//
//        self.captureSession.commitConfiguration()
//        self.captureSession.startRunning()
//    }
//}
//
//
///// Add input to capture session
//func setupInput() {
//    guard let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
//        else {
//            print("Unable to true deptch front camera!")
//            return
//    }
//
//    guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
//        captureSession.canAddInput(videoDeviceInput)
//        else { return }
//    captureSession.addInput(videoDeviceInput)
//}
//
//func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
//    return
//}
//
//
//
//
///// Setup UIView preview layer
//func setupPreviewLayer(){
//    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//    previewLayer.frame = cameraPreviewView.layer.bounds
//    cameraPreviewView.layer.insertSublayer(previewLayer, at: 0)
//}
//
//
///// Capture session failure
//@objc func error(notification: Notification) {
//    guard let errorKey = notification.userInfo?["AVCaptureSessionErrorKey"] as? String else { return }
//    print("Error: \(errorKey)")
//}
