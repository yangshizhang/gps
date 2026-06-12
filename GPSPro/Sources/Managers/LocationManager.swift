import Foundation
import CoreLocation
import CoreMotion
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()

    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0
    @Published var currentAltitude: Double = 0
    @Published var currentCourse: Double = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var accelerationData: AccelerationData?
    @Published var isTracking: Bool = false

    var onLocationUpdate: ((CLLocation) -> Void)?
    var onAccelerationUpdate: ((AccelerationData) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation

        authorizationStatus = locationManager.authorizationStatus
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        isTracking = true
        locationManager.startUpdatingLocation()
        startAccelerometer()
    }

    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        stopAccelerometer()
    }

    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else { return }
            let acceleration = AccelerationData(
                timestamp: Date(),
                x: data.acceleration.x,
                y: data.acceleration.y,
                z: data.acceleration.z
            )
            self?.accelerationData = acceleration
            self?.onAccelerationUpdate?(acceleration)
        }
    }

    private func stopAccelerometer() {
        motionManager.stopAccelerometerUpdates()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        currentSpeed = max(0, location.speed * 3.6)
        currentAltitude = location.altitude
        currentCourse = location.course >= 0 ? location.course : 0
        onLocationUpdate?(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}
