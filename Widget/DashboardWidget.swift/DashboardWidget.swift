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
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.25), radius: 13, x: 0, y: 7)
            content
                .padding(13)
        }
        .padding(5)
    }
}

struct WidgetStat: View {
    let label: String
    let value: String
    var size: CGFloat = 17

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
                .lineLimit(1)
            Text(value)
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }
}

struct SmallView: View {
    let data: DashboardData

    var body: some View {
        CardShell {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Muse 仪表盘")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        HStack(spacing: 3) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("运行中 · \(data.updatedTimeShort)")
                                .font(.system(size: 10))
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                        }
                    }
                }
                Divider()
                WidgetStat(label: "记忆状态", value: data.memoryDisplay, size: 16)
                HStack {
                    WidgetStat(label: "未读邮件", value: "\(data.unreadMail)", size: 16)
                    Spacer()
                    WidgetStat(label: "进行中项目", value: "\(data.projects)", size: 16)
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
                HStack(spacing: 8) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 34, height: 34)
                        .clipShape(Circle())
                    Text("Muse · 健康检查仪表盘")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                    Spacer()
                    Text(data.updatedTimeShort)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Divider()
                HStack(alignment: .top) {
                    WidgetStat(label: "记忆状态", value: data.memoryDisplay, size: 16)
                    Spacer()
                    WidgetStat(label: "未读邮件", value: "\(data.unreadMail)", size: 16)
                    Spacer()
                    WidgetStat(label: "进行中项目", value: "\(data.projects)", size: 16)
                    Spacer()
                    WidgetStat(label: "定时任务", value: data.tasksStatus, size: 16)
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 9) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Muse · 健康检查仪表盘")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 7, height: 7)
                            Text("Muse 运行中 · 更新于 \(data.updatedTimeShort)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                Divider()
                HStack(alignment: .top) {
                    WidgetStat(label: "记忆状态", value: data.memoryDisplay, size: 22)
                    Spacer()
                    WidgetStat(label: "未读邮件", value: "\(data.unreadMail)", size: 22)
                }
                HStack(alignment: .top) {
                    WidgetStat(label: "进行中项目", value: "\(data.projects)", size: 22)
                    Spacer()
                    WidgetStat(label: "定时任务", value: data.tasksStatus, size: 22)
                }
                Spacer(minLength: 0)
                Text("体检提醒：\(data.healthNote)")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 9).fill(Color.green.opacity(0.12)))
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
