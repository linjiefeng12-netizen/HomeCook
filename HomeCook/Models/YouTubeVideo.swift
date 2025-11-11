//
//  YouTubeVideo.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import Foundation

// YouTube视频数据模型
struct YouTubeVideo: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let channelTitle: String
    let publishedAt: String
    let duration: String?
    let likeCount: Int
    let viewCount: Int
    
    // 生成YouTube视频URL
    var videoURL: String {
        return "https://www.youtube.com/watch?v=\(id)"
    }
    
    // 生成嵌入式播放器URL
    var embedURL: String {
        return "https://www.youtube.com/embed/\(id)"
    }
    
    // 格式化点赞数显示
    var formattedLikeCount: String {
        if likeCount >= 1000000 {
            return String(format: "%.1fM", Double(likeCount) / 1000000.0)
        } else if likeCount >= 1000 {
            return String(format: "%.1fK", Double(likeCount) / 1000.0)
        } else {
            return "\(likeCount)"
        }
    }
    
    // 格式化播放量显示
    var formattedViewCount: String {
        if viewCount >= 1000000 {
            return String(format: "%.1fM", Double(viewCount) / 1000000.0)
        } else if viewCount >= 1000 {
            return String(format: "%.1fK", Double(viewCount) / 1000.0)
        } else {
            return "\(viewCount)"
        }
    }
}

// YouTube搜索响应模型
struct YouTubeSearchResponse: Codable {
    let items: [YouTubeVideoItem]
}

struct YouTubeVideoItem: Codable {
    let id: YouTubeVideoId
    let snippet: YouTubeVideoSnippet
}

struct YouTubeVideoId: Codable {
    let videoId: String
}

struct YouTubeVideoSnippet: Codable {
    let title: String
    let description: String
    let thumbnails: YouTubeThumbnails
    let channelTitle: String
    let publishedAt: String
}

struct YouTubeThumbnails: Codable {
    let medium: YouTubeThumbnail
}

struct YouTubeThumbnail: Codable {
    let url: String
}

// YouTube视频详细信息响应模型
struct YouTubeVideoDetailsResponse: Codable {
    let items: [YouTubeVideoDetailsItem]
}

struct YouTubeVideoDetailsItem: Codable {
    let id: String
    let snippet: YouTubeVideoSnippet
    let statistics: YouTubeVideoStatistics
    let contentDetails: YouTubeVideoContentDetails
}

struct YouTubeVideoStatistics: Codable {
    let viewCount: String?
    let likeCount: String?
    let commentCount: String?
}

struct YouTubeVideoContentDetails: Codable {
    let duration: String
}
