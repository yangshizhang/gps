import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recordingManager: RecordingManager

    @State private var selectedTab: Tab = .speedometer

    enum Tab: String, CaseIterable {
        case map = "地图"
        case speedometer = "时速表"
        case history = "历史"
        case settings = "设置"

        var icon: String {
            switch self {
            case .map: return "map.fill"
            case .speedometer: return "speedometer"
            case .history: return "clock.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label(Tab.map.rawValue, systemImage: Tab.map.icon)
                }
                .tag(Tab.map)

            SpeedometerView()
                .tabItem {
                    Label(Tab.speedometer.rawValue, systemImage: Tab.speedometer.icon)
                }
                .tag(Tab.speedometer)

            HistoryView()
                .tabItem {
                    Label(Tab.history.rawValue, systemImage: Tab.history.icon)
                }
                .tag(Tab.history)

            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(.blue)
        .onAppear {
            setupTabBarAppearance()
            locationManager.requestAuthorization()
        }
        .onChange(of: locationManager.currentSpeed) { _, newValue in
            updateSpeedAnimation(newValue)
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func updateSpeedAnimation(_ speed: Double) {
        withAnimation(.easeInOut(duration: 0.3)) {
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(RecordingManager())
}
