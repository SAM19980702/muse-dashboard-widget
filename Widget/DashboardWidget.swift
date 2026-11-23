import WidgetKit
import SwiftUI

struct DashboardEntry: TimelineEntry {
    let date: Date
    let data: DashboardData
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DashboardEntry {
        DashboardEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DashboardEntry) -> Void) {
        if context.isPreview {
            completion(DashboardEntry(date: Date(), data: .placeholder))
        } else {
            DashboardStore.fetch { data in
                completion(DashboardEntry(date: Date(), data: data))
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DashboardEntry>) -> Void) {
        DashboardStore.fetch { data in
            let now = Date()
            let entry = DashboardEntry(date: now, data: data)
            let next = Self.nextBoundary(after: now)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    static func nextBoundary(after date: Date) -> Date {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let nextHour = ((hour / 4) + 1) * 4
        if nextHour >= 24 {
            let start = cal.startOfDay(for: date)
            return cal.date(byAdding: .day, value: 1, to: start) ?? date.addingTimeInterval(4 * 3600)
        }
        return cal.date(bySettingHour: nextHour, minute: 0, second: 0, of: date)
            ?? date.addingTimeInterval(4 * 3600)
    }
}

struct CardShell<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
            content
                .padding(16)
        }
        .padding(5)
    }
}

struct StatCell: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let caption: String
    var valueColor: Color = .black
    var valueSize: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(iconColor)
                Text(label)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(Color(white: 0.35))
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: valueSize, weight: .bold))
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(caption)
                .font(.system(size: 11.5))
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private let tealColor = Color(red: 0.08, green: 0.62, blue: 0.52)

struct SmallView: View {
    let data: DashboardData

    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Muse 仪表盘")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        Text("更新于 \(data.updatedTimeShort)")
                            .font(.system(size: 10.5))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                }
                Divider()
                StatCell(icon: "memorychip", iconColor: .purple, label: "记忆状态",
                         value: data.memoryDisplay, caption: "我的记忆库", valueSize: 17)
                HStack(alignment: .top, spacing: 8) {
                    StatCell(icon: "envelope.fill", iconColor: .blue, label: "未读邮件",
                             value: "\(data.unreadMail)", caption: "未读", valueSize: 17)
                    StatCell(icon: "folder.fill", iconColor: tealColor, label: "项目",
                             value: "\(data.projects)", caption: "进行中", valueSize: 17)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct MediumView: View {
    let data: DashboardData

    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 9) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 38, height: 38)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Muse · 健康检查仪表盘")
                            .font(.system(size: 15.5, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        Text("已于 \(data.updatedTimeShort) 更新")
                            .font(.system(size: 11.5))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 7, height: 7)
                        Text("运行中")
                            .font(.system(size: 11.5))
                            .foregroundStyle(.gray)
                    }
                }
                Divider()
                HStack(alignment: .top, spacing: 8) {
                    StatCell(icon: "memorychip", iconColor: .purple, label: "记忆状态",
                             value: data.memoryDisplay, caption: "我的记忆库", valueSize: 19)
                    StatCell(icon: "envelope.fill", iconColor: .blue, label: "未读邮件",
                             value: "\(data.unreadMail)", caption: "未读", valueSize: 19)
                    StatCell(icon: "folder.fill", iconColor: tealColor, label: "进行中项目",
                             value: "\(data.projects)", caption: "活跃项目", valueSize: 19)
                    StatCell(icon: "clock.fill", iconColor: .green, label: "定时任务",
                             value: data.tasksStatus, caption: "整点刷新", valueColor: .green, valueSize: 19)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct LargeView: View {
    let data: DashboardData

    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 14) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 62, height: 62)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Muse ·\n健康检查仪表盘")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.black)
                        Text("健康摘要 · 已于 \(data.updatedTimeShort) 更新")
                            .font(.system(size: 12.5))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }

                Divider()
                    .padding(.vertical, 14)

                HStack(alignment: .top, spacing: 12) {
                    StatCell(icon: "memorychip", iconColor: .purple, label: "记忆状态",
                             value: data.memoryDisplay, caption: "我的记忆库")
                    StatCell(icon: "envelope.fill", iconColor: .blue, label: "未读邮件",
                             value: "\(data.unreadMail)", caption: "未读")
                }

                Spacer(minLength: 10)

                HStack(alignment: .top, spacing: 12) {
                    StatCell(icon: "folder.fill", iconColor: tealColor, label: "进行中项目",
                             value: "\(data.projects)", caption: "活跃项目")
                    StatCell(icon: "clock.fill", iconColor: .green, label: "定时任务",
                             value: data.tasksStatus, caption: "每 4 小时整点刷新", valueColor: .green)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct DashboardWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: DashboardEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(data: entry.data)
        case .systemLarge:
            LargeView(data: entry.data)
        default:
            MediumView(data: entry.data)
        }
    }
}

struct DashboardWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MuseDashboardWidget", provider: Provider()) { entry in
            DashboardWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Muse 仪表盘")
        .description("Muse 的健康检查摘要：记忆、未读邮件、项目与定时任务。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct MuseDashboardWidgetBundle: WidgetBundle {
    var body: some Widget {
        DashboardWidget()
    }
}
