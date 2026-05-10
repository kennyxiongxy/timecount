import SwiftUI

struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("暂无倒计时")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("在上方输入框中输入时间后按回车，创建第一个倒计时")
                .font(.body)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
