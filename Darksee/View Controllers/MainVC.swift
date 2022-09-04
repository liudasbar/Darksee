//
//  MainVC.swift
//  Darksee
//
//  Created by LiudasBar on 2021-03-21.
//

import UIKit
import AVFoundation
import MetalKit
import ARKit

class MainVC: UIViewController, MTKViewDelegate {
    
    @IBOutlet weak var mainView: UIView!
    
    var blurEffectView = UIVisualEffectView()
    
    @IBOutlet weak var metalKitView: MTKView!
    @IBOutlet weak var metalKitViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cameraPreviewView: UIView!
    
    @IBOutlet weak var infoView: UIVisualEffectView!
    
    @IBOutlet weak var thermalStateView: UIVisualEffectView!
    @IBOutlet weak var thermalStateLabel: UILabel!
    
    @IBOutlet weak var contrastView: UIVisualEffectView!
    @IBAction func contrastSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            addContrast = true
        } else {
            addContrast = false
        }
    }
    
    @IBOutlet weak var distanceChangeSegmentedControl: UISegmentedControl!
    @IBAction func distanceChangeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            longDistance = true
        } else {
            longDistance = false
        }
    }
    
    @IBOutlet weak var cameraInfoView: UIVisualEffectView!
    
    
    @IBOutlet weak var warningTitleLabel: UILabel!
    @IBOutlet weak var warningBodyLabel: UILabel!
    @IBOutlet weak var permissionsButton: UIButton!
    @IBAction func permissionsButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "permissionsVC", sender: nil)
    }
    
    
    
    var videoCapture: VideoCapture!
    
    let serialQueue = DispatchQueue(label: "serialQueue")
    
    var captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInLiDARDepthCamera], mediaType: .video, position: .back)
    var currentCameraType: CameraType = .back(true)
    var renderer: MetalRenderer!
    var depthImage: CIImage?
    var currentDrawableSize: CGSize!
    
    var videoImage: CIImage?
    
    var addContrast = false
    var longDistance = true
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {return}
        videoCapture.imageBufferHandler = nil
        videoCapture.stopCapture()
        metalKitView.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ARFaceTrackingConfiguration.isSupported {
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                setup()
                
                guard let videoCapture = videoCapture else {return}
                videoCapture.startCapture()
                
                UIView.animate(withDuration: 0.3) {
                    self.blurEffectView.alpha = 0
                }
                
            } else {
                performSegue(withIdentifier: "permissionsVC", sender: nil)
            }
        } else {
            trueDepthNotSupported()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let videoCapture = videoCapture else {return}
        videoCapture.resizePreview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observersInit()
        designInit()
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            warningTitleLabel.alpha = 0
            warningBodyLabel.alpha = 0
            permissionsButton.alpha = 0
        }
        
        if !ARFaceTrackingConfiguration.isSupported {
            trueDepthNotSupported()
        }
        
        showThermalState(state: ProcessInfo.processInfo.thermalState)
    }
    
    /// Add observers
    func observersInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(thermalStateChanged), name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(permissionGranted), name: NSNotification.Name(rawValue: "permission"), object: nil)
    }
    
    /// Executed on granted permission
    @objc func permissionGranted() {
        self.blurEffectView.alpha = 0
        self.warningTitleLabel.alpha = 0
        self.warningBodyLabel.alpha = 0
        self.permissionsButton.alpha = 0
        
        setup()
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    /// Design init
    func designInit() {
        mainView.layer.cornerRadius = 25
        mainView.clipsToBounds = true
        mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        infoView.layer.cornerRadius = 13
        infoView.clipsToBounds = true
        
        thermalStateView.layer.cornerRadius = 13
        thermalStateView.clipsToBounds = true
        
        cameraInfoView.layer.cornerRadius = 13
        cameraInfoView.clipsToBounds = true
        
        contrastView.layer.cornerRadius = 13
        contrastView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 1
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        view.bringSubviewToFront(warningTitleLabel)
        view.bringSubviewToFront(warningBodyLabel)
        view.bringSubviewToFront(permissionsButton)
    }
    
    
    /// TrueDepth not supported
    func trueDepthNotSupported() {
        warningTitleLabel.text = "Device not supported"
        warningBodyLabel.text = "Your device does not support TrueDepth scanning (does not have Face ID biometrics recognition)."
        permissionsButton.alpha = 0
    }
    
    /// Depth and real preview and scanning setup
    func setup() {
        let device = MTLCreateSystemDefaultDevice()!
        metalKitView.device = device
        metalKitView.backgroundColor = UIColor.clear
        metalKitView.delegate = self
        renderer = MetalRenderer(metalDevice: device, renderDestination: metalKitView)
        currentDrawableSize = metalKitView.currentDrawable!.layer.drawableSize

        videoCapture = VideoCapture(cameraType: currentCameraType, preferredSpec: nil, previewContainer: cameraPreviewView.layer)
        
        videoCapture.syncedDataBufferHandler = { [weak self] videoPixelBuffer, depthData, face in
            guard let self = self else { return }
            
            self.videoImage = CIImage(cvPixelBuffer: videoPixelBuffer)
            
            let applyHistoEq: Bool = true
            
            self.serialQueue.async {
                guard let depthData = self.longDistance ? depthData?.convertToDisparity() : depthData else { return }
                
                guard let ciImage = depthData.depthDataMap.transformedImage(targetSize: self.currentDrawableSize, rotationAngle: 0) else { return }
                self.depthImage = applyHistoEq ? ciImage.applyingFilter("YUCIHistogramEqualization") : ciImage
                
                //Add contrast
                if self.addContrast {
                    self.depthImage = self.filter(self.depthImage ?? ciImage, intensity: 1.1)
                }
                
                //self.setAutomaticDistance(ciImage: ciImage)
            }
        }
        videoCapture.setDepthFilterEnabled(false)
        
        metalKitView.frame = cameraPreviewView.layer.bounds
    }
    
    func avgColor(image: CIImage) -> UIColor? {
        let extentVector = CIVector(x: image.extent.origin.x, y: image.extent.origin.y, z: image.extent.size.width, w: image.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: image, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    /// Sets automatic distance 
    func setAutomaticDistance(ciImage: CIImage) {
        DispatchQueue.main.async {
            let components = self.avgColor(image: self.depthImage ?? ciImage)!.cgColor.components
            
            let red = components?[0] ?? 0.0
            print(red)
            if self.longDistance {
                //If long distance is set
                if red > 0.6 {
                    //Lots of white - detected lots of short distance objects - switch to short distance
                    self.longDistance = false
                }
                
            } else {
                //If short distance is set
                if red > 0.6 {
                    //Lots of white - detected lots of long distance objects - switch to long distance
                    self.longDistance = true
                }
            }
        }
    }
    
    func filter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let colorControlFilter = CIFilter(name:"CIColorControls")
        colorControlFilter?.setValue(input, forKey: kCIInputImageKey)
        colorControlFilter?.setValue(intensity, forKey: kCIInputContrastKey)
        return colorControlFilter?.outputImage
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        currentDrawableSize = size
    }
    
    func draw(in view: MTKView) {
        if let image = depthImage {
            renderer.update(with: image)
        }
    }
    
    
    
    
    
    /// Thermal state tracking
    @objc func thermalStateChanged(notification: NSNotification) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        if let processInfo = notification.object as? ProcessInfo {
            showThermalState(state: processInfo.thermalState)
        }
    }
    
    /// Determine what to perform on different thermal states
    func showThermalState(state: ProcessInfo.ThermalState) {
        DispatchQueue.main.async {
            if state == .nominal {
                self.thermalStateLabel.text = "Good"
                self.thermalStateLabel.textColor = UIColor.systemGreen
            } else if state == .fair {
                self.videoCapture.startCapture()
                self.thermalStateLabel.text = "Normal"
                self.thermalStateLabel.textColor = UIColor.systemGreen
            } else if state == .serious {
                self.thermalStateLabel.text = "Serious"
                self.thermalStateLabel.textColor = UIColor.systemOrange
            } else if state == .critical {
                self.videoCapture.stopCapture()
                self.thermalStateLabel.text = "Critical"
                self.thermalStateLabel.textColor = UIColor.systemRed
                
                let alert = UIAlertController(title: "Did you bring your towel?", message: "It's recommended you bring your towel before continuing.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

                self.present(alert, animated: true)
            }
        }
    }
}
