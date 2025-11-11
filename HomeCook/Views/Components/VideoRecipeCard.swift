//
//  VideoRecipeCard.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI
import UIKit

// 带有YouTube视频预览的食谱卡片
struct VideoRecipeCard: View {
    let video: YouTubeVideo
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var showFavoriteToast = false
    @State private var favoriteToastMessage = ""
    
    var body: some View {
        ZStack {
            // 主要卡片内容
            HStack(spacing: 16) {
                // 左侧内容
                VStack(alignment: .leading, spacing: 8) {
                    // 频道信息
                    HStack(spacing: 6) {
                        Image(systemName: "tv.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(video.channelTitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 视频标题
                    Text(video.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // 视频描述
                    Text(video.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    // 时长、播放量和点赞信息
                    HStack(spacing: 12) {
                        if let duration = video.duration {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                
                                Text(duration)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // 播放量信息
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                            
                            Text(video.formattedViewCount)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        // 点赞数信息
                        HStack(spacing: 4) {
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                            
                            Text(video.formattedLikeCount)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                // 右侧视频预览区域（移除了收藏按钮）
                Button(action: {
                    openYouTubeVideo()
                }) {
                    ZStack {
                        // 缩略图背景
                        AsyncImage(url: URL(string: video.thumbnailURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .frame(width: 120, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // 只保留播放按钮
                        Button(action: {
                            openYouTubeVideo()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.7))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // YouTube标识和提示
                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 2) {
                                    Image(systemName: "play.rectangle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                    
                                    Text("YouTube")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.red)
                                }
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.95))
                                )
                            }
                            Spacer()
                            
                            // 底部提示
                            HStack {
                                Spacer()
                                Text("点击观看")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.7))
                                    )
                                Spacer()
                            }
                        }
                        .padding(6)
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // 外部收藏按钮 - 位于卡片右上角外部
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        toggleFavorite()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: favoriteManager.isFavorite(video) ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(favoriteManager.isFavorite(video) ? .red : .gray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: 8, y: -8) // 向右上角偏移
                }
                Spacer()
            }
            
            // 收藏提示Toast
            VStack {
                if showFavoriteToast {
                    HStack(spacing: 8) {
                        Image(systemName: favoriteManager.isFavorite(video) ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(favoriteManager.isFavorite(video) ? .red : .gray)
                        
                        Text(favoriteToastMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showFavoriteToast)
                }
                Spacer()
            }
            .padding(.top, 8)
        }
    }
    
    // 直接打开YouTube视频
    // 切换收藏状态
    private func toggleFavorite() {
        favoriteManager.toggleFavorite(video)
        
        // 设置提示消息
        let currentLanguage = languageManager.currentLanguage
        if favoriteManager.isFavorite(video) {
            favoriteToastMessage = getFavoriteMessage(for: currentLanguage, isFavorited: true)
        } else {
            favoriteToastMessage = getFavoriteMessage(for: currentLanguage, isFavorited: false)
        }
        
        // 显示提示
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showFavoriteToast = true
        }
        
        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showFavoriteToast = false
            }
        }
        
        // 添加触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // 获取收藏提示消息
    private func getFavoriteMessage(for language: String, isFavorited: Bool) -> String {
        switch language {
        case "zh-Hans":
            return isFavorited ? "已收藏" : "已取消收藏"
        case "en":
            return isFavorited ? "Favorited" : "Unfavorited"
        case "de":
            return isFavorited ? "Favorisiert" : "Nicht mehr favorisiert"
        case "es":
            return isFavorited ? "Favorito" : "No favorito"
        case "ja":
            return isFavorited ? "お気に入りに追加" : "お気に入りから削除"
        case "ko":
            return isFavorited ? "즐겨찾기에 추가됨" : "즐겨찾기에서 제거됨"
        case "fr":
            return isFavorited ? "Ajouté aux favoris" : "Retiré des favoris"
        case "ru":
            return isFavorited ? "Добавлено в избранное" : "Удалено из избранного"
        default:
            return isFavorited ? "Favorited" : "Unfavorited"
        }
    }
    
    // 直接打开YouTube视频
    private func openYouTubeVideo() {
        // 记录到观看历史
        HistoryManager.shared.addVideoToHistory(video)
        
        // 首先尝试打开YouTube应用
        if let youtubeAppURL = URL(string: "youtube://watch?v=\(video.id)"),
           UIApplication.shared.canOpenURL(youtubeAppURL) {
            UIApplication.shared.open(youtubeAppURL)
        } else if let youtubeWebURL = URL(string: video.videoURL) {
            // 如果YouTube应用不可用，则在Safari中打开
            UIApplication.shared.open(youtubeWebURL)
        }
    }
}


#Preview {
    VideoRecipeCard(video: YouTubeVideo(
        id: "dQw4w9WgXcQ",
        title: "美味土豆炖猪肉 - 家常菜制作教程",
        description: "学习如何制作经典的土豆炖猪肉，简单易学的家常菜谱。使用烤箱烹饪，口感更佳。",
        thumbnailURL: "https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg",
        channelTitle: "美食厨房",
        publishedAt: "2024-01-15T10:30:00Z",
        duration: "12:45",
        likeCount: 125000,
        viewCount: 850000
    ))
    .padding()
}
