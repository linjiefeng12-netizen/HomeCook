//
//  HomeCookApp.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI
import SwiftData

// 创建全局单例来管理主题和语言
class AppState: ObservableObject {
    static let shared = AppState()
    
    let themeManager = ThemeManager()
    let languageManager = LanguageManager()
    let historyManager = HistoryManager.shared
    
    private init() {
        // 初始化历史记录管理器
        _ = historyManager
        
        // 监听语言变化通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name("LanguageChanged"), object: nil, queue: .main) { [weak self] _ in
            // 强制刷新所有视图
            self?.objectWillChange.send()
        }
        
        // 监听强制刷新所有视图通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ForceRefreshAllViews"), object: nil, queue: .main) { [weak self] _ in
            // 强制刷新所有视图
            self?.objectWillChange.send()
        }
        
        // 监听主题变化通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ThemeChanged"), object: nil, queue: .main) { [weak self] _ in
            // 强制刷新所有视图
            self?.objectWillChange.send()
        }
    }
}

@main
struct HomeCookApp: App {
    // 使用全局单例来管理状态
    @ObservedObject private var appState = AppState.shared
    @State private var showWelcome = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Recipe.self,
            Ingredient.self,
            Kitchenware.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // 设置本地化文件
        setupLocalization()
    }
    
    // 设置本地化文件
    private func setupLocalization() {
        // 打印当前可用的本地化语言
        print("应用可用的本地化语言: \(Bundle.main.localizations)")
        
        // 检查Resources目录中的本地化文件
        if let resourcesPath = Bundle.main.path(forResource: "Resources", ofType: nil) {
            print("Resources目录路径: \(resourcesPath)")
            
            // 检查各语言的本地化文件
            let languages = ["zh-Hans", "en", "de", "es", "ja", "ko", "ru", "fr"]
            let fileManager = FileManager.default
            
            for language in languages {
                let langPath = "\(resourcesPath)/\(language).lproj"
                let localizablePath = "\(langPath)/Localizable.strings"
                
                if fileManager.fileExists(atPath: localizablePath) {
                    print("\(language) 本地化文件存在于 Resources 目录")
                    
                    // 尝试加载本地化文件内容，验证是否可以正确读取
                    if let dict = NSDictionary(contentsOfFile: localizablePath) as? [String: String] {
                        print("\(language) 本地化文件加载成功，包含 \(dict.count) 个键值对")
                        
                        // 打印一些关键的本地化字符串，用于调试
                        if let settingsTitle = dict["settings_title"] {
                            print("\(language) 设置标题: \(settingsTitle)")
                        }
                        if let darkMode = dict["dark_mode"] {
                            print("\(language) 深色模式: \(darkMode)")
                        }
                        if let lightMode = dict["light_mode"] {
                            print("\(language) 浅色模式: \(lightMode)")
                        }
                    } else {
                        print("\(language) 本地化文件无法加载或格式不正确")
                    }
                } else {
                    print("\(language) 本地化文件不存在于 Resources 目录")
                }
            }
        } else {
            print("Resources目录不存在")
        }
    }

    var body: some Scene {
        WindowGroup {
            if showWelcome {
                WelcomeView()
                    .environment(\.locale, appState.languageManager.locale)
                    .preferredColorScheme(appState.themeManager.colorScheme)
                    .environmentObject(appState.themeManager)
                    .environmentObject(appState.languageManager)
                    .onAppear {
                        // 2秒后隐藏欢迎页面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showWelcome = false
                            }
                        }
                    }
            } else {
                MainTabView()
                    .environment(\.locale, appState.languageManager.locale)
                    .preferredColorScheme(appState.themeManager.colorScheme)
                    .environmentObject(appState.themeManager)
                    .environmentObject(appState.languageManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}