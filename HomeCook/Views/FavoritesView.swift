//
//  FavoritesView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var favoriteManager = FavoriteManager.shared
    
    // 添加ID用于强制刷新视图
    @State private var id = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 美化的Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.myFavorites)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(LocalizedStrings.favoriteCount(favoriteManager.favoriteVideos.count))
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 收藏列表
                    if favoriteManager.favoriteVideos.isEmpty {
                        // 空状态
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(LocalizedStrings.noFavorites)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(LocalizedStrings.noFavoritesDescription)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 60)
                    } else {
                        // 收藏视频列表
                        LazyVStack(spacing: 16) {
                            ForEach(favoriteManager.favoriteVideos) { favoriteItem in
                                FavoriteVideoCard(favoriteItem: favoriteItem)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .padding(.top, 1)
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
                self.id = UUID()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .id(id)
    }
}

// 收藏视频卡片组件
struct FavoriteVideoCard: View {
    let favoriteItem: FavoriteVideoItem
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var favoriteManager = FavoriteManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部标题和收藏按钮区域
            HStack(alignment: .top, spacing: 12) {
                // 左侧视频信息
                VStack(alignment: .leading, spacing: 8) {
                    // 频道信息
                    HStack(spacing: 6) {
                        Image(systemName: "tv.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(favoriteItem.channelTitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 视频标题
                    Text(favoriteItem.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // 播放量和收藏时间
                    HStack(spacing: 12) {
                        // 播放量
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            
                            Text("\(favoriteItem.formattedViewCount) \(LocalizedStrings.views)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        // 收藏时间
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text(favoriteItem.formattedFavoriteTime(language: languageManager.currentLanguage))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // 右侧收藏按钮
                Button(action: {
                    // 创建YouTubeVideo对象来调用收藏功能
                    let video = YouTubeVideo(
                        id: favoriteItem.videoId,
                        title: favoriteItem.title,
                        description: favoriteItem.description,
                        thumbnailURL: favoriteItem.thumbnailURL,
                        channelTitle: favoriteItem.channelTitle,
                        publishedAt: favoriteItem.favoriteDate.ISO8601Format(),
                        duration: favoriteItem.duration,
                        likeCount: favoriteItem.likeCount,
                        viewCount: favoriteItem.viewCount
                    )
                    favoriteManager.removeFromFavorites(video)
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // 视频缩略图和播放按钮
            Button(action: {
                openYouTubeVideo()
            }) {
                ZStack {
                    AsyncImage(url: URL(string: favoriteItem.thumbnailURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(16/9, contentMode: .fill)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            )
                    }
                    .clipped()
                    .cornerRadius(12)
                    
                    // 播放按钮覆盖层
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    // YouTube标识
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                
                                Text("YouTube")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.95))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                        }
                        Spacer()
                        
                        // 底部观看提示
                        HStack {
                            Spacer()
                            Text("点击观看")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.7))
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                )
                            Spacer()
                        }
                    }
                    .padding(12)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // 打开YouTube视频
    private func openYouTubeVideo() {
        let youtubeURL = "https://www.youtube.com/watch?v=\(favoriteItem.videoId)"
        
        if let url = URL(string: youtubeURL) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(LanguageManager())
}