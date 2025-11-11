//
//  ThemeManager.swift
//  HomeCook
//
//  Created by linjiefeng on 2025/7/3.
//

import SwiftUI

enum AppTheme: String {
    case light = "light"
    case dark = "dark"
    
    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("appTheme") var currentTheme: String = "light" {
        didSet {
            applyTheme()
        }
    }
    
    @Published var colorScheme: ColorScheme = .light
    
    init() {
        // 确保初始化时使用浅色主题
        currentTheme = "light"
        applyTheme()
    }
    
    func applyTheme() {
        let theme = AppTheme(rawValue: currentTheme) ?? .light
        colorScheme = theme.colorScheme
        
        // 打印当前主题状态，用于调试
        print("当前主题设置为: \(currentTheme), ColorScheme: \(colorScheme)")
        
        // 强制刷新所有视图
        DispatchQueue.main.async {
            // 先发送主题变化通知
            NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: nil)
            
            // 然后触发objectWillChange
            self.objectWillChange.send()
            
            // 最后发送强制刷新所有视图的通知
            NotificationCenter.default.post(name: NSNotification.Name("ForceRefreshAllViews"), object: nil)
            
            print("已发送主题变化和强制刷新通知")
        }
    }
    
    func toggleTheme() {
        currentTheme = currentTheme == "dark" ? "light" : "dark"
    }
}