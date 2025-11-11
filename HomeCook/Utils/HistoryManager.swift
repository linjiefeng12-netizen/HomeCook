//
//  HistoryManager.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import Foundation

// 历史记录项模型
struct VideoHistoryItem: Identifiable, Codable {
    let id: UUID
    let videoId: String
    let title: String
    let description: String
    let thumbnailURL: String
    let channelTitle: String
    let duration: String?
    let likeCount: Int
    let viewCount: Int
    let watchedAt: Date
    
    init(from video: YouTubeVideo) {
        self.id = UUID()
        self.videoId = video.id
        self.title = video.title
        self.description = video.description
        self.thumbnailURL = video.thumbnailURL
        self.channelTitle = video.channelTitle
        self.duration = video.duration
        self.likeCount = video.likeCount
        self.viewCount = video.viewCount
        self.watchedAt = Date()
    }
}

// 历史记录管理器
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var watchHistory: [VideoHistoryItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "video_watch_history"
    private let maxHistoryDays = 7
    
    private init() {
        loadHistory()
        cleanOldHistory()
    }
    
    // 添加视频到观看历史
    func addVideoToHistory(_ video: YouTubeVideo) {
        // 检查是否已经存在相同的视频（避免重复添加）
        if let existingIndex = watchHistory.firstIndex(where: { $0.videoId == video.id }) {
            // 如果已存在，移除旧记录并添加新记录到最前面
            watchHistory.remove(at: existingIndex)
            
            // 创建新的历史项目，更新观看时间
            let newItem = VideoHistoryItem(from: video)
            watchHistory.insert(newItem, at: 0)
        } else {
            // 如果不存在，添加新的历史记录
            let historyItem = VideoHistoryItem(from: video)
            watchHistory.insert(historyItem, at: 0)
        }
        
        // 清理超过7天的记录
        cleanOldHistory()
        
        // 保存到本地存储
        saveHistory()
        
        print("已添加视频到观看历史: \(video.title)")
    }
    
    // 清理超过7天的历史记录
    private func cleanOldHistory() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -maxHistoryDays, to: Date()) ?? Date()
        
        let originalCount = watchHistory.count
        watchHistory = watchHistory.filter { $0.watchedAt >= sevenDaysAgo }
        
        let removedCount = originalCount - watchHistory.count
        if removedCount > 0 {
            print("已清理 \(removedCount) 条超过7天的历史记录")
        }
    }
    
    // 获取指定日期的观看历史
    func getHistoryForDate(_ date: Date) -> [VideoHistoryItem] {
        let calendar = Calendar.current
        return watchHistory.filter { calendar.isDate($0.watchedAt, inSameDayAs: date) }
    }
    
    // 获取最近的观看历史（用于显示在History页面）
    func getRecentHistory(limit: Int = 20) -> [VideoHistoryItem] {
        return Array(watchHistory.prefix(limit))
    }
    
    // 检查指定日期是否有观看记录（用于日历显示）
    func hasHistoryForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return watchHistory.contains { calendar.isDate($0.watchedAt, inSameDayAs: date) }
    }
    
    // 获取有观看记录的日期列表（用于日历高亮显示）
    func getDatesWithHistory() -> Set<Date> {
        let calendar = Calendar.current
        var dates = Set<Date>()
        
        for item in watchHistory {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: item.watchedAt)
            if let date = calendar.date(from: dateComponents) {
                dates.insert(date)
            }
        }
        
        return dates
    }
    
    // 清除所有历史记录
    func clearAllHistory() {
        watchHistory.removeAll()
        saveHistory()
        print("已清除所有观看历史")
    }
    
    // 删除指定的历史记录
    func removeHistoryItem(_ item: VideoHistoryItem) {
        if let index = watchHistory.firstIndex(where: { $0.id == item.id }) {
            watchHistory.remove(at: index)
            saveHistory()
            print("已删除历史记录: \(item.title)")
        }
    }
    
    // 保存历史记录到本地存储
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(watchHistory)
            userDefaults.set(data, forKey: historyKey)
            print("历史记录已保存，共 \(watchHistory.count) 条")
        } catch {
            print("保存历史记录失败: \(error.localizedDescription)")
        }
    }
    
    // 从本地存储加载历史记录
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey) else {
            print("没有找到历史记录数据")
            return
        }
        
        do {
            watchHistory = try JSONDecoder().decode([VideoHistoryItem].self, from: data)
            print("已加载历史记录，共 \(watchHistory.count) 条")
        } catch {
            print("加载历史记录失败: \(error.localizedDescription)")
            watchHistory = []
        }
    }
}

// 扩展VideoHistoryItem，添加格式化方法
extension VideoHistoryItem {
    // 格式化播放量
    var formattedViewCount: String {
        return formatCount(viewCount)
    }
    
    // 格式化点赞数
    var formattedLikeCount: String {
        return formatCount(likeCount)
    }
    
    // 格式化观看时间
    func formattedWatchTime(language: String = "zh-Hans") -> String {
        let formatter = DateFormatter()
        
        if language == "zh-Hans" {
            formatter.dateFormat = "MM月dd日 HH:mm"
        } else {
            formatter.dateFormat = "MMM dd, HH:mm"
            formatter.locale = Locale(identifier: language)
        }
        
        return formatter.string(from: watchedAt)
    }
    
    // 格式化数字（播放量、点赞数）
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        } else {
            return "\(count)"
        }
    }
}