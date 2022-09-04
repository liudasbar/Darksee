import Foundation
import UIKit

enum CustomError: Error {
    case generic
    case genericWith(_ error: Error)
    case failedToDetermineCameraAccessStatus
    case failedToFindVideoDevice
    case couldNotCreateVideoDeviceInput
    case couldNotAddVideoDeviceInputToSession
    case couldNotAddDepthDataOutputToSession
    case noAVCaptureSession
    case couldNotLockDeviceForConfiguration
 }

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .generic:
            return "Generic error"
        case .genericWith(let error):
            return "Generic error: \(error.localizedDescription)"
        case .failedToDetermineCameraAccessStatus:
            return "failedToDetermineCameraAccessStatus"
        case .failedToFindVideoDevice:
            return "failedToDetermineCameraAccessStatus"
        case .couldNotCreateVideoDeviceInput:
            return "couldNotCreateVideoDeviceInput"
        case .couldNotAddVideoDeviceInputToSession:
            return "couldNotAddVideoDeviceInputToSession"
        case .couldNotAddDepthDataOutputToSession:
            return "couldNotAddDepthDataOutputToSession"
        case .noAVCaptureSession:
            return "noAVCaptureSession"
        case .couldNotLockDeviceForConfiguration:
            return "couldNotLockDeviceForConfiguration"
        }
    }
    
    public var image: UIImage? {
        switch self {
        case .generic,
             .genericWith:
            return nil
        default:
            return nil
        }
    }
}
