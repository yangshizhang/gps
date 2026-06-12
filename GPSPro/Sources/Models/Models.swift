import Foundation
import CoreLocation

struct LocationPoint: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let speed: Double
    let course: Double
    let horizontalAccuracy: Double
    let verticalAccuracy: Double

    init(id: UUID = UUID(), timestamp: Date, latitude: Double, longitude: Double, altitude: Double, speed: Double, course: Double, horizontalAccuracy: Double, verticalAccuracy: Double) {
        self.id = id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.speed = speed
        self.course = course
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
    }

    init(from location: CLLocation) {
        self.id = UUID()
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.speed = max(0, location.speed)
        self.course = location.course
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct AccelerationData: Codable {
    let timestamp: Date
    let x: Double
    let y: Double
    let z: Double

    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
}

struct Recording: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    var locationPoints: [LocationPoint]
    var accelerationData: [AccelerationData]
    var maxSpeed: Double
    var averageSpeed: Double
    var totalDistance: Double

    init(id: UUID = UUID(), startTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = nil
        self.locationPoints = []
        self.accelerationData = []
        self.maxSpeed = 0
        self.averageSpeed = 0
        self.totalDistance = 0
    }

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: startTime)
    }

    mutating func addLocationPoint(_ point: LocationPoint) {
        if let lastPoint = locationPoints.last {
            let lastLocation = CLLocation(latitude: lastPoint.latitude, longitude: lastPoint.longitude)
            let currentLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
            totalDistance += currentLocation.distance(from: lastLocation)
        }
        locationPoints.append(point)
        if point.speed > maxSpeed {
            maxSpeed = point.speed
        }
        if !locationPoints.isEmpty {
            averageSpeed = totalDistance / duration
        }
    }

    mutating func addAccelerationData(_ data: AccelerationData) {
        accelerationData.append(data)
    }

    mutating func finish() {
        endTime = Date()
        if !locationPoints.isEmpty && duration > 0 {
            averageSpeed = totalDistance / duration
        }
    }
}
