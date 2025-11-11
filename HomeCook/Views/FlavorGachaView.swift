//
//  FlavorGachaView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

struct FlavorGachaView: View {
    @State private var servings: Int = 4
    @State private var selectedRecipes: [GachaRecipe] = []
    @State private var isAnimating = false
    @State private var showingVideoResults = false
    @State private var isSearching = false // 添加搜索状态
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var youtubeService = YouTubeService.shared
    
    // 添加ID用于强制刷新视图
    @State private var id = UUID()
    
    // 获取安全区域高度
    @State private var safeAreaTop: CGFloat = 0
    
    let sampleRecipes: [GachaRecipe] = [
        GachaRecipe(nameKey: "pasta_carbonara", imageName: "pasta", categoryKey: "staple_foods"),
        GachaRecipe(nameKey: "mediterranean_salad", imageName: "salad", categoryKey: "vegetables"),
        GachaRecipe(nameKey: "tomato_soup", imageName: "soup", categoryKey: "vegetables"),
        GachaRecipe(nameKey: "chocolate_mousse", imageName: "dessert", categoryKey: "dessert"),
        GachaRecipe(nameKey: "grilled_salmon", imageName: "fish", categoryKey: "meats"),
        GachaRecipe(nameKey: "beef_stir_fry", imageName: "beef", categoryKey: "meats"),
        GachaRecipe(nameKey: "chicken_curry", imageName: "chicken", categoryKey: "meats"),
        GachaRecipe(nameKey: "vegetable_stew", imageName: "stew", categoryKey: "vegetables"),
        GachaRecipe(nameKey: "rice_pudding", imageName: "rice", categoryKey: "staple_foods"),
        GachaRecipe(nameKey: "apple_pie", imageName: "pie", categoryKey: "dessert"),
        GachaRecipe(nameKey: "mushroom_risotto", imageName: "risotto", categoryKey: "staple_foods"),
        GachaRecipe(nameKey: "caesar_salad", imageName: "salad", categoryKey: "vegetables"),
        GachaRecipe(nameKey: "beef_burger", imageName: "burger", categoryKey: "meats"),
        GachaRecipe(nameKey: "fish_tacos", imageName: "tacos", categoryKey: "meats"),
        GachaRecipe(nameKey: "vegetable_lasagna", imageName: "lasagna", categoryKey: "staple_foods"),
        GachaRecipe(nameKey: "chicken_soup", imageName: "soup", categoryKey: "meats"),
        GachaRecipe(nameKey: "fruit_salad", imageName: "fruit", categoryKey: "dessert"),
        GachaRecipe(nameKey: "pork_chops", imageName: "pork", categoryKey: "meats"),
        GachaRecipe(nameKey: "quinoa_bowl", imageName: "quinoa", categoryKey: "staple_foods"),
        GachaRecipe(nameKey: "shrimp_scampi", imageName: "shrimp", categoryKey: "meats")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .top) {
                    // 背景色
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // 添加顶部安全区域间距，确保内容不会叠加到状态栏
                            Color.clear.frame(height: safeAreaTop + 20)
                            
                            VStack(spacing: 20) {
                                // Header
                                Text(LocalizedStrings.flavorGacha)
                                    .font(.title)
                                    .fontWeight(.bold)
                        
                                // Servings Selector
                                VStack(spacing: 16) {
                                    // 美化后的份数选择器
                                    HStack {
                                        Text(LocalizedStrings.servings)
                                            .font(.headline)
                                            .fontWeight(.medium)
                                        
                                        Spacer()
                                        
                                        // 美化后的加减控制器
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                if servings > 1 {
                                                    servings -= 1
                                                    hapticFeedback()
                                                }
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.orange)
                                            }
                                            
                                            // 添加数值显示
                                            Text("\(servings)")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .frame(minWidth: 36)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.orange.opacity(0.15))
                                                )
                                            
                                            Button(action: {
                                                if servings < 10 {
                                                    servings += 1
                                                    hapticFeedback()
                                                }
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    )
                                    .padding(.horizontal, 16)
                                    
                                    // Random Match Button
                                    Button(action: randomMatch) {
                                        HStack {
                                            Image(systemName: "dice.fill")
                                                .font(.headline)
                                            
                                            Text(LocalizedStrings.randomMatch)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                        .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 3)
                                    }
                                    .padding(.horizontal, 16)
                                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.1), value: isAnimating)
                                }
                                
                                // Recipes Section
                                VStack(alignment: .leading, spacing: 15) {
                                    HStack {
                                        Text(LocalizedStrings.recipes)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        if !selectedRecipes.isEmpty {
                                            Text("\(selectedRecipes.count)")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(
                                                    Capsule()
                                                        .fill(Color.orange.opacity(0.2))
                                                )
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    if !showingVideoResults {
                                        if isSearching {
                                            // 搜索中的状态提示
                                            VStack(spacing: 20) {
                                                ProgressView()
                                                    .scaleEffect(1.5)
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                                    .padding(.bottom, 10)
                                                
                                                Text(LocalizedStrings.searchingForRecipes)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 40)
                                                    .animation(.easeInOut(duration: 0.3), value: isSearching)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 200)
                                            .padding(.vertical, 30)
                                        } else {
                                            VStack(spacing: 24) {
                                                Image(systemName: "dice")
                                                    .font(.system(size: 60))
                                                    .foregroundColor(.orange.opacity(0.5))
                                                    .padding()
                                                    .background(
                                                        Circle()
                                                            .fill(Color.orange.opacity(0.1))
                                                            .frame(width: 120, height: 120)
                                                    )
                                                
                                                Text(LocalizedStrings.clickRandomMatch)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 40)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 200)
                                            .padding(.vertical, 30)
                                        }
                                    } else {
                                        // 显示YouTube视频结果
                                        if youtubeService.isLoading {
                                            // 搜索中的状态
                                            VStack(spacing: 12) {
                                                ProgressView()
                                                    .scaleEffect(1.2)
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                                
                                                Text(LocalizedStrings.searchingCookingVideos)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 40)
                                        } else if !youtubeService.videos.isEmpty {
                                            LazyVStack(spacing: 12) {
                                                ForEach(youtubeService.videos) { video in
                                                    VideoRecipeCard(video: video)
                                                        .padding(.horizontal, 16)
                                                }
                                            }
                                        } else {
                                            // 搜索后没有结果的提示
                                            VStack(spacing: 12) {
                                                Image(systemName: "magnifyingglass")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray.opacity(0.6))
                                                
                                                Text(LocalizedStrings.noVideosFound)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                
                                                Text(LocalizedStrings.tryRandomMatchAgain)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.secondary.opacity(0.8))
                                            }
                                            .padding(.vertical, 40)
                                        }
                                    }
                                    
                                    // 错误信息显示
                                    if let errorMessage = youtubeService.errorMessage {
                                        Text(errorMessage)
                                            .font(.system(size: 14))
                                            .foregroundColor(.red)
                                            .padding()
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(8)
                                            .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.top, 10)
                                
                                // 底部安全区域
                                Color.clear.frame(height: 20)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // 顶部安全区域覆盖层，防止内容滚动到状态栏
                    VStack {
                        Rectangle()
                            .fill(Color(.systemGroupedBackground))
                            .frame(height: safeAreaTop)
                            .ignoresSafeArea(.all, edges: .top)
                        Spacer()
                    }
                }
                .id(id) // 使用id强制刷新整个视图
                .navigationBarHidden(true)
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
                    // 收到刷新通知时更新ID，强制刷新视图
                    self.id = UUID()
                    print("FlavorGachaView 收到强制刷新通知，已更新ID")
                }
                .onChange(of: servings) { oldValue, newValue in
                    // 当serving数量改变时，如果已有选中的食谱，重新生成以匹配新数量
                    if !selectedRecipes.isEmpty {
                        let recipeCount = min(newValue, sampleRecipes.count)
                        selectedRecipes = Array(sampleRecipes.shuffled().prefix(recipeCount))
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                // 获取安全区域高度
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                safeAreaTop = window?.safeAreaInsets.top ?? 47 // 默认值为iPhone标准状态栏高度
            }
        }
    }
    
    private func randomMatch() {
        isAnimating = true
        hapticFeedback()
        
        // 重置搜索状态
        showingVideoResults = false
        youtubeService.videos = []
        youtubeService.errorMessage = nil
        
        // 显示搜索中状态
        isSearching = true
        
        // 模拟加载动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
        
        // 随机选择食材进行搜索
        let randomIngredients = getRandomIngredients()
        
        // 搜索YouTube视频
        Task {
            await youtubeService.searchTrendingVideos(
                ingredients: randomIngredients,
                maxResults: servings
            )
            
            // 搜索完成后更新状态
            isSearching = false
            showingVideoResults = true
        }
    }
    
    // 随机选择食材
    private func getRandomIngredients() -> [String] {
        let allIngredients = [
            "potato", "carrot", "tomato", "onion", "chicken", "beef", "pork", 
            "fish", "shrimp", "pasta", "rice", "noodles", "eggs", "mushrooms"
        ]
        
        // 随机选择2-4个食材
        let count = Int.random(in: 2...4)
        return Array(allIngredients.shuffled().prefix(count))
    }
    
    // 添加触觉反馈
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct GachaRecipe: Identifiable {
    let id = UUID()
    let nameKey: String
    let imageName: String
    let categoryKey: String
}

struct RecipeCard: View {
    let recipe: GachaRecipe
    @EnvironmentObject private var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 10) {
            // 美化食谱图片
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.7), Color.orange.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 130)
                
                VStack {
                    Image(systemName: getSystemImageName(for: recipe.imageName))
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                    
                    Text(recipe.imageName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationManager.shared.localizedString(for: recipe.nameKey))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(LocalizationManager.shared.localizedString(for: recipe.categoryKey))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // 根据食谱类型返回对应的系统图标
    private func getSystemImageName(for imageName: String) -> String {
        switch imageName {
        case "pasta":
            return "fork.knife"
        case "salad":
            return "leaf"
        case "soup":
            return "cup.and.saucer"
        case "dessert":
            return "birthday.cake"
        case "fish":
            return "fish"
        case "beef":
            return "flame"
        case "chicken":
            return "bird"
        case "stew":
            return "pot"
        case "rice":
            return "circle.grid.2x2"
        case "pie":
            return "birthday.cake"
        case "risotto":
            return "circle.grid.3x3"
        case "burger":
            return "circle"
        case "tacos":
            return "triangle"
        case "lasagna":
            return "rectangle.stack"
        case "fruit":
            return "applelogo"
        case "pork":
            return "flame.fill"
        case "quinoa":
            return "circle.grid.cross"
        case "shrimp":
            return "seal"
        default:
            return "fork.knife"
        }
    }
}

#Preview {
    FlavorGachaView()
        .environmentObject(LanguageManager())
        .environmentObject(ThemeManager())
}