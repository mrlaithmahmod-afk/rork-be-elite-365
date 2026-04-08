import SwiftUI
import SwiftData

struct PressureNormaliserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: PressureNormPhase = .ready
    @State private var countdownValue: Int = 5
    @State private var timer: Timer?
    @State private var selectedLocation: String = ""
    @State private var accepted = false
    @State private var effectiveness: Int = 3
    @State private var heartbeatScale: CGFloat = 1.0

    private let pressureLocations = [
        ("chest", "Chest", "heart.fill"),
        ("stomach", "Stomach", "staroflife.fill"),
        ("head", "Head", "brain.head.profile")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .ready: readyView
                case .countdown: countdownView
                case .locate: locateView
                case .reframe: reframeView
                case .accept: acceptView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Pressure Normaliser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { stopTimer(); dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
        .onDisappear { stopTimer() }
    }

    private var readyView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Pressure Normaliser")
                    .font(.title2.weight(.bold))

                Text("Pressure is not danger. It is your body preparing to perform. This drill teaches you to accept and channel it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("60s")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text("Duration")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text("3 Steps")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text("Process")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                phase = .countdown
                startCountdown()
            } label: {
                Text("Begin")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var countdownView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.breakdown)
                    .scaleEffect(heartbeatScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            heartbeatScale = 1.15
                        }
                    }

                Text("Feel the pressure building...")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("\(countdownValue)")
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.gold)
                    .contentTransition(.numericText())
            }

            Spacer()
        }
    }

    private var locateView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("STEP 1")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))
                    .tracking(2)

                Text("Where do you\nfeel pressure?")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                ForEach(pressureLocations, id: \.0) { key, label, icon in
                    Button {
                        selectedLocation = label
                        withAnimation(.easeInOut(duration: 0.3)) { phase = .reframe }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundStyle(AppTheme.gold)
                                .frame(width: 32)
                            Text(label)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: selectedLocation)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var reframeView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("STEP 2")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))
                    .tracking(2)

                Image(systemName: "bolt.heart")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))

                Text("This is readiness,\nnot danger")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Your body is activating to perform. The \(selectedLocation.lowercased()) tension is adrenaline preparing your muscles for action.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.3)) { phase = .accept }
            } label: {
                Text("I Understand")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.impact(weight: .medium), trigger: phase)
        }
    }

    private var acceptView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("STEP 3")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))
                    .tracking(2)

                Text("Accept it.\nUse it.")
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)

                Button {
                    accepted = true
                    withAnimation(.easeInOut(duration: 0.3)) { phase = .complete }
                } label: {
                    Text("I accept it")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(width: 160, height: 160)
                        .background(Color(red: 0.25, green: 0.75, blue: 0.40))
                        .clipShape(Circle())
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: accepted)
            }

            Spacer()
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Pressure Normalised")
                    .font(.title2.weight(.bold))

                Text("Pressure location: \(selectedLocation)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
            }

            VStack(spacing: 10) {
                Text("How effective was this?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button { effectiveness = value } label: {
                            Text("\(value)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(value <= effectiveness ? .black : .white)
                                .frame(width: 44, height: 44)
                                .background(value <= effectiveness ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }

            Spacer()

            Button {
                let completion = DrillCompletion(drillID: "pressure-normaliser", effectiveness: effectiveness)
                modelContext.insert(completion)
                dismiss()
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: phase)
        }
    }

    private func startCountdown() {
        countdownValue = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            countdownValue -= 1
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            if countdownValue <= 0 {
                t.invalidate()
                heartbeatScale = 1.0
                withAnimation { phase = .locate }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum PressureNormPhase: Sendable {
    case ready, countdown, locate, reframe, accept, complete
}
