import Foundation
import UIKit

enum CustomError: Error {
    case generic
    case failedToDetermineCameraAccessStatus
    case failedToFindVideoDevice
    case couldNotCreateVideoDeviceInput
    case couldNotAddVideoDeviceInputToSession
    case couldNotAddDepthDataOutputToSession
    case noAVCaptureSession
    case couldNotLockDeviceForConfiguration
 }

extension CustomError: LocalizedError {
    public var title: String {
        switch self {
        case .generic:
            return "Encountered an error"
        case .failedToDetermineCameraAccessStatus,
             .failedToFindVideoDevice,
             .couldNotCreateVideoDeviceInput,
             .couldNotAddVideoDeviceInputToSession,
             .couldNotAddDepthDataOutputToSession,
             .noAVCaptureSession,
             .couldNotLockDeviceForConfiguration:
            return "Could not proceed further"
        }
    }
    
    public var description: String {
        switch self {
        case .generic:
            return "Unfortunately, it appears that the application has some kind of a problem"
        case .failedToDetermineCameraAccessStatus:
            return "Unknown camera access status"
        case .failedToFindVideoDevice:
            return "Unfortunately, your device does not have LiDAR sensor or it is just inaccessible.\n\nMake sure a LiDAR sensor on the back of your device exists."
        case .couldNotCreateVideoDeviceInput:
            return "Unfortunately, input that provides media from a capture device to a capture session failed to initialize."
        case .couldNotAddVideoDeviceInputToSession:
            return "Unfortunately, video device input could not add an input to a capture session."
        case .couldNotAddDepthDataOutputToSession:
            return "Unfortunately, depth data output could not be added to a capture session."
        case .noAVCaptureSession:
            return "Unfortunately, depth data output connection with an input port of a specified media type failed to initialize."
        case .couldNotLockDeviceForConfiguration:
            return "Unfortunately, video device could not be locked for configuration changes."
        }
    }
    
    public var dismissable: Bool {
        return false
    }
    
    public var image: UIImage? {
        switch self {
        case .generic:
            return UIImage(named: "error/warning")
        case .failedToDetermineCameraAccessStatus,
             .failedToFindVideoDevice,
             .couldNotCreateVideoDeviceInput,
             .couldNotAddVideoDeviceInputToSession,
             .couldNotAddDepthDataOutputToSession,
             .noAVCaptureSession,
             .couldNotLockDeviceForConfiguration:
            return UIImage(named: "error/process")
        }
    }
}
