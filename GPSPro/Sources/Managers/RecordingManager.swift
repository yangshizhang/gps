import Foundation
import CoreLocation
import Combine

class RecordingManager: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var currentRecording: Recording?
    @Published var recordings: [Recording] = []
    @Published var currentDuration: TimeInterval = 0
    @Published var currentAverageSpeed: Double = 0
    @Published var currentMaxSpeed: Double = 0

    private var recordingTimer: Timer?
    private let recordingsKey = "saved_recordings"

    init() {
        loadRecordings()
    }

    func startRecording() {
        let newRecording = Recording(startTime: Date())
        currentRecording = newRecording
        isRecording = true
        startTimer()
    }

    func stopRecording() {
        guard var recording = currentRecording else { return }
        recording.finish()
        recordings.insert(recording, at: 0)
        saveRecordings()
        isRecording = false
        currentRecording = nil
        stopTimer()
        currentDuration = 0
        currentAverageSpeed = 0
        currentMaxSpeed = 0
    }

    func addLocationPoint(_ location: CLLocation) {
        guard var recording = currentRecording, isRecording else { return }
        let point = LocationPoint(from: location)
        recording.addLocationPoint(point)
        currentRecording = recording
        currentMaxSpeed = recording.maxSpeed * 3.6
        currentAverageSpeed = recording.averageSpeed * 3.6
    }

    func addAccelerationData(_ data: AccelerationData) {
        guard var recording = currentRecording, isRecording else { return }
        recording.addAccelerationData(data)
        currentRecording = recording
    }

    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let recording = self.currentRecording else { return }
            self.currentDuration = recording.duration
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    func deleteRecording(_ recording: Recording) {
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }

    func deleteRecording(at offsets: IndexSet) {
        recordings.remove(atOffsets: offsets)
        saveRecordings()
    }

    private func saveRecordings() {
        do {
            let data = try JSONEncoder().encode(recordings)
            UserDefaults.standard.set(data, forKey: recordingsKey)
        } catch {
            print("Failed to save recordings: \(error)")
        }
    }

    private func loadRecordings() {
        guard let data = UserDefaults.standard.data(forKey: recordingsKey) else { return }
        do {
            recordings = try JSONDecoder().decode([Recording].self, from: data)
        } catch {
            print("Failed to load recordings: \(error)")
        }
    }

    func getRecording(by id: UUID) -> Recording? {
        recordings.first { $0.id == id }
    }
}
