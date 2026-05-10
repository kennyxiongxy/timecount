import SwiftUI

struct MultiTimerGridView: View {
    let timers: [TimerModel]

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

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
