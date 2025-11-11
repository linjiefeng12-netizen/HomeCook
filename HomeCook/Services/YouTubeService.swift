//
//  YouTubeService.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import Foundation

class YouTubeService: ObservableObject {
    static let shared = YouTubeService()
    
    // YouTube Data API配置
    // 注意：您需要从Google Cloud Console获取YouTube Data API密钥
    private let apiKey = "AIzaSyClg2PfN8sDmxijNudJszFTxYsFsbkonWE" // 请替换为真实的API密钥
    private let baseURL = "https://www.googleapis.com/youtube/v3/search"
    
    @Published var isLoading = false
    @Published var videos: [YouTubeVideo] = []
    @Published var errorMessage: String?
    
    private init() {}
    
    // 搜索YouTube视频（用于Home页面）- 支持排列组合搜索
    func searchVideos(ingredients: [String], kitchenware: [String]) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // 获取当前语言设置
        let currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        // 分离蔬菜和肉类
        let vegetables = ingredients.filter { vegetableIngredientKeys.contains($0) }
        let meats = ingredients.filter { meatIngredientKeys.contains($0) }
        let otherIngredients = ingredients.filter { !vegetableIngredientKeys.contains($0) && !meatIngredientKeys.contains($0) }
        
        do {
            let finalVideos: [YouTubeVideo]
            
            // 如果有蔬菜和肉类，进行排列组合搜索
            if !vegetables.isEmpty && !meats.isEmpty {
                let combinations = generateCombinations(vegetables: vegetables, meats: meats)
                let maxVideosPerCombination = combinations.count < 4 ? 2 : 1
                
                // 使用 withThrowingTaskGroup 来安全地处理并发搜索
                finalVideos = try await withThrowingTaskGroup(of: [YouTubeVideo].self, returning: [YouTubeVideo].self) { group in
                    // 为每个组合添加搜索任务
                    for combination in combinations {
                        group.addTask {
                            let combinedIngredients = combination + otherIngredients
                            let searchQuery = self.buildSearchQuery(ingredients: combinedIngredients, kitchenware: kitchenware, language: currentLanguage)
                            
                            // 为每个组合搜索视频
                            return try await self.performCombinationAPICall(
                                query: searchQuery, 
                                language: currentLanguage,
                                maxVideos: maxVideosPerCombination
                            )
                        }
                    }
                    
                    // 收集所有结果
                    var combinedResults: [YouTubeVideo] = []
                    for try await combinationVideos in group {
                        combinedResults.append(contentsOf: combinationVideos)
                    }
                    
                    return combinedResults
                }
            } else {
                // 如果没有蔬菜和肉类的组合，使用原有搜索方式
                let searchQuery = buildSearchQuery(ingredients: ingredients, kitchenware: kitchenware, language: currentLanguage)
                finalVideos = try await performRealAPICall(query: searchQuery, language: currentLanguage)
            }
            
            await MainActor.run {
                self.videos = finalVideos
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.videos = []
                self.isLoading = false
            }
        }
    }
    
    // 生成蔬菜和肉类的排列组合
    private func generateCombinations(vegetables: [String], meats: [String]) -> [[String]] {
        var combinations: [[String]] = []
        
        for vegetable in vegetables {
            for meat in meats {
                combinations.append([vegetable, meat])
            }
        }
        
        return combinations
    }
    
    // 蔬菜食材键列表
    private let vegetableIngredientKeys = [
        "potato", "carrot", "tomato", "onion", "green_pepper", 
        "eggplant", "spinach", "cucumber", "sweet_corn", "celery", 
        "cauliflower", "broccoli", "bitter_melon", "pumpkin", "lotus_root", 
        "mushrooms", "enoki_mushrooms", "shiitake_mushrooms", "oyster_mushrooms", "king_oyster_mushrooms"
    ]
    
    // 肉类食材键列表
    private let meatIngredientKeys = [
        "sausage", "pork", "beef", "eggs", "fish", "shrimp", 
        "chicken", "lamb", "duck", "goose", "offal", "tripe"
    ]
    
    // 搜索热门视频（用于Flavor Gacha）
    func searchTrendingVideos(ingredients: [String], maxResults: Int) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // 获取当前语言设置
        let currentLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        // 构建搜索查询
        let searchQuery = buildGachaSearchQuery(ingredients: ingredients, language: currentLanguage)
        
        do {
            // 尝试真实的API调用
            let trendingVideos = try await performTrendingAPICall(query: searchQuery, language: currentLanguage, maxResults: maxResults)
            await MainActor.run {
                self.videos = trendingVideos
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.videos = []
                self.isLoading = false
            }
        }
    }
    
    // 构建搜索查询字符串（用于Home页面）
    private func buildSearchQuery(ingredients: [String], kitchenware: [String], language: String) -> String {
        var queryParts: [String] = []
        
        // 添加食材到搜索查询
        if !ingredients.isEmpty {
            let ingredientNames = ingredients.map { LocalizationManager.shared.localizedString(for: $0) }
            queryParts.append(ingredientNames.joined(separator: " "))
        }
        
        // 添加厨具到搜索查询
        if !kitchenware.isEmpty {
            let kitchenwareNames = kitchenware.map { LocalizationManager.shared.localizedString(for: $0) }
            queryParts.append(kitchenwareNames.joined(separator: " "))
        }
        
        // 根据语言添加相应的烹饪关键词
        let cookingKeywords = getCookingKeywords(for: language)
        queryParts.append(cookingKeywords)
        
        return queryParts.joined(separator: " ")
    }
    
    // 构建Gacha搜索查询（用于Flavor Gacha）
    private func buildGachaSearchQuery(ingredients: [String], language: String) -> String {
        var queryParts: [String] = []
        
        // 添加食材到搜索查询
        if !ingredients.isEmpty {
            let ingredientNames = ingredients.map { LocalizationManager.shared.localizedString(for: $0) }
            queryParts.append(ingredientNames.joined(separator: " "))
        }
        
        // 根据语言添加相应的烹饪关键词
        let cookingKeywords = getCookingKeywords(for: language)
        queryParts.append(cookingKeywords)
        
        return queryParts.joined(separator: " ")
    }
    
    // 根据语言获取烹饪关键词
    private func getCookingKeywords(for language: String) -> String {
        switch language {
        case "en":
            return "recipe cooking tutorial how to cook"
        case "zh-Hans":
            return "食谱 烹饪 教程 怎么做 制作方法"
        case "ja":
            return "レシピ 料理 作り方 クッキング チュートリアル"
        case "ko":
            return "레시피 요리 만들기 쿠킹 튜토리얼"
        case "de":
            return "rezept kochen anleitung wie man kocht"
        case "es":
            return "receta cocinar tutorial cómo cocinar"
        case "fr":
            return "recette cuisine tutoriel comment cuisiner"
        case "ru":
            return "рецепт готовить урок как готовить"
        default:
            return "recipe cooking tutorial"
        }
    }
    
    // 实际的YouTube API调用实现（用于Home页面）
    private func performRealAPICall(query: String, language: String) async throws -> [YouTubeVideo] {
        guard !apiKey.isEmpty else {
            throw YouTubeError.invalidAPIKey
        }
        
        // 第一步：搜索视频
        let searchVideos = try await searchYouTubeVideos(query: query, language: language)
        
        // 第二步：获取视频详细信息和统计数据
        let videoIds = searchVideos.map { $0.id }.joined(separator: ",")
        let videosWithStats = try await getVideoDetails(videoIds: videoIds)
        
        // 第三步：按点赞数排序并返回前6个
        return Array(videosWithStats.sorted { $0.likeCount > $1.likeCount }.prefix(6))
    }
    
    // 排列组合搜索的API调用实现
    private func performCombinationAPICall(query: String, language: String, maxVideos: Int) async throws -> [YouTubeVideo] {
        guard !apiKey.isEmpty else {
            throw YouTubeError.invalidAPIKey
        }
        
        // 第一步：尝试搜索最近半年视频
        let recentVideos = try await searchMonthlyVideos(query: query, language: language, maxResults: maxVideos * 3)
        
        // 如果最近半年视频不足，回退到常规搜索
        if recentVideos.isEmpty {
            print("最近半年视频搜索结果为空，回退到常规搜索: \(query)")
            return try await performRealAPICall(query: query, language: language)
        }
        
        // 第二步：获取视频详细信息和统计数据
        let videoIds = recentVideos.map { $0.id }.joined(separator: ",")
        let videosWithStats = try await getVideoDetails(videoIds: videoIds)
        
        // 如果获取详细信息后仍然为空，回退到常规搜索
        if videosWithStats.isEmpty {
            print("最近半年视频详细信息为空，回退到常规搜索: \(query)")
            return try await performRealAPICall(query: query, language: language)
        }
        
        // 第三步：按最近半年点赞数排序并返回指定数量
        let sortedVideos = videosWithStats.sorted { $0.likeCount > $1.likeCount }
        let finalVideos = Array(sortedVideos.prefix(maxVideos))
        
        // 如果结果仍然不足，回退到常规搜索
        if finalVideos.count < maxVideos {
            print("最近半年视频数量不足(\(finalVideos.count)/\(maxVideos))，回退到常规搜索: \(query)")
            return try await performRealAPICall(query: query, language: language)
        }
        
        return finalVideos
    }
    
    // 搜索最近半年热门视频
    private func searchMonthlyVideos(query: String, language: String, maxResults: Int) async throws -> [YouTubeVideo] {
        let (regionCode, relevanceLanguage) = getRegionAndLanguage(for: language)
        
        // 计算半年前的日期
        let calendar = Calendar.current
        let now = Date()
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        let dateFormatter = ISO8601DateFormatter()
        let publishedAfter = dateFormatter.string(from: sixMonthsAgo)
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "order", value: "relevance"), // 按相关性排序
            URLQueryItem(name: "publishedAfter", value: publishedAfter), // 最近半年发布
            URLQueryItem(name: "regionCode", value: regionCode),
            URLQueryItem(name: "relevanceLanguage", value: relevanceLanguage),
            URLQueryItem(name: "videoDuration", value: "medium"), // 中等时长视频
            URLQueryItem(name: "videoDefinition", value: "high"), // 高清视频
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw YouTubeError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw YouTubeError.networkError
            }
        }
        
        let searchResponse = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
        
        return searchResponse.items.map { item in
            YouTubeVideo(
                id: item.id.videoId,
                title: cleanTitle(item.snippet.title),
                description: cleanDescription(item.snippet.description),
                thumbnailURL: item.snippet.thumbnails.medium.url,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                duration: nil,
                likeCount: 0, // 将在下一步获取
                viewCount: 0 // 将在下一步获取
            )
        }
    }
    
    // 执行热门视频API调用（用于Flavor Gacha）
    private func performTrendingAPICall(query: String, language: String, maxResults: Int) async throws -> [YouTubeVideo] {
        guard !apiKey.isEmpty else {
            throw YouTubeError.invalidAPIKey
        }
        
        // 第一步：搜索视频，获取更多结果确保有足够的视频
        let searchVideos = try await searchTrendingYouTubeVideos(query: query, language: language, maxResults: max(maxResults * 3, 20)) // 获取至少3倍或20个结果
        
        // 第二步：获取视频详细信息和统计数据
        let videoIds = searchVideos.map { $0.id }.joined(separator: ",")
        let videosWithStats = try await getVideoDetails(videoIds: videoIds)
        
        // 第三步：按播放量排序并返回指定数量的视频
        let sortedVideos = videosWithStats.sorted { $0.viewCount > $1.viewCount }
        
        // 确保返回足够的视频数量
        if sortedVideos.count >= maxResults {
            return Array(sortedVideos.prefix(maxResults))
        } else {
            // 如果搜索结果不足，尝试不限制发布时间再次搜索
            let fallbackVideos = try await searchFallbackVideos(query: query, language: language, maxResults: maxResults)
            return fallbackVideos
        }
    }
    
    // 搜索YouTube视频（用于Home页面）
    private func searchYouTubeVideos(query: String, language: String) async throws -> [YouTubeVideo] {
        let (regionCode, relevanceLanguage) = getRegionAndLanguage(for: language)
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "20"), // 先获取更多结果用于筛选
            URLQueryItem(name: "order", value: "relevance"), // 按相关性排序
            URLQueryItem(name: "regionCode", value: regionCode),
            URLQueryItem(name: "relevanceLanguage", value: relevanceLanguage),
            URLQueryItem(name: "videoDuration", value: "medium"), // 中等时长视频
            URLQueryItem(name: "videoDefinition", value: "high"), // 高清视频
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw YouTubeError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw YouTubeError.networkError
            }
        }
        
        let searchResponse = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
        
        return searchResponse.items.map { item in
            YouTubeVideo(
                id: item.id.videoId,
                title: cleanTitle(item.snippet.title),
                description: cleanDescription(item.snippet.description),
                thumbnailURL: item.snippet.thumbnails.medium.url,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                duration: nil,
                likeCount: 0, // 将在下一步获取
                viewCount: 0 // 将在下一步获取
            )
        }
    }
    
    // 搜索热门YouTube视频（用于Flavor Gacha）
    private func searchTrendingYouTubeVideos(query: String, language: String, maxResults: Int) async throws -> [YouTubeVideo] {
        let (regionCode, relevanceLanguage) = getRegionAndLanguage(for: language)
        
        // 计算一个月前的日期
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let dateFormatter = ISO8601DateFormatter()
        let publishedAfter = dateFormatter.string(from: oneMonthAgo)
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "order", value: "viewCount"), // 按播放量排序
            URLQueryItem(name: "publishedAfter", value: publishedAfter), // 近一个月内
            URLQueryItem(name: "regionCode", value: regionCode),
            URLQueryItem(name: "relevanceLanguage", value: relevanceLanguage),
            URLQueryItem(name: "videoDuration", value: "medium"), // 中等时长视频
            URLQueryItem(name: "videoDefinition", value: "high"), // 高清视频
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw YouTubeError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw YouTubeError.networkError
            }
        }
        
        let searchResponse = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
        
        return searchResponse.items.map { item in
            YouTubeVideo(
                id: item.id.videoId,
                title: cleanTitle(item.snippet.title),
                description: cleanDescription(item.snippet.description),
                thumbnailURL: item.snippet.thumbnails.medium.url,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                duration: nil,
                likeCount: 0, // 将在下一步获取
                viewCount: 0 // 将在下一步获取
            )
        }
    }
    
    // 备用搜索方法（不限制发布时间）
    private func searchFallbackVideos(query: String, language: String, maxResults: Int) async throws -> [YouTubeVideo] {
        let (regionCode, relevanceLanguage) = getRegionAndLanguage(for: language)
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "maxResults", value: "\(maxResults * 2)"), // 获取更多结果
            URLQueryItem(name: "order", value: "viewCount"), // 按播放量排序
            URLQueryItem(name: "regionCode", value: regionCode),
            URLQueryItem(name: "relevanceLanguage", value: relevanceLanguage),
            URLQueryItem(name: "videoDuration", value: "medium"), // 中等时长视频
            URLQueryItem(name: "videoDefinition", value: "high"), // 高清视频
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw YouTubeError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw YouTubeError.networkError
            }
        }
        
        let searchResponse = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
        
        let searchVideos = searchResponse.items.map { item in
            YouTubeVideo(
                id: item.id.videoId,
                title: cleanTitle(item.snippet.title),
                description: cleanDescription(item.snippet.description),
                thumbnailURL: item.snippet.thumbnails.medium.url,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                duration: nil,
                likeCount: 0, // 将在下一步获取
                viewCount: 0 // 将在下一步获取
            )
        }
        
        // 获取视频详细信息
        let videoIds = searchVideos.map { $0.id }.joined(separator: ",")
        let videosWithStats = try await getVideoDetails(videoIds: videoIds)
        
        // 按播放量排序并返回指定数量
        let sortedVideos = videosWithStats.sorted { $0.viewCount > $1.viewCount }
        return Array(sortedVideos.prefix(maxResults))
    }
    
    // 获取视频详细信息和统计数据
    private func getVideoDetails(videoIds: String) async throws -> [YouTubeVideo] {
        let detailsURL = "https://www.googleapis.com/youtube/v3/videos"
        
        var components = URLComponents(string: detailsURL)!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet,statistics,contentDetails"),
            URLQueryItem(name: "id", value: videoIds),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw YouTubeError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw YouTubeError.networkError
            }
        }
        
        let detailsResponse = try JSONDecoder().decode(YouTubeVideoDetailsResponse.self, from: data)
        
        return detailsResponse.items.map { item in
            YouTubeVideo(
                id: item.id,
                title: cleanTitle(item.snippet.title),
                description: cleanDescription(item.snippet.description),
                thumbnailURL: item.snippet.thumbnails.medium.url,
                channelTitle: item.snippet.channelTitle,
                publishedAt: item.snippet.publishedAt,
                duration: formatDuration(item.contentDetails.duration),
                likeCount: Int(item.statistics.likeCount ?? "0") ?? 0,
                viewCount: Int(item.statistics.viewCount ?? "0") ?? 0
            )
        }
    }
    
    // 格式化视频时长
    private func formatDuration(_ duration: String) -> String {
        // YouTube API返回的时长格式为 PT4M13S (4分13秒)
        let pattern = "PT(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+)S)?"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = duration as NSString
        let results = regex?.firstMatch(in: duration, range: NSRange(location: 0, length: nsString.length))
        
        var hours = 0
        var minutes = 0
        var seconds = 0
        
        if let results = results {
            if results.range(at: 1).location != NSNotFound {
                hours = Int(nsString.substring(with: results.range(at: 1))) ?? 0
            }
            if results.range(at: 2).location != NSNotFound {
                minutes = Int(nsString.substring(with: results.range(at: 2))) ?? 0
            }
            if results.range(at: 3).location != NSNotFound {
                seconds = Int(nsString.substring(with: results.range(at: 3))) ?? 0
            }
        }
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // 清理视频标题
    private func cleanTitle(_ title: String) -> String {
        // 移除HTML实体编码
        return title
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
    }
    
    // 清理视频描述
    private func cleanDescription(_ description: String) -> String {
        // 限制描述长度并清理HTML实体编码
        let cleanedDescription = description
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
        
        // 限制描述长度为200个字符
        if cleanedDescription.count > 200 {
            let index = cleanedDescription.index(cleanedDescription.startIndex, offsetBy: 200)
            return String(cleanedDescription[..<index]) + "..."
        }
        
        return cleanedDescription
    }
    
    // 根据语言获取区域代码和语言代码
    private func getRegionAndLanguage(for language: String) -> (regionCode: String, relevanceLanguage: String) {
        switch language {
        case "en":
            return ("US", "en")
        case "zh-Hans":
            return ("CN", "zh")
        case "ja":
            return ("JP", "ja")
        case "ko":
            return ("KR", "ko")
        case "de":
            return ("DE", "de")
        case "es":
            return ("ES", "es")
        case "fr":
            return ("FR", "fr")
        case "ru":
            return ("RU", "ru")
        default:
            return ("US", "en")
        }
    }
}

// YouTube服务错误类型
enum YouTubeError: Error, LocalizedError {
    case invalidAPIKey
    case invalidURL
    case networkError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "无效的YouTube API密钥，请检查配置"
        case .invalidURL:
            return "无效的请求URL"
        case .networkError:
            return "网络连接错误，请检查网络连接"
        case .decodingError:
            return "数据解析错误，请稍后重试"
        }
    }
}