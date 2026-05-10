import SwiftUI

struct TimeInputView: View {
    @Bindable var timer: TimerModel
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @State private var inputText = ""
    @State private var isInvalid = false

    var body: some View {
        if timer.isRunning || timer.status == .paused {
            NeonTextField(
                placeholder: "+5m / -30s",
                text: $inputText,
                borderColor: themeManager.accent.opacity(0.5),
                frameWidth: 110,
                isInvalid: isInvalid,
                onSubmit: applyAdjustment
            )
        } else {
            NeonTextField(
                placeholder: "例如 5m30s",
                text: $inputText,
                borderColor: themeManager.primary.opacity(0.5),
                frameWidth: 130,
                isInvalid: isInvalid,
                onSubmit: applySetup
            )
        }
    }

    private func applySetup() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let result = TimeParseEngine.parse(inputText)

        switch result {
        case .absolute(let seconds):
            guard seconds > 0 else { isInvalid = true; return }
            isInvalid = false
            timerEngine.setTime(timer: timer, totalSeconds: seconds)
            timerEngine.start(timer: timer)
            inputText = ""
        case .relative(let delta):
            isInvalid = false
            timerEngine.setTime(timer: timer, totalSeconds: max(1, delta))
            timerEngine.start(timer: timer)
            inputText = ""
        case .invalid:
            isInvalid = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isInvalid = false }
        }
    }

    private func applyAdjustment() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let result = TimeParseEngine.parse(inputText)

        switch result {
        case .absolute(let seconds):
            isInvalid = false
            timerEngine.setTime(timer: timer, totalSeconds: seconds)
            timerEngine.start(timer: timer)
            inputText = ""
        case .relative(let delta):
            isInvalid = false
            timerEngine.adjustTime(timer: timer, deltaSeconds: delta)
            inputText = ""
        case .invalid:
            isInvalid = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isInvalid = false }
        }
    }
}
