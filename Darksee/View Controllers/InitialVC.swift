//
//  InitialVC.swift
//  Darksee
//
//  Created by LiudasBar on 2021-03-23.
//

import UIKit
import AVFoundation

class InitialVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestCameraAccess()
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
            
            DispatchQueue.main.async {
                if !granted {
                    //Camera permission not granted
                    let cameraAuthorizationAlert = UIAlertController(title: "Warning", message: "Camera seems not to be authorized to be used in Darksee.", preferredStyle: .alert)
                    
                    cameraAuthorizationAlert.addAction(UIAlertAction(title: "Let me authorize it!", style: .default, handler: { action in
                        
                        let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
                        UIApplication.shared.open(settingsUrl)
                    }))
                    
                    cameraAuthorizationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(cameraAuthorizationAlert, animated: true, completion: nil)
                    
                } else {
                    //Camera permission granted
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "permission"), object: nil, userInfo: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
}
