import SwiftUI

struct NeonTextField: View {
    let placeholder: String
    @Binding var text: String
    var borderColor: Color = Color(hex: "#FF00FF")
    var font: Font = .caption.monospaced()
    var frameWidth: CGFloat? = nil
    var isInvalid: Bool = false
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(font)
                    .foregroundStyle(Color.white.opacity(0.25))
                    .padding(.horizontal, 10)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .font(font)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .iflet(frameWidth) { view, width in
            view.frame(width: width)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isInvalid ? Color.red : borderColor,
                    lineWidth: isInvalid ? 1.5 : 1
                )
        )
        .shadow(color: (isInvalid ? Color.red : borderColor).opacity(isInvalid ? 0.3 : 0.1), radius: 3)
        .onSubmit {
            onSubmit?()
        }
    }
}

extension View {
    @ViewBuilder
    func iflet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}
