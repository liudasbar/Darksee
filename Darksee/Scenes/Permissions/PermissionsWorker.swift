import Foundation
import Combine

protocol PermissionsWorker {
    func loadUserName() -> AnyPublisher<String, Error>
}

class DefaultPermissionsWorker: PermissionsWorker {
    func loadUserName() -> AnyPublisher<String, Error> {
        Just("John Ive")
            .setFailureType(to: Error.self)
            .delay(for: 3, scheduler: RunLoop.current)
            .eraseToAnyPublisher()
    }
}
