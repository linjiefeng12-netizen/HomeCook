//
//  FavoriteManager.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import Foundation
import SwiftUI

// 收藏的视频项目
struct FavoriteVideoItem: Identifiable, Codable {
    let id: UUID
    let videoId: String
    let title: String
    let description: String
    let thumbnailURL: String
    let channelTitle: String
    let duration: String?
    let likeCount: Int
    let viewCount: Int
    let favoriteDate: Date
    
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
        self.favoriteDate = Date()
    }
    
    // 格式化播放量
    var formattedViewCount: String {
        if viewCount >= 1000000 {
            return String(format: "%.1fM", Double(viewCount) / 1000000.0)
        } else if viewCount >= 1000 {
            return String(format: "%.1fK", Double(viewCount) / 1000.0)
        } else {
            return "\(viewCount)"
        }
    }
    
    // 格式化收藏时间
    func formattedFavoriteTime(language: String) -> String {
        let formatter = DateFormatter()
        
        switch language {
        case "zh-Hans":
            formatter.dateFormat = "MM月dd日"
        case "en":
            formatter.dateFormat = "MMM dd"
            formatter.locale = Locale(identifier: "en")
        case "de":
            formatter.dateFormat = "dd. MMM"
            formatter.locale = Locale(identifier: "de")
        case "es":
            formatter.dateFormat = "dd MMM"
            formatter.locale = Locale(identifier: "es")
        case "ja":
            formatter.dateFormat = "MM月dd日"
            formatter.locale = Locale(identifier: "ja")
        case "ko":
            formatter.dateFormat = "MM월 dd일"
            formatter.locale = Locale(identifier: "ko")
        case "fr":
            formatter.dateFormat = "dd MMM"
            formatter.locale = Locale(identifier: "fr")
        case "ru":
            formatter.dateFormat = "dd MMM"
            formatter.locale = Locale(identifier: "ru")
        default:
            formatter.dateFormat = "MMM dd"
            formatter.locale = Locale(identifier: "en")
        }
        
        return formatter.string(from: favoriteDate)
    }
}

// 收藏管理器
class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    
    @Published var favoriteVideos: [FavoriteVideoItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteVideos"
    
    private init() {
        loadFavorites()
    }
    
    // 加载收藏列表
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: favoritesKey) {
            do {
                let decoder = JSONDecoder()
                favoriteVideos = try decoder.decode([FavoriteVideoItem].self, from: data)
                print("成功加载 \(favoriteVideos.count) 个收藏视频")
            } catch {
                print("加载收藏列表失败: \(error)")
                favoriteVideos = []
            }
        }
    }
    
    // 保存收藏列表
    private func saveFavorites() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favoriteVideos)
            userDefaults.set(data, forKey: favoritesKey)
            print("成功保存 \(favoriteVideos.count) 个收藏视频")
        } catch {
            print("保存收藏列表失败: \(error)")
        }
    }
    
    // 检查视频是否已收藏
    func isFavorite(_ video: YouTubeVideo) -> Bool {
        return favoriteVideos.contains { $0.videoId == video.id }
    }
    
    // 添加到收藏
    func addToFavorites(_ video: YouTubeVideo) {
        // 检查是否已经收藏
        if !isFavorite(video) {
            let favoriteItem = FavoriteVideoItem(from: video)
            favoriteVideos.insert(favoriteItem, at: 0) // 插入到开头
            saveFavorites()
            
            // 发送通知
            NotificationCenter.default.post(name: NSNotification.Name("VideoFavorited"), object: video.id)
        }
    }
    
    // 从收藏中移除
    func removeFromFavorites(_ video: YouTubeVideo) {
        favoriteVideos.removeAll { $0.videoId == video.id }
        saveFavorites()
        
        // 发送通知
        NotificationCenter.default.post(name: NSNotification.Name("VideoUnfavorited"), object: video.id)
    }
    
    // 切换收藏状态
    func toggleFavorite(_ video: YouTubeVideo) {
        if isFavorite(video) {
            removeFromFavorites(video)
        } else {
            addToFavorites(video)
        }
    }
    
    // 获取收藏列表
    func getFavoriteVideos() -> [FavoriteVideoItem] {
        return favoriteVideos
    }
    
    // 清空收藏列表
    func clearAllFavorites() {
        favoriteVideos.removeAll()
        saveFavorites()
    }
}