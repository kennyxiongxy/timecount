import SwiftUI

struct EmptyStateView: View {
    let onAdd: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(themeManager.accent.opacity(0.05))
                    .frame(width: 100, height: 100)
                Circle()
                    .strokeBorder(themeManager.accent.opacity(0.15), lineWidth: 1)
                    .frame(width: 100, height: 100)
                Image(systemName: "timer")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(themeManager.accent.opacity(0.4))
            }

            VStack(spacing: 8) {
                Text("暂无倒计时")
                    .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 18))
                    .foregroundStyle(themeManager.primary.opacity(0.7))

                Text("在上方输入框中输入时间后按回车，创建第一个倒计时")
                    .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13))
                    .foregroundStyle(themeManager.secondary.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10))
                    .foregroundStyle(themeManager.accent.opacity(0.4))
                Text("或从左侧预设快速开始")
                    .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 11))
                    .foregroundStyle(themeManager.secondary.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
