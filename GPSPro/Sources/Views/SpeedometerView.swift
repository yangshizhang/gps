import SwiftUI

struct SpeedometerView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var recordingManager: RecordingManager

    @State private var animatedSpeed: Double = 0
    @State private var showRecordingControls: Bool = false

    private let maxSpeed: Double = 240
    private let startAngle: Double = 135
    private let endAngle: Double = 405

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                speedGaugeView

                speedInfoView

                recordingInfoView

                recordButton

                Spacer()
            }
            .padding()
        }
    }

    private var speedGaugeView: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                .frame(width: 280, height: 280)

            speedArcView

            compassView
                .offset(y: -80)

            speedDigitView
                .offset(y: 20)

            altitudeView
                .offset(y: 90)
        }
    }

    private var speedArcView: some View {
        Circle()
            .trim(from: trimStart, to: trimEnd)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                    center: .center,
                    startAngle: .degrees(startAngle),
                    endAngle: .degrees(endAngle)
                ),
                style: StrokeStyle(lineWidth: 20, lineCap: .round)
            )
            .frame(width: 280, height: 280)
            .rotationEffect(.degrees(startAngle))
            .shadow(color: .blue.opacity(0.5), radius: 10)
    }

    private var trimStart: CGFloat {
        CGFloat((0 - 0) / maxSpeed)
    }

    private var trimEnd: CGFloat {
        CGFloat((animatedSpeed - 0) / maxSpeed).clamped(to: 0...1)
    }

    private var speedDigitView: some View {
        VStack(spacing: 5) {
            Text("\(Int(animatedSpeed))")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("km/h")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var altitudeView: some View {
        VStack(spacing: 2) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 14))
                .foregroundColor(.cyan)
            Text("\(Int(locationManager.currentAltitude)) m")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
    }

    private var compassView: some View {
        VStack(spacing: 2) {
            Image(systemName: compassIconName)
                .font(.system(size: 20))
                .foregroundColor(.cyan)
                .rotationEffect(.degrees(locationManager.currentCourse))
            Text(compassDirection)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var compassIconName: String {
        "location.north.fill"
    }

    private var compassDirection: String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((locationManager.currentCourse + 22.5) / 45) % 8
        return directions[index]
    }

    private var speedInfoView: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text("持续时间")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(recordingManager.currentRecording?.formattedDuration ?? "00:00")
                    .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text("平均时速")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(String(format: "%.1f km/h", recordingManager.currentAverageSpeed))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    private var recordingInfoView: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text("开始时间")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(recordingManager.currentRecording?.formattedStartTime ?? "--")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text("最高速度")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(String(format: "%.1f km/h", recordingManager.currentMaxSpeed))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
        }
    }

    private var recordButton: some View {
        Button(action: {
            if recordingManager.isRecording {
                recordingManager.stopRecording()
            } else {
                recordingManager.startRecording()
            }
        }) {
            HStack {
                Image(systemName: recordingManager.isRecording ? "stop.fill" : "record.circle")
                Text(recordingManager.isRecording ? "停止记录" : "开始记录")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(recordingManager.isRecording ? Color.red : Color.blue)
            .cornerRadius(25)
            .glassBackground()
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension View {
    func glassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(25)
    }
}

#Preview {
    SpeedometerView()
        .environmentObject(LocationManager())
        .environmentObject(RecordingManager())
}
