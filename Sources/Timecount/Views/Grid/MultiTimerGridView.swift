import SwiftUI

struct MultiTimerGridView: View {
    let timers: [TimerModel]

    var body: some View {
        let columnCount = min(4, max(1, timers.count))
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: columnCount)

        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(timers) { timer in
                    TimerCardView(timer: timer)
                }
            }
            .padding(12)
        }
    }
}
