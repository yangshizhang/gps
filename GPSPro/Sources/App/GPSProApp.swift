import SwiftUI

@main
struct GPSProApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var recordingManager = RecordingManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(recordingManager)
        }
    }
}
