import Foundation
import Combine
import CoreMotion

class DeviceOrientationManager: ObservableObject {
    @Published var isScreenFacingDown = false
    private let motionManager = CMMotionManager()
    
    init() {
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else { return }
            self?.isScreenFacingDown = data.gravity.z > 0.8
        }
    }
}
