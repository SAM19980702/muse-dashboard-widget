import Foundation

struct DashboardData: Codable {
    var updatedAt: String
    var memoryDisplay: String
    var unreadMail: Int
    var projects: Int
    var autoTasks: Int
    var tasksStatus: String
    var healthNote: String

    static let placeholder = DashboardData(
        updatedAt: "2026-11-23T16:00:00+08:00",
        memoryDisplay: "722 KB",
        unreadMail: 1851,
        projects: 15,
        autoTasks: 5,
        tasksStatus: "運行中",
        healthNote: "最大的記憶文件 reflections.md 已 306 KB"
    )

    var updatedTimeShort: String {
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime]
        guard let date = parser.date(from: updatedAt) else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}

enum DashboardStore {
    static let appGroup = "group.com.sam.musedashboard"
    static let dataURL = URL(string: "https://raw.githubusercontent.com/SAM19980702/muse-dashboard-data/main/data.json")!
    private static let cacheKey = "dashboardDataJSON"

    static func cached() -> DashboardData {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let raw = defaults.data(forKey: cacheKey),
              let data = try? JSONDecoder().decode(DashboardData.self, from: raw)
        else { return .placeholder }
        return data
    }

    static func save(_ data: DashboardData) {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let raw = try? JSONEncoder().encode(data) else { return }
        defaults.set(raw, forKey: cacheKey)
    }

    static func fetch(completion: @escaping (DashboardData) -> Void) {
        var request = URLRequest(url: dataURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 20
        URLSession.shared.dataTask(with: request) { raw, _, _ in
            if let raw, let data = try? JSONDecoder().decode(DashboardData.self, from: raw) {
                save(data)
                completion(data)
            } else {
                completion(cached())
            }
        }.resume()
    }
}
