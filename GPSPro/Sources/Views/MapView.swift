import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recordingManager: RecordingManager

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var routePolyline: [CLLocationCoordinate2D] = []

    var body: some View {
        ZStack {
            mapContent

            VStack {
                Spacer()
                mapOverlayInfo
                    .padding()
            }
        }
        .onAppear {
            setupLocationUpdates()
        }
    }

    private var mapContent: some View {
        Map(position: $cameraPosition) {
            if let currentLocation = locationManager.currentLocation {
                Annotation("当前位置", coordinate: currentLocation.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.3))
                            .frame(width: 40, height: 40)
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 16, height: 16)
                    }
                }
            }

            if !routePolyline.isEmpty {
                MapPolyline(coordinates: routePolyline)
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
    }

    private var mapOverlayInfo: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("当前速度")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f km/h", locationManager.currentSpeed))
                    .font(.title2.bold())
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("海拔")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(Int(locationManager.currentAltitude)) m")
                    .font(.title2.bold())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private func setupLocationUpdates() {
        locationManager.onLocationUpdate = { location in
            recordingManager.addLocationPoint(location)
            updateRoute(with: location)
            centerOnLocation(location)
        }
    }

    private func updateRoute(with location: CLLocation) {
        if recordingManager.isRecording {
            routePolyline.append(location.coordinate)
        }
    }

    private func centerOnLocation(_ location: CLLocation) {
        withAnimation {
            cameraPosition = .camera(MapCamera(
                centerCoordinate: location.coordinate,
                distance: 500,
                heading: location.course >= 0 ? location.course : 0,
                pitch: 0
            ))
        }
    }

    func clearRoute() {
        routePolyline.removeAll()
    }
}

extension CLLocation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

#Preview {
    MapView()
        .environmentObject(LocationManager())
        .environmentObject(RecordingManager())
}
