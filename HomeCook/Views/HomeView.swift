//
//  HomeView.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var youtubeService = YouTubeService.shared
    @State private var selectedIngredients: Set<String> = []
    @State private var selectedKitchenware: Set<String> = []
    @State private var showingVideoResults = false
    @State private var id = UUID() // 添加ID用于强制刷新视图
    
    // 使用本地化键而不是硬编码文本
    let vegetableIngredientKeys = [
        "potato", "carrot", "tomato", "onion", "green_pepper", 
        "eggplant", "spinach", "cucumber", "sweet_corn", "celery", 
        "cauliflower", "broccoli", "bitter_melon", "pumpkin", "lotus_root", 
        "mushrooms", "enoki_mushrooms", "shiitake_mushrooms", "oyster_mushrooms", "king_oyster_mushrooms"
    ]
    
    let meatIngredientKeys = [
        "sausage", "pork", "beef", "eggs", "fish", "shrimp", 
        "chicken", "lamb", "duck", "goose", "offal", "tripe"
    ]
    
    let stapleFoodIngredientKeys = [
        "pasta", "bread", "rice", "noodles", "rice_flour", 
        "grains", "beans", "bean_products", "tubers", "nuts"
    ]
    
    let kitchenwareItemKeys = [
        "oven", "air_fryer", "microwave", "rice_cooker", "versatile_pot"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 美化的Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "fork.knife")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        
                        Text(LocalizedStrings.letsCooking)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // 选择食材部分
                    SectionCard(title: LocalizedStrings.selectIngredients) {
                        // 蔬菜
                        CategorySection(
                            title: LocalizedStrings.vegetables,
                            icon: "leaf.fill",
                            iconColor: .green
                        ) {
                            IngredientGrid(
                                keys: vegetableIngredientKeys,
                                selectedKeys: selectedIngredients,
                                columns: 3,
                                baseColor: .green,
                                onToggle: toggleIngredient
                            )
                        }
                        
                        Divider()
                            .padding(.vertical, 12)
                        
                        // 肉类
                        CategorySection(
                            title: LocalizedStrings.meats,
                            icon: "flame.fill",
                            iconColor: .red
                        ) {
                            IngredientGrid(
                                keys: meatIngredientKeys,
                                selectedKeys: selectedIngredients,
                                columns: 4,
                                baseColor: .red,
                                onToggle: toggleIngredient
                            )
                        }
                        
                        Divider()
                            .padding(.vertical, 12)
                        
                        // 主食
                        CategorySection(
                            title: LocalizedStrings.stapleFoods,
                            icon: "cup.and.saucer.fill",
                            iconColor: .yellow
                        ) {
                            IngredientGrid(
                                keys: stapleFoodIngredientKeys,
                                selectedKeys: selectedIngredients,
                                columns: 4,
                                baseColor: .yellow,
                                onToggle: toggleIngredient
                            )
                        }
                    }
                    
                    // 选择厨具部分
                    SectionCard(title: LocalizedStrings.selectKitchenware) {
                        CategorySection(
                            title: "",
                            icon: "cooktop.fill",
                            iconColor: .blue,
                            showTitle: false
                        ) {
                            IngredientGrid(
                                keys: kitchenwareItemKeys,
                                selectedKeys: selectedKitchenware,
                                columns: 3,
                                baseColor: .blue,
                                onToggle: toggleKitchenware
                            )
                        }
                    }
                    
                    // 推荐食谱部分
                    SectionCard(title: LocalizedStrings.recommendedRecipes) {
                        VStack(spacing: 16) {
                            // 搜索按钮
                            SearchRecipeButton(
                                selectedIngredients: Array(selectedIngredients),
                                selectedKitchenware: Array(selectedKitchenware),
                                isLoading: youtubeService.isLoading,
                                onSearch: {
                                    Task {
                                        // 重置显示状态，清空之前的搜索结果
                                        await MainActor.run {
                                            showingVideoResults = false
                                            youtubeService.videos = []
                                        }
                                        
                                        // 开始新的搜索
                                        await youtubeService.searchVideos(
                                            ingredients: Array(selectedIngredients),
                                            kitchenware: Array(selectedKitchenware)
                                        )
                                        
                                        // 搜索完成后显示结果
                                        await MainActor.run {
                                            showingVideoResults = true
                                        }
                                    }
                                }
                            )
                            
                            // 只有在搜索后才显示YouTube视频结果
                            if showingVideoResults {
                                if !youtubeService.videos.isEmpty {
                                    VStack(spacing: 16) {
                                        // 显示搜索组合信息
                                        let vegetables = Array(selectedIngredients).filter { vegetableIngredientKeys.contains($0) }
                                        let meats = Array(selectedIngredients).filter { meatIngredientKeys.contains($0) }
                                        
                                        if !vegetables.isEmpty && !meats.isEmpty {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(NSLocalizedString("search_combination_result_title", comment: ""))
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.primary)
                                                
                                                Text(String(format: NSLocalizedString("search_combination_result", comment: ""), vegetables.count, meats.count, vegetables.count * meats.count))
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.bottom, 8)
                                        }
                                        
                                        // 显示视频结果
                                        VStack(spacing: 12) {
                                            ForEach(youtubeService.videos) { video in
                                                VideoRecipeCard(video: video)
                                            }
                                        }
                                    }
                                } else if !youtubeService.isLoading {
                                    // 搜索后没有结果的提示
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray.opacity(0.6))
                                        
                                        Text(LocalizedStrings.noVideosFound)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Text(LocalizedStrings.tryOtherIngredients)
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .padding(.top, 1) // 添加最小顶部间距，防止内容覆盖状态栏
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .id(id) // 使用id强制刷新整个视图
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefreshAllViews"))) { _ in
                // 收到刷新通知时更新ID，强制刷新视图
                self.id = UUID()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func toggleIngredient(_ ingredient: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedIngredients.contains(ingredient) {
                selectedIngredients.remove(ingredient)
            } else {
                selectedIngredients.insert(ingredient)
                // 添加触觉反馈
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            // 当食材选择发生变化时，重置搜索结果显示状态
            if showingVideoResults {
                showingVideoResults = false
                youtubeService.videos = []
            }
        }
    }
    
    private func toggleKitchenware(_ item: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedKitchenware.contains(item) {
                selectedKitchenware.remove(item)
            } else {
                selectedKitchenware.insert(item)
                // 添加触觉反馈
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            
            // 当厨具选择发生变化时，重置搜索结果显示状态
            if showingVideoResults {
                showingVideoResults = false
                youtubeService.videos = []
            }
        }
    }
}

// 美化的部分标题组件
struct CategorySection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let showTitle: Bool
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, showTitle: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.showTitle = showTitle
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showTitle {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(iconColor)
                        )
                    
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            content
        }
    }
}

// 美化的卡片容器
struct SectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

// 美化的食材网格
struct IngredientGrid: View {
    let keys: [String]
    let selectedKeys: Set<String>
    let columns: Int
    let baseColor: Color
    let onToggle: (String) -> Void
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 10) {
            ForEach(keys, id: \.self) { key in
                EnhancedIngredientButton(
                    key: key,
                    isSelected: selectedKeys.contains(key),
                    baseColor: baseColor,
                    action: {
                        onToggle(key)
                    }
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// 美化的食材按钮
struct EnhancedIngredientButton: View {
    let key: String
    let isSelected: Bool
    let baseColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Spacer()
                Text(LocalizationManager.shared.localizedString(for: key))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 32)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected 
                        ? LinearGradient(
                            gradient: Gradient(colors: [baseColor, baseColor.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                        : LinearGradient(
                            gradient: Gradient(colors: [baseColor.opacity(0.15), baseColor.opacity(0.15)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : baseColor.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? baseColor.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 美化的食谱卡片
struct EnhancedRecipeCard: View {
    let titleKey: String
    let subtitleKey: String
    let descriptionKey: String
    let imageName: String
    let iconName: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 16) {
            // 左侧内容
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: iconName)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(LocalizationManager.shared.localizedString(for: subtitleKey))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Text(LocalizationManager.shared.localizedString(for: titleKey))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(LocalizationManager.shared.localizedString(for: descriptionKey))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 右侧图片
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: gradientColors[0].opacity(0.3), radius: 5, x: 0, y: 3)
                
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}


// 搜索食谱按钮组件
struct SearchRecipeButton: View {
    let selectedIngredients: [String]
    let selectedKitchenware: [String]
    let isLoading: Bool
    let onSearch: () -> Void
    
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
    
    private var hasSelections: Bool {
        !selectedIngredients.isEmpty || !selectedKitchenware.isEmpty
    }
    
    var body: some View {
        Button(action: onSearch) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(isLoading ? LocalizedStrings.searchingVideos : LocalizedStrings.searchRecipes)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if hasSelections && !isLoading {
                        // 检查是否有蔬菜和肉类组合
                        let vegetables = selectedIngredients.filter { self.vegetableIngredientKeys.contains($0) }
                        let meats = selectedIngredients.filter { self.meatIngredientKeys.contains($0) }
                        
                        if !vegetables.isEmpty && !meats.isEmpty {
                            Text(String(format: NSLocalizedString("search_combination_hint", comment: ""), vegetables.count, meats.count, vegetables.count * meats.count))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            Text(LocalizedStrings.basedOnSelection)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else if !hasSelections && !isLoading {
                        Text(LocalizedStrings.pleaseSelectFirst)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                if !isLoading {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: hasSelections ? [Color.red, Color.red.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: (hasSelections ? Color.red : Color.gray).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!hasSelections || isLoading)
        .opacity(hasSelections || isLoading ? 1.0 : 0.7)
    }
}

#Preview {
    HomeView()
        .environmentObject(LanguageManager())
        .environmentObject(ThemeManager())
}
