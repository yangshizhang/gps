import SwiftUI
import MapKit
import Charts

struct HistoryView: View {
    @EnvironmentObject var recordingManager: RecordingManager
    @State private var selectedRecording: Recording?

    var body: some View {
        NavigationStack {
            List {
                if recordingManager.recordings.isEmpty {
                    emptyStateView
                } else {
                    ForEach(recordingManager.recordings) { recording in
                        NavigationLink(destination: RecordingDetailView(recording: recording)) {
                            RecordingRowView(recording: recording)
                        }
                    }
                    .onDelete(perform: recordingManager.deleteRecording)
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("暂无记录")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("开始记录您的行程，数据将显示在这里")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .listRowBackground(Color.clear)
    }
}

struct RecordingRowView: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.formattedStartTime)
                        .font(.headline)
                    Text("持续 \(recording.formattedDuration)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f km/h", recording.maxSpeed * 3.6))
                        .font(.title3.bold())
                        .foregroundColor(.orange)
                    Text("最高速度")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if !recording.locationPoints.isEmpty {
                SpeedChartPreview(locationPoints: recording.locationPoints)
                    .frame(height: 60)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SpeedChartPreview: View {
    let locationPoints: [LocationPoint]

    var body: some View {
        Chart {
            ForEach(locationPoints) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Speed", point.speed * 3.6)
                )
                .foregroundStyle(.blue)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct RecordingDetailView: View {
    let recording: Recording

    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                mapSection

                statsSection

                speedChartSection

                locationPointsSection
            }
            .padding()
        }
        .navigationTitle("记录详情")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupMapRegion()
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("路径地图")
                .font(.headline)

            if recording.locationPoints.isEmpty {
                Text("无路径数据")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                Map {
                    MapPolyline(coordinates: recording.locationPoints.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 4)

                    if let first = recording.locationPoints.first {
                        Annotation("起点", coordinate: first.coordinate) {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.green)
                        }
                    }

                    if let last = recording.locationPoints.last {
                        Annotation("终点", coordinate: last.coordinate) {
                            Image(systemName: "flag.checkered")
                                .foregroundColor(.red)
                        }
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("统计数据")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "开始时间", value: recording.formattedStartTime, icon: "clock.fill", color: .blue)
                StatCard(title: "持续时间", value: recording.formattedDuration, icon: "timer", color: .green)
                StatCard(title: "最高速度", value: String(format: "%.1f km/h", recording.maxSpeed * 3.6), icon: "speedometer", color: .orange)
                StatCard(title: "平均速度", value: String(format: "%.1f km/h", recording.averageSpeed * 3.6), icon: "chart.bar.fill", color: .purple)
                StatCard(title: "总距离", value: String(format: "%.2f km", recording.totalDistance / 1000), icon: "location.fill", color: .cyan)
                StatCard(title: "海拔变化", value: String(format: "%.0f m", recording.locationPoints.last?.altitude ?? 0 - (recording.locationPoints.first?.altitude ?? 0)), icon: "mountain.2.fill", color: .teal)
            }
        }
    }

    private var speedChartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("速度图表")
                .font(.headline)

            if recording.locationPoints.isEmpty {
                Text("无速度数据")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                Chart {
                    ForEach(recording.locationPoints) { point in
                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Speed", point.speed * 3.6)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.5), .blue.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Speed", point.speed * 3.6)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }

    private var locationPointsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("位置点数")
                .font(.headline)

            Text("\(recording.locationPoints.count) 个数据点")
                .foregroundColor(.secondary)
        }
    }

    private func setupMapRegion() {
        guard !recording.locationPoints.isEmpty else { return }
        let coordinates = recording.locationPoints.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0

        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.5,
                longitudeDelta: (maxLon - minLon) * 1.5
            )
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HistoryView()
        .environmentObject(RecordingManager())
}
