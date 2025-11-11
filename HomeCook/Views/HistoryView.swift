//
//  HistoryView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var historyManager = HistoryManager.shared
    
    // 添加ID用于强制刷新视图
    @State private var id = UUID()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // 日历部分
                        VStack(spacing: 16) {
                            // 月份导航
                            HStack {
                                Button(action: {
                                    // 上个月
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                Text(LocalizedStrings.yearMonth)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: {
                                    // 下个月
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // 日历网格
                            CalendarGridView()
                                .padding(.horizontal, 20)
                                .environmentObject(languageManager)
                        }
                        .padding(.vertical, 20)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // 历史记录列表
                        VStack(spacing: 0) {
                            // 列表标题
                            HStack {
                                Text(LocalizedStrings.recentlyCooking)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                            
                            // 历史记录项
                            LazyVStack(spacing: 0) {
                                let recentHistory = historyManager.getRecentHistory(limit: 20)
                                
                                if recentHistory.isEmpty {
                                    // 空状态显示
                                    VStack(spacing: 12) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 48))
                                            .foregroundColor(.secondary.opacity(0.6))
                                        
                                        Text("暂无观看记录")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        Text("观看视频后会在这里显示历史记录")
                                            .font(.caption)
                                            .foregroundColor(.secondary.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    ForEach(recentHistory, id: \.id) { item in
                                        VideoHistoryItemRow(item: item)
                                            .environmentObject(languageManager)
                                        
                                        if item.id != recentHistory.last?.id {
                                            Divider()
                                                .padding(.leading, 75)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // 底部安全区域
                        Color.clear.frame(height: 20)
                    }
                    .padding(.top, 8) // 减少顶部间距
                }
                .padding(.top, 1) // 添加最小顶部间距，防止内容覆盖状态栏
                .background(Color(.systemGroupedBackground))
            }
            .id(id) // 使用id强制刷新整个视图
            .navigationTitle(LocalizedStrings.history)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
                // 收到刷新通知时更新ID，强制刷新视图
                self.id = UUID()
                print("HistoryView 收到强制刷新通知，已更新ID")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CalendarGridView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var historyManager = HistoryManager.shared
    
    var weekdays: [String] {
        if languageManager.currentLanguage == "zh-Hans" {
            return ["日", "一", "二", "三", "四", "五", "六"]
        } else {
            return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        }
    }
    
    let calendar = Calendar.current
    @State private var currentDate = Date()
    
    var body: some View {
        VStack(spacing: 12) {
            // 星期标题
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)
            
            // 日历天数
            let days = generateCalendarDays()
            let datesWithHistory = historyManager.getDatesWithHistory()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { day in
                    let dayDate = calendar.date(byAdding: .day, value: day - calendar.component(.day, from: currentDate), to: currentDate) ?? currentDate
                    CalendarDayView(day: day, hasActivity: datesWithHistory.contains { calendar.isDate($0, inSameDayAs: dayDate) })
                }
            }
        }
    }
    
    private func generateCalendarDays() -> [Int] {
        let range = calendar.range(of: .day, in: .month, for: currentDate) ?? 1..<31
        return Array(range)
    }
}

struct CalendarDayView: View {
    let day: Int
    let hasActivity: Bool
    
    var body: some View {
        Text("\(day)")
            .font(.system(size: 16, weight: hasActivity ? .semibold : .regular))
            .foregroundColor(hasActivity ? .white : .primary)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(hasActivity ? Color.orange : Color.clear)
            )
            .overlay(
                Circle()
                    .stroke(hasActivity ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// 视频历史记录行组件
struct VideoHistoryItemRow: View {
    let item: VideoHistoryItem
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        HStack(spacing: 16) {
            // 视频缩略图
            AsyncImage(url: URL(string: item.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "play.rectangle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 60, height: 45)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            // 视频信息
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(item.channelTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // 观看时间
                    Text(item.formattedWatchTime(language: languageManager.currentLanguage))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // 视频时长
                    if let duration = item.duration {
                        Text("• \(duration)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // 播放量
                    Text("• \(item.formattedViewCount) 次观看")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 右侧播放按钮
            Button(action: {
                openYouTubeVideo()
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            openYouTubeVideo()
        }
    }
    
    // 打开YouTube视频
    private func openYouTubeVideo() {
        // 更新观看时间（重新添加到历史记录顶部）
        let video = YouTubeVideo(
            id: item.videoId,
            title: item.title,
            description: item.description,
            thumbnailURL: item.thumbnailURL,
            channelTitle: item.channelTitle,
            publishedAt: "", // 历史记录中不需要发布时间
            duration: item.duration,
            likeCount: item.likeCount,
            viewCount: item.viewCount
        )
        
        HistoryManager.shared.addVideoToHistory(video)
        
        // 打开YouTube视频
        if let youtubeAppURL = URL(string: "youtube://watch?v=\(item.videoId)"),
           UIApplication.shared.canOpenURL(youtubeAppURL) {
            UIApplication.shared.open(youtubeAppURL)
        } else if let youtubeWebURL = URL(string: "https://www.youtube.com/watch?v=\(item.videoId)") {
            UIApplication.shared.open(youtubeWebURL)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(LanguageManager())
}