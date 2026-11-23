import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var data = DashboardStore.cached()
    @State private var refreshing = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemGray5), Color(.systemGray6)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                DashboardCard(data: data)
                    .padding(.horizontal, 20)

                Text("数据更新于 \(data.updatedTimeShort) · 每 4 小时整点自动刷新")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button {
                    refreshing = true
                    DashboardStore.fetch { fresh in
                        DispatchQueue.main.async {
                            data = fresh
                            refreshing = false
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                } label: {
                    Label(refreshing ? "刷新中…" : "立即刷新数据", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .disabled(refreshing)

                Text("把「Muse 仪表盘」小组件添加到主屏幕，就能在桌面看这份摘要。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .onAppear {
            DashboardStore.fetch { fresh in
                DispatchQueue.main.async { data = fresh }
            }
        }
    }
}

struct DashboardCard: View {
    let data: DashboardData

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image("avatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Muse · 健康检查仪表盘")
                        .font(.headline)
                        .foregroundStyle(.black)
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 7, height: 7)
                        Text("Muse 运行中")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer()
            }

            Divider()

            HStack(alignment: .top) {
                StatView(label: "记忆状态", value: data.memoryDisplay)
                Spacer()
                StatView(label: "未读邮件", value: "\(data.unreadMail)")
                Spacer()
                StatView(label: "进行中项目", value: "\(data.projects)")
                Spacer()
                StatView(label: "定时任务", value: data.tasksStatus)
            }

            Text("体检提醒：\(data.healthNote)")
                .font(.caption)
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 9)
        )
    }
}

struct StatView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
            Text(value)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
