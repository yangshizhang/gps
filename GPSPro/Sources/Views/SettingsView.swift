import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @AppStorage("unit_system") private var unitSystem: String = "metric"
    @AppStorage("auto_record") private var autoRecord: Bool = false
    @AppStorage("background_tracking") private var backgroundTracking: Bool = true
    @AppStorage("speed_threshold") private var speedThreshold: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                locationSection

                unitsSection

                recordingSection

                aboutSection
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var locationSection: some View {
        Section {
            HStack {
                Text("定位权限")
                Spacer()
                Text(authorizationStatusText)
                    .foregroundColor(.secondary)
            }

            Button(action: openSettings) {
                HStack {
                    Text("打开系统设置")
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .foregroundColor(.blue)
                }
            }
        } header: {
            Text("定位服务")
        } footer: {
            Text("需要定位权限才能记录您的行驶路线和速度")
        }
    }

    private var authorizationStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "未确定"
        case .restricted:
            return "受限制"
        case .denied:
            return "被拒绝"
        case .authorizedAlways:
            return "始终允许"
        case .authorizedWhenInUse:
            return "使用时允许"
        @unknown default:
            return "未知"
        }
    }

    private var unitsSection: some View {
        Section {
            Picker("单位制", selection: $unitSystem) {
                Text("公制 (km/h)").tag("metric")
                Text("英制 (mph)").tag("imperial")
            }
        } header: {
            Text("单位")
        }
    }

    private var recordingSection: some View {
        Section {
            Toggle("自动开始记录", isOn: $autoRecord)

            Toggle("后台追踪", isOn: $backgroundTracking)

            HStack {
                Text("速度阈值")
                Spacer()
                Text(String(format: "%.0f km/h", speedThreshold))
                    .foregroundColor(.secondary)
            }
            Slider(value: $speedThreshold, in: 0...20, step: 1)
        } header: {
            Text("记录设置")
        } footer: {
            Text("当速度超过阈值时自动开始记录（需要开启自动开始记录）")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("版本")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("构建")
                Spacer()
                Text("1")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("关于")
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LocationManager())
}
