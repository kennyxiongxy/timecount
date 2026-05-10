import SwiftUI

struct GradientBackground: View {
    let colors: [Color]
    @State private var animate = false

    init(colors: [Color]? = nil) {
        self.colors = colors ?? [
            Color(hex: "#0A0A1A"),
            Color(hex: "#1A0A2E"),
            Color(hex: "#0F0F2A"),
            Color(hex: "#0A0A1A"),
        ]
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            AngularGradient(
                stops: [
                    .init(color: colors[0], location: 0),
                    .init(color: colors[1], location: 0.3),
                    .init(color: colors[2], location: 0.6),
                    .init(color: colors[3], location: 1),
                ],
                center: .center,
                angle: .degrees(t * 10)
            )
        }
    }
}
