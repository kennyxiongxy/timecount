import SwiftUI
import SwiftData

struct TimerCardView: View {
    @Bindable var timer: TimerModel
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.modelContext) private var modelContext
    @State private var editedName: String

    init(timer: TimerModel) {
        self.timer = timer
        _editedName = State(initialValue: timer.name)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                // Name field — always editable
                TextField("计时器名称", text: $editedName, onCommit: commitName)
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .foregroundStyle(themeManager.primary)
                    .multilineTextAlignment(.center)

                TimerDisplayView(timer: timer)

                TimeInputView(timer: timer)

                TimerControlsView(timer: timer)
            }
            .padding(16)

            // Delete button — top-right corner
            Button(action: deleteTimer) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(themeManager.primary)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .padding(6)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(timer.backgroundColorHex.isEmpty
                      ? themeManager.cardBg
                      : Color(hex: timer.backgroundColorHex))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(themeManager.cardBorder.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: themeManager.glow.opacity(0.15), radius: 8)
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                windowManager.openFullscreen(for: timer.id, modelContext: modelContext)
            }
        )
        .contextMenu {
            Button("复制", action: duplicateTimer)
            Divider()
            Button("删除", role: .destructive, action: deleteTimer)
        }
    }

    private func commitName() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            timer.name = trimmed
            try? modelContext.save()
        } else {
            editedName = timer.name
        }
    }

    private func duplicateTimer() {
        let newTimer = TimerModel(
            name: "\(timer.name) 副本",
            totalSeconds: timer.totalSeconds,
            sortOrder: timer.sortOrder + 1
        )
        modelContext.insert(newTimer)
        try? modelContext.save()
    }

    private func deleteTimer() {
        if timer.status == .running {
            timerEngine.pause(timer: timer)
        }
        if timer.status == .finished {
            soundManager.stopEndSound()
        }
        windowManager.closeFullscreen(for: timer.id)
        modelContext.delete(timer)
        try? modelContext.save()
    }
}
